import 'package:flutter/material.dart';
import 'package:cinema_booking_app/presentation/cinema_login_screen/models/cinema_login_model.dart';
import 'package:cinema_booking_app/core/app_export.dart';
import 'package:cinema_booking_app/providers/auth_provider.dart';

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
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
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

      AppSnackBar.showWithMessenger(
        messenger,
        message: 'Login successful! Welcome back.',
        type: AppSnackBarType.success,
      );

      navigator.pushReplacementNamed(AppRoutes.cinemaHomeScreen);
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      isSuccess = false;
      notifyListeners();

      AppSnackBar.showWithMessenger(
        messenger,
        message: errorMessage ?? 'An error occurred.',
        type: AppSnackBarType.error,
      );
    }
  }

  Future<void> onForgotPasswordTapped(BuildContext context) async {
    final email = emailController.text.trim();
    final messenger = ScaffoldMessenger.of(context);

    if (email.isEmpty || !_isValidEmail(email)) {
      AppSnackBar.showWithMessenger(
        messenger,
        message: 'Please enter a valid email to reset password.',
        type: AppSnackBarType.error,
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final sent = await authProvider.sendPasswordResetCode(email: email);

    isLoading = false;
    errorMessage = authProvider.errorMessage;
    notifyListeners();

    if (!context.mounted) return;

    if (!sent) {
      AppSnackBar.showWithMessenger(
        messenger,
        message: errorMessage ?? 'Failed to send reset code.',
        type: AppSnackBarType.error,
      );
      return;
    }

    AppSnackBar.showWithMessenger(
      messenger,
      message: 'A reset code has been sent to $email.',
      type: AppSnackBarType.success,
    );

    await _showResetPasswordDialog(context, email);
  }

  Future<void> _showResetPasswordDialog(
    BuildContext context,
    String email,
  ) async {
    final codeController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final parentMessenger = ScaffoldMessenger.of(context);
    bool isSubmitting = false;
    bool isResending = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: !isSubmitting,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              Future<void> resendCode() async {
                setDialogState(() {
                  isResending = true;
                });

                final authProvider = Provider.of<AuthProvider>(
                  dialogContext,
                  listen: false,
                );
                final dialogMountedContext = dialogContext;
                final sent = await authProvider.sendPasswordResetCode(
                  email: email,
                );

                if (!dialogMountedContext.mounted) return;

                setDialogState(() {
                  isResending = false;
                });

                AppSnackBar.showWithMessenger(
                  parentMessenger,
                  message: sent
                      ? 'A new reset code has been sent.'
                      : authProvider.errorMessage ??
                            'Failed to resend reset code.',
                  type: sent ? AppSnackBarType.success : AppSnackBarType.error,
                );
              }

              Future<void> submitReset() async {
                final code = codeController.text.trim();
                final newPassword = newPasswordController.text;
                final confirmPassword = confirmPasswordController.text;

                if (newPassword != confirmPassword) {
                  AppSnackBar.showWithMessenger(
                    parentMessenger,
                    message: 'Passwords do not match.',
                    type: AppSnackBarType.error,
                  );
                  return;
                }

                setDialogState(() {
                  isSubmitting = true;
                });

                final authProvider = Provider.of<AuthProvider>(
                  dialogContext,
                  listen: false,
                );
                final dialogNavigator = Navigator.of(dialogContext);
                final dialogMountedContext = dialogContext;
                final success = await authProvider.resetPasswordWithCode(
                  email: email,
                  code: code,
                  newPassword: newPassword,
                );

                if (!dialogMountedContext.mounted) return;

                setDialogState(() {
                  isSubmitting = false;
                });

                if (success) {
                  dialogNavigator.pop();
                  passwordController.clear();
                  AppSnackBar.showWithMessenger(
                    parentMessenger,
                    message:
                        'Password updated. Please sign in with your new password.',
                    type: AppSnackBarType.success,
                  );
                } else {
                  AppSnackBar.showWithMessenger(
                    parentMessenger,
                    message:
                        authProvider.errorMessage ??
                        'Failed to reset password.',
                    type: AppSnackBarType.error,
                  );
                }
              }

              return AlertDialog(
                backgroundColor: appTheme.gray_900_01,
                title: Text(
                  'Reset Password',
                  style: TextStyleHelper.instance.title20SemiBoldBodoniModa,
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter the code sent to $email and choose a new password.',
                        style: TextStyleHelper.instance.title16RegularDMSans,
                      ),
                      SizedBox(height: 16.h),
                      _buildDialogTextField(
                        controller: codeController,
                        label: 'Reset code',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 12.h),
                      _buildDialogTextField(
                        controller: newPasswordController,
                        label: 'New password',
                        obscureText: true,
                      ),
                      SizedBox(height: 12.h),
                      _buildDialogTextField(
                        controller: confirmPasswordController,
                        label: 'Confirm password',
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isSubmitting || isResending ? null : resendCode,
                    child: Text(isResending ? 'Sending...' : 'Resend code'),
                  ),
                  TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: isSubmitting ? null : submitReset,
                    child: Text(isSubmitting ? 'Updating...' : 'Update'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      codeController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    }
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyleHelper.instance.title16RegularDMSans.copyWith(
        color: appTheme.gray_300,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyleHelper.instance.title16RegularDMSans.copyWith(
          color: appTheme.gray_500,
        ),
        filled: true,
        fillColor: appTheme.black_900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.h),
          borderSide: BorderSide(color: appTheme.color33A48B),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.h),
          borderSide: BorderSide(color: appTheme.color33A48B),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.h),
          borderSide: BorderSide(color: appTheme.orange_100),
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
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

  void onJoinThePremiereTapped(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.cinemaRegisterScreen);
  }
}
