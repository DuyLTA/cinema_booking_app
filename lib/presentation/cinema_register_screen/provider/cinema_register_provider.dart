import 'package:flutter/material.dart';
import 'package:cinema_booking_app/presentation/cinema_register_screen/models/cinema_register_model.dart';
import 'package:cinema_booking_app/core/app_export.dart';
import 'package:cinema_booking_app/providers/auth_provider.dart';
import 'package:cinema_booking_app/routes/app_routes.dart';

class CinemaRegisterProvider extends ChangeNotifier {
  CinemaRegisterModel cinemaRegisterModel = CinemaRegisterModel();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FocusNode fullNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode phoneFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  FocusNode confirmPasswordFocusNode = FocusNode();

  bool isLoading = false;
  bool isSuccess = false;
  String? errorMessage;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number';
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

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> onSignUpPressed(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    try {
      final success = await authProvider.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone.isEmpty ? null : phone,
      );

      if (!success) {
        throw Exception(authProvider.errorMessage ?? 'Registration failed.');
      }

      cinemaRegisterModel
        ..fullName = fullName
        ..email = email
        ..phone = phone.isEmpty ? null : phone
        ..password = password;

      isLoading = false;
      isSuccess = true;
      notifyListeners();

      fullNameController.clear();
      emailController.clear();
      phoneController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      if (!context.mounted) return;

      AppSnackBar.showWithMessenger(
        messenger,
        message: 'Registration successful! Welcome to Cine Booking.',
        type: AppSnackBarType.success,
      );

      navigator.pushReplacementNamed(AppRoutes.cinemaHomeScreen);
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      isSuccess = false;
      notifyListeners();

      if (!context.mounted) return;

      AppSnackBar.showWithMessenger(
        messenger,
        message: errorMessage ?? 'An error occurred.',
        type: AppSnackBarType.error,
      );
    }
  }

  void onGoogleSignInPressed(BuildContext context) {
    AppSnackBar.show(
      context,
      message: 'Google Sign-In coming soon.',
      type: AppSnackBarType.info,
    );
  }

  void onAppleSignInPressed(BuildContext context) {
    AppSnackBar.show(
      context,
      message: 'Apple Sign-In coming soon.',
      type: AppSnackBarType.info,
    );
  }

  void onSignInTapped(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.cinemaLoginScreen);
  }
}
