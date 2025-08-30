import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart' as app_models;

class VeriffService {
  static const String _baseUrl = 'http://18.102.14.247:4000';

  /// Richiede una sessione di verifica Veriff
  Future<Map<String, dynamic>> requestVeriffSession({
    required app_models.AppUser user,
    String callbackUrl = 'https://example.com/callback',
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/session-request-veriff');

      final body = {
        'callback': callbackUrl,
        'firstName': user.firstName ?? '',
        'lastName': user.lastName ?? '',
        'additionalFields': {
          'email': user.email ?? '',
          'phoneNumber': user.phone ?? '',
          'gender': _mapGenderToVeriff(user.gender),
          'dateOfBirth': user.dateOfBirth?.toIso8601String() ?? '',
        },
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Salva i dati della sessione nel database
        await _saveKycAttempt(user.idUser, body, responseData);

        return responseData;
      } else {
        throw Exception(
          'Failed to request Veriff session: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error requesting Veriff session: $e');
      rethrow;
    }
  }

  /// Controlla lo stato di una sessione Veriff
  Future<Map<String, dynamic>> checkVeriffSessionStatus({
    required String sessionId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/session-status');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to check session status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error checking Veriff session status: $e');
      rethrow;
    }
  }

  /// Ottiene i risultati di una sessione Veriff
  Future<Map<String, dynamic>> getVeriffSessionResults({
    required String sessionId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/session-results');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to get session results: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error getting Veriff session results: $e');
      rethrow;
    }
  }

  /// Mappa il genere dell'utente al formato richiesto da Veriff
  String _mapGenderToVeriff(app_models.Gender? gender) {
    switch (gender) {
      case app_models.Gender.male:
        return 'M';
      case app_models.Gender.female:
        return 'F';
      case app_models.Gender.other:
        return 'O';
      default:
        return 'M'; // Default
    }
  }

  /// Salva il tentativo KYC nel database
  Future<void> _saveKycAttempt(
    String userId,
    Map<String, dynamic> requestBody,
    Map<String, dynamic> responseData,
  ) async {
    try {
      // TODO: Implementare la chiamata al database per salvare il tentativo KYC
      // Questo dovrebbe utilizzare il SupabaseService per inserire nella tabella kyc_attempt
      print('KYC attempt saved for user: $userId');

      // Log della nuova struttura response
      if (responseData['success'] == true) {
        print('Veriff session created successfully');
        print('Session ID: ${responseData['sessionId']}');
        print('Verification URL: ${responseData['verificationUrl']}');
        print('Station URL: ${responseData['verificationUrl']}');
        print('Session URL: ${responseData['sessionUrl']}');

        // Estrai i dati dalla nuova struttura
        final verification = responseData['response']?['verification'];
        if (verification != null) {
          print('Verification ID: ${verification['id']}');
          print('Verification URL: ${verification['url']}');
          print('Session Token: ${verification['sessionToken']}');
        }
      }
    } catch (e) {
      print('Error saving KYC attempt: $e');
    }
  }
}
