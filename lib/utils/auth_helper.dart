import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AuthHelper {
  static final SupabaseService _supabaseService = SupabaseService();

  /// Check if user is authenticated and handle unauthenticated state
  static Future<bool> checkAuthentication(BuildContext context) async {
    try {
      // Check if user is authenticated
      if (!_supabaseService.isUserAuthenticated) {
        print('❌ AuthHelper: User not authenticated');
        _showAuthenticationRequiredDialog(context);
        return false;
      }

      print('✅ AuthHelper: User is authenticated');
      return true;
    } catch (e) {
      print('❌ AuthHelper: Error checking authentication: $e');
      _showAuthenticationRequiredDialog(context);
      return false;
    }
  }

  /// Show dialog when authentication is required
  static void _showAuthenticationRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authentication Required'),
          content: const Text(
            'You need to be logged in to perform this action. Please log in and try again.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushNamed(context, '/login'); // Navigate to login
              },
              child: const Text('Go to Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Check authentication and redirect to login if needed
  static Future<bool> requireAuthentication(BuildContext context) async {
    if (!_supabaseService.isUserAuthenticated) {
      // Redirect to login screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false, // Remove all previous routes
      );
      return false;
    }
    return true;
  }

  /// Safe function call with authentication check
  static Future<T?> safeFunctionCall<T>(
    BuildContext context,
    Future<T?> Function() function,
  ) async {
    try {
      // Check authentication first
      if (!await checkAuthentication(context)) {
        return null;
      }

      // Call the function
      return await function();
    } catch (e) {
      print('❌ AuthHelper: Error in safe function call: $e');
      return null;
    }
  }
}
