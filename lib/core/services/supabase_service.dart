import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/legal_entity_model.dart';
import '../config/app_config.dart';
import '../constants/app_constants.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  
  SupabaseService._();
  
  late final SupabaseClient _client;
  
  SupabaseClient get client => _client;
  
  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }
  
  // Authentication methods
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: userData,
    );
  }
  
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  User? get currentUser => _client.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  // User management
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _client
          .from(AppConstants.usersTable)
          .select()
          .eq('idUser', userId)
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
  
  Future<UserModel?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;
    
    return await getUserById(user.id);
  }
  
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _client
        .from(AppConstants.usersTable)
        .update(data)
        .eq('idUser', userId);
  }
  
  // Legal Entity management
  Future<List<LegalEntity>> getLegalEntities() async {
    try {
      final response = await _client
          .from(AppConstants.legalEntitiesTable)
          .select()
          .order('createdAt', ascending: false);
      
      return response.map((json) => LegalEntity.fromJson(json)).toList();
    } catch (e) {
      print('Error getting legal entities: $e');
      return [];
    }
  }
  
  Future<LegalEntity?> getLegalEntityById(String id) async {
    try {
      final response = await _client
          .from(AppConstants.legalEntitiesTable)
          .select()
          .eq('idLegalEntity', id)
          .single();
      
      return LegalEntity.fromJson(response);
    } catch (e) {
      print('Error getting legal entity: $e');
      return null;
    }
  }
  
  Future<void> createLegalEntity(Map<String, dynamic> data) async {
    await _client
        .from(AppConstants.legalEntitiesTable)
        .insert(data);
  }
  
  Future<void> updateLegalEntity(String id, Map<String, dynamic> data) async {
    await _client
        .from(AppConstants.legalEntitiesTable)
        .update(data)
        .eq('idLegalEntity', id);
  }
  
  Future<void> updateLegalEntityStatus(
    String id, 
    String status, 
    String? rejectionReason,
    String adminUserId,
  ) async {
    final updateData = {
      'status': status,
      'statusUpdatedAt': DateTime.now().toIso8601String(),
      'statusUpdatedByIdUser': adminUserId,
    };
    
    if (status == 'rejected' && rejectionReason != null) {
      updateData['rejectionReason'] = rejectionReason;
    }
    
    await updateLegalEntity(id, updateData);
  }
  
  // Edge Function calls
  Future<Map<String, dynamic>> callEdgeFunction(
    String functionName, 
    Map<String, dynamic> params,
  ) async {
    try {
      final response = await _client.functions.invoke(
        functionName,
        body: params,
      );
      
      if (response.status != 200) {
        throw Exception('Edge function error: ${response.status}');
      }
      
      return response.data ?? {};
    } catch (e) {
      print('Error calling edge function $functionName: $e');
      rethrow;
    }
  }
  
  // Email invitation
  Future<void> sendLegalEntityInvitation({
    required String email,
    required String legalEntityName,
    required String invitationLink,
  }) async {
    await callEdgeFunction('send-legal-entity-invitation', {
      'email': email,
      'legalEntityName': legalEntityName,
      'invitationLink': invitationLink,
    });
  }
  
  // Admin functions
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _client
          .from(AppConstants.usersTable)
          .select()
          .order('createdAt', ascending: false);
      
      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }
  
  Future<void> updateUserType(String userId, String userType) async {
    await updateUser(userId, {
      'type': userType,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
  
  // Utility methods
  bool get isAuthenticated => currentUser != null;
  
  String? get currentUserId => currentUser?.id;
  
  Future<void> refreshSession() async {
    await _client.auth.refreshSession();
  }
}

// Provider for SupabaseService
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

// Provider for SupabaseClient
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return ref.watch(supabaseServiceProvider).client;
});
