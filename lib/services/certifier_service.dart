import '../models/certifier.dart';
import '../services/email_service.dart';
import '../config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CertifierService {
  final EmailService _emailService = EmailService();

  static const String _baseUrl = AppConfig.supabaseUrl;
  static const String _apiKey = AppConfig.supabaseAnonKey;

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'apikey': _apiKey,
    'Authorization': 'Bearer $_apiKey',
  };

  // Carica tutti i certificatori
  Future<List<Certifier>> getAllCertifiers() async {
    try {
      print('🔍 Getting all certifiers');

      // Usa REST API per recuperare tutti i certificatori
      final response = await http.get(
        Uri.parse('$_baseUrl/rest/v1/certifier?select=*&order=created_at.desc'),
        headers: _headers,
      );

      print(
        '📊 All certifiers response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final certifiers = data
            .map((item) => Certifier.fromJson(item))
            .toList();

        print('✅ Found ${certifiers.length} total certifiers');
        return certifiers;
      } else {
        print(
          '❌ Error getting all certifiers: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('❌ Error getting all certifiers: $e');
      return [];
    }
  }

  // Carica certificatori per legal entity
  Future<List<Certifier>> getCertifiersByLegalEntity(
    String legalEntityId,
  ) async {
    try {
      print('🔍 Getting certifiers for legal entity: $legalEntityId');

      // Usa REST API per recuperare i certificatori
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/rest/v1/certifier?select=*&id_legal_entity=eq.$legalEntityId&order=created_at.desc',
        ),
        headers: _headers,
      );

      print(
        '📊 Certifiers response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final certifiers = data
            .map((item) => Certifier.fromJson(item))
            .toList();

        print('✅ Found ${certifiers.length} certifiers');
        return certifiers;
      } else {
        print(
          '❌ Error getting certifiers: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('❌ Error getting certifiers by legal entity: $e');
      return [];
    }
  }

  // Carica certificatore per ID
  Future<Certifier?> getCertifierById(String idCertifier) async {
    try {
      // TODO: Implementare chiamata al database
      return null;
    } catch (e) {
      print('Error getting certifier by ID: $e');
      return null;
    }
  }

  // Carica certificatore per utente
  Future<Certifier?> getCertifierByUser(String idUser) async {
    try {
      // TODO: Implementare chiamata al database
      return null;
    } catch (e) {
      print('Error getting certifier by user: $e');
      return null;
    }
  }

  // Crea un nuovo certificatore
  Future<bool> createCertifier(Certifier certifier) async {
    try {
      // TODO: Implementare chiamata al database
      print('Creating certifier: ${certifier.idCertifier}');
      return true;
    } catch (e) {
      print('Error creating certifier: $e');
      return false;
    }
  }

  // Aggiorna un certificatore esistente
  Future<bool> updateCertifier(Certifier certifier) async {
    try {
      // TODO: Implementare chiamata al database
      print('Updating certifier: ${certifier.idCertifier}');
      return true;
    } catch (e) {
      print('Error updating certifier: $e');
      return false;
    }
  }

  // Elimina un certificatore
  Future<bool> deleteCertifier(String idCertifier) async {
    try {
      // TODO: Implementare chiamata al database
      print('Deleting certifier: $idCertifier');
      return true;
    } catch (e) {
      print('Error deleting certifier: $e');
      return false;
    }
  }

  // Invita un nuovo certificatore
  Future<bool> inviteCertifier({
    required String email,
    required String legalEntityId,
    String? role,
    String? message,
  }) async {
    try {
      // Genera token di invito
      final invitationToken = _generateInvitationToken();

      // Crea certificatore con token di invito
      final certifier = Certifier(
        idLegalEntity: legalEntityId,
        role: role,
        invitationToken: invitationToken,
      );

      // Salva nel database
      final success = await createCertifier(certifier);
      if (!success) return false;

      // Invia email di invito
      final emailSent = await _emailService.sendCertifierInvitation(
        email: email,
        invitationToken: invitationToken,
        legalEntityId: legalEntityId,
        role: role,
        message: message,
      );

      return emailSent;
    } catch (e) {
      print('Error inviting certifier: $e');
      return false;
    }
  }

  // Accetta invito certificatore
  Future<bool> acceptCertifierInvitation({
    required String invitationToken,
    required String idUser,
  }) async {
    try {
      // Trova certificatore per token
      final certifier = await getCertifierByInvitationToken(invitationToken);
      if (certifier == null) return false;

      // Aggiorna certificatore con utente
      final updatedCertifier = certifier.copyWith(
        idUser: idUser,
        invitationToken: null, // Rimuovi token dopo accettazione
      );

      return await updateCertifier(updatedCertifier);
    } catch (e) {
      print('Error accepting certifier invitation: $e');
      return false;
    }
  }

  // Rifiuta invito certificatore
  Future<bool> rejectCertifierInvitation(String invitationToken) async {
    try {
      // Trova certificatore per token
      final certifier = await getCertifierByInvitationToken(invitationToken);
      if (certifier == null) return false;

      // Elimina certificatore
      return await deleteCertifier(certifier.idCertifier);
    } catch (e) {
      print('Error rejecting certifier invitation: $e');
      return false;
    }
  }

  // Carica certificatore per token di invito
  Future<Certifier?> getCertifierByInvitationToken(
    String invitationToken,
  ) async {
    try {
      // TODO: Implementare chiamata al database
      return null;
    } catch (e) {
      print('Error getting certifier by invitation token: $e');
      return null;
    }
  }

  // Verifica se un utente è certificatore
  Future<bool> isUserCertifier(String idUser) async {
    try {
      final certifier = await getCertifierByUser(idUser);
      return certifier != null && certifier.active;
    } catch (e) {
      print('Error checking if user is certifier: $e');
      return false;
    }
  }

  // Verifica se un utente è certificatore per una legal entity
  Future<bool> isUserCertifierForLegalEntity(
    String idUser,
    String legalEntityId,
  ) async {
    try {
      final certifier = await getCertifierByUser(idUser);
      return certifier != null &&
          certifier.active &&
          certifier.idLegalEntity == legalEntityId;
    } catch (e) {
      print('Error checking if user is certifier for legal entity: $e');
      return false;
    }
  }

  // Aggiorna stato KYC del certificatore
  Future<bool> updateCertifierKycStatus({
    required String idCertifier,
    required bool kycPassed,
    String? idKycAttempt,
  }) async {
    try {
      final certifier = await getCertifierById(idCertifier);
      if (certifier == null) return false;

      final updatedCertifier = certifier.copyWith(
        kycPassed: kycPassed,
        idKycAttempt: idKycAttempt,
      );

      return await updateCertifier(updatedCertifier);
    } catch (e) {
      print('Error updating certifier KYC status: $e');
      return false;
    }
  }

  // Genera token di invito
  String _generateInvitationToken() {
    // Genera un token di 43 caratteri come richiesto dal database
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-';
    final random = DateTime.now().millisecondsSinceEpoch;

    String result = '';
    for (int i = 0; i < 43; i++) {
      result += chars[random % chars.length];
    }

    return result;
  }

  // Carica statistiche certificatori
  Future<Map<String, int>> getCertifierStats(String legalEntityId) async {
    try {
      final certifiers = await getCertifiersByLegalEntity(legalEntityId);

      return {
        'total': certifiers.length,
        'active': certifiers.where((c) => c.active).length,
        'inactive': certifiers.where((c) => !c.active).length,
        'withKyc': certifiers.where((c) => c.hasKyc && c.isKycPassed).length,
        'withoutKyc': certifiers.where((c) => !c.hasKyc).length,
        'pendingInvitation': certifiers
            .where((c) => c.hasInvitationToken)
            .length,
      };
    } catch (e) {
      print('Error getting certifier stats: $e');
      return {};
    }
  }
}
