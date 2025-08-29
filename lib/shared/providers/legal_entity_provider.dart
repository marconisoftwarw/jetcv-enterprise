import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../models/legal_entity_model.dart';

class LegalEntityNotifier extends StateNotifier<AsyncValue<List<LegalEntity>>> {
  final SupabaseService _supabaseService;
  
  LegalEntityNotifier(this._supabaseService) : super(const AsyncValue.loading()) {
    if (_supabaseService.isInitialized) {
      loadLegalEntities();
    } else {
      state = AsyncValue.error(
        'Supabase non è configurato. Configura le credenziali per utilizzare l\'app.',
        StackTrace.current,
      );
    }
  }
  
  Future<void> loadLegalEntities() async {
    if (!_supabaseService.isInitialized) {
      state = AsyncValue.error(
        'Supabase non è configurato. Configura le credenziali per utilizzare l\'app.',
        StackTrace.current,
      );
      return;
    }
    
    try {
      state = const AsyncValue.loading();
      final entities = await _supabaseService.getLegalEntities();
      state = AsyncValue.data(entities);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> createLegalEntity(Map<String, dynamic> data) async {
    if (!_supabaseService.isInitialized) {
      throw Exception('Supabase non è configurato. Configura le credenziali per utilizzare l\'app.');
    }
    
    try {
      await _supabaseService.createLegalEntity(data);
      await loadLegalEntities(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> updateLegalEntity(String id, Map<String, dynamic> data) async {
    if (!_supabaseService.isInitialized) {
      throw Exception('Supabase non è configurato. Configura le credenziali per utilizzare l\'app.');
    }
    
    try {
      await _supabaseService.updateLegalEntity(id, data);
      await loadLegalEntities(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> updateLegalEntityStatus(
    String id, 
    String status, 
    String? rejectionReason,
    String adminUserId,
  ) async {
    if (!_supabaseService.isInitialized) {
      throw Exception('Supabase non è configurato. Configura le credenziali per utilizzare l\'app.');
    }
    
    try {
      await _supabaseService.updateLegalEntityStatus(
        id, 
        status, 
        rejectionReason, 
        adminUserId,
      );
      await loadLegalEntities(); // Refresh the list
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> approveLegalEntity(String id, String adminUserId) async {
    await updateLegalEntityStatus(id, 'approved', null, adminUserId);
  }
  
  Future<void> rejectLegalEntity(String id, String rejectionReason, String adminUserId) async {
    await updateLegalEntityStatus(id, 'rejected', rejectionReason, adminUserId);
  }
  
  Future<void> sendInvitation({
    required String email,
    required String legalEntityName,
    required String invitationLink,
  }) async {
    if (!_supabaseService.isInitialized) {
      throw Exception('Supabase non è configurato. Configura le credenziali per utilizzare l\'app.');
    }
    
    try {
      await _supabaseService.sendLegalEntityInvitation(
        email: email,
        legalEntityName: legalEntityName,
        invitationLink: invitationLink,
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  List<LegalEntity> get legalEntities => state.value ?? [];
  bool get isLoading => state.isLoading;
  bool get hasError => state.hasError;
  Object? get error => state.error;
  
  List<LegalEntity> get pendingEntities => 
      legalEntities.where((entity) => entity.isPending).toList();
  
  List<LegalEntity> get approvedEntities => 
      legalEntities.where((entity) => entity.isApproved).toList();
  
  List<LegalEntity> get rejectedEntities => 
      legalEntities.where((entity) => entity.isRejected).toList();
}

final legalEntityProvider = StateNotifierProvider<LegalEntityNotifier, AsyncValue<List<LegalEntity>>>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return LegalEntityNotifier(supabaseService);
});

// Convenience providers
final legalEntitiesListProvider = Provider<List<LegalEntity>>((ref) {
  return ref.watch(legalEntityProvider).value ?? [];
});

final pendingLegalEntitiesProvider = Provider<List<LegalEntity>>((ref) {
  final entities = ref.watch(legalEntityProvider).value ?? [];
  return entities.where((entity) => entity.isPending).toList();
});

final approvedLegalEntitiesProvider = Provider<List<LegalEntity>>((ref) {
  final entities = ref.watch(legalEntityProvider).value ?? [];
  return entities.where((entity) => entity.isApproved).toList();
});

final rejectedLegalEntitiesProvider = Provider<List<LegalEntity>>((ref) {
  final entities = ref.watch(legalEntityProvider).value ?? [];
  return entities.where((entity) => entity.isRejected).toList();
});

final legalEntityLoadingProvider = Provider<bool>((ref) {
  return ref.watch(legalEntityProvider).isLoading;
});
