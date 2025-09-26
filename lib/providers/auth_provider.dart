import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';
import '../services/update_user_type_service.dart';
import '../services/user_type_service.dart';
import '../services/edge_function_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  AppUserType? _userType;
  bool _shouldRedirectToKyc = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get shouldRedirectToKyc => _shouldRedirectToKyc;
  bool get isAuthenticated =>
      _supabaseService.isUserAuthenticated && _currentUser != null;
  bool get isUserDataLoaded => _currentUser != null;
  AppUserType? get userType => _userType;

  // Getter per controllare se l'utente corrente è admin
  bool get isCurrentUserAdmin => _currentUser?.isAdminFromDatabase ?? false;

  // Method to check and refresh authentication status
  Future<bool> checkAuthenticationStatus() async {
    try {
      print('🔍 AuthProvider: Checking authentication status...');

      // First refresh the session if needed
      await _supabaseService.refreshSessionIfNeeded();

      // Check if Supabase has a valid session
      if (_supabaseService.hasValidSession) {
        final supabaseUser = _supabaseService.currentUser;
        if (supabaseUser != null) {
          print(
            '✅ AuthProvider: Valid session found for user: ${supabaseUser.id}',
          );

          // Check if we need to restore or update user data
          if (_currentUser == null || _currentUser!.idUser != supabaseUser.id) {
            print('🔄 AuthProvider: Restoring/updating user data...');

            // Try to load complete user data from database first
            try {
              print(
                '🔄 AuthProvider: Loading complete user data from database...',
              );
              _currentUser = await _supabaseService.getUserById(
                supabaseUser.id,
              );

              if (_currentUser != null) {
                print('✅ AuthProvider: User data loaded from database');
                print(
                  '✅ AuthProvider: User type from database: ${_currentUser!.type}',
                );

                // Convert UserType to AppUserType for menu navigation
                _userType = _convertUserTypeToAppUserType(_currentUser!.type);
                print('✅ AuthProvider: Converted to AppUserType: $_userType');
              } else {
                print(
                  '⚠️ AuthProvider: User not found in database, creating from Supabase data',
                );
                _createUserFromSupabaseData(supabaseUser);

                // Try to get user type from edge function as fallback
                try {
                  final userTypeString =
                      await UserTypeService.getUserTypeWithFallback(
                        supabaseUser.email ?? '',
                      );
                  if (userTypeString != null) {
                    _userType = userTypeString.toUserType;
                    print(
                      '✅ AuthProvider: User type loaded from edge function: $_userType',
                    );
                  }
                } catch (e) {
                  print(
                    '⚠️ AuthProvider: Could not load user type from edge function: $e',
                  );
                }
              }
            } catch (e) {
              print('❌ AuthProvider: Error loading user from database: $e');
              print('🔄 AuthProvider: Falling back to Supabase data');
              _createUserFromSupabaseData(supabaseUser);
            }

            _safeNotifyListeners();
          }

          // Ensure user type is set
          if (_userType == null) {
            _userType = AppUserType.user;
            _safeNotifyListeners();
          }

          return true;
        }
        print('❌ AuthProvider: Valid session but no user found');
        return false;
      } else {
        print('❌ AuthProvider: No valid session found');
        // No valid session, clear user data
        if (_currentUser != null) {
          _currentUser = null;
          _userType = null;
          _safeNotifyListeners();
        }
        return false;
      }
    } catch (e) {
      print('❌ AuthProvider: Authentication check failed: $e');
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
      print('🔐 AuthProvider: Initializing...');
      await _supabaseService.initialize();

      // After Supabase initialization, check if there's a persisted session
      print('🔍 AuthProvider: Checking for persisted session...');
      await _restoreSessionFromPersistence();

      _isInitialized = true;
      print('✅ AuthProvider: Initialization completed');
    } catch (e) {
      print('❌ AuthProvider: Initialization failed: $e');
      _errorMessage = 'Failed to initialize: $e';
    }
  }

  /// Restore session and user data from Supabase persistence
  Future<void> _restoreSessionFromPersistence() async {
    try {
      // First refresh the session to ensure it's valid
      await _supabaseService.refreshSessionIfNeeded();

      // Check if Supabase has a valid persisted session
      if (_supabaseService.hasValidSession) {
        final supabaseUser = _supabaseService.currentUser;
        if (supabaseUser != null) {
          print(
            '🔄 AuthProvider: Restoring user from persisted session: ${supabaseUser.id}',
          );

          // Try to load complete user data from database first
          try {
            print(
              '🔄 AuthProvider: Loading complete user data from database during session restore...',
            );
            _currentUser = await _supabaseService.getUserById(supabaseUser.id);

            if (_currentUser != null) {
              print(
                '✅ AuthProvider: User data loaded from database during session restore',
              );
              print(
                '✅ AuthProvider: User type from database: ${_currentUser!.type}',
              );

              // Convert UserType to AppUserType for menu navigation
              _userType = _convertUserTypeToAppUserType(_currentUser!.type);
              print('✅ AuthProvider: Converted to AppUserType: $_userType');
            } else {
              print(
                '⚠️ AuthProvider: User not found in database during session restore, creating from Supabase data',
              );
              _createUserFromSupabaseData(supabaseUser);

              // Try to get user type from edge function as fallback
              try {
                final userTypeString =
                    await UserTypeService.getUserTypeWithFallback(
                      supabaseUser.email ?? '',
                    );
                if (userTypeString != null) {
                  _userType = userTypeString.toUserType;
                  print(
                    '✅ AuthProvider: User type loaded from edge function: $_userType',
                  );
                }
              } catch (e) {
                print(
                  '⚠️ AuthProvider: Could not load user type from edge function: $e',
                );
              }
            }
          } catch (e) {
            print(
              '❌ AuthProvider: Error loading user from database during session restore: $e',
            );
            print('🔄 AuthProvider: Falling back to Supabase data');
            _createUserFromSupabaseData(supabaseUser);
          }

          print('✅ AuthProvider: User session restored successfully');
          _safeNotifyListeners();
        }
      } else {
        print('ℹ️ AuthProvider: No valid persisted session found');
      }
    } catch (e) {
      print('❌ AuthProvider: Error restoring session: $e');
      // Don't set error here as this is initialization
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

        // Aggiorna il tipo utente a 'certifier' dopo la registrazione
        print('AuthProvider: Aggiornando tipo utente a certifier...');
        await _updateUserTypeToCertifier(response.user!.id);

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
        print(
          '✅ AuthProvider: Login successful for user: ${response.user!.id}',
        );

        // Try to load complete user data from database first
        try {
          print('🔄 AuthProvider: Loading complete user data from database...');
          _currentUser = await _supabaseService.getUserById(response.user!.id);

          if (_currentUser != null) {
            print('✅ AuthProvider: User data loaded from database');
            print(
              '✅ AuthProvider: User type from database: ${_currentUser!.type}',
            );

            // Convert UserType to AppUserType for menu navigation
            _userType = _convertUserTypeToAppUserType(_currentUser!.type);
            print('✅ AuthProvider: Converted to AppUserType: $_userType');
          } else {
            print(
              '⚠️ AuthProvider: User not found in database, creating from Supabase data',
            );
            _createUserFromSupabaseData(response.user!);

            // Try to get user type from edge function as fallback
            try {
              final userTypeString =
                  await UserTypeService.getUserTypeWithFallback(
                    response.user!.email ?? '',
                  );
              if (userTypeString != null) {
                _userType = userTypeString.toUserType;
                print(
                  '✅ AuthProvider: User type loaded from edge function: $_userType',
                );
              }
            } catch (e) {
              print(
                '⚠️ AuthProvider: Could not load user type from edge function: $e',
              );
            }
          }
        } catch (e) {
          print('❌ AuthProvider: Error loading user from database: $e');
          print('🔄 AuthProvider: Falling back to Supabase data');
          _createUserFromSupabaseData(response.user!);
        }

        print('✅ AuthProvider: User created/loaded');
        print('  ID: ${_currentUser!.idUser}');
        print('  Email: ${_currentUser!.email}');
        print('  Name: ${_currentUser!.firstName} ${_currentUser!.lastName}');
        print('  Phone: ${_currentUser!.phone}');
        print('  Type: ${_currentUser!.type}');
        print('  AppUserType: $_userType');
        print('  Email Verified: ${response.user!.emailConfirmedAt != null}');

        // Controlla se l'utente è certifier e deve completare il KYC
        if (_userType == AppUserType.certifier) {
          await _checkAndRedirectToKycIfNeeded();
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

  // Handle OAuth callback (useful for manual callback handling)
  Future<bool> handleOAuthCallback() async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _supabaseService.handleOAuthCallback();

      if (success) {
        // Refresh user data after successful OAuth
        await checkAuthenticationStatus();
        print('✅ AuthProvider: OAuth callback handled successfully');
        return true;
      } else {
        _setError('OAuth authentication failed');
        return false;
      }
    } catch (e) {
      print('❌ AuthProvider: OAuth callback error: $e');
      _setError('OAuth callback failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      print('🔄 AuthProvider: Starting signOut process...');
      await _supabaseService.signOut();
      _currentUser = null;
      _userType = null;
      _clearError();
      print('🔄 AuthProvider: User data cleared, notifying listeners...');

      // Use safe notification to avoid issues during build
      _safeNotifyListeners();

      print('✅ AuthProvider: SignOut completed successfully');
    } catch (e) {
      print('❌ AuthProvider: SignOut error: $e');
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
          firstName: _extractFirstName(supabaseUser.userMetadata?['full_name']),
          lastName: _extractLastName(supabaseUser.userMetadata?['full_name']),
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

      // Try to load complete user data from database first
      try {
        print('🔄 AuthProvider: Loading complete user data from database...');
        _currentUser = await _supabaseService.getUserById(supabaseUser.id);

        if (_currentUser != null) {
          print('✅ AuthProvider: User data loaded from database');
          print(
            '✅ AuthProvider: User type from database: ${_currentUser!.type}',
          );

          // Convert UserType to AppUserType for menu navigation
          _userType = _convertUserTypeToAppUserType(_currentUser!.type);
          print('✅ AuthProvider: Converted to AppUserType: $_userType');
        } else {
          print(
            '⚠️ AuthProvider: User not found in database, creating from Supabase data',
          );
          _createUserFromSupabaseData(supabaseUser);

          // Try to get user type from edge function as fallback
          try {
            final userTypeString =
                await UserTypeService.getUserTypeWithFallback(
                  supabaseUser.email ?? '',
                );
            if (userTypeString != null) {
              _userType = userTypeString.toUserType;
              print(
                '✅ AuthProvider: User type loaded from edge function: $_userType',
              );
            }
          } catch (e) {
            print(
              '⚠️ AuthProvider: Could not load user type from edge function: $e',
            );
          }
        }
      } catch (e) {
        print('❌ AuthProvider: Error loading user from database: $e');
        print('🔄 AuthProvider: Falling back to Supabase data');
        _createUserFromSupabaseData(supabaseUser);
      }
    } catch (e) {
      _setError('Failed to load user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Metodo per testare manualmente il tipo utente
  Future<void> testUserType() async {
    print('🧪 Testing user type loading...');
    print('Current user: $_currentUser');
    print('Current user type: $_userType');
    print('✅ User type is already loaded from database');
  }

  // Metodo per forzare il caricamento del tipo utente se non disponibile
  Future<void> ensureUserTypeLoaded() async {
    if (_userType != null) {
      print('✅ AuthProvider: User type already loaded: $_userType');
      return;
    }

    if (_currentUser == null) {
      print('⚠️ AuthProvider: No current user, cannot load user type');
      return;
    }

    try {
      print('🔄 AuthProvider: User type not loaded, loading from database...');
      final userData = await _supabaseService.getUserById(_currentUser!.idUser);

      if (userData != null) {
        _currentUser = userData;
        _userType = _convertUserTypeToAppUserType(userData.type);
        print('✅ AuthProvider: User type loaded from database: $_userType');
        _safeNotifyListeners();
      } else {
        print(
          '⚠️ AuthProvider: User not found in database, trying edge function...',
        );
        // Fallback: try to get user type from edge function with database fallback
        final userTypeString = await UserTypeService.getUserTypeWithFallback(
          _currentUser!.email ?? '',
        );
        if (userTypeString != null) {
          _userType = userTypeString.toUserType;
          print(
            '✅ AuthProvider: User type loaded from edge function: $_userType',
          );
          _safeNotifyListeners();
        } else {
          print('⚠️ AuthProvider: User type not found, using default type');
          _userType = AppUserType.user;
          _safeNotifyListeners();
        }
      }
    } catch (e) {
      print('❌ AuthProvider: Error loading user type: $e');
      _userType = AppUserType.user;
      _safeNotifyListeners();
    }
  }

  Future<bool> resetPasswordWithOldPassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _supabaseService.resetPasswordWithOldPassword(
        email: email,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (success) {
        print('✅ Password reset successful');
        return true;
      } else {
        _setError('Password reset failed');
        return false;
      }
    } catch (e) {
      print('❌ Password reset error: $e');
      _setError('Password reset failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Metodo helper per creare utente dai dati di Supabase (fallback)
  void _createUserFromSupabaseData(User supabaseUser) {
    _currentUser = AppUser(
      idUser: supabaseUser.id,
      email: supabaseUser.email ?? '',
      firstName: _extractFirstName(supabaseUser.userMetadata?['full_name']),
      lastName: _extractLastName(supabaseUser.userMetadata?['full_name']),
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

    // Set default user type if not already set
    if (_userType == null) {
      _userType = AppUserType.user;
    }
  }

  // Metodo helper per creare utente dai dati di Supabase con caricamento del tipo utente
  Future<void> _createUserFromSupabaseDataWithType(User supabaseUser) async {
    _createUserFromSupabaseData(supabaseUser);

    // Try to get user type from edge function
    try {
      final userTypeString = await UserTypeService.getUserType(
        supabaseUser.email ?? '',
      );
      if (userTypeString != null) {
        _userType = userTypeString.toUserType;
        print(
          '✅ AuthProvider: User type loaded from edge function: $_userType',
        );
      }
    } catch (e) {
      print('⚠️ AuthProvider: Could not load user type from edge function: $e');
    }
  }

  // Metodo helper per convertire UserType in AppUserType
  AppUserType _convertUserTypeToAppUserType(UserType? userType) {
    if (userType == null) return AppUserType.user;

    switch (userType) {
      case UserType.admin:
        return AppUserType.admin;
      case UserType.legalRepresentative:
        return AppUserType.legalEntity;
      case UserType.certifier:
        return AppUserType.certifier;
      default:
        return AppUserType.user;
    }
  }

  void _safeNotifyListeners() {
    // Evita di chiamare notifyListeners durante la fase di build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Safe name extraction methods to prevent RangeError
  String _extractFirstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '';

    try {
      final parts = fullName.trim().split(' ');
      return parts.isNotEmpty ? parts[0] : '';
    } catch (e) {
      print('Error extracting first name from "$fullName": $e');
      return '';
    }
  }

  String _extractLastName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '';

    try {
      final parts = fullName.trim().split(' ');
      if (parts.length <= 1) return '';

      return parts.skip(1).join(' ');
    } catch (e) {
      print('Error extracting last name from "$fullName": $e');
      return '';
    }
  }

  /// Aggiorna il tipo utente a 'certifier' dopo la registrazione
  Future<void> _updateUserTypeToCertifier(String userId) async {
    try {
      print(
        'AuthProvider: Chiamando edge function per collegare utente a certifier...',
      );

      // Ottieni i dati dell'utente corrente
      final currentUser = _currentUser;
      if (currentUser == null) {
        print('❌ AuthProvider: Nessun utente corrente disponibile');
        return;
      }

      // Chiama la nuova Edge Function post-signup-link-certifier
      final response = await EdgeFunctionService.postSignupLinkCertifier(
        email: currentUser.email ?? '',
        firstName: currentUser.firstName,
        lastName: currentUser.lastName,
        idUser: userId,
      );

      if (response != null && response['ok'] == true) {
        print('✅ AuthProvider: Utente collegato a certifier con successo');
        print('✅ AuthProvider: Dati certifier: ${response['data']}');

        // Aggiorna i dati dell'utente locale
        if (response['data'] != null) {
          final data = response['data'] as Map<String, dynamic>;
          final userData = data['user'] as Map<String, dynamic>?;
          final certifierData = data['certifier'] as Map<String, dynamic>?;

          if (userData != null) {
            _currentUser = AppUser.fromJson(userData);
            _userType = AppUserType.certifier;
            print('✅ AuthProvider: Tipo utente aggiornato a certifier');
          }
        }

        // Reindirizza al KYC Veriff
        print('🔄 AuthProvider: Reindirizzando al KYC Veriff...');
        await _redirectToKycVeriff();
      } else {
        print('⚠️ AuthProvider: Fallimento nel collegamento a certifier');
        final message = response?['message'] ?? 'Errore sconosciuto';
        print('⚠️ AuthProvider: Errore: $message');
      }
    } catch (e) {
      print('❌ AuthProvider: Errore durante il collegamento a certifier: $e');
      // Non bloccare il processo di registrazione se l'aggiornamento del tipo fallisce
    }
  }

  Future<void> _redirectToKycVeriff() async {
    try {
      print('🔄 AuthProvider: Avviando processo KYC Veriff...');

      // Imposta il flag per il redirect al KYC
      _shouldRedirectToKyc = true;

      // Notifica i listener che il KYC deve essere avviato
      _safeNotifyListeners();

      print('✅ AuthProvider: KYC Veriff notificato ai listener');
    } catch (e) {
      print('❌ AuthProvider: Errore durante l\'avvio del KYC Veriff: $e');
    }
  }

  void clearKycRedirect() {
    _shouldRedirectToKyc = false;
    _safeNotifyListeners();
  }

  Future<void> _checkAndRedirectToKycIfNeeded() async {
    try {
      print('🔍 AuthProvider: Checking KYC status for certifier user...');

      // Controlla se l'utente ha completato il KYC
      // Per ora assumiamo che se non c'è un campo specifico, il KYC non è completato
      // In futuro potresti aggiungere un campo nel database per tracciare lo stato KYC

      // Per ora, reindirizza sempre al KYC per i certifier
      // TODO: Implementare controllo reale dello stato KYC dal database
      print(
        '🔄 AuthProvider: Certifier user needs KYC verification, redirecting...',
      );

      // Imposta il flag per il redirect al KYC
      _shouldRedirectToKyc = true;
      _safeNotifyListeners();

      print('✅ AuthProvider: KYC redirect flag set for certifier user');
    } catch (e) {
      print('❌ AuthProvider: Error checking KYC status: $e');
    }
  }
}
