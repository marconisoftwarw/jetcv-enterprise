import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated =>
      _supabaseService.isUserAuthenticated && _currentUser != null;
  bool get isUserDataLoaded => _currentUser != null;

  // Method to check and refresh authentication status
  Future<bool> checkAuthenticationStatus() async {
    try {
      // First refresh the session if needed
      await _supabaseService.refreshSessionIfNeeded();

      // Check if Supabase has a valid session
      if (_supabaseService.hasValidSession) {
        final supabaseUser = _supabaseService.currentUser;
        if (supabaseUser != null) {
          if (_currentUser == null) {
            // Session exists but user data not loaded, load it
            await _loadUserData(supabaseUser.id);
          }
          return true;
        }
        return false;
      } else {
        // No valid session, clear user data
        if (_currentUser != null) {
          _currentUser = null;
          notifyListeners();
        }
        return false;
      }
    } catch (e) {
      _setError('Authentication check failed: $e');
      return false;
    }
  }

  // Method to force synchronization between session and user data
  Future<bool> forceSynchronize() async {
    try {
      print('AuthProvider: Starting force synchronization...');

      // First check if we have a valid Supabase session
      if (!_supabaseService.hasValidSession) {
        print('AuthProvider: No valid Supabase session found');
        _currentUser = null;
        notifyListeners();
        return false;
      }

      final supabaseUser = _supabaseService.currentUser;
      if (supabaseUser == null) {
        print('AuthProvider: No Supabase user found despite valid session');
        _currentUser = null;
        notifyListeners();
        return false;
      }

      print('AuthProvider: Supabase user ID: ${supabaseUser.id}');
      print('AuthProvider: Current user data: ${_currentUser?.idUser}');

      // If we have a session but no user data, load it
      if (_currentUser == null) {
        print(
          'AuthProvider: Loading user data for Supabase user: ${supabaseUser.id}',
        );
        await _loadUserData(supabaseUser.id);
        final success = _currentUser != null;
        print('AuthProvider: User data loaded: $success');
        return success;
      }

      // If we have both, verify they match
      if (_currentUser!.idUser == supabaseUser.id) {
        print('AuthProvider: User IDs match, synchronization successful');
        return true;
      } else {
        print('AuthProvider: User ID mismatch, reloading user data');
        // IDs don't match, reload user data
        await _loadUserData(supabaseUser.id);
        final success = _currentUser != null;
        print('AuthProvider: User data reloaded: $success');
        return success;
      }
    } catch (e) {
      print('AuthProvider: Synchronization failed: $e');
      _setError('Synchronization failed: $e');
      return false;
    }
  }

  // Debug method to understand current state
  void debugAuthState() {
    print('=== AuthProvider Debug Info ===');
    print('isInitialized: $_isInitialized');
    print('isAuthenticated: $isAuthenticated');
    print(
      'currentUser: ${_currentUser != null ? "Loaded (${_currentUser!.idUser})" : "Not Loaded"}',
    );
    print(
      'supabaseService.isUserAuthenticated: ${_supabaseService.isUserAuthenticated}',
    );
    print(
      'supabaseService.hasValidSession: ${_supabaseService.hasValidSession}',
    );
    print('supabaseService.currentUser: ${_supabaseService.currentUser?.id}');
    print('================================');
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _supabaseService.initialize();

      // Check if user is already signed in by restoring session
      final supabaseUser = await _supabaseService.restoreSession();
      if (supabaseUser != null) {
        await _loadUserData(supabaseUser.id);
      }

      _isInitialized = true;
    } catch (e) {
      _errorMessage = 'Failed to initialize: $e';
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    print('AuthProvider: Iniziando signUpWithEmail per: $email');
    _setLoading(true);
    _clearError();

    try {
      final userData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'type': 'user',
        'hasWallet': false,
        'hasCv': false,
        'profileCompleted': false,
        'idUserHash': _generateUserHash(email),
      };

      print('AuthProvider: User data preparati: $userData');

      final response = await _supabaseService.signUpWithEmail(
        email: email,
        password: password,
        userData: userData,
      );

      print('AuthProvider: Risposta da Supabase: ${response.user?.id}');

      if (response.user != null) {
        print('AuthProvider: Utente creato in Supabase con successo');

        // Non serve caricare dati aggiuntivi dopo la registrazione
        // L'utente è già autenticato e i dati sono disponibili
        print('AuthProvider: Registrazione completata con successo');
        return true;
      }

      print('AuthProvider: Fallimento nella creazione dell\'account utente');
      _setError('Failed to create user account');
      return false;
    } catch (e) {
      print('AuthProvider: Errore durante la registrazione: $e');
      _setError('Sign up failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserData(response.user!.id);
        return true;
      }

      _setError('Invalid email or password');
      return false;
    } catch (e) {
      _setError('Sign in failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _supabaseService.signInWithGoogle();

      if (success) {
        // For OAuth, we need to wait for the user to complete the flow
        // The user will be redirected to complete authentication
        // We'll check for the user after a delay
        await Future.delayed(const Duration(seconds: 2));

        // Check if user is now authenticated
        final supabaseUser = _supabaseService.currentUser;
        if (supabaseUser != null) {
          await _loadUserData(supabaseUser.id);
          return true;
        }
      }

      _setError('Google sign in failed');
      return false;
    } catch (e) {
      _setError('Google sign in failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUpWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _supabaseService.signInWithGoogle();

      if (success) {
        // For OAuth, we need to wait for the user to complete the flow
        // The user will be redirected to complete authentication
        // We'll check for the user after a delay
        await Future.delayed(const Duration(seconds: 2));

        // Check if user is now authenticated
        final supabaseUser = _supabaseService.currentUser;
        if (supabaseUser != null) {
          await _loadUserData(supabaseUser.id);
          return true;
        }
      }

      _setError('Google sign up failed');
      return false;
    } catch (e) {
      _setError('Google sign up failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _supabaseService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError('Sign out failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _supabaseService.resetPassword(email);
    } catch (e) {
      _setError('Password reset failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = await _supabaseService.updateUser(
        _currentUser!.idUser,
        updates,
      );

      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      _setError('Profile update failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUserData() async {
    if (_currentUser == null) return;

    try {
      await _loadUserData(_currentUser!.idUser);
    } catch (e) {
      _setError('Failed to refresh user data: $e');
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final user = await _supabaseService.getUserById(userId);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to load user data: $e');
    }
  }

  String _generateUserHash(String email) {
    // Simple hash generation - in production, use proper hashing
    return email.hashCode.toString();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
