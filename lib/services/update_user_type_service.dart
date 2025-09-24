import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class UpdateUserTypeService {
  static const String _baseUrl = AppConfig.supabaseUrl;

  /// Aggiorna il tipo utente a 'certifier' dopo la registrazione
  static Future<Map<String, dynamic>?> updateUserTypeToCertifier({
    required String userId,
    String? legalEntityId,
  }) async {
    try {
      print(
        '🔄 UpdateUserTypeService: Aggiornando tipo utente a certifier per: $userId',
      );
      if (legalEntityId != null) {
        print('🔄 UpdateUserTypeService: Legal entity ID: $legalEntityId');
      }

      final requestBody = {
        'user_id': userId,
        if (legalEntityId != null) 'legal_entity_id': legalEntityId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/functions/v1/update-user-type-to-certifier'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        },
        body: json.encode(requestBody),
      );

      print('📡 UpdateUserTypeService: Status code: ${response.statusCode}');
      print('📡 UpdateUserTypeService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        print('✅ UpdateUserTypeService: Tipo utente aggiornato con successo');
        print('✅ UpdateUserTypeService: Response data: $responseData');
        return responseData;
      } else {
        print(
          '❌ UpdateUserTypeService: Errore nella chiamata API: ${response.statusCode}',
        );
        print('❌ UpdateUserTypeService: Error body: ${response.body}');
        return null;
      }
    } catch (e) {
      print(
        '❌ UpdateUserTypeService: Errore durante l\'aggiornamento del tipo utente: $e',
      );
      return null;
    }
  }

  /// Verifica se l'aggiornamento è andato a buon fine
  static bool isUpdateSuccessful(Map<String, dynamic>? response) {
    if (response == null) return false;
    return response['success'] == true;
  }

  /// Ottiene il messaggio di risposta
  static String getResponseMessage(Map<String, dynamic>? response) {
    if (response == null) return 'Errore sconosciuto';
    return response['message'] ?? 'Operazione completata';
  }

  /// Ottiene i dati dell'utente aggiornato
  static Map<String, dynamic>? getUpdatedUserData(
    Map<String, dynamic>? response,
  ) {
    if (response == null) return null;
    return response['data']?['user'];
  }

  /// Verifica se è stato creato un record certifier
  static bool isCertifierCreated(Map<String, dynamic>? response) {
    if (response == null) return false;
    return response['data']?['certifier_created'] == true;
  }
}
