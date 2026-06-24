import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/customer_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String googleOAuthRedirectUrl =
      'cinemabookingapp://login-callback';

  // Cache for customer profile to avoid repeated queries
  CustomerModel? _cachedCustomer;
  String? _cachedUserId;

  /// Get the current authenticated user
  User? get currentUser => _supabase.auth.currentUser;

  /// Get the current auth session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Auth state changes emitted by Supabase.
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Check if user is logged in with a valid user record
  bool get isLoggedIn =>
      _supabase.auth.currentSession != null &&
      _supabase.auth.currentUser != null;

  /// Start registering a new user and send a signup confirmation code.
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

      return user;
    } on AuthException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  /// Verify the signup confirmation code and create the customer profile.
  Future<User> verifyRegistrationCode({
    required String email,
    required String token,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _supabase.auth
          .verifyOTP(email: email, token: token, type: OtpType.signup)
          .timeout(const Duration(seconds: 10));

      final user = response.user ?? currentUser;
      if (user == null) {
        throw Exception('Unable to verify registration.');
      }

      await _createCustomerProfile(
        userId: user.id,
        email: email,
        fullName: fullName,
        phone: phone,
      );

      await _supabase.auth.signOut();
      clearCache();

      return user;
    } on AuthException catch (e) {
      throw Exception('Registration verification failed: ${e.message}');
    } catch (e) {
      throw Exception('Registration verification error: $e');
    }
  }

  /// Resend the signup confirmation code to the user's email.
  Future<void> resendRegistrationCode({required String email}) async {
    try {
      await _supabase.auth
          .resend(email: email, type: OtpType.signup)
          .timeout(const Duration(seconds: 10));
    } on AuthException catch (e) {
      throw Exception('Failed to resend registration code: ${e.message}');
    } catch (e) {
      throw Exception('Failed to resend registration code: $e');
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
      await _supabase.from('customers').upsert({
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

  /// Start Google OAuth login. Native apps return through the configured deep link.
  Future<void> signInWithGoogle() async {
    try {
      final redirectUrl = kIsWeb ? Uri.base.origin : googleOAuthRedirectUrl;
      final opened = await _supabase.auth
          .signInWithOAuth(OAuthProvider.google, redirectTo: redirectUrl)
          .timeout(const Duration(seconds: 10));
      if (!opened) {
        throw Exception('Unable to open Google sign-in.');
      }
    } on AuthException catch (e) {
      throw Exception('Google sign-in failed: ${e.message}');
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  /// Ensure a customer profile exists for the currently authenticated user.
  Future<CustomerModel?> ensureCurrentCustomerProfile() async {
    final user = currentUser;
    if (user == null) {
      return null;
    }

    try {
      final existing = await _supabase
          .from('customers')
          .select()
          .eq('id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      if (existing != null) {
        _cachedCustomer = CustomerModel.fromJson(existing);
        _cachedUserId = user.id;
        return _cachedCustomer;
      }

      final metadata = user.userMetadata ?? const <String, dynamic>{};
      final fullName =
          (metadata['full_name'] ??
                  metadata['name'] ??
                  metadata['display_name'] ??
                  user.email ??
                  'Google User')
              .toString()
              .trim();
      final email = user.email;
      if (email == null || email.trim().isEmpty) {
        throw Exception('Google account did not provide an email address.');
      }

      await _createCustomerProfile(
        userId: user.id,
        email: email,
        fullName: fullName.isEmpty ? 'Google User' : fullName,
      );

      return getCurrentUserProfile();
    } catch (e) {
      throw Exception('Failed to ensure customer profile: $e');
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

  /// Update current user's customer profile.
  Future<CustomerModel> updateCurrentUserProfile({
    required String fullName,
    String? phone,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        throw Exception('No authenticated user found.');
      }

      final response = await _supabase
          .from('customers')
          .update({
            'full_name': fullName,
            'phone': phone,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single()
          .timeout(const Duration(seconds: 10));

      _cachedCustomer = CustomerModel.fromJson(response);
      _cachedUserId = userId;
      return _cachedCustomer!;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Change password for the currently signed-in user.
  Future<void> changePassword({required String newPassword}) async {
    try {
      await _supabase.auth
          .updateUser(UserAttributes(password: newPassword))
          .timeout(const Duration(seconds: 10));
    } on AuthException catch (e) {
      throw Exception('Failed to change password: ${e.message}');
    } catch (e) {
      throw Exception('Failed to change password: $e');
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
    await sendPasswordResetCode(email: email);
  }

  /// Send a password recovery code to the user's email.
  Future<void> sendPasswordResetCode({required String email}) async {
    try {
      await _supabase.auth
          .resetPasswordForEmail(email)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception('Failed to send password reset code: $e');
    }
  }

  /// Verify the recovery code and update the password.
  ///
  /// Supabase creates a short-lived recovery session after OTP verification.
  /// The password update must be performed while that recovery session is active.
  Future<void> resetPasswordWithCode({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      await _supabase.auth
          .verifyOTP(email: email, token: token, type: OtpType.recovery)
          .timeout(const Duration(seconds: 10));

      await _supabase.auth
          .updateUser(UserAttributes(password: newPassword))
          .timeout(const Duration(seconds: 10));

      await _supabase.auth.signOut();
      clearCache();
    } on AuthException catch (e) {
      throw Exception('Password reset failed: ${e.message}');
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }
}
