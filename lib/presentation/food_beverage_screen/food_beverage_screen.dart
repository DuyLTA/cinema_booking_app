import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../models/booking_flow_models.dart';
import 'provider/food_beverage_provider.dart';
import 'widgets/food_beverage_widgets.dart';

class FoodBeverageScreen extends StatelessWidget {
  const FoodBeverageScreen({
    super.key,
    required this.movieTitle,
    required this.session,
    required this.selectedSeats,
    required this.seatTotal,
  });

  final String movieTitle;
  final BookingSessionModel session;
  final List<ShowtimeSeatModel> selectedSeats;
  final double seatTotal;

  static Widget builder(BuildContext context) {
    return fromRouteSettings(ModalRoute.of(context)?.settings);
  }

  static Widget fromRouteSettings(RouteSettings? routeSettings) {
    final args = routeSettings?.arguments as Map<String, dynamic>? ?? {};
    final session = args['session'];
    final selectedSeats = args['selectedSeats'];

    if (session is! BookingSessionModel ||
        selectedSeats is! List<ShowtimeSeatModel>) {
      return const _InvalidFoodState();
    }

    return ChangeNotifierProvider(
      create: (context) => FoodBeverageProvider()..loadFoods(),
      child: FoodBeverageScreen(
        movieTitle: args['movieTitle'] as String? ?? 'Movie',
        session: session,
        selectedSeats: selectedSeats,
        seatTotal: args['seatTotal'] as double? ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: SafeArea(
        child: Consumer<FoodBeverageProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                const FoodBeverageHeader(),
                Expanded(child: _buildBody(provider)),
                FoodBottomBar(
                  itemCount: provider.selectedItemCount,
                  total: provider.foodTotal,
                  onProceed: () => _openConfirmation(context, provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(FoodBeverageProvider provider) {
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

    return SingleChildScrollView(
      child: Column(
        children: [
          const FoodBeverageTitle(),
          FoodCategorySelector(
            categories: provider.categories,
            selectedCategory: provider.selectedCategory,
            onSelected: provider.selectCategory,
          ),
          if (provider.filteredFoods.isEmpty)
            const _MessageState(message: 'No food or beverage available.')
          else
            FoodGrid(
              foods: provider.filteredFoods,
              quantityOf: (food) => provider.quantities[food.id] ?? 0,
              onIncrement: provider.increment,
              onDecrement: provider.decrement,
            ),
        ],
      ),
    );
  }

  void _openConfirmation(BuildContext context, FoodBeverageProvider provider) {
    Navigator.of(context).pushNamed(
      AppRoutes.bookingConfirmationScreen,
      arguments: {
        'movieTitle': movieTitle,
        'session': session,
        'selectedSeats': selectedSeats,
        'seatTotal': seatTotal,
        'selectedFoods': provider.selectedFoods,
        'foodTotal': provider.foodTotal,
      },
    );
  }
}

class _InvalidFoodState extends StatelessWidget {
  const _InvalidFoodState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: const SafeArea(
        child: Column(
          children: [
            FoodBeverageHeader(),
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
