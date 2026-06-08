import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinema_booking_app/presentation/cinema_login_screen/models/cinema_login_model.dart';
import 'package:cinema_booking_app/core/app_export.dart';
import 'package:cinema_booking_app/providers/auth_provider.dart';
import 'package:cinema_booking_app/routes/app_routes.dart';

class CinemaLoginProvider extends ChangeNotifier {
  CinemaLoginModel cinemaLoginModel = CinemaLoginModel();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email or phone is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!emailRegex.hasMatch(value) && !phoneRegex.hasMatch(value)) {
      return 'Enter a valid email or phone number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> onSignInPressed(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final emailOrPhone = emailController.text.trim();
    final password = passwordController.text;

    try {
      final success = await authProvider.login(
        emailOrPhone: emailOrPhone,
        password: password,
      );

      if (!success) {
        throw Exception(authProvider.errorMessage ?? 'Login failed.');
      }

      cinemaLoginModel.email = emailOrPhone;
      cinemaLoginModel.password = password;
      isLoading = false;
      isSuccess = true;
      notifyListeners();

      emailController.clear();
      passwordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login successful! Welcome back.'),
          backgroundColor: appTheme.gray_900,
        ),
      );

      Navigator.of(context).pushReplacementNamed(AppRoutes.cinemaHomeScreen);
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      isSuccess = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'An error occurred.'),
          backgroundColor: appTheme.gray_900,
        ),
      );
    }
  }

  void onForgotPasswordTapped(BuildContext context) {
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email to reset password.'),
          backgroundColor: appTheme.gray_900,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password recovery coming soon.'),
        backgroundColor: appTheme.gray_900,
      ),
    );
  }

  void onGoogleSignInPressed(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Google Sign-In coming soon.'),
        backgroundColor: appTheme.gray_900,
      ),
    );
  }

  void onAppleSignInPressed(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Apple Sign-In coming soon.'),
        backgroundColor: appTheme.gray_900,
      ),
    );
  }

  void onJoinThePremiereTapped(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.cinemaRegisterScreen);
  }
}
