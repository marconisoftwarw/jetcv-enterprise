import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_models;
import '../models/legal_entity.dart';
import '../models/legal_entity_invitation.dart';
import '../config/app_config.dart';

/// SupabaseService - Optimized with Edge Functions + HTTP Fallback
///
/// This service is optimized to use Edge Functions for all operations, bypassing
/// RLS and 403/42501 errors. Primary operations use Edge Functions, with HTTP
/// fallback for get-legal-entities to ensure reliability:
/// - create-user (Edge Function)
/// - getUserById (get-user Edge Function)
/// - update-user (Edge Function)
/// - get-user-by-email (Edge Function)
/// - get-legal-entities (Edge Function + HTTP fallback)
/// - upsert-legal-entity (Edge Function)
/// - delete-legal-entity (Edge Function)
///
/// HTTP fallback ensures legal entities are always accessible even if Edge Function fails.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;
  late final GoTrueClient _auth;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );

    _client = Supabase.instance.client;
    _auth = _client.auth;

    // Listen to auth state changes
    _auth.onAuthStateChange.listen((data) {
      print('Auth state changed: ${data.event}');
    });
  }

  SupabaseClient get client => _client;
  GoTrueClient get auth => _auth;

  // Authentication methods
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: userData,
      );

      if (response.user != null && userData != null) {
        // Crea il record utente nella tabella users
        await _createUserRecord(response.user!, userData);
        print('User registration completed successfully');
      }

      return response;
    } catch (e) {
      print('Error in signUpWithEmail: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithPassword(email: email, password: password);
  }

  Future<bool> signInWithGoogle() async {
    try {
      await _auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
      );
      return true;
    } catch (e) {
      print('Error signing in with Google: $e');
      return false;
    }
  }

  // Metodo privato per uso interno
  Future<void> _createUserRecord(
    User user,
    Map<String, dynamic> userData,
  ) async {
    try {
      // Durante la registrazione, non serve verificare se l'utente esiste già
      // perché stiamo appena creando l'account
      print('Creating new user record for ID: ${user.id}');

      final recordData = {
        'idUser': user.id,
        'firstName':
            userData['firstName'] ?? user.userMetadata?['first_name'] ?? '',
        'lastName':
            userData['lastName'] ?? user.userMetadata?['last_name'] ?? '',
        'email': userData['email'] ?? user.email ?? '',
        'type': userData['type'] ?? 'user',
        'idUserHash': _generateUserHash(user.id),
        'profileCompleted': false,
        'languageCode': userData['languageCode'] ?? 'it',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Use Edge Function to bypass RLS and 403/42501 errors
      final response = await _client.functions.invoke(
        'create-user',
        body: recordData,
      );

      print(
        '🔍 _createUserRecord Edge Function response status: ${response.status}',
      );

      if (response.status != 201 && response.status != 200) {
        print(
          '❌ _createUserRecord Edge Function error: Status ${response.status}',
        );
        print('❌ Response data: ${response.data}');
        throw Exception(
          'Failed to create user record via Edge Function: ${response.status}',
        );
      }

      print('User record created successfully for ID: ${user.id}');
    } catch (e) {
      print('Error creating user record for ID ${user.id}: $e');
      rethrow;
    }
  }

  String _generateUserHash(String userId) {
    // Genera un hash univoco per l'utente
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = userId.hashCode;
    return '${timestamp}_${random}';
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.resetPasswordForEmail(email);
  }

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;

  // Metodo per verificare se l'utente è effettivamente autenticato
  bool get isUserAuthenticated {
    final user = _auth.currentUser;
    return user != null && user.id.isNotEmpty;
  }

  // Method to restore session and get current user
  Future<User?> restoreSession() async {
    try {
      final session = _auth.currentSession;
      if (session != null && !session.isExpired) {
        return _auth.currentUser;
      }
      return null;
    } catch (e) {
      print('Error restoring session: $e');
      return null;
    }
  }

  // Check if there's a valid session
  bool get hasValidSession {
    final session = _auth.currentSession;
    return session != null && !session.isExpired;
  }

  // Check if session is about to expire (within 5 minutes)
  bool get isSessionExpiringSoon {
    final session = _auth.currentSession;
    if (session == null) return false;

    final now = DateTime.now();
    final expiresAt = session.expiresAt;
    if (expiresAt == null) return false;

    // Convert Unix timestamp to DateTime
    final expiresAtDateTime = DateTime.fromMillisecondsSinceEpoch(
      expiresAt * 1000,
    );
    final timeUntilExpiry = expiresAtDateTime.difference(now);

    return timeUntilExpiry.inMinutes <= 5;
  }

  // Refresh the session if needed
  Future<bool> refreshSessionIfNeeded() async {
    try {
      final session = _auth.currentSession;
      if (session == null) return false;

      if (isSessionExpiringSoon) {
        final response = await _auth.refreshSession();
        return response.session != null;
      }

      return true;
    } catch (e) {
      print('Error refreshing session: $e');
      return false;
    }
  }

  // User management
  Future<app_models.AppUser?> getUserById(String userId) async {
    try {
      print('🔍 SupabaseService: Getting user by ID: $userId');

      // Ensure user is authenticated
      if (!isUserAuthenticated) {
        print('❌ SupabaseService: User not authenticated for getUserById');
        return null;
      }

      // Use Edge Function to bypass RLS and 406 errors
      return await getUserViaEdgeFunction(userId);
    } catch (e) {
      print('❌ SupabaseService: Error getting user $userId: $e');
      print('❌ SupabaseService: Error type: ${e.runtimeType}');

      // Gestisci il caso in cui l'utente non esiste
      if (e.toString().contains('PGRST116') ||
          e.toString().contains('0 rows') ||
          e.toString().contains('406')) {
        print('User not found in database or access denied: $userId');
        return null;
      }
      print('Error getting user $userId: $e');
      return null;
    }
  }

  // Metodo per creare utenti via Edge Function (bypass RLS)
  Future<app_models.AppUser?> createUserViaEdgeFunction(
    Map<String, dynamic> userData,
  ) async {
    try {
      print('🔄 SupabaseService: Creating user via Edge Function...');
      print('🔄 SupabaseService: User data: $userData');

      final response = await _client.functions.invoke(
        'create-user',
        body: userData,
      );

      print(
        '🔄 SupabaseService: Edge Function response status: ${response.status}',
      );
      print(
        '🔄 SupabaseService: Edge Function response data: ${response.data}',
      );

      if (response.status != 200 && response.status != 201) {
        print(
          '❌ SupabaseService: Edge Function error: Status ${response.status}',
        );
        return null;
      }

      final data = response.data;
      if (data == null || data['ok'] != true) {
        print(
          '❌ SupabaseService: Edge Function error: ${data?['message'] ?? 'Unknown error'}',
        );
        return null;
      }

      print('✅ SupabaseService: User created successfully via Edge Function');
      return app_models.AppUser.fromJson(data['user']);
    } catch (e) {
      print('❌ SupabaseService: Error creating user via Edge Function: $e');
      return null;
    }
  }

  // Metodo per recuperare utenti via Edge Function (bypass RLS)
  Future<app_models.AppUser?> getUserViaEdgeFunction(String userId) async {
    try {
      print('🔍 SupabaseService: Getting user via Edge Function: $userId');

      final response = await _client.functions.invoke(
        'get-user',
        body: {'idUser': userId},
      );

      print(
        '🔍 SupabaseService: Edge Function response status: ${response.status}',
      );

      if (response.status != 200) {
        print(
          '❌ SupabaseService: Edge Function error: Status ${response.status}',
        );
        return null;
      }

      final data = response.data;
      if (data == null || data['ok'] != true) {
        print(
          '❌ SupabaseService: Edge Function error: ${data?['message'] ?? 'Unknown error'}',
        );
        return null;
      }

      print('✅ SupabaseService: User retrieved successfully via Edge Function');
      return app_models.AppUser.fromJson(data['user']);
    } catch (e) {
      print('❌ SupabaseService: Error getting user via Edge Function: $e');
      return null;
    }
  }

  // Metodo per aggiornare utenti via Edge Function (bypass RLS)
  Future<app_models.AppUser?> updateUserViaEdgeFunction(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      print('🔄 SupabaseService: Updating user via Edge Function: $userId');

      final response = await _client.functions.invoke(
        'update-user',
        body: {'idUser': userId, ...updates},
      );

      print(
        '🔍 SupabaseService: Edge Function response status: ${response.status}',
      );

      if (response.status != 200) {
        print(
          '❌ SupabaseService: Edge Function error: Status ${response.status}',
        );
        return null;
      }

      final data = response.data;
      if (data == null || data['ok'] != true) {
        print(
          '❌ SupabaseService: Edge Function error: ${data?['message'] ?? 'Unknown error'}',
        );
        return null;
      }

      print('✅ SupabaseService: User updated successfully via Edge Function');
      return app_models.AppUser.fromJson(data['user']);
    } catch (e) {
      print('❌ SupabaseService: Error updating user via Edge Function: $e');
      return null;
    }
  }

  // Metodo per garantire che esista un record utente
  Future<app_models.AppUser?> ensureUserExists(
    String userId, {
    User? supabaseUser,
  }) async {
    try {
      // Prima prova a recuperare l'utente esistente
      var user = await getUserById(userId);
      if (user != null) {
        return user;
      }

      // Se non esiste, crealo automaticamente se abbiamo i dati di Supabase
      if (supabaseUser != null) {
        print('Creating missing user record for: $userId');
        final userData = {
          'firstName': supabaseUser.userMetadata?['first_name'] ?? '',
          'lastName': supabaseUser.userMetadata?['last_name'] ?? '',
          'email': supabaseUser.email ?? '',
          'type': 'user',
          'languageCode': 'it',
        };

        // Try Edge Function first, then fallback to direct method
        var createdUser = await createUserViaEdgeFunction(userData);
        if (createdUser == null) {
          print(
            '⚠️ SupabaseService: Edge Function failed, trying direct method',
          );
          await _createUserRecord(supabaseUser, userData);
        } else {
          print('✅ SupabaseService: User created via Edge Function');
          return createdUser;
        }

        // Riprova a recuperare l'utente appena creato
        return await getUserById(userId);
      }

      print('Cannot create user record: no Supabase user data available');
      return null;
    } catch (e) {
      print('Error ensuring user exists: $e');
      return null;
    }
  }

  Future<app_models.AppUser?> getUserByEmail(String email) async {
    try {
      print('🔍 SupabaseService: Getting user by email: $email');

      // Ensure user is authenticated
      if (!isUserAuthenticated) {
        print('❌ SupabaseService: User not authenticated for getUserByEmail');
        return null;
      }

      // Use Edge Function to bypass RLS and 406 errors
      final response = await _client.functions.invoke(
        'get-user-by-email',
        body: {'email': email},
      );

      if (response.status != 200) {
        print(
          '❌ getUserByEmail Edge Function error: Status ${response.status}',
        );
        return null;
      }

      final data = response.data;
      if (data == null || data['ok'] != true) {
        print(
          '❌ getUserByEmail Edge Function error: ${data?['message'] ?? 'Unknown error'}',
        );
        return null;
      }

      print(
        '✅ SupabaseService: User retrieved by email successfully via Edge Function',
      );
      return app_models.AppUser.fromJson(data['user']);
    } catch (e) {
      print('❌ SupabaseService: Error getting user by email $email: $e');
      print('❌ SupabaseService: Error type: ${e.runtimeType}');

      // Handle specific error cases
      if (e.toString().contains('PGRST116') ||
          e.toString().contains('0 rows') ||
          e.toString().contains('406')) {
        print('User not found in database or access denied: $email');
        return null;
      }
      return null;
    }
  }

  Future<app_models.AppUser?> createUser(Map<String, dynamic> userData) async {
    try {
      print('🔍 SupabaseService: Creating user with data: $userData');

      // Ensure user is authenticated
      if (!isUserAuthenticated) {
        print('❌ SupabaseService: User not authenticated for createUser');
        return null;
      }

      // Use Edge Function to bypass RLS and 403/42501 errors
      final response = await _client.functions.invoke(
        'create-user',
        body: userData,
      );

      print('🔍 createUser Edge Function response status: ${response.status}');

      if (response.status != 201 && response.status != 200) {
        print('❌ createUser Edge Function error: Status ${response.status}');
        print('❌ Response data: ${response.data}');
        return null;
      }

      final data = response.data;
      if (data == null || data['ok'] != true) {
        print(
          '❌ createUser Edge Function error: ${data?['message'] ?? 'Unknown error'}',
        );
        return null;
      }

      print('✅ SupabaseService: User created successfully via Edge Function');
      return app_models.AppUser.fromJson(data['user']);
    } catch (e) {
      print('❌ SupabaseService: Error creating user: $e');
      print('❌ SupabaseService: Error type: ${e.runtimeType}');

      // Handle specific error cases
      if (e.toString().contains('406')) {
        print('Access denied or invalid request format');
      }
      return null;
    }
  }

  Future<app_models.AppUser?> updateUser(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      print('🔍 SupabaseService: Updating user $userId with data: $updates');

      // Ensure user is authenticated
      if (!isUserAuthenticated) {
        print('❌ SupabaseService: User not authenticated for updateUser');
        return null;
      }

      // Use Edge Function to bypass RLS and 403/42501 errors
      final response = await _client.functions.invoke(
        'update-user',
        body: {'idUser': userId, ...updates},
      );

      print('🔍 updateUser Edge Function response status: ${response.status}');

      if (response.status != 200) {
        print('❌ updateUser Edge Function error: Status ${response.status}');
        print('❌ Response data: ${response.data}');
        return null;
      }

      final data = response.data;
      if (data == null || data['ok'] != true) {
        print(
          '❌ updateUser Edge Function error: ${data?['message'] ?? 'Unknown error'}',
        );
        return null;
      }

      print('✅ SupabaseService: User updated successfully via Edge Function');
      return app_models.AppUser.fromJson(data['user']);
    } catch (e) {
      print('❌ SupabaseService: Error updating user $userId: $e');
      print('❌ SupabaseService: Error type: ${e.runtimeType}');

      // Handle specific error cases
      if (e.toString().contains('406')) {
        print('Access denied or invalid request format');
      }
      return null;
    }
  }

  // Legal Entity management
  /// Upsert a legal entity using the upsert-legal-entity Edge Function
  /// This method handles both creation and updates automatically
  Future<LegalEntity?> upsertLegalEntity(
    Map<String, dynamic> entityData,
  ) async {
    try {
      print('🔄 SupabaseService: Starting upsertLegalEntity...');
      print('🔄 SupabaseService: Entity data: $entityData');

      final response = await _client.functions.invoke(
        'upsert-legal-entity',
        body: entityData,
      );

      print(
        '🔄 SupabaseService: Edge Function response status: ${response.status}',
      );
      print(
        '🔄 SupabaseService: Edge Function response data: ${response.data}',
      );

      if (response.status != 200 && response.status != 201) {
        print(
          '❌ SupabaseService: Error upserting legal entity: Status ${response.status}',
        );
        return null;
      }

      final data = response.data;
      if (data == null || data['ok'] != true) {
        print(
          '❌ SupabaseService: Error upserting legal entity: ${data?['message'] ?? 'Unknown error'}',
        );
        return null;
      }

      print(
        '✅ SupabaseService: Edge Function successful, processing response...',
      );

      // Return the entity with the response data
      if (data['operation'] == 'create') {
        final entity = LegalEntity.fromJson({
          'id_legal_entity': data['id_legal_entity'],
          'id_legal_entity_hash': data['id_legal_entity_hash'],
          'created_at': data['created_at'],
          'updated_at': data['updated_at'],
          ...entityData,
        });
        print('✅ SupabaseService: Created entity: ${entity.legalName}');
        return entity;
      } else {
        final entity = LegalEntity.fromJson({
          'id_legal_entity': data['id_legal_entity'],
          'updated_at': data['updated_at'],
          ...entityData,
        });
        print('✅ SupabaseService: Updated entity: ${entity.legalName}');
        return entity;
      }
    } catch (e) {
      print('Error upserting legal entity: $e');
      return null;
    }
  }

  Future<List<LegalEntity>> getLegalEntities({String? status}) async {
    try {
      print('🔍 Attempting to fetch legal entities via Edge Function...');
      print('🔍 Status filter: ${status ?? 'none'}');

      // Ensure user is authenticated
      if (!isUserAuthenticated) {
        print('❌ User not authenticated');
        return [];
      }

      // Call the get-legal-entities Edge Function
      // First try with Edge Function, fallback to HTTP if needed
      try {
        final response = await _client.functions.invoke(
          'get-legal-entities',
          method: HttpMethod.get,
          body: {'status': status},
        );

        print('🔍 Edge Function response status: ${response.status}');

        if (response.status != 200) {
          print('❌ Edge Function error: Status ${response.status}');
          print('❌ Response data: ${response.data}');
          throw Exception(
            'Edge Function failed with status ${response.status}',
          );
        }

        final data = response.data;
        if (data == null || data['ok'] != true) {
          print(
            '❌ Edge Function error: ${data?['message'] ?? 'Unknown error'}',
          );
          throw Exception(
            'Edge Function returned error: ${data?['message'] ?? 'Unknown error'}',
          );
        }

        final entitiesList = data['data'] as List;
        print('🔍 Edge Function returned ${entitiesList.length} entities');

        // Apply status filter if specified
        List<dynamic> filteredEntities = entitiesList;
        if (status != null) {
          filteredEntities = entitiesList.where((entity) {
            final entityStatus = entity['status']?.toString() ?? '';
            return entityStatus == status;
          }).toList();
          print(
            '🔍 After status filter "$status": ${filteredEntities.length} entities',
          );
        }

        // Convert to LegalEntity objects
        final entities = filteredEntities.map((entity) {
          print(
            '🔍 Processing entity: ${entity['id_legal_entity']} - ${entity['legal_name']}',
          );
          return LegalEntity.fromJson(entity);
        }).toList();

        print('🔍 Successfully processed ${entities.length} entities');
        return entities;
      } catch (e) {
        print('⚠️ Edge Function failed, trying HTTP fallback: $e');

        // Fallback to HTTP method with proper authentication
        final url = '${AppConfig.supabaseUrl}/functions/v1/get-legal-entities';

        // Get the current user's access token
        final session = _client.auth.currentSession;
        if (session == null) {
          print('❌ No active session found - attempting to restore session...');

          try {
            await _auth.refreshSession();
            final restoredSession = _client.auth.currentSession;
            if (restoredSession == null) {
              print('❌ Failed to restore session');
              return [];
            }
            print('✅ Session restored successfully');
          } catch (e) {
            print('❌ Failed to restore session: $e');
            return [];
          }
        }

        // Get the session again after potential restoration
        final currentSession = _client.auth.currentSession;
        if (currentSession == null) {
          print('❌ Still no active session after restoration attempt');
          return [];
        }

        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer ${currentSession.accessToken}',
            'Content-Type': 'application/json',
          },
        );

        print('🔍 HTTP fallback response status: ${response.statusCode}');

        if (response.statusCode != 200) {
          print('❌ HTTP fallback error: Status ${response.statusCode}');
          print('❌ Response body: ${response.body}');
          return [];
        }

        final data = jsonDecode(response.body);
        if (data == null || data['ok'] != true) {
          print(
            '❌ HTTP fallback error: ${data?['message'] ?? 'Unknown error'}',
          );
          return [];
        }

        final entitiesList = data['data'] as List;
        print('🔍 HTTP fallback returned ${entitiesList.length} entities');

        // Apply status filter if specified
        List<dynamic> filteredEntities = entitiesList;
        if (status != null) {
          filteredEntities = entitiesList.where((entity) {
            final entityStatus = entity['status']?.toString() ?? '';
            return entityStatus == status;
          }).toList();
          print(
            '🔍 After status filter "$status": ${filteredEntities.length} entities',
          );
        }

        // Convert to LegalEntity objects
        final entities = filteredEntities.map((entity) {
          print(
            '🔍 Processing entity: ${entity['id_legal_entity']} - ${entity['legal_name']}',
          );
          return LegalEntity.fromJson(entity);
        }).toList();

        print(
          '🔍 Successfully processed ${entities.length} entities via HTTP fallback',
        );
        return entities;
      }
    } catch (e) {
      print('❌ Error getting legal entities via Edge Function: $e');
      print('❌ Error type: ${e.runtimeType}');
      return [];
    }
  }

  Future<LegalEntity?> getLegalEntityById(String id) async {
    try {
      print('🔍 Attempting to fetch legal entity by ID: $id');

      // Ensure user is authenticated
      if (!isUserAuthenticated) {
        print('❌ User not authenticated');
        return null;
      }

      // Call the get-legal-entities Edge Function
      // First try with Edge Function, fallback to HTTP if needed
      try {
        final response = await _client.functions.invoke(
          'get-legal-entities',
          method: HttpMethod.get,
          body: {},
        );

        if (response.status != 200) {
          print('❌ Edge Function error: Status ${response.status}');
          print('❌ Response data: ${response.data}');
          throw Exception(
            'Edge Function failed with status ${response.status}',
          );
        }

        final data = response.data;
        if (data == null || data['ok'] != true) {
          print(
            '❌ Edge Function error: ${data?['message'] ?? 'Unknown error'}',
          );
          throw Exception(
            'Edge Function returned error: ${data?['message'] ?? 'Unknown error'}',
          );
        }

        final entitiesList = data['data'] as List;
        print('🔍 Edge Function returned ${entitiesList.length} entities');

        // Find entity by ID
        final entityData = entitiesList.firstWhere(
          (entity) => entity['id_legal_entity'] == id,
          orElse: () => null,
        );

        if (entityData == null) {
          print('❌ Legal entity with ID $id not found');
          return null;
        }

        print(
          '🔍 Successfully found legal entity: ${entityData['legal_name']}',
        );
        return LegalEntity.fromJson(entityData);
      } catch (e) {
        print('⚠️ Edge Function failed, trying HTTP fallback: $e');

        // Fallback to HTTP method with proper authentication
        final url = '${AppConfig.supabaseUrl}/functions/v1/get-legal-entities';

        // Get the current user's access token
        final session = _client.auth.currentSession;
        if (session == null) {
          print('❌ No active session found - attempting to restore session...');

          try {
            await _auth.refreshSession();
            final restoredSession = _client.auth.currentSession;
            if (restoredSession == null) {
              print('❌ Failed to restore session');
              return null;
            }
            print('✅ Session restored successfully');
          } catch (e) {
            print('❌ Failed to restore session: $e');
            return null;
          }
        }

        // Get the session again after potential restoration
        final currentSession = _client.auth.currentSession;
        if (currentSession == null) {
          print('❌ Still no active session after restoration attempt');
          return null;
        }

        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer ${currentSession.accessToken}',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode != 200) {
          print('❌ HTTP fallback error: Status ${response.statusCode}');
          print('❌ Response body: ${response.body}');
          return null;
        }

        final data = jsonDecode(response.body);
        if (data == null || data['ok'] != true) {
          print(
            '❌ HTTP fallback error: ${data?['message'] ?? 'Unknown error'}',
          );
          return null;
        }

        final entitiesList = data['data'] as List;
        print('🔍 HTTP fallback returned ${entitiesList.length} entities');

        // Find entity by ID
        final entityData = entitiesList.firstWhere(
          (entity) => entity['id_legal_entity'] == id,
          orElse: () => null,
        );

        if (entityData == null) {
          print('❌ Legal entity with ID $id not found via HTTP fallback');
          return null;
        }

        print(
          '🔍 Successfully found legal entity via HTTP fallback: ${entityData['legal_name']}',
        );
        return LegalEntity.fromJson(entityData);
      }
    } catch (e) {
      print('❌ Error getting legal entity by ID $id via Edge Function: $e');
      print('❌ Error type: ${e.runtimeType}');
      return null;
    }
  }

  Future<LegalEntity?> createLegalEntity(
    Map<String, dynamic> entityData,
  ) async {
    try {
      // Call the upsert-legal-entity Edge Function for creation
      final response = await _client.functions.invoke(
        'upsert-legal-entity',
        body: entityData,
      );

      if (response.status != 201) {
        print('Error creating legal entity: Status ${response.status}');
        return null;
      }

      final data = response.data;
      if (data == null || data['ok'] != true) {
        print(
          'Error creating legal entity: ${data?['message'] ?? 'Unknown error'}',
        );
        return null;
      }

      // Return the created entity with the generated ID and hash
      return LegalEntity.fromJson({
        'id_legal_entity': data['id_legal_entity'],
        'id_legal_entity_hash': data['id_legal_entity_hash'],
        'created_at': data['created_at'],
        'updated_at': data['updated_at'],
        ...entityData,
      });
    } catch (e) {
      print('Error creating legal entity: $e');
      return null;
    }
  }

  Future<LegalEntity?> updateLegalEntityStatus({
    required String id,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      // Prepare update data with the ID
      final updateData = {'id_legal_entity': id, 'status': status};

      if (rejectionReason != null) {
        updateData['rejection_reason'] = rejectionReason;
      }

      // Call the upsert-legal-entity Edge Function for update
      final response = await _client.functions.invoke(
        'upsert-legal-entity',
        body: updateData,
      );

      if (response.status != 200) {
        print('Error updating legal entity status: Status ${response.status}');
        return null;
      }

      final data = response.data;
      if (data == null || data['ok'] != true) {
        print(
          'Error updating legal entity status: ${data?['message'] ?? 'Unknown error'}',
        );
        return null;
      }

      // Return the updated entity
      return LegalEntity.fromJson({
        'id_legal_entity': data['id_legal_entity'],
        'updated_at': data['updated_at'],
        'status': status,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
      });
    } catch (e) {
      print('Error updating legal entity status: $e');
      return null;
    }
  }

  Future<LegalEntity?> updateLegalEntity({
    required String id,
    required Map<String, dynamic> entityData,
  }) async {
    try {
      // Prepare update data with the ID
      final updateData = Map<String, dynamic>.from(entityData);
      updateData['id_legal_entity'] = id;

      // Call the upsert-legal-entity Edge Function for update
      final response = await _client.functions.invoke(
        'upsert-legal-entity',
        body: updateData,
      );

      if (response.status != 200) {
        print('Error updating legal entity: Status ${response.status}');
        return null;
      }

      final data = response.data;
      if (data == null || data['ok'] != true) {
        print(
          'Error updating legal entity: ${data?['message'] ?? 'Unknown error'}',
        );
        return null;
      }

      // Return the updated entity
      return LegalEntity.fromJson({
        'id_legal_entity': data['id_legal_entity'],
        'updated_at': data['updated_at'],
        ...entityData,
      });
    } catch (e) {
      print('Error updating legal entity: $e');
      return null;
    }
  }

  Future<bool> deleteLegalEntity(String id) async {
    try {
      // Use Edge Function to delete legal entity (no user table calls needed)
      final response = await _client.functions.invoke(
        'delete-legal-entity',
        body: {'id_legal_entity': id},
      );

      print(
        '🔍 SupabaseService: Delete Edge Function response status: ${response.status}',
      );
      print(
        '🔍 SupabaseService: Delete Edge Function response data: ${response.data}',
      );

      if (response.status != 200) {
        print(
          '❌ SupabaseService: Error deleting legal entity: Status ${response.status}',
        );
        return false;
      }

      final data = response.data;
      if (data == null || data['ok'] != true) {
        print(
          '❌ SupabaseService: Error deleting legal entity: ${data?['message'] ?? 'Unknown error'}',
        );
        print('❌ SupabaseService: Error code: ${data?['code'] ?? 'No code'}');
        return false;
      }

      print('✅ SupabaseService: Legal entity deleted successfully');
      print('🔍 SupabaseService: Operation: ${data['operation'] ?? 'unknown'}');
      return true;
    } catch (e) {
      print('❌ SupabaseService: Error deleting legal entity: $e');
      print('❌ SupabaseService: Error type: ${e.runtimeType}');

      // Check if it's a function not found error
      if (e.toString().contains('function not found') ||
          e.toString().contains('delete-legal-entity')) {
        print('❌ SupabaseService: Edge Function delete-legal-entity not found');
        print(
          '❌ SupabaseService: Please deploy the delete-legal-entity Edge Function',
        );
        print(
          '❌ SupabaseService: Check EDGE_FUNCTIONS_SETUP.md for deployment instructions',
        );
      }
      return false;
    }
  }

  // Profile picture upload
  Future<String?> uploadProfilePicture({
    required String userId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      final file = File(filePath);
      final response = await _client.storage
          .from('profile-pictures')
          .upload(
            '$userId/$fileName',
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final url = _client.storage
          .from('profile-pictures')
          .getPublicUrl(response);

      return url;
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  Future<String?> uploadCompanyPicture({
    required String legalEntityId,
    required String filePath,
    required String fileName,
    required String pictureType, // 'logo' or 'company'
  }) async {
    try {
      final file = File(filePath);
      final response = await _client.storage
          .from('company-pictures')
          .upload(
            '$legalEntityId/$pictureType/$fileName',
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final url = _client.storage
          .from('company-pictures')
          .getPublicUrl(response);

      return url;
    } catch (e) {
      print('Error uploading company picture: $e');
      return null;
    }
  }

  // Country management
  Future<List<Map<String, dynamic>>> getCountries() async {
    try {
      final response = await _client.from('country').select().order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting countries: $e');
      return [];
    }
  }

  // Real-time subscriptions - using Edge Function instead of direct DB access
  Stream<List<LegalEntity>> subscribeToLegalEntities({String? status}) {
    // Since we can't use real-time subscriptions with Edge Functions,
    // we'll create a periodic stream that fetches data every few seconds
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      try {
        return await getLegalEntities(status: status);
      } catch (e) {
        print('❌ Error in legal entities stream: $e');
        return <LegalEntity>[];
      }
    }).asyncMap((future) => future);
  }

  // Admin functions - Removed unnecessary user table query
  // This method is no longer needed as admin check is done via AuthProvider
  // Future<bool> isUserAdmin(String userId) async {
  //   try {
  //     final user = await getUserById(userId);
  //     return user?.type == app_models.UserType.admin;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // Metodi per gestire gli inviti alle legal entity
  Future<List<LegalEntityInvitation>> getLegalEntityInvitations({
    String? legalEntityId,
    String? email,
    String? status,
  }) async {
    try {
      var query = _client.from('legal_entity_invitations').select();

      if (legalEntityId != null) {
        query = query.eq('id_legal_entity', legalEntityId);
      }

      if (email != null) {
        query = query.eq('email', email);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('sent_at', ascending: false);
      return (response as List)
          .map((json) => LegalEntityInvitation.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting legal entity invitations: $e');
      return [];
    }
  }

  Future<LegalEntityInvitation?> getLegalEntityInvitationByToken(
    String token,
  ) async {
    try {
      final response = await _client
          .from('legal_entity_invitations')
          .select()
          .eq('invitation_token', token)
          .single();

      return LegalEntityInvitation.fromJson(response);
    } catch (e) {
      print('Error getting invitation by token: $e');
      return null;
    }
  }

  Future<bool> createLegalEntityInvitation(
    LegalEntityInvitation invitation,
  ) async {
    try {
      final response = await _client
          .from('legal_entity_invitations')
          .insert(invitation.toJson());

      return response != null;
    } catch (e) {
      print('Error creating legal entity invitation: $e');
      return false;
    }
  }

  Future<bool> updateLegalEntityInvitationStatus({
    required String token,
    required String status,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (acceptedAt != null) {
        updates['accepted_at'] = acceptedAt.toIso8601String();
      }

      if (rejectedAt != null) {
        updates['rejected_at'] = rejectedAt.toIso8601String();
      }

      final response = await _client
          .from('legal_entity_invitations')
          .update(updates)
          .eq('invitation_token', token);

      return response != null;
    } catch (e) {
      print('Error updating invitation status: $e');
      return false;
    }
  }

  Future<bool> deleteLegalEntityInvitation(String token) async {
    try {
      final response = await _client
          .from('legal_entity_invitations')
          .delete()
          .eq('invitation_token', token);

      return response != null;
    } catch (e) {
      print('Error deleting invitation: $e');
      return false;
    }
  }

  // Metodo per verificare se un invito è ancora valido
  Future<bool> isInvitationValid(String token) async {
    try {
      final invitation = await getLegalEntityInvitationByToken(token);
      if (invitation == null) return false;

      return invitation.isActive;
    } catch (e) {
      print('Error checking invitation validity: $e');
      return false;
    }
  }

  // Email invitation
  Future<bool> sendLegalEntityInvitation({
    required String email,
    required String legalEntityId,
    required String inviterId,
  }) async {
    try {
      // This would typically call an edge function
      // For now, we'll just log the invitation
      print('Sending invitation to $email for legal entity $legalEntityId');

      // You can implement the actual email sending logic here
      // or call your existing edge function

      return true;
    } catch (e) {
      print('Error sending invitation: $e');
      return false;
    }
  }

  // KYC management - Only essential operations, no unnecessary user table queries
  Future<Map<String, dynamic>?> createKycAttempt({
    required String userId,
    required Map<String, dynamic> requestBody,
  }) async {
    try {
      final response = await _client
          .from('kyc_attempt')
          .insert({
            'idUser': userId,
            'requestBody': jsonEncode(requestBody),
            'createdAt': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating KYC attempt: $e');
      return null;
    }
  }
}
