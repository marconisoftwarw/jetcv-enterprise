import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../models/legal_entity_invitation.dart';
import '../services/supabase_service.dart';
import '../services/email_service.dart';

class InvitationProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final EmailService _emailService = EmailService();

  List<LegalEntityInvitation> _invitations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LegalEntityInvitation> get invitations => _invitations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filtri
  String? _filterStatus;
  String? _filterEmail;
  String? _filterLegalEntityId;

  String? get filterStatus => _filterStatus;
  String? get filterEmail => _filterEmail;
  String? get filterLegalEntityId => _filterLegalEntityId;

  // Statistiche
  int get totalInvitations => _invitations.length;
  int get pendingInvitations => _invitations.where((i) => i.isPending).length;
  int get acceptedInvitations => _invitations.where((i) => i.isAccepted).length;
  int get rejectedInvitations => _invitations.where((i) => i.isRejected).length;
  int get expiredInvitations => _invitations.where((i) => i.isExpired).length;

  // Carica tutti gli inviti
  Future<void> loadInvitations() async {
    _setLoading(true);
    _clearError();

    try {
      final invitations = await _supabaseService.getLegalEntityInvitations(
        status: _filterStatus,
        email: _filterEmail,
        legalEntityId: _filterLegalEntityId,
      );

      _invitations = invitations;
      _safeNotifyListeners();
    } catch (e) {
      _setError('Errore nel caricamento degli inviti: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Carica inviti per una specifica legal entity
  Future<void> loadInvitationsForLegalEntity(String legalEntityId) async {
    _setLoading(true);
    _clearError();

    try {
      final invitations = await _supabaseService.getLegalEntityInvitations(
        legalEntityId: legalEntityId,
      );

      _invitations = invitations;
      _safeNotifyListeners();
    } catch (e) {
      _setError('Errore nel caricamento degli inviti: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Crea un nuovo invito
  Future<bool> createInvitation({
    required String legalEntityId,
    required String email,
    DateTime? expiresAt,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Crea l'oggetto invito
      final invitation = LegalEntityInvitation.create(
        idLegalEntity: legalEntityId,
        email: email,
        expiresAt: expiresAt,
      );

      // Salva nel database
      final success = await _supabaseService.createLegalEntityInvitation(
        invitation,
      );
      if (!success) {
        _setError('Errore nel salvataggio dell\'invito');
        return false;
      }

      // Invia l'email
      final emailSent = await _emailService.sendLegalEntityInvitation(
        invitation,
      );
      if (!emailSent) {
        _setError('Invito creato ma email non inviata');
        // Non ritorniamo false perché l'invito è stato creato
      }

      // Ricarica la lista
      await loadInvitations();

      return true;
    } catch (e) {
      _setError('Errore nella creazione dell\'invito: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Aggiorna lo stato di un invito
  Future<bool> updateInvitationStatus({
    required String token,
    required InvitationStatus status,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      DateTime? acceptedAt;
      DateTime? rejectedAt;

      if (status == InvitationStatus.accepted) {
        acceptedAt = DateTime.now();
      } else if (status == InvitationStatus.rejected) {
        rejectedAt = DateTime.now();
      }

      final success = await _supabaseService.updateLegalEntityInvitationStatus(
        token: token,
        status: status.name,
        acceptedAt: acceptedAt,
        rejectedAt: rejectedAt,
      );

      if (success) {
        // Aggiorna la lista locale
        await loadInvitations();
      }

      return success;
    } catch (e) {
      _setError('Errore nell\'aggiornamento dello stato: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Accetta un invito
  Future<bool> acceptInvitation(String token) async {
    return await updateInvitationStatus(
      token: token,
      status: InvitationStatus.accepted,
    );
  }

  // Rifiuta un invito
  Future<bool> rejectInvitation(String token) async {
    return await updateInvitationStatus(
      token: token,
      status: InvitationStatus.rejected,
    );
  }

  // Elimina un invito
  Future<bool> deleteInvitation(String token) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _supabaseService.deleteLegalEntityInvitation(token);

      if (success) {
        // Aggiorna la lista locale
        await loadInvitations();
      }

      return success;
    } catch (e) {
      _setError('Errore nell\'eliminazione dell\'invito: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reinvia un invito
  Future<bool> resendInvitation(String token) async {
    _setLoading(true);
    _clearError();

    try {
      // Trova l'invito
      final invitation = _invitations.firstWhere(
        (i) => i.invitationToken == token,
      );

      // Invia nuovamente l'email
      final emailSent = await _emailService.sendLegalEntityInvitation(
        invitation,
      );

      if (emailSent) {
        // Aggiorna la data di invio
        final updatedInvitation = invitation.copyWith(sentAt: DateTime.now());

        await _supabaseService.updateLegalEntityInvitationStatus(
          token: token,
          status: updatedInvitation.status.name,
        );

        await loadInvitations();
        return true;
      } else {
        _setError('Errore nell\'invio dell\'email');
        return false;
      }
    } catch (e) {
      _setError('Errore nel reinvio dell\'invito: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verifica se un invito è valido
  Future<bool> isInvitationValid(String token) async {
    try {
      return await _supabaseService.isInvitationValid(token);
    } catch (e) {
      _setError('Errore nella verifica dell\'invito: $e');
      return false;
    }
  }

  // Filtra gli inviti
  void setFilters({String? status, String? email, String? legalEntityId}) {
    _filterStatus = status;
    _filterEmail = email;
    _filterLegalEntityId = legalEntityId;

    // Ricarica con i nuovi filtri
    loadInvitations();
  }

  // Pulisce i filtri
  void clearFilters() {
    _filterStatus = null;
    _filterEmail = null;
    _filterLegalEntityId = null;

    // Ricarica senza filtri
    loadInvitations();
  }

  // Metodi privati per la gestione dello stato
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

  // Pulisce la cache locale
  void clearCache() {
    _invitations.clear();
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
