import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';

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
      // Wait a moment for the OAuth callback to be processed
      await Future.delayed(const Duration(milliseconds: 1000));

      // Check if we have a current session (OAuth should have set this)
      final currentSession = Supabase.instance.client.auth.currentSession;

      if (currentSession != null) {
        // User is authenticated, redirect to home
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        // Still no session, show error
        setState(() {
          _error = 'Authentication failed. Please try logging in again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error during authentication: $e';
        _isLoading = false;
      });
    }
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
