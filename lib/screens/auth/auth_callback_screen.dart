import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../l10n/app_localizations.dart';

class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  bool _isLoading = true;
  String? _error;
  late StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    _handleAuthCallback();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  void _setupAuthListener() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        // User successfully signed in, redirect to home
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else if (event == AuthChangeEvent.signedOut) {
        // User signed out, redirect to login
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    });
  }

  Future<void> _handleAuthCallback() async {
    try {
      // Handle PKCE callback from URL
      await _handlePKCECallback();

      // Wait a moment for the OAuth callback to be processed
      await Future.delayed(const Duration(milliseconds: 1500));

      // Check if we have a current session (OAuth should have set this)
      final currentSession = Supabase.instance.client.auth.currentSession;

      if (currentSession != null) {
        print('✅ Auth callback: Session found, redirecting to home');
        // User is authenticated, redirect to home
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        print('❌ Auth callback: No session found');
        // Show error alert and redirect to login
        if (mounted) {
          await _showLoginErrorAlert();
        }
      }
    } catch (e) {
      print('❌ Auth callback error: $e');
      if (mounted) {
        await _showLoginErrorAlert(errorDetails: e.toString());
      }
    }
  }

  Future<void> _handlePKCECallback() async {
    try {
      // Use the improved OAuth callback handler from SupabaseService
      final supabaseService = SupabaseService();
      final success = await supabaseService.handleOAuthCallback();

      if (success) {
        print('✅ PKCE exchange successful');
      } else {
        print('❌ PKCE exchange failed');
        throw Exception('PKCE exchange failed');
      }
    } catch (e) {
      print('❌ Error handling PKCE callback: $e');
      rethrow;
    }
  }

  // Show login error alert
  Future<void> _showLoginErrorAlert({String? errorDetails}) async {
    final l10n = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[600], size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.getString('login_failed'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.getString('login_parameters_incorrect'),
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text(
                l10n.getString('try_again'),
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Completing authentication...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              )
            : _error != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text('Back to Login'),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
