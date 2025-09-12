import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../models/legal_entity.dart';
import '../models/legal_entity_invitation.dart';
import '../services/supabase_service.dart';
import '../services/email_service.dart';

class LegalEntityProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<LegalEntity> _legalEntities = [];
  LegalEntity? _selectedLegalEntity;
  bool _isLoading = false;
  String? _errorMessage;
  String? _filterStatus;

  List<LegalEntity> get legalEntities => _legalEntities;
  LegalEntity? get selectedLegalEntity => _selectedLegalEntity;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get filterStatus => _filterStatus;

  List<LegalEntity> get filteredLegalEntities {
    if (_filterStatus == null) return _legalEntities;
    return _legalEntities
        .where(
          (entity) => entity.status.toString().split('.').last == _filterStatus,
        )
        .toList();
  }

  List<LegalEntity> get pendingLegalEntities {
    return _legalEntities.where((entity) => entity.isPending).toList();
  }

  List<LegalEntity> get approvedLegalEntities {
    return _legalEntities.where((entity) => entity.isApproved).toList();
  }

  List<LegalEntity> get rejectedLegalEntities {
    return _legalEntities.where((entity) => entity.isRejected).toList();
  }

  Future<void> loadLegalEntities({String? status}) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔄 LegalEntityProvider: Starting to load legal entities...');
      print('🔄 Status filter: ${status ?? 'none'}');

      // Ensure user is authenticated before proceeding
      if (!await ensureAuthentication()) {
        return;
      }

      final entities = await _supabaseService.getLegalEntities(status: status);

      print(
        '🔄 LegalEntityProvider: Received ${entities.length} entities from service',
      );

      _legalEntities = entities;
      _filterStatus = status;

      print(
        '🔄 LegalEntityProvider: Updated local state with ${_legalEntities.length} entities',
      );
      print(
        '🔄 LegalEntityProvider: Entity names: ${_legalEntities.map((e) => e.legalName).join(', ')}',
      );

      _safeNotifyListeners();
    } catch (e) {
      print('❌ LegalEntityProvider: Error loading legal entities: $e');
      _setError('Failed to load legal entities: $e');
    } finally {
      _setLoading(false);
      print('🔄 LegalEntityProvider: Loading completed');
    }
  }

  Future<void> refreshLegalEntities() async {
    print('🔄 LegalEntityProvider: Refreshing legal entities...');
    await loadLegalEntities(status: _filterStatus);
  }

  /// Upsert a legal entity using the upsert-legal-entity Edge Function
  /// This method handles both creation and updates automatically
  Future<LegalEntity?> upsertLegalEntity(
    Map<String, dynamic> entityData,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔄 LegalEntityProvider: Starting upsertLegalEntity...');
      print('🔄 LegalEntityProvider: Entity data: $entityData');

      // Ensure user is authenticated before proceeding
      if (!await ensureAuthentication()) {
        return null;
      }

      final entity = await _supabaseService.upsertLegalEntity(entityData);

      print(
        '🔄 LegalEntityProvider: SupabaseService response: ${entity?.legalName ?? 'null'}',
      );

      if (entity != null) {
        print(
          '🔄 LegalEntityProvider: Entity received, updating local state...',
        );

        // Check if this is an update or create operation
        final existingIndex = _legalEntities.indexWhere(
          (e) => e.idLegalEntity == entity.idLegalEntity,
        );

        if (existingIndex != -1) {
          // Update existing entity
          print(
            '🔄 LegalEntityProvider: Updating existing entity at index $existingIndex',
          );
          _legalEntities[existingIndex] = entity;
        } else {
          // Add new entity at the beginning
          print('🔄 LegalEntityProvider: Adding new entity at beginning');
          _legalEntities.insert(0, entity);
        }

        print(
          '🔄 LegalEntityProvider: Local state updated, notifying listeners...',
        );
        _safeNotifyListeners();
        print('✅ LegalEntityProvider: Upsert completed successfully');
        return entity;
      }

      print(
        '❌ LegalEntityProvider: SupabaseService returned null, setting error',
      );
      _setError('Failed to upsert legal entity');
      return null;
    } catch (e) {
      print('❌ LegalEntityProvider: Exception during upsert: $e');
      print('❌ LegalEntityProvider: Exception type: ${e.runtimeType}');
      _setError('Failed to upsert legal entity: $e');
      return null;
    } finally {
      _setLoading(false);
      print('🔄 LegalEntityProvider: Loading completed');
    }
  }

  Future<LegalEntity?> createLegalEntity(
    Map<String, dynamic> entityData,
  ) async {
    return await upsertLegalEntity(entityData);
  }

  Future<bool> approveLegalEntity(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Ensure user is authenticated before proceeding
      if (!await ensureAuthentication()) {
        return false;
      }

      print('🔄 LegalEntityProvider: Approving legal entity: $id');

      // Use upsert-legal-entity Edge Function to change status to approved
      final updateData = {
        'id_legal_entity': id,
        'status': 'approved',
        'updated_at': DateTime.now().toIso8601String(),
      };

      final updatedEntity = await _supabaseService.upsertLegalEntity(
        updateData,
      );
      if (updatedEntity != null) {
        // Update local state
        final index = _legalEntities.indexWhere((e) => e.idLegalEntity == id);
        if (index != -1) {
          _legalEntities[index] = updatedEntity;
          _safeNotifyListeners();
        }
        print('✅ LegalEntityProvider: Legal entity approved successfully');
        return true;
      }

      _setError('Failed to approve legal entity');
      return false;
    } catch (e) {
      print('❌ LegalEntityProvider: Error approving legal entity: $e');
      _setError('Error approving legal entity: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> rejectLegalEntity(String id, String rejectionReason) async {
    _setLoading(true);
    _clearError();

    try {
      // Ensure user is authenticated before proceeding
      if (!await ensureAuthentication()) {
        return false;
      }

      print('🔄 LegalEntityProvider: Rejecting legal entity: $id');
      print('🔄 LegalEntityProvider: Rejection reason: $rejectionReason');

      // Use upsert-legal-entity Edge Function to change status to rejected
      final updateData = {
        'id_legal_entity': id,
        'status': 'rejected',
        'rejection_reason': rejectionReason,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final updatedEntity = await _supabaseService.upsertLegalEntity(
        updateData,
      );
      if (updatedEntity != null) {
        // Update local state
        final index = _legalEntities.indexWhere((e) => e.idLegalEntity == id);
        if (index != -1) {
          _legalEntities[index] = updatedEntity;
          _safeNotifyListeners();
        }
        print('✅ LegalEntityProvider: Legal entity rejected successfully');
        return true;
      }

      _setError('Failed to reject legal entity');
      return false;
    } catch (e) {
      print('❌ LegalEntityProvider: Error rejecting legal entity: $e');
      _setError('Error rejecting legal entity: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<LegalEntity?> getLegalEntityById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Ensure user is authenticated before proceeding
      if (!await ensureAuthentication()) {
        return null;
      }

      final entity = await _supabaseService.getLegalEntityById(id);

      if (entity != null) {
        _selectedLegalEntity = entity;
        _safeNotifyListeners();
        return entity;
      }

      _setError('Legal entity not found');
      return null;
    } catch (e) {
      _setError('Failed to get legal entity: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<LegalEntity?> updateLegalEntity({
    required String id,
    required Map<String, dynamic> entityData,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Ensure user is authenticated before proceeding
      if (!await ensureAuthentication()) {
        return null;
      }

      print('🔄 LegalEntityProvider: Updating legal entity: $id');

      // Prepare update data with the ID
      final updateData = Map<String, dynamic>.from(entityData);
      updateData['id_legal_entity'] = id;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      return await upsertLegalEntity(updateData);
    } catch (e) {
      print('❌ LegalEntityProvider: Error updating legal entity: $e');
      _setError('Error updating legal entity: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateLegalEntityStatus(
    String id,
    LegalEntityStatus newStatus, {
    String? rejectionReason,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Ensure user is authenticated before proceeding
      if (!await ensureAuthentication()) {
        return false;
      }

      print(
        '🔄 LegalEntityProvider: Updating legal entity status: $id to ${newStatus.toString().split('.').last}',
      );

      final updateData = <String, dynamic>{
        'id_legal_entity': id,
        'status': newStatus.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Add rejection reason if provided
      if (newStatus == LegalEntityStatus.rejected && rejectionReason != null) {
        updateData['rejection_reason'] = rejectionReason;
      }

      final updatedEntity = await _supabaseService.upsertLegalEntity(
        updateData,
      );
      if (updatedEntity != null) {
        // Update local state
        final index = _legalEntities.indexWhere((e) => e.idLegalEntity == id);
        if (index != -1) {
          _legalEntities[index] = updatedEntity;
          _safeNotifyListeners();
        }
        print(
          '✅ LegalEntityProvider: Legal entity status updated successfully',
        );
        return true;
      }

      _setError('Failed to update legal entity status');
      return false;
    } catch (e) {
      print('❌ LegalEntityProvider: Error updating legal entity status: $e');
      _setError('Error updating legal entity status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteLegalEntity(String id) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔄 LegalEntityProvider: Deleting legal entity: $id');

      // No need to check authentication here - the Edge Function handles it
      // and bypasses RLS without calling the user table
      final success = await _supabaseService.deleteLegalEntity(id);

      if (success) {
        // Remove from local state
        final initialCount = _legalEntities.length;
        _legalEntities.removeWhere((entity) => entity.idLegalEntity == id);
        final finalCount = _legalEntities.length;

        if (initialCount > finalCount) {
          print('✅ LegalEntityProvider: Entity removed from local state');
          _safeNotifyListeners();
        } else {
          print('⚠️ LegalEntityProvider: Entity not found in local state');
        }
        return true;
      }

      _setError('Failed to delete legal entity');
      return false;
    } catch (e) {
      print('❌ LegalEntityProvider: Error deleting legal entity: $e');
      _setError('Failed to delete legal entity: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendInvitation({
    required String email,
    required String legalEntityId,
    required String inviterId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Ensure user is authenticated before proceeding
      if (!await ensureAuthentication()) {
        return false;
      }

      final success = await _supabaseService.sendLegalEntityInvitation(
        email: email,
        legalEntityId: legalEntityId,
        inviterId: inviterId,
      );

      if (success) {
        return true;
      }

      _setError('Failed to send invitation');
      return false;
    } catch (e) {
      _setError('Failed to send invitation: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendEmailInvitation({
    required String email,
    required String legalEntityId,
    required String inviterId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Ensure user is authenticated before proceeding
      if (!await ensureAuthentication()) {
        return false;
      }

      print(
        '🔄 LegalEntityProvider: Sending email invitation to $email for entity $legalEntityId',
      );

      // Prima crea l'invito nel database
      final invitationSuccess = await _supabaseService
          .sendLegalEntityInvitation(
            email: email,
            legalEntityId: legalEntityId,
            inviterId: inviterId,
          );

      if (!invitationSuccess) {
        _setError('Failed to create invitation in database');
        return false;
      }

      // Poi invia l'email
      final emailService = EmailService();
      final invitation = LegalEntityInvitation.create(
        idLegalEntity: legalEntityId,
        email: email,
      );

      // Ottieni i dati della legal entity per il link
      final legalEntity = await _supabaseService.getLegalEntityById(
        legalEntityId,
      );
      final legalEntityData = legalEntity?.toJson();

      final emailSuccess = await emailService.sendLegalEntityInvitation(
        invitation,
        legalEntityData: legalEntityData,
      );

      if (emailSuccess) {
        print('✅ LegalEntityProvider: Email invitation sent successfully');
        return true;
      } else {
        _setError('Failed to send invitation email');
        return false;
      }
    } catch (e) {
      print('❌ LegalEntityProvider: Error sending email invitation: $e');
      _setError('Failed to send invitation: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void selectLegalEntity(LegalEntity entity) {
    _selectedLegalEntity = entity;
    notifyListeners();
  }

  void clearSelectedLegalEntity() {
    _selectedLegalEntity = null;
    notifyListeners();
  }

  void setFilterStatus(String? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void clearFilter() {
    _filterStatus = null;
    notifyListeners();
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

  // Metodo per assicurarsi che l'utente sia autenticato prima di qualsiasi operazione
  Future<bool> ensureAuthentication() async {
    try {
      if (_supabaseService.isUserAuthenticated) {
        return true;
      }

      print(
        '⚠️ LegalEntityProvider: User not authenticated, attempting to restore session...',
      );

      // Try to restore session
      final restored = await _supabaseService.restoreSession();
      if (restored == null) {
        print('❌ LegalEntityProvider: Failed to restore session');
        _setError('User not authenticated');
        return false;
      }

      print('✅ LegalEntityProvider: Session restored successfully');
      return true;
    } catch (e) {
      print('❌ LegalEntityProvider: Error ensuring authentication: $e');
      _setError('Authentication error: $e');
      return false;
    }
  }

  // Search functionality
  List<LegalEntity> searchLegalEntities(String query) {
    if (query.isEmpty) return filteredLegalEntities;

    final lowercaseQuery = query.toLowerCase();
    return filteredLegalEntities.where((entity) {
      return (entity.legalName?.toLowerCase() ?? '').contains(lowercaseQuery) ||
          (entity.email?.toLowerCase() ?? '').contains(lowercaseQuery) ||
          (entity.identifierCode?.toLowerCase() ?? '').contains(
            lowercaseQuery,
          ) ||
          (entity.legalRapresentative?.toLowerCase() ?? '').contains(
            lowercaseQuery,
          );
    }).toList();
  }

  // Statistics
  int get totalCount => _legalEntities.length;
  int get pendingCount => pendingLegalEntities.length;
  int get approvedCount => approvedLegalEntities.length;
  int get rejectedCount => rejectedLegalEntities.length;

  // Invitation tracking
  final Map<String, List<LegalEntityInvitation>> _entityInvitations = {};

  Future<List<LegalEntityInvitation>> getEntityInvitations(
    String entityId,
  ) async {
    if (_entityInvitations.containsKey(entityId)) {
      return _entityInvitations[entityId]!;
    }

    try {
      // TODO: Implementare chiamata al servizio per ottenere gli inviti
      // Per ora restituiamo una lista vuota
      _entityInvitations[entityId] = [];
      return [];
    } catch (e) {
      print('❌ LegalEntityProvider: Error getting entity invitations: $e');
      return [];
    }
  }

  bool hasActiveInvitation(String entityId) {
    final invitations = _entityInvitations[entityId];
    if (invitations == null) return false;

    return invitations.any((invitation) => invitation.isActive);
  }

  double get approvalRate {
    if (totalCount == 0) return 0.0;
    return (approvedCount / totalCount) * 100;
  }

  double get rejectionRate {
    if (totalCount == 0) return 0.0;
    return (rejectedCount / totalCount) * 100;
  }

  void _safeNotifyListeners() {
    // Evita di chiamare notifyListeners durante la fase di build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeNotifyListeners();
    });
  }
}
