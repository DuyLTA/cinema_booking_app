import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/booked_ticket_model.dart';
import '../../models/booking_flow_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import 'widgets/payment_result_widgets.dart';

class BookingSuccessScreen extends StatefulWidget {
  const BookingSuccessScreen({
    super.key,
    required this.movieTitle,
    required this.session,
    required this.selectedSeats,
    required this.selectedFoods,
    required this.total,
    required this.paymentMethod,
    required this.txnRef,
  });

  final String movieTitle;
  final BookingSessionModel session;
  final List<ShowtimeSeatModel> selectedSeats;
  final List<SelectedFoodItemModel> selectedFoods;
  final double total;
  final String paymentMethod;
  final String txnRef;

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();

  static Widget builder(BuildContext context) {
    return fromRouteSettings(ModalRoute.of(context)?.settings);
  }

  static Widget fromRouteSettings(RouteSettings? routeSettings) {
    final args = routeSettings?.arguments as Map<String, dynamic>? ?? {};
    final session = args['session'];
    final selectedSeats = args['selectedSeats'];

    if (session is! BookingSessionModel ||
        selectedSeats is! List<ShowtimeSeatModel>) {
      return const _InvalidResultState();
    }

    return BookingSuccessScreen(
      movieTitle: args['movieTitle'] as String? ?? 'Movie',
      session: session,
      selectedSeats: selectedSeats,
      selectedFoods: args['selectedFoods'] is List<SelectedFoodItemModel>
          ? args['selectedFoods'] as List<SelectedFoodItemModel>
          : const [],
      total: args['total'] as double? ?? 0,
      paymentMethod: args['paymentMethod'] as String? ?? 'VNPay QR Sandbox',
      txnRef: args['txnRef'] as String? ?? '',
    );
  }
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> {
  bool _hasSavedTicket = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _saveBookedTicket());
  }

  Future<void> _saveBookedTicket() async {
    if (_hasSavedTicket || !mounted) return;

    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null || userId.isEmpty) return;

    final ticketId = buildBookingId(
      txnRef: widget.txnRef,
      session: widget.session,
    );

    final ticket = BookedTicketModel(
      id: ticketId,
      userId: userId,
      movieTitle: widget.movieTitle,
      session: widget.session,
      selectedSeats: widget.selectedSeats,
      selectedFoods: widget.selectedFoods,
      total: widget.total,
      paymentMethod: widget.paymentMethod,
      txnRef: widget.txnRef,
      bookedAt: DateTime.now(),
    );

    try {
      await context.read<TicketProvider>().finalizeSuccessfulBooking(ticket);
      _hasSavedTicket = true;
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message:
            'Thanh toan da thanh cong nhung khong dong bo duoc trang thai ghe. '
            'Hay kiem tra policy update showtime_seats trong Supabase. ($error)',
        type: AppSnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            const ResultHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SuccessHero(),
                    SuccessTicket(
                      movieTitle: widget.movieTitle,
                      session: widget.session,
                      selectedSeats: widget.selectedSeats,
                      bookingId: buildBookingId(
                        txnRef: widget.txnRef,
                        session: widget.session,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ResultActionButtons(
              primaryLabel: 'GET SUPPORT',
              onPrimary: () {},
              onHome: () => Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.cinemaHomeScreen,
                (route) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvalidResultState extends StatelessWidget {
  const _InvalidResultState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: Center(
        child: Text(
          'Booking result is missing.',
          style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
            color: appTheme.gray_500,
          ),
        ),
      ),
    );
  }
}
