import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_models;
import '../models/legal_entity.dart';
import '../models/legal_entity_invitation.dart';
import '../config/app_config.dart';

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
      // Prima verifica se l'utente esiste già
      final existingUser = await getUserById(user.id);
      if (existingUser != null) {
        print('User record already exists for ID: ${user.id}');
        return;
      }

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

      await _client.from('user').insert(recordData);
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
      final response = await _client
          .from('user')
          .select('*')
          .eq('idUser', userId)
          .single();

      return app_models.AppUser.fromJson(response);
    } catch (e) {
      // Gestisci il caso in cui l'utente non esiste
      if (e.toString().contains('PGRST116') ||
          e.toString().contains('0 rows')) {
        print('User not found in database: $userId');
        return null;
      }
      print('Error getting user $userId: $e');
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

        await _createUserRecord(supabaseUser, userData);

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
      final response = await _client
          .from('user')
          .select()
          .eq('email', email)
          .single();

      return app_models.AppUser.fromJson(response);
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  Future<app_models.AppUser?> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _client
          .from('user')
          .insert(userData)
          .select()
          .single();

      return app_models.AppUser.fromJson(response);
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  Future<app_models.AppUser?> updateUser(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _client
          .from('user')
          .update(updates)
          .eq('idUser', userId)
          .select()
          .single();

      return app_models.AppUser.fromJson(response);
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  // Legal Entity management
  Future<List<LegalEntity>> getLegalEntities({String? status}) async {
    try {
      var query = _client.from('legal_entities').select();

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((entity) => LegalEntity.fromJson(entity))
          .toList();
    } catch (e) {
      print('Error getting legal entities: $e');
      return [];
    }
  }

  Future<LegalEntity?> getLegalEntityById(String id) async {
    try {
      final response = await _client
          .from('legal_entities')
          .select()
          .eq('id_legal_entity', id)
          .single();

      return LegalEntity.fromJson(response);
    } catch (e) {
      print('Error getting legal entity: $e');
      return null;
    }
  }

  Future<LegalEntity?> createLegalEntity(
    Map<String, dynamic> entityData,
  ) async {
    try {
      final response = await _client
          .from('legal_entities')
          .insert(entityData)
          .select()
          .single();

      return LegalEntity.fromJson(response);
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
      final updates = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (rejectionReason != null) {
        updates['rejection_reason'] = rejectionReason;
      }

      final response = await _client
          .from('legal_entities')
          .update(updates)
          .eq('id_legal_entity', id)
          .select()
          .single();

      return LegalEntity.fromJson(response);
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
      final updates = Map<String, dynamic>.from(entityData);
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('legal_entities')
          .update(updates)
          .eq('id_legal_entity', id)
          .select()
          .single();

      return LegalEntity.fromJson(response);
    } catch (e) {
      print('Error updating legal entity: $e');
      return null;
    }
  }

  Future<bool> deleteLegalEntity(String id) async {
    try {
      final response = await _client
          .from('legal_entities')
          .delete()
          .eq('id_legal_entity', id);

      return response != null;
    } catch (e) {
      print('Error deleting legal entity: $e');
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

  // Real-time subscriptions
  Stream<List<LegalEntity>> subscribeToLegalEntities({String? status}) {
    final query = _client
        .from('legal_entity')
        .stream(primaryKey: ['idLegalEntity']);

    return query.map(
      (event) => event.map((entity) => LegalEntity.fromJson(entity)).toList(),
    );
  }

  // Admin functions
  Future<bool> isUserAdmin(String userId) async {
    try {
      final user = await getUserById(userId);
      return user?.type == app_models.UserType.admin;
    } catch (e) {
      return false;
    }
  }

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

  // KYC management
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

  Future<bool> updateKycStatus({
    required String userId,
    required bool completed,
    required bool passed,
  }) async {
    try {
      await _client
          .from('user')
          .update({
            'kycCompleted': completed,
            'kycPassed': passed,
            'updatedAt': DateTime.now().toIso8601String(),
          })
          .eq('idUser', userId);

      return true;
    } catch (e) {
      print('Error updating KYC status: $e');
      return false;
    }
  }
}
