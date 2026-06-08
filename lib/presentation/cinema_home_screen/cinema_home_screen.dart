import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../movie_detail_screen/movie_detail_screen.dart';
import '../movie_detail_screen/provider/movie_detail_provider.dart';
import '../movie_list_screen/movie_list_screen.dart';
import '../profile_screen/profile_screen.dart';
import 'cinema_home_screen_initial_page.dart';
import 'provider/cinema_home_provider.dart';

class CinemaHomeScreen extends StatefulWidget {
  CinemaHomeScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Navigator.of(context).pushReplacementNamed(
              AppRoutes.cinemaLoginScreen,
            );
          });
          return Scaffold(
            backgroundColor: appTheme.gray_900,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(appTheme.orange_100),
              ),
            ),
          );
        }

        return ChangeNotifierProvider(
          create: (context) => CinemaHomeProvider(),
          child: CinemaHomeScreen(),
        );
      },
    );
  }

  @override
  CinemaHomeScreenState createState() => CinemaHomeScreenState();
}

class CinemaHomeScreenState extends State<CinemaHomeScreen> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.screenBackground,
      body: SafeArea(
        child: Navigator(
          key: navigatorKey,
          initialRoute: AppRoutes.cinemaHomeScreenInitialPage,
          onGenerateRoute: (routeSetting) => PageRouteBuilder(
            pageBuilder: (ctx, a1, a2) =>
                getCurrentPage(context, routeSetting.name!, routeSetting),
            transitionDuration: Duration.zero,
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        width: double.maxFinite,
        child: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final bottomBarItemList = <CustomBottomBarItem>[
      CustomBottomBarItem(
        iconPath: ImageConstant.imgNavHome,
        activeIconPath: ImageConstant.imgNavHome,
        title: 'Home',
        routeName: AppRoutes.cinemaHomeScreenInitialPage,
      ),
      CustomBottomBarItem(
        iconPath: ImageConstant.imgNavMovies,
        activeIconPath: ImageConstant.imgNavMovies,
        title: 'Movies',
        routeName: AppRoutes.movieListScreen,
      ),
      CustomBottomBarItem(
        iconPath: ImageConstant.imgIconGray50016x20,
        title: 'Tickets',
        routeName: AppRoutes.cinemaHomeScreenInitialPage,
      ),
      CustomBottomBarItem(
        iconPath: ImageConstant.imgIconGray50016x16,
        title: 'Profile',
        routeName: AppRoutes.profileScreen,
      ),
    ];

    return CustomBottomBar(
      selectedIndex: selectedIndex,
      onChanged: (index) {
        setState(() {
          selectedIndex = index;
        });
        final bottomBarItem = bottomBarItemList[index];
        navigatorKey.currentState?.pushNamed(bottomBarItem.routeName);
      },
      bottomBarItems: bottomBarItemList,
    );
  }

  Widget getCurrentPage(BuildContext context, String currentRoute, RouteSettings? routeSettings) {
    switch (currentRoute) {
      case AppRoutes.cinemaHomeScreenInitialPage:
        return CinemaHomeScreenInitialPage.builder(context);
      case AppRoutes.movieListScreen:
        return MovieListScreen.builder(context);
      case AppRoutes.movieDetailScreen:
        final args = routeSettings?.arguments as Map<String, dynamic>?;
        final movieId = args?['movieId'] as String? ?? '';
        print('DEBUG: getCurrentPage - movieId from routeSettings: $movieId');
        
        return ChangeNotifierProvider(
          create: (ctx) => MovieDetailProvider()..loadMovieDetail(movieId, ctx),
          child: MovieDetailScreen(movieId: movieId),
        );
      case AppRoutes.profileScreen:
        return ProfileScreen.builder(context);
      default:
        return CinemaHomeScreenInitialPage.builder(context);
    }
  }
}
