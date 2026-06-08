import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Cache for customer profile to avoid repeated queries
  CustomerModel? _cachedCustomer;
  String? _cachedUserId;

  /// Get the current authenticated user
  User? get currentUser => _supabase.auth.currentUser;

  /// Get the current auth session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Check if user is logged in with a valid user record
  bool get isLoggedIn =>
      _supabase.auth.currentSession != null &&
      _supabase.auth.currentUser != null;

  /// Register a new user
  ///
  /// Parameters:
  /// - [email]: User email
  /// - [password]: User password (at least 6 characters)
  /// - [fullName]: User full name
  /// - [phone]: User phone number (optional)
  ///
  /// Returns: User object from Supabase Auth
  /// Throws: Exception if registration fails
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      // Sign up with Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('User not created');
      }

      // Create customer profile in database
      await _createCustomerProfile(
        userId: user.id,
        email: email,
        fullName: fullName,
        phone: phone,
      );

      return user;
    } on AuthException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  /// Create customer profile in the customers table
  Future<void> _createCustomerProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phone,
  }) async {
    try {
      await _supabase.from('customers').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'membership_level': 'regular',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to create customer profile: $e');
    }
  }

  /// Login user with email and password
  ///
  /// Parameters:
  /// - [email]: User email
  /// - [password]: User password
  ///
  /// Returns: Session object if login successful
  /// Throws: Exception if login fails
  Future<Session> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response.session!;
    } on AuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  /// Resolve the email address for a given phone number.
  /// Throws an exception if the phone number is not found.
  Future<String> resolveEmailFromPhone(String phone) async {
    try {
      final response = await _supabase
          .from('customers')
          .select('email')
          .eq('phone', phone)
          .maybeSingle();

      if (response == null || response['email'] == null) {
        throw Exception('No account found for this phone number.');
      }

      return response['email'] as String;
    } catch (e) {
      throw Exception('Failed to resolve email from phone: $e');
    }
  }

  /// Get current user's customer profile
  ///
  /// Returns: CustomerModel if user exists, null otherwise
  /// Throws: Exception if query fails
  /// Note: Results are cached per user session to avoid repeated queries
  Future<CustomerModel?> getCurrentUserProfile() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        _cachedCustomer = null;
        _cachedUserId = null;
        return null;
      }

      // Return cached profile if user hasn't changed
      if (_cachedUserId == userId && _cachedCustomer != null) {
        return _cachedCustomer;
      }

      // Query with timeout to prevent hanging
      final response = await _supabase
          .from('customers')
          .select()
          .eq('id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 5));

      if (response == null) {
        _cachedCustomer = null;
        return null;
      }

      _cachedCustomer = CustomerModel.fromJson(response);
      _cachedUserId = userId;
      return _cachedCustomer;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Clear cached customer profile (call on logout)
  void clearCache() {
    _cachedCustomer = null;
    _cachedUserId = null;
  }

  /// Logout current user
  ///
  /// Throws: Exception if logout fails
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      clearCache();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /// Validate the current session (used at app startup).
  /// Returns false and clears auth state when the session is missing or expired.
  Future<bool> validateSession() async {
    final session = _supabase.auth.currentSession;
    final user = _supabase.auth.currentUser;

    if (session == null || user == null) {
      return false;
    }

    final expiresAt = session.expiresAt;
    if (expiresAt != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
      if (DateTime.now().isAfter(expiry)) {
        try {
          final response = await _supabase.auth.refreshSession();
          return response.session != null && response.user != null;
        } catch (_) {
          await logout();
          return false;
        }
      }
    }

    return true;
  }

  /// Reset password with email
  ///
  /// Parameters:
  /// - [email]: User email
  ///
  /// Throws: Exception if password reset fails
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }
}
