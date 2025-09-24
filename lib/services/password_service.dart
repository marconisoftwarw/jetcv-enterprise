import 'package:flutter/foundation.dart';
import 'edge_function_service.dart';

/// Service for handling password operations via Supabase Edge Functions
class PasswordService {
  /// Reset password using a token received via email
  ///
  /// [token] - The reset token from the email link
  /// [newPassword] - The new password to set
  ///
  /// Returns a map with success status and message
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      debugPrint('🔐 PasswordService: Starting password reset with token');

      final response = await EdgeFunctionService.invokeFunction(
        'reset-password', // This might need to be updated based on the actual edge function name
        {'token': token, 'password': newPassword},
      );

      debugPrint('🔐 PasswordService: Reset password response: $response');

      return response;
    } catch (e) {
      debugPrint('❌ PasswordService: Password reset error: $e');

      // Return a structured error response
      return {
        'ok': false,
        'status': 500,
        'message': 'Errore nella reimpostazione della password: $e',
      };
    }
  }

  /// Validate password according to security policy
  /// Same rules as signup: min 8 chars, uppercase, lowercase, digit, symbol
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'La password è obbligatoria';
    }

    if (password.length < 8) {
      return 'La password deve essere di almeno 8 caratteri';
    }

    // Check for uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'La password deve contenere almeno una lettera maiuscola, una minuscola, un numero e un simbolo';
    }

    // Check for lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'La password deve contenere almeno una lettera maiuscola, una minuscola, un numero e un simbolo';
    }

    // Check for number
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'La password deve contenere almeno una lettera maiuscola, una minuscola, un numero e un simbolo';
    }

    // Check for symbol
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'La password deve contenere almeno una lettera maiuscola, una minuscola, un numero e un simbolo';
    }

    return null; // Password is valid
  }

  /// Validate that passwords match
  static String? validatePasswordConfirmation(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'La conferma password è obbligatoria';
    }

    if (password != confirmPassword) {
      return 'Le password non coincidono';
    }

    return null; // Passwords match
  }

  /// Send password reset email using edge function
  ///
  /// [email] - The user's email address
  /// [localizedMessages] - Localized error messages for different scenarios
  ///
  /// Returns a map with success status and message
  static Future<Map<String, dynamic>> sendPasswordResetEmail({
    required String email,
    Map<String, String>? localizedMessages,
  }) async {
    try {
      debugPrint('🔐 PasswordService: Sending password reset email to: $email');
      debugPrint(
        '🔐 PasswordService: Calling send-password-reset-email edge function',
      );

      // Get the current origin for the reset link
      String origin;
      if (kIsWeb) {
        final uri = Uri.base;
        origin =
            '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}';
      } else {
        // For mobile, use a default origin or get from config
        origin = 'https://jetcv.app'; // Update this with your actual domain
      }

      debugPrint('🔐 PasswordService: Using origin: $origin');

      final response = await EdgeFunctionService.invokeFunction(
        'send-password-reset-email', // Correct edge function name
        {'email': email, 'origin': origin},
      );

      debugPrint('🔐 PasswordService: Edge function response: $response');
      debugPrint('🔐 PasswordService: Response type: ${response.runtimeType}');
      debugPrint(
        '🔐 PasswordService: Response keys: ${response.keys.toList()}',
      );

      // Map the response to expected format
      final result = {
        'success': response['ok'] == true || response['success'] == true,
        'message': response['message'] ?? 'Email di reset inviata',
      };

      debugPrint('🔐 PasswordService: Mapped result: $result');
      return result;
    } catch (e) {
      debugPrint('❌ PasswordService: Send email error: $e');
      debugPrint('❌ PasswordService: Error type: ${e.runtimeType}');

      // Return a structured error response
      return {
        'success': false,
        'message':
            localizedMessages?['genericError'] ??
            'Errore durante l\'invio dell\'email. Riprova più tardi.',
      };
    }
  }

  /// Extract token from browser URL
  /// Looks for 'token' parameter in the current URL
  static String? getTokenFromUrl() {
    try {
      if (kIsWeb) {
        final uri = Uri.base;
        return uri.queryParameters['token'];
      }
      return null;
    } catch (e) {
      debugPrint('❌ PasswordService: Error extracting token from URL: $e');
      return null;
    }
  }

  // Legacy methods for backward compatibility
  // Valida il token di impostazione password
  Future<bool> validatePasswordSetupToken(String token) async {
    try {
      debugPrint('🔐 Validating password setup token: $token');

      final response = await EdgeFunctionService.invokeFunction(
        'validate-password-token',
        {'token': token},
      );

      debugPrint('🔐 Token validation response: $response');

      return response['valid'] == true;
    } catch (e) {
      debugPrint('❌ Error validating password setup token: $e');
      return false;
    }
  }

  // Imposta la password per l'utente
  Future<bool> setPassword({
    required String token,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Setting password for token: $token');

      final response = await EdgeFunctionService.invokeFunction(
        'set-password',
        {'token': token, 'password': password},
      );

      debugPrint('🔐 Set password response: $response');

      return response['success'] == true;
    } catch (e) {
      debugPrint('❌ Error setting password: $e');
      return false;
    }
  }
}
