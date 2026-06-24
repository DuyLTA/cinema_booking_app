import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/booking_flow_models.dart';
import 'widgets/payment_result_widgets.dart';

class PaymentErrorScreen extends StatelessWidget {
  const PaymentErrorScreen({
    super.key,
    this.movieTitle,
    this.session,
    this.selectedSeats,
    this.selectedFoods,
    this.total,
  });

  final String? movieTitle;
  final BookingSessionModel? session;
  final List<ShowtimeSeatModel>? selectedSeats;
  final List<SelectedFoodItemModel>? selectedFoods;
  final double? total;

  static Widget builder(BuildContext context) {
    return fromRouteSettings(ModalRoute.of(context)?.settings);
  }

  static Widget fromRouteSettings(RouteSettings? routeSettings) {
    final args = routeSettings?.arguments as Map<String, dynamic>? ?? {};

    return PaymentErrorScreen(
      movieTitle: args['movieTitle'] as String?,
      session: args['session'] as BookingSessionModel?,
      selectedSeats: args['selectedSeats'] as List<ShowtimeSeatModel>?,
      selectedFoods: args['selectedFoods'] as List<SelectedFoodItemModel>?,
      total: args['total'] as double?,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            const ResultHeader(),
            const Expanded(child: PaymentErrorContent()),
            ResultActionButtons(
              primaryLabel: 'GET SUPPORT',
              showTryAgain: true,
              onTryAgain: () => _retryPayment(context),
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

  void _retryPayment(BuildContext context) {
    if (session == null ||
        selectedSeats == null ||
        selectedFoods == null ||
        total == null) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushReplacementNamed(
      AppRoutes.paymentMethodScreen,
      arguments: {
        'movieTitle': movieTitle ?? 'Movie',
        'session': session,
        'selectedSeats': selectedSeats,
        'selectedFoods': selectedFoods,
        'total': total,
        'autoStartVnPay': true,
      },
    );
  }
}
