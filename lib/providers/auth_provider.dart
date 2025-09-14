import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';
import '../services/user_type_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  AppUserType? _userType;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated =>
      _supabaseService.isUserAuthenticated && _currentUser != null;
  bool get isUserDataLoaded => _currentUser != null;
  AppUserType? get userType => _userType;

  // Getter per controllare se l'utente corrente è admin
  bool get isCurrentUserAdmin => _currentUser?.isAdminFromDatabase ?? false;

  // Method to check and refresh authentication status
  Future<bool> checkAuthenticationStatus() async {
    try {
      // First refresh the session if needed
      await _supabaseService.refreshSessionIfNeeded();

      // Check if Supabase has a valid session
      if (_supabaseService.hasValidSession) {
        final supabaseUser = _supabaseService.currentUser;
        if (supabaseUser != null) {
          // Crea l'utente direttamente dai dati di Supabase se non esiste
          if (_currentUser == null) {
            _currentUser = AppUser(
              idUser: supabaseUser.id,
              email: supabaseUser.email ?? '',
              firstName:
                  supabaseUser.userMetadata?['full_name']?.split(' ').first ??
                  '',
              lastName:
                  supabaseUser.userMetadata?['full_name']
                      ?.split(' ')
                      .skip(1)
                      .join(' ') ??
                  '',
              type: UserType.user, // Default type
              languageCode: 'it',
              phone: supabaseUser.phone ?? '',
              idUserHash: supabaseUser.id, // Usa l'ID come hash
              createdAt: supabaseUser.createdAt != null
                  ? DateTime.parse(supabaseUser.createdAt!)
                  : null,
              updatedAt: supabaseUser.updatedAt != null
                  ? DateTime.parse(supabaseUser.updatedAt!)
                  : null,
            );
            _safeNotifyListeners();
          }
          // Imposta tipo utente di default se non è stato caricato
          if (_userType == null) {
            _userType = AppUserType.user;
            _safeNotifyListeners();
          }
          return true;
        }
        return false;
      } else {
        // No valid session, clear user data
        if (_currentUser != null) {
          _currentUser = null;
          _safeNotifyListeners();
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
        _safeNotifyListeners();
        return false;
      }

      final supabaseUser = _supabaseService.currentUser;
      if (supabaseUser == null) {
        print('AuthProvider: No Supabase user found despite valid session');
        _currentUser = null;
        _safeNotifyListeners();
        return false;
      }

      print('AuthProvider: Supabase user ID: ${supabaseUser.id}');
      print('AuthProvider: Current user data: ${_currentUser?.idUser}');
      return true;
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

      // No need to load user data on initialization
      // User data will be loaded only when explicitly needed
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
        // Crea l'utente direttamente dai dati di Supabase
        _currentUser = AppUser(
          idUser: response.user!.id,
          email: response.user!.email ?? '',
          firstName:
              response.user!.userMetadata?['full_name']?.split(' ').first ?? '',
          lastName:
              response.user!.userMetadata?['full_name']
                  ?.split(' ')
                  .skip(1)
                  .join(' ') ??
              '',
          type: UserType.user, // Default type
          languageCode: 'it',
          phone: response.user!.phone ?? '',
          idUserHash: response.user!.id, // Usa l'ID come hash
          createdAt: response.user!.createdAt != null
              ? DateTime.parse(response.user!.createdAt!)
              : null,
          updatedAt: response.user!.updatedAt != null
              ? DateTime.parse(response.user!.updatedAt!)
              : null,
        );

        print('✅ AuthProvider: User created from Supabase response');
        print('  ID: ${_currentUser!.idUser}');
        print('  Email: ${_currentUser!.email}');
        print('  Name: ${_currentUser!.firstName} ${_currentUser!.lastName}');
        print('  Phone: ${_currentUser!.phone}');
        print('  Email Verified: ${response.user!.emailConfirmedAt != null}');

        // Carica il tipo di utente dall'edge function
        if (_currentUser!.email != null && _currentUser!.email!.isNotEmpty) {
          print('🔄 Loading user type for: ${_currentUser!.email}');
          await _loadUserType(_currentUser!.email!);
        } else {
          print('⚠️ No user email available for type loading');
          _userType = AppUserType.user;
        }

        _safeNotifyListeners();
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
          // No need to load user data automatically after OAuth
          // User data will be loaded when explicitly needed
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
          // No need to load user data automatically after OAuth
          // User data will be loaded when explicitly needed
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
    try {
      await _supabaseService.signOut();
      _currentUser = null;
      _userType = null;
      _clearError();
      _safeNotifyListeners();
    } catch (e) {
      _setError('Sign out failed: $e');
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
        _safeNotifyListeners();
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
      final supabaseUser = _supabaseService.currentUser;
      if (supabaseUser != null) {
        // Aggiorna l'utente con i dati più recenti da Supabase
        _currentUser = AppUser(
          idUser: supabaseUser.id,
          email: supabaseUser.email ?? '',
          firstName:
              supabaseUser.userMetadata?['full_name']?.split(' ').first ?? '',
          lastName:
              supabaseUser.userMetadata?['full_name']
                  ?.split(' ')
                  .skip(1)
                  .join(' ') ??
              '',
          type: UserType.user, // Default type
          languageCode: 'it',
          phone: supabaseUser.phone ?? '',
          idUserHash: supabaseUser.id, // Usa l'ID come hash
          createdAt: supabaseUser.createdAt != null
              ? DateTime.parse(supabaseUser.createdAt!)
              : null,
          updatedAt: supabaseUser.updatedAt != null
              ? DateTime.parse(supabaseUser.updatedAt!)
              : null,
        );
        _safeNotifyListeners();
      }
    } catch (e) {
      _setError('Failed to refresh user data: $e');
    }
  }

  Future<String?> getCurrentUserId() async {
    // Se abbiamo già l'utente caricato, restituisci l'ID
    if (_currentUser != null) {
      return _currentUser!.idUser;
    }

    // Altrimenti, prova a ottenere l'ID direttamente da Supabase
    try {
      final supabaseUser = _supabaseService.currentUser;
      if (supabaseUser != null) {
        // Restituisci direttamente l'ID di Supabase senza caricare i dati completi
        return supabaseUser.id;
      }
    } catch (e) {
      print('AuthProvider: Error getting current user ID: $e');
    }

    return null;
  }

  String _generateUserHash(String email) {
    // Simple hash generation - in production, use proper hashing
    return email.hashCode.toString();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _safeNotifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _safeNotifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _safeNotifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Metodo pubblico per caricare i dati dell'utente
  Future<void> loadUserData() async {
    if (_isLoading) return;

    try {
      _setLoading(true);

      // Verifica se c'è una sessione valida
      if (!_supabaseService.hasValidSession) {
        _setError('No valid session found');
        return;
      }

      final supabaseUser = _supabaseService.currentUser;
      if (supabaseUser == null) {
        _setError('No authenticated user found');
        return;
      }

      // Crea l'utente direttamente dai dati di Supabase
      _currentUser = AppUser(
        idUser: supabaseUser.id,
        email: supabaseUser.email ?? '',
        firstName:
            supabaseUser.userMetadata?['full_name']?.split(' ').first ?? '',
        lastName:
            supabaseUser.userMetadata?['full_name']
                ?.split(' ')
                .skip(1)
                .join(' ') ??
            '',
        type: UserType.user, // Default type
        languageCode: 'it',
        phone: supabaseUser.phone ?? '',
        idUserHash: supabaseUser.id, // Usa l'ID come hash
        createdAt: supabaseUser.createdAt != null
            ? DateTime.parse(supabaseUser.createdAt!)
            : null,
        updatedAt: supabaseUser.updatedAt != null
            ? DateTime.parse(supabaseUser.updatedAt!)
            : null,
      );
    } catch (e) {
      _setError('Failed to load user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Metodo pubblico per caricare il tipo di utente dall'edge function
  Future<void> loadUserType() async {
    if (_currentUser?.email == null) {
      print('No user email available for type loading');
      return;
    }

    try {
      final userTypeString = await UserTypeService.getUserType(
        _currentUser!.email!,
      );
      if (userTypeString != null) {
        _userType = userTypeString.toUserType;
        print('✅ User type loaded: $_userType');
        _safeNotifyListeners();
      } else {
        print('⚠️ No user type received, using default');
        _userType = AppUserType.user;
        _safeNotifyListeners();
      }
    } catch (e) {
      print('❌ Error loading user type: $e');
      print('🔄 Using default user type');
      _userType = AppUserType.user;
      _safeNotifyListeners();
    }
  }

  // Metodo per testare manualmente il tipo utente
  Future<void> testUserType() async {
    print('🧪 Testing user type loading...');
    print('Current user: $_currentUser');
    print('Current user type: $_userType');
    if (_currentUser?.email != null) {
      await loadUserType();
    } else {
      print('❌ No user email available for testing');
    }
  }

  // Metodo privato per caricare il tipo di utente dall'edge function
  Future<void> _loadUserType(String email) async {
    try {
      final userTypeString = await UserTypeService.getUserType(email);
      if (userTypeString != null) {
        _userType = userTypeString.toUserType;
        print('✅ User type loaded: $_userType');
        _safeNotifyListeners();
      } else {
        print('⚠️ No user type received, using default');
        _userType = AppUserType.user;
        _safeNotifyListeners();
      }
    } catch (e) {
      print('❌ Error loading user type: $e');
      print('🔄 Using default user type');
      _userType = AppUserType.user;
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    // Evita di chiamare notifyListeners durante la fase di build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
