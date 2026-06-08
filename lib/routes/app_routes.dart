import 'package:flutter/material.dart';
import '../presentation/cinema_login_screen/cinema_login_screen.dart';
import '../presentation/cinema_register_screen/cinema_register_screen.dart';
import '../presentation/cinema_home_screen/cinema_home_screen.dart';
import '../presentation/app_navigation_screen/app_navigation_screen.dart';
import '../presentation/movie_detail_screen/movie_detail_screen.dart';

class AppRoutes {
  static const String loginScreen = '/login';
  static const String cinemaLoginScreen = '/cinema_login_screen';
  static const String cinemaRegisterScreen = '/cinema_register_screen';
  static const String cinemaHomeScreen = '/cinema_home_screen';
  static const String cinemaHomeScreenInitialPage =
      '/cinema_home_screen_initial_page';
  static const String movieListScreen = '/movie_list_screen';
  static const String movieDetailScreen = '/movie_detail_screen';
  static const String profileScreen = '/profile_screen';
  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = cinemaLoginScreen;

  static Map<String, WidgetBuilder> get routes => {
    loginScreen: CinemaLoginScreen.builder,
    cinemaLoginScreen: CinemaLoginScreen.builder,
    cinemaRegisterScreen: CinemaRegisterScreen.builder,
    cinemaHomeScreen: CinemaHomeScreen.builder,
    movieDetailScreen: MovieDetailScreen.builder,
    appNavigationScreen: AppNavigationScreen.builder,
  };
}
