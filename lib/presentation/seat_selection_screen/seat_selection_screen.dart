import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/booking_flow_models.dart';
import 'provider/seat_selection_provider.dart';
import 'widgets/seat_selection_widgets.dart';

class SeatSelectionScreen extends StatelessWidget {
  const SeatSelectionScreen({
    super.key,
    required this.movieTitle,
    required this.session,
  });

  final String movieTitle;
  final BookingSessionModel session;

  static Widget builder(BuildContext context) {
    return fromRouteSettings(ModalRoute.of(context)?.settings);
  }

  static Widget fromRouteSettings(RouteSettings? routeSettings) {
    final args = routeSettings?.arguments as Map<String, dynamic>? ?? {};
    final session = args['session'];

    if (session is! BookingSessionModel) {
      return const _InvalidSeatSelectionState();
    }

    return ChangeNotifierProvider(
      create: (context) => SeatSelectionProvider()..loadSeats(session.id),
      child: SeatSelectionScreen(
        movieTitle: args['movieTitle'] as String? ?? 'Movie',
        session: session,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: SafeArea(
        child: Consumer<SeatSelectionProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                const SeatSelectionHeader(),
                Expanded(child: _buildBody(provider)),
                SeatBottomSummary(
                  selectedSeats: provider.selectedSeats,
                  totalAmount: provider.totalAmount(),
                  onConfirm: () => _openFoodBeverage(context, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(SeatSelectionProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(appTheme.orange_100),
        ),
      );
    }

    if (provider.errorMessage != null) {
      return _MessageState(message: provider.errorMessage!);
    }

    if (provider.seats.isEmpty) {
      return const _MessageState(message: 'No seats available.');
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SeatMovieHeader(title: movieTitle, session: session),
          SeatGrid(
            seats: provider.seats,
            isSelected: provider.isSelected,
            onSeatTap: provider.toggleSeat,
          ),
          const SeatLegend(),
          SizedBox(height: 14.h),
        ],
      ),
    );
  }

  void _openFoodBeverage(BuildContext context, SeatSelectionProvider provider) {
    Navigator.of(context).pushNamed(
      AppRoutes.foodBeverageScreen,
      arguments: {
        'movieTitle': movieTitle,
        'session': session,
        'selectedSeats': provider.selectedSeats,
        'seatTotal': provider.totalAmount(),
      },
    );
  }
}

class _InvalidSeatSelectionState extends StatelessWidget {
  const _InvalidSeatSelectionState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: SafeArea(
        child: Column(
          children: const [
            SeatSelectionHeader(),
            Expanded(child: _MessageState(message: 'Session data is missing.')),
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
