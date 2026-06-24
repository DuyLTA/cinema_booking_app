import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  CustomerModel? _currentCustomer;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  CustomerModel? get currentCustomer => _currentCustomer;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  Session? get currentSession => _authService.currentSession;

  /// Check if user has an active session (call at app startup)
  /// This is optimized to be fast - customer profile loads async in background
  Future<void> checkSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasValidSession = await _authService.validateSession();
      _isLoggedIn = hasValidSession;

      if (hasValidSession) {
        _currentUser = _authService.currentUser;
        _currentCustomer = await _authService.ensureCurrentCustomerProfile();
      } else {
        _currentUser = null;
        _currentCustomer = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoggedIn = false;
      _currentUser = null;
      _currentCustomer = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new user
  ///
  /// Parameters:
  /// - [email]: User email
  /// - [password]: Password (at least 6 chars)
  /// - [fullName]: Full name
  /// - [phone]: Phone number (optional)
  ///
  /// Returns: true if registration successful, false otherwise
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate inputs
      if (email.isEmpty) {
        throw Exception('Please enter your email.');
      }
      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email.');
      }
      if (password.isEmpty) {
        throw Exception('Please enter your password.');
      }
      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters.');
      }
      if (fullName.isEmpty) {
        throw Exception('Please enter your full name.');
      }

      // Supabase sends a signup confirmation code when email confirmation is
      // enabled. Keep the registration pending until the user verifies it.
      await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      try {
        await _authService.logout();
      } catch (_) {
        // Some Supabase projects do not create a session until email confirmation.
      }

      _currentUser = null;
      _currentCustomer = null;
      _isLoggedIn = false;

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoggedIn = false;
      _currentUser = null;
      _currentCustomer = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verify the signup confirmation code sent to the user's email.
  Future<bool> verifyRegistrationCode({
    required String email,
    required String code,
    required String fullName,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty) {
        throw Exception('Please enter your email.');
      }
      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email.');
      }
      if (code.trim().isEmpty) {
        throw Exception('Please enter the verification code from your email.');
      }
      if (fullName.trim().isEmpty) {
        throw Exception('Please enter your full name.');
      }

      await _authService.verifyRegistrationCode(
        email: email,
        token: code.trim(),
        fullName: fullName.trim(),
        phone: (phone ?? '').trim().isEmpty ? null : phone!.trim(),
      );

      _isLoggedIn = false;
      _currentUser = null;
      _currentCustomer = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoggedIn = false;
      _currentUser = null;
      _currentCustomer = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resend the signup confirmation code.
  Future<bool> resendRegistrationCode({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty) {
        throw Exception('Please enter your email.');
      }
      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email.');
      }

      await _authService.resendRegistrationCode(email: email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login user
  ///
  /// Parameters:
  /// - [emailOrPhone]: User email or phone number
  /// - [password]: User password
  ///
  /// Returns: true if login successful, false otherwise
  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate inputs
      if (emailOrPhone.isEmpty) {
        throw Exception('Please enter your email or phone number.');
      }
      if (password.isEmpty) {
        throw Exception('Please enter your password.');
      }

      final isEmail = _isValidEmail(emailOrPhone);
      final loginEmail = isEmail
          ? emailOrPhone
          : await _resolveEmailFromPhone(emailOrPhone);

      // Call auth service
      await _authService.login(email: loginEmail, password: password);

      _currentUser = _authService.currentUser;
      _isLoggedIn = true;
      await _loadCustomerProfile();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoggedIn = false;
      _currentUser = null;
      _currentCustomer = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start Google OAuth login and wait for the callback session.
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    StreamSubscription<AuthState>? subscription;
    final completer = Completer<bool>();

    try {
      if (_authService.currentSession == null) {
        subscription = _authService.authStateChanges.listen(
          (data) {
            if (data.event != AuthChangeEvent.signedIn ||
                data.session == null) {
              return;
            }

            if (!completer.isCompleted) {
              completer.complete(true);
            }
          },
          onError: (Object error) {
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          },
        );
      }

      await _authService.signInWithGoogle();

      if (_authService.currentSession == null) {
        await completer.future.timeout(const Duration(minutes: 2));
      }

      _currentUser = _authService.currentUser;
      _isLoggedIn = _currentUser != null && _authService.currentSession != null;

      if (!_isLoggedIn) {
        throw Exception('Google sign-in was not completed.');
      }

      _currentCustomer = await _authService.ensureCurrentCustomerProfile();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoggedIn = false;
      _currentUser = null;
      _currentCustomer = null;
      return false;
    } finally {
      await subscription?.cancel();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resolve email from phone using customer profile data
  Future<String> _resolveEmailFromPhone(String phone) async {
    return _authService.resolveEmailFromPhone(phone);
  }

  /// Logout current user
  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.logout();
      _isLoggedIn = false;
      _currentUser = null;
      _currentCustomer = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update the current user's profile row.
  Future<bool> updateProfile({required String fullName, String? phone}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (fullName.trim().isEmpty) {
        throw Exception('Please enter your full name.');
      }

      _currentCustomer = await _authService.updateCurrentUserProfile(
        fullName: fullName.trim(),
        phone: (phone ?? '').trim().isEmpty ? null : phone!.trim(),
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change password for the currently signed-in user.
  Future<bool> changePassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (newPassword.isEmpty) {
        throw Exception('Please enter your new password.');
      }
      if (newPassword.length < 6) {
        throw Exception('Password must be at least 6 characters.');
      }
      if (newPassword != confirmPassword) {
        throw Exception('Passwords do not match.');
      }

      await _authService.changePassword(newPassword: newPassword);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send a password recovery code to the user's email.
  Future<bool> sendPasswordResetCode({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty) {
        throw Exception('Please enter your email.');
      }
      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email.');
      }

      await _authService.sendPasswordResetCode(email: email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verify the email recovery code and set a new password.
  Future<bool> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (email.isEmpty) {
        throw Exception('Please enter your email.');
      }
      if (!_isValidEmail(email)) {
        throw Exception('Please enter a valid email.');
      }
      if (code.isEmpty) {
        throw Exception('Please enter the reset code from your email.');
      }
      if (newPassword.isEmpty) {
        throw Exception('Please enter your new password.');
      }
      if (newPassword.length < 6) {
        throw Exception('Password must be at least 6 characters.');
      }

      await _authService.resetPasswordWithCode(
        email: email,
        token: code,
        newPassword: newPassword,
      );

      _isLoggedIn = false;
      _currentUser = null;
      _currentCustomer = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load customer profile for current user with timeout
  /// Completes silently even if there's an error (doesn't break auth state)
  Future<void> _loadCustomerProfile() async {
    try {
      // Set a 5 second timeout for loading customer profile
      _currentCustomer = await _authService.getCurrentUserProfile().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
    } catch (e) {
      // Silently fail - customer profile is optional for basic flow
      _currentCustomer = null;
    }
  }

  /// Explicitly load customer profile (can be called when needed)
  Future<void> loadCustomerProfile() async {
    try {
      _currentCustomer = await _authService.getCurrentUserProfile();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _currentCustomer = null;
      notifyListeners();
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
