import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  bool _isLoading = true;
  String? _error;
  String? _successMessage;
  late StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    _handlePasswordReset();
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

      if (event == AuthChangeEvent.passwordRecovery && session != null) {
        // Password reset successful, redirect to login
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    });
  }

  Future<void> _handlePasswordReset() async {
    try {
      // Wait a moment for the password reset callback to be processed
      await Future.delayed(const Duration(milliseconds: 1000));

      // Check if we have a current session (password reset should have set this)
      final currentSession = Supabase.instance.client.auth.currentSession;

      if (currentSession != null) {
        // Password reset successful
        setState(() {
          _successMessage =
              'Password reset successful! You can now log in with your new password.';
          _isLoading = false;
        });

        // Redirect to login after a delay
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        // No session found, show error
        setState(() {
          _error =
              'Password reset failed. The link may have expired or been used already.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error during password reset: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Processing password reset...',
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: AppTheme.pureWhite,
                    ),
                    child: const Text('Back to Login'),
                  ),
                ],
              )
            : _successMessage != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: AppTheme.successGreen,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _successMessage!,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: AppTheme.pureWhite,
                    ),
                    child: const Text('Go to Login'),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
