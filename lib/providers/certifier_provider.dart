import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/certifier.dart';
import '../services/certifier_service.dart';

class CertifierProvider extends ChangeNotifier {
  final CertifierService _certifierService = CertifierService();

  // Stato
  List<Certifier> _certifiers = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _filterLegalEntityId;
  String? _filterRole;
  bool _filterActiveOnly = true;

  // Getters per lo stato
  List<Certifier> get certifiers => _certifiers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get filterLegalEntityId => _filterLegalEntityId;
  String? get filterRole => _filterRole;
  bool get filterActiveOnly => _filterActiveOnly;

  // Getters per i certificatori filtrati
  List<Certifier> get filteredCertifiers {
    var filtered = _certifiers;

    if (_filterLegalEntityId != null) {
      filtered = filtered
          .where((c) => c.idLegalEntity == _filterLegalEntityId)
          .toList();
    }

    if (_filterRole != null) {
      filtered = filtered.where((c) => c.role == _filterRole).toList();
    }

    if (_filterActiveOnly) {
      filtered = filtered.where((c) => c.active).toList();
    }

    return filtered;
  }

  // Statistiche
  Map<String, int> get stats {
    final total = _certifiers.length;
    final active = _certifiers.where((c) => c.active).length;
    final inactive = total - active;
    final withKyc = _certifiers.where((c) => c.hasKyc && c.isKycPassed).length;
    final withoutKyc = _certifiers.where((c) => !c.hasKyc).length;
    final pendingInvitation = _certifiers
        .where((c) => c.hasInvitationToken)
        .length;

    return {
      'total': total,
      'active': active,
      'inactive': inactive,
      'withKyc': withKyc,
      'withoutKyc': withoutKyc,
      'pendingInvitation': pendingInvitation,
    };
  }

  // Carica tutti i certificatori
  Future<void> loadAllCertifiers() async {
    _setLoading(true);
    _clearError();

    try {
      final certifiers = await _certifierService.getAllCertifiers();
      _certifiers = certifiers;
      _safeNotifyListeners();
    } catch (e) {
      _setError('Errore nel caricamento dei certificatori: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Carica certificatori per legal entity
  Future<void> loadCertifiersByLegalEntity(String legalEntityId) async {
    _setLoading(true);
    _clearError();

    try {
      final certifiers = await _certifierService.getCertifiersByLegalEntity(
        legalEntityId,
      );
      _certifiers = certifiers;
      _safeNotifyListeners();
    } catch (e) {
      _setError('Errore nel caricamento dei certificatori: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Carica certificatore per ID
  Future<Certifier?> loadCertifierById(String idCertifier) async {
    try {
      return await _certifierService.getCertifierById(idCertifier);
    } catch (e) {
      _setError('Errore nel caricamento del certificatore: $e');
      return null;
    }
  }

  // Crea un nuovo certificatore
  Future<bool> createCertifier(Certifier certifier) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _certifierService.createCertifier(certifier);
      if (success) {
        _certifiers.add(certifier);
        _safeNotifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Errore nella creazione del certificatore: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Aggiorna un certificatore esistente
  Future<bool> updateCertifier(Certifier certifier) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _certifierService.updateCertifier(certifier);
      if (success) {
        final index = _certifiers.indexWhere(
          (c) => c.idCertifier == certifier.idCertifier,
        );
        if (index != -1) {
          _certifiers[index] = certifier;
          _safeNotifyListeners();
        }
      }
      return success;
    } catch (e) {
      _setError('Errore nell\'aggiornamento del certificatore: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Elimina un certificatore
  Future<bool> deleteCertifier(String idCertifier) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _certifierService.deleteCertifier(idCertifier);
      if (success) {
        _certifiers.removeWhere((c) => c.idCertifier == idCertifier);
        _safeNotifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Errore nell\'eliminazione del certificatore: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Invita un nuovo certificatore
  Future<bool> inviteCertifier({
    required String email,
    required String legalEntityId,
    String? role,
    String? message,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _certifierService.inviteCertifier(
        email: email,
        legalEntityId: legalEntityId,
        role: role,
        message: message,
      );

      if (success) {
        // Ricarica i certificatori per mostrare il nuovo invito
        await loadCertifiersByLegalEntity(legalEntityId);
      }

      return success;
    } catch (e) {
      _setError('Errore nell\'invito del certificatore: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Accetta invito certificatore
  Future<bool> acceptCertifierInvitation({
    required String invitationToken,
    required String idUser,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _certifierService.acceptCertifierInvitation(
        invitationToken: invitationToken,
        idUser: idUser,
      );

      if (success) {
        // Ricarica i certificatori
        await loadAllCertifiers();
      }

      return success;
    } catch (e) {
      _setError('Errore nell\'accettazione dell\'invito: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Rifiuta invito certificatore
  Future<bool> rejectCertifierInvitation(String invitationToken) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _certifierService.rejectCertifierInvitation(
        invitationToken,
      );

      if (success) {
        // Ricarica i certificatori
        await loadAllCertifiers();
      }

      return success;
    } catch (e) {
      _setError('Errore nel rifiuto dell\'invito: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Aggiorna stato KYC del certificatore
  Future<bool> updateCertifierKycStatus({
    required String idCertifier,
    required bool kycPassed,
    String? idKycAttempt,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _certifierService.updateCertifierKycStatus(
        idCertifier: idCertifier,
        kycPassed: kycPassed,
        idKycAttempt: idKycAttempt,
      );

      if (success) {
        // Ricarica i certificatori
        await loadAllCertifiers();
      }

      return success;
    } catch (e) {
      _setError('Errore nell\'aggiornamento dello stato KYC: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verifica se un utente è certificatore
  Future<bool> isUserCertifier(String idUser) async {
    try {
      return await _certifierService.isUserCertifier(idUser);
    } catch (e) {
      _setError('Errore nella verifica del ruolo certificatore: $e');
      return false;
    }
  }

  // Verifica se un utente è certificatore per una legal entity
  Future<bool> isUserCertifierForLegalEntity(
    String idUser,
    String legalEntityId,
  ) async {
    try {
      return await _certifierService.isUserCertifierForLegalEntity(
        idUser,
        legalEntityId,
      );
    } catch (e) {
      _setError('Errore nella verifica del ruolo certificatore: $e');
      return false;
    }
  }

  // Imposta filtri
  void setFilters({String? legalEntityId, String? role, bool? activeOnly}) {
    _filterLegalEntityId = legalEntityId;
    _filterRole = role;
    _filterActiveOnly = activeOnly ?? _filterActiveOnly;
    _safeNotifyListeners();
  }

  // Pulisce i filtri
  void clearFilters() {
    _filterLegalEntityId = null;
    _filterRole = null;
    _filterActiveOnly = true;
    _safeNotifyListeners();
  }

  // Metodi privati per la gestione dello stato
  void _setLoading(bool loading) {
    _isLoading = loading;
    _safeNotifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _safeNotifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Pulisce la cache
  void clearCache() {
    _certifiers.clear();
    _errorMessage = null;
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    // Evita di chiamare notifyListeners durante la fase di build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
