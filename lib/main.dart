import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cinema_booking_app/core/utils/navigator_service.dart';
import 'package:cinema_booking_app/core/utils/size_utils.dart';
import 'package:cinema_booking_app/providers/auth_provider.dart';
import 'package:cinema_booking_app/providers/movie_provider.dart';
import 'package:cinema_booking_app/routes/app_routes.dart';
import 'package:cinema_booking_app/presentation/launch_screen.dart';
import 'package:cinema_booking_app/presentation/onboarding_screen/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_KEY'];

  if (supabaseUrl == null || supabaseKey == null) {
    throw Exception('Missing SUPABASE_URL or SUPABASE_KEY in .env');
  }

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => MovieProvider()),
          ],
          child: MaterialApp(
            title: 'CineBooking',
            navigatorKey: NavigatorService.navigatorKey,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.red,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            home: const OnboardingScreen(),
            routes: AppRoutes.routes,
          ),
        );
      },
    );
  }
}

/// Splash screen that checks authentication state
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<void> _authCheckFuture;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    _authCheckFuture = authProvider.checkSession().then((_) async {
      if (!mounted) return;
      await Future.microtask(() {});
      if (!mounted) return;

      if (authProvider.isLoggedIn) {
        navigator.pushReplacementNamed(AppRoutes.cinemaHomeScreen);
      } else {
        navigator.pushReplacementNamed(AppRoutes.cinemaLoginScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _authCheckFuture,
        builder: (context, snapshot) {
          return Stack(
            children: [
              // Launch screen background
              const LaunchScreen(),
              if (snapshot.connectionState == ConnectionState.waiting)
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              else if (snapshot.hasError)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 50),
                      const SizedBox(height: 20),
                      const Text('Connection Error'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Retry by navigating back
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const SplashScreen(),
                            ),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
