import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/booking_flow_models.dart';
import '../../presentation/cinema_home_screen/models/offer_model.dart';
import '../../services/coupon_service.dart';
import 'widgets/booking_confirmation_widgets.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.movieTitle,
    required this.session,
    required this.selectedSeats,
    required this.selectedFoods,
    required this.seatTotal,
    required this.foodTotal,
  });

  final String movieTitle;
  final BookingSessionModel session;
  final List<ShowtimeSeatModel> selectedSeats;
  final List<SelectedFoodItemModel> selectedFoods;
  final double seatTotal;
  final double foodTotal;

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
      return const _InvalidConfirmationState();
    }

    return BookingConfirmationScreen(
      movieTitle: args['movieTitle'] as String? ?? 'Movie',
      session: session,
      selectedSeats: selectedSeats,
      selectedFoods: selectedFoods,
      seatTotal: args['seatTotal'] as double? ?? 0,
      foodTotal: args['foodTotal'] as double? ?? 0,
    );
  }

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final CouponService _couponService = CouponService();
  List<OfferModel> _ownedVouchers = const [];
  OfferModel? _appliedOffer;
  double _discountAmount = 0;
  String? _errorMessage;
  bool _isLoadingVouchers = true;

  double get subtotal => widget.seatTotal + widget.foodTotal;

  double get total => (subtotal - _discountAmount).clamp(0, subtotal);

  @override
  void initState() {
    super.initState();
    _loadOwnedVouchers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            const BookingConfirmationHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ConfirmationTicketCard(
                      movieTitle: widget.movieTitle,
                      session: widget.session,
                      selectedSeats: widget.selectedSeats,
                      selectedFoods: widget.selectedFoods,
                      seatTotal: widget.seatTotal,
                      foodTotal: widget.foodTotal,
                    ),
                    VoucherSelector(
                      vouchers: _ownedVouchers,
                      selectedVoucher: _appliedOffer,
                      isLoading: _isLoadingVouchers,
                      errorMessage: _errorMessage,
                      onChanged: _selectVoucher,
                    ),
                    PriceSummaryCard(
                      subtotal: subtotal,
                      discount: _discountAmount,
                      total: total,
                    ),
                  ],
                ),
              ),
            ),
            ConfirmPayButton(onPressed: () => _openPaymentMethod(context)),
          ],
        ),
      ),
    );
  }

  Future<void> _loadOwnedVouchers() async {
    try {
      final vouchers = await _couponService.getClaimedOffers();
      if (!mounted) return;
      setState(() {
        _ownedVouchers = vouchers;
        _isLoadingVouchers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingVouchers = false;
        _errorMessage = 'Unable to load your vouchers.';
      });
    }
  }

  void _selectVoucher(OfferModel? voucher) {
    if (voucher == null) {
      setState(() {
        _appliedOffer = null;
        _discountAmount = 0;
        _errorMessage = null;
      });
      return;
    }

    final discount = _couponService.calculateDiscountForOffer(
      voucher,
      subtotal,
    );

    setState(() {
      _appliedOffer = discount > 0 ? voucher : null;
      _discountAmount = discount;
      _errorMessage = discount <= 0
          ? 'Voucher does not meet the minimum order amount.'
          : null;
    });
  }

  void _openPaymentMethod(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRoutes.paymentMethodScreen,
      arguments: {
        'movieTitle': widget.movieTitle,
        'session': widget.session,
        'selectedSeats': widget.selectedSeats,
        'selectedFoods': widget.selectedFoods,
        'total': total,
        'appliedCouponCode': _appliedOffer?.promoCode,
        'discountAmount': _discountAmount,
      },
    );
  }
}

class _InvalidConfirmationState extends StatelessWidget {
  const _InvalidConfirmationState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: const SafeArea(
        child: Column(
          children: [
            BookingConfirmationHeader(),
            Expanded(child: _MessageState(message: 'Booking data is missing.')),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.h),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
            color: appTheme.gray_500,
          ),
        ),
      ),
    );
  }
}
