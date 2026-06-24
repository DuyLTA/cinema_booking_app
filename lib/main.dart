import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cinema_booking_app/core/utils/navigator_service.dart';
import 'package:cinema_booking_app/core/utils/size_utils.dart';
import 'package:cinema_booking_app/providers/auth_provider.dart';
import 'package:cinema_booking_app/providers/movie_provider.dart';
import 'package:cinema_booking_app/providers/ticket_provider.dart';
import 'package:cinema_booking_app/routes/app_routes.dart';
import 'package:cinema_booking_app/presentation/launch_screen.dart';
import 'package:cinema_booking_app/presentation/onboarding_screen/onboarding_screen.dart';
import 'package:cinema_booking_app/services/payment_return_store.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  final Set<String> _handledPaymentLinks = <String>{};
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _listenForPaymentReturnLinks();
  }

  Future<void> _listenForPaymentReturnLinks() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleIncomingLink(initialLink);
      }
    } catch (_) {
      // Deep link startup errors should not block normal app startup.
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleIncomingLink,
      onError: (_) {},
    );
  }

  void _handleIncomingLink(Uri uri) {
    if (uri.scheme != 'cinemabookingapp' || uri.host != 'payment-result') {
      return;
    }

    final linkKey = uri.toString();
    if (!_handledPaymentLinks.add(linkKey)) return;

    final status = uri.queryParameters['status'];
    final responseCode = uri.queryParameters['responseCode'];
    final isSuccess = status == null
        ? responseCode == '00'
        : status == 'success';
    final txnRef = uri.queryParameters['txnRef'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = NavigatorService.navigatorKey.currentState;
      if (navigator == null) return;
      final pendingPayment = PaymentReturnStore.pendingPayment;

      if (!isSuccess) {
        PaymentReturnStore.markResult(
          status: PaymentReturnStatus.failed,
          txnRef: txnRef,
        );
        PaymentReturnStore.clearPending();
        navigator.pushNamed(
          AppRoutes.paymentErrorScreen,
          arguments: pendingPayment?.toRouteArguments(),
        );
        return;
      }

      final payment = PaymentReturnStore.consumePending(txnRef: txnRef);
      if (payment == null) {
        PaymentReturnStore.markResult(
          status: PaymentReturnStatus.failed,
          txnRef: txnRef,
        );
        navigator.pushNamed(
          AppRoutes.paymentErrorScreen,
          arguments: pendingPayment?.toRouteArguments(),
        );
        return;
      }

      PaymentReturnStore.markResult(
        status: PaymentReturnStatus.success,
        txnRef: txnRef,
      );

      navigator.pushNamed(
        AppRoutes.bookingSuccessScreen,
        arguments: payment.toRouteArguments(),
      );
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => MovieProvider()),
            ChangeNotifierProvider(create: (_) => TicketProvider()),
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
