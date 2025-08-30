import 'package:flutter/material.dart';
import '../models/legal_entity.dart';
import '../services/supabase_service.dart';

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
      final entities = await _supabaseService.getLegalEntities(status: status);
      _legalEntities = entities;
      _filterStatus = status;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load legal entities: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshLegalEntities() async {
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
      final entity = await _supabaseService.upsertLegalEntity(entityData);

      if (entity != null) {
        // Check if this is an update or create operation
        final existingIndex = _legalEntities.indexWhere(
          (e) => e.idLegalEntity == entity.idLegalEntity,
        );

        if (existingIndex != -1) {
          // Update existing entity
          _legalEntities[existingIndex] = entity;
        } else {
          // Add new entity at the beginning
          _legalEntities.insert(0, entity);
        }

        notifyListeners();
        return entity;
      }

      _setError('Failed to upsert legal entity');
      return null;
    } catch (e) {
      _setError('Failed to upsert legal entity: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<LegalEntity?> createLegalEntity(
    Map<String, dynamic> entityData,
  ) async {
    return await upsertLegalEntity(entityData);
  }

  Future<bool> updateLegalEntityStatus({
    required String id,
    required String status,
    String? rejectionReason,
  }) async {
    // Prepare update data with the ID
    final updateData = {'id_legal_entity': id, 'status': status};

    if (rejectionReason != null) {
      updateData['rejection_reason'] = rejectionReason;
    }

    final updatedEntity = await upsertLegalEntity(updateData);
    return updatedEntity != null;
  }

  Future<bool> approveLegalEntity(String id) async {
    return await updateLegalEntityStatus(id: id, status: 'approved');
  }

  Future<bool> rejectLegalEntity(String id, String rejectionReason) async {
    return await updateLegalEntityStatus(
      id: id,
      status: 'rejected',
      rejectionReason: rejectionReason,
    );
  }

  Future<LegalEntity?> getLegalEntityById(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final entity = await _supabaseService.getLegalEntityById(id);

      if (entity != null) {
        _selectedLegalEntity = entity;
        notifyListeners();
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
    // Prepare update data with the ID
    final updateData = Map<String, dynamic>.from(entityData);
    updateData['id_legal_entity'] = id;

    return await upsertLegalEntity(updateData);
  }

  Future<bool> deleteLegalEntity(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _supabaseService.deleteLegalEntity(id);

      if (success) {
        _legalEntities.removeWhere((entity) => entity.idLegalEntity == id);
        notifyListeners();
        return true;
      }

      _setError('Failed to delete legal entity');
      return false;
    } catch (e) {
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

  double get approvalRate {
    if (totalCount == 0) return 0.0;
    return (approvedCount / totalCount) * 100;
  }

  double get rejectionRate {
    if (totalCount == 0) return 0.0;
    return (rejectedCount / totalCount) * 100;
  }
}
