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
        await _loadCustomerProfile();
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

      // Call auth service
      final user = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      _currentUser = user;
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
