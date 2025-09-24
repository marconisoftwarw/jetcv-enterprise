import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/supabase_service.dart';

class UpdateUserToLegalEntityService {
  static const String _baseUrl = 'https://skqsuxmdfqxbkhmselaz.supabase.co';

  /// Chiama la Edge Function per aggiornare il tipo utente a 'legal_entity'
  static Future<Map<String, dynamic>?> updateUserToLegalEntity({
    required String userId,
    String? legalEntityId,
  }) async {
    try {
      print(
        '🔄 UpdateUserToLegalEntityService: Aggiornando tipo utente a legal_entity per: $userId',
      );
      if (legalEntityId != null) {
        print(
          '🔄 UpdateUserToLegalEntityService: Legal entity ID: $legalEntityId',
        );
      }

      final supabaseService = SupabaseService();
      final token = supabaseService.client.auth.currentSession?.accessToken;

      if (token == null) {
        print(
          '❌ UpdateUserToLegalEntityService: Access token non disponibile.',
        );
        return null;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/functions/v1/update-user-to-legalentity'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user_id': userId,
          if (legalEntityId != null) 'legal_entity_id': legalEntityId,
        }),
      );

      print(
        '🔄 UpdateUserToLegalEntityService: Risposta Edge Function status: ${response.statusCode}',
      );
      print(
        '🔄 UpdateUserToLegalEntityService: Risposta Edge Function body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        return responseData;
      } else {
        print(
          '❌ UpdateUserToLegalEntityService: Errore nella chiamata API: ${response.statusCode}',
        );
        print('❌ UpdateUserToLegalEntityService: Error body: ${response.body}');
        return null;
      }
    } catch (e) {
      print(
        '❌ UpdateUserToLegalEntityService: Errore durante l\'aggiornamento del tipo utente: $e',
      );
      return null;
    }
  }

  /// Verifica se l'aggiornamento è avvenuto con successo
  static bool isUpdateSuccessful(Map<String, dynamic>? response) {
    return response != null && response['success'] == true;
  }

  /// Ottiene il messaggio dalla risposta
  static String getResponseMessage(Map<String, dynamic>? response) {
    return response?['message'] ?? response?['error'] ?? 'Unknown error';
  }

  /// Ottiene i dati dell'utente aggiornato
  static Map<String, dynamic>? getUpdatedUserData(
    Map<String, dynamic>? response,
  ) {
    if (response == null) return null;
    return response['data']?['user'];
  }

  /// Verifica se il record certifier è stato creato
  static bool isCertifierCreated(Map<String, dynamic>? response) {
    if (response == null) return false;
    return response['data']?['certifier_created'] == true;
  }
}
