import 'package:flutter/material.dart';
import '../presentation/cinema_login_screen/cinema_login_screen.dart';
import '../presentation/cinema_register_screen/cinema_register_screen.dart';
import '../presentation/cinema_home_screen/cinema_home_screen.dart';
import '../presentation/movie_list_screen/movie_list_screen.dart';
import '../presentation/app_navigation_screen/app_navigation_screen.dart';
import '../presentation/movie_detail_screen/movie_detail_screen.dart';
import '../presentation/offer_screen/offer_screen.dart';
import '../presentation/session_selection_screen/session_selection_screen.dart';
import '../presentation/seat_selection_screen/seat_selection_screen.dart';
import '../presentation/food_beverage_screen/food_beverage_screen.dart';
import '../presentation/booking_confirmation_screen/booking_confirmation_screen.dart';
import '../presentation/payment_method_screen/payment_method_screen.dart';
import '../presentation/payment_result_screen/booking_success_screen.dart';
import '../presentation/payment_result_screen/payment_error_screen.dart';
import '../presentation/ticket_screen/ticket_detail_screen.dart';
import '../presentation/ticket_screen/ticket_screen.dart';
import '../presentation/cinema_selection_screen/cinema_selection_screen.dart';
import '../presentation/cinema_schedule_screen/cinema_schedule_screen.dart';
import '../presentation/cinema_map_screen/cinema_map_screen.dart';

class AppRoutes {
  static const String loginScreen = '/login';
  static const String cinemaLoginScreen = '/cinema_login_screen';
  static const String cinemaRegisterScreen = '/cinema_register_screen';
  static const String cinemaHomeScreen = '/cinema_home_screen';
  static const String cinemaHomeScreenInitialPage =
      '/cinema_home_screen_initial_page';
  static const String movieListScreen = '/movie_list_screen';
  static const String cinemaSelectionScreen = '/cinema_selection_screen';
  static const String cinemaScheduleScreen = '/cinema_schedule_screen';
  static const String cinemaMapScreen = '/cinema_map_screen';
  static const String movieDetailScreen = '/movie_detail_screen';
  static const String sessionSelectionScreen = '/session_selection_screen';
  static const String seatSelectionScreen = '/seat_selection_screen';
  static const String foodBeverageScreen = '/food_beverage_screen';
  static const String bookingConfirmationScreen =
      '/booking_confirmation_screen';
  static const String paymentMethodScreen = '/payment_method_screen';
  static const String bookingSuccessScreen = '/booking_success_screen';
  static const String paymentErrorScreen = '/payment_error_screen';
  static const String ticketScreen = '/ticket_screen';
  static const String ticketDetailScreen = '/ticket_detail_screen';
  static const String offerScreen = '/offer_screen';
  static const String profileScreen = '/profile_screen';
  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = cinemaLoginScreen;

  static Map<String, WidgetBuilder> get routes => {
    loginScreen: CinemaLoginScreen.builder,
    cinemaLoginScreen: CinemaLoginScreen.builder,
    cinemaRegisterScreen: CinemaRegisterScreen.builder,
    cinemaHomeScreen: CinemaHomeScreen.builder,
    cinemaSelectionScreen: CinemaSelectionScreen.builder,
    cinemaScheduleScreen: CinemaScheduleScreen.builder,
    cinemaMapScreen: CinemaMapScreen.builder,
    movieListScreen: MovieListScreen.builder,
    movieDetailScreen: MovieDetailScreen.builder,
    sessionSelectionScreen: SessionSelectionScreen.builder,
    seatSelectionScreen: SeatSelectionScreen.builder,
    foodBeverageScreen: FoodBeverageScreen.builder,
    bookingConfirmationScreen: BookingConfirmationScreen.builder,
    paymentMethodScreen: PaymentMethodScreen.builder,
    bookingSuccessScreen: BookingSuccessScreen.builder,
    paymentErrorScreen: PaymentErrorScreen.builder,
    ticketScreen: TicketScreen.builder,
    ticketDetailScreen: TicketDetailScreen.builder,
    offerScreen: OfferScreen.builder,
    appNavigationScreen: AppNavigationScreen.builder,
  };
}
