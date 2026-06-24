import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../models/booking_flow_models.dart';
import '../../services/payment_return_store.dart';
import 'provider/payment_method_provider.dart';
import 'widgets/payment_method_widgets.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({
    super.key,
    required this.movieTitle,
    required this.session,
    required this.selectedSeats,
    required this.selectedFoods,
    required this.total,
    this.appliedCouponCode,
    this.discountAmount = 0,
  });

  final String movieTitle;
  final BookingSessionModel session;
  final List<ShowtimeSeatModel> selectedSeats;
  final List<SelectedFoodItemModel> selectedFoods;
  final double total;
  final String? appliedCouponCode;
  final double discountAmount;

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();

  static Widget builder(BuildContext context) {
    return fromRouteSettings(ModalRoute.of(context)?.settings);
  }

  static Widget fromRouteSettings(RouteSettings? routeSettings) {
    final args = routeSettings?.arguments as Map<String, dynamic>? ?? {};
    final session = args['session'];
    final selectedSeats = args['selectedSeats'];
    final selectedFoods = args['selectedFoods'];

    if (session is! BookingSessionModel ||
        selectedSeats is! List<ShowtimeSeatModel> ||
        selectedFoods is! List<SelectedFoodItemModel>) {
      return const _InvalidPaymentState();
    }

    return ChangeNotifierProvider(
      create: (context) => PaymentMethodProvider(),
      child: PaymentMethodScreen(
        movieTitle: args['movieTitle'] as String? ?? 'Movie',
        session: session,
        selectedSeats: selectedSeats,
        selectedFoods: selectedFoods,
        total: args['total'] as double? ?? 0,
        appliedCouponCode: args['appliedCouponCode'] as String?,
        discountAmount: args['discountAmount'] as double? ?? 0,
      ),
    );
  }
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  bool _hasTriggeredAutoStart = false;

  bool get _shouldAutoStart {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return args?['autoStartVnPay'] as bool? ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: SafeArea(
        child: Consumer<PaymentMethodProvider>(
          builder: (context, provider, child) {
            final paymentResult = PaymentReturnStore.consumeResult(
              txnRef: provider.activeVnPayTxnRef,
            );
            if (paymentResult != null && provider.hasOpenedVnPay) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  provider.resetVnPaySession();
                }
              });
            }

            if (_shouldAutoStart &&
                !_hasTriggeredAutoStart &&
                !provider.isProcessing) {
              _hasTriggeredAutoStart = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  _openVnPaySandbox(context, provider);
                }
              });
            }

            return Column(
              children: [
                const PaymentHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        PaymentAmountSummary(
                          total: widget.total,
                          discountAmount: widget.discountAmount,
                          appliedCouponCode: widget.appliedCouponCode,
                          seatCount: widget.selectedSeats.length,
                          foodCount: widget.selectedFoods.fold(
                            0,
                            (sum, item) => sum + item.quantity,
                          ),
                        ),
                        PaymentMethodList(
                          methods: provider.methods,
                          selectedType: provider.selectedType,
                          onSelected: provider.select,
                        ),
                      ],
                    ),
                  ),
                ),
                PayNowBar(
                  total: widget.total,
                  isProcessing: provider.isProcessing,
                  onPay: () => _completePayment(context, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _completePayment(
    BuildContext context,
    PaymentMethodProvider provider,
  ) async {
    await _openVnPaySandbox(context, provider);
  }

  Future<void> _openVnPaySandbox(
    BuildContext context,
    PaymentMethodProvider provider,
  ) async {
    try {
      final bookingId = 'CB${DateTime.now().millisecondsSinceEpoch}';
      final paymentSession = await provider.createVnPayPaymentUrl(
        bookingId: bookingId,
        amount: widget.total,
        orderInfo: 'Thanh toan ve phim $bookingId',
      );

      PaymentReturnStore.savePending(
        PaymentReturnData(
          movieTitle: widget.movieTitle,
          session: widget.session,
          selectedSeats: widget.selectedSeats,
          selectedFoods: widget.selectedFoods,
          total: widget.total,
          paymentMethod: provider.selectedMethod.name,
          txnRef: paymentSession.txnRef,
        ),
      );

      final uri = Uri.parse(paymentSession.paymentUrl);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Cannot open VNPay payment URL.');
      }

      provider.markVnPayOpened(txnRef: paymentSession.txnRef);
      if (!context.mounted) return;
      AppSnackBar.show(
        context,
        message: 'VNPay will return to the app automatically after payment.',
        type: AppSnackBarType.info,
      );
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBar.show(
        context,
        message:
            'Cannot open VNPay Sandbox. Start backend/vnpay-server and check config.',
        type: AppSnackBarType.error,
      );
    }
  }
}

class _InvalidPaymentState extends StatelessWidget {
  const _InvalidPaymentState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            const PaymentHeader(),
            Expanded(
              child: Center(
                child: Text(
                  'Payment data is missing.',
                  style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
                    color: appTheme.gray_500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
