import '../models/user.dart' as app_models;
import 'supabase_service.dart';

class VeriffService {
  /// Richiede una sessione di verifica Veriff tramite Supabase Edge Function
  Future<Map<String, dynamic>> requestVeriffSession({
    required app_models.AppUser user,
    String callbackUrl = 'https://example.com/callback',
  }) async {
    try {
      print('🔍 VeriffService: Starting requestVeriffSession');
      print('🔍 User ID: ${user.idUser}');
      print('🔍 User email: ${user.email}');
      
      final supabaseService = SupabaseService();

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
      
      print('🔍 Request body: $body');

      // Chiama la Supabase Edge Function
      print('🔍 Calling Edge Function: kyc-create-new-session');
      final response = await supabaseService.client.functions.invoke(
        'kyc-create-new-session',
        body: body,
      );
      
      print('🔍 Edge Function response status: ${response.status}');
      print('🔍 Edge Function response data: ${response.data}');

      if (response.status == 200) {
        final responseData = response.data as Map<String, dynamic>;
        print('🔍 Success! Response data: $responseData');

        // Salva i dati della sessione nel database
        await _saveKycAttempt(user.idUser, body, responseData);

        return responseData;
      } else {
        print('❌ Edge Function failed with status: ${response.status}');
        print('❌ Response data: ${response.data}');
        throw Exception('Failed to request Veriff session: ${response.status} - ${response.data}');
      }
    } catch (e) {
      print('❌ Error requesting Veriff session: $e');
      print('❌ Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  /// Controlla lo stato di una sessione Veriff tramite Supabase Edge Function
  Future<Map<String, dynamic>> checkVeriffSessionStatus({
    required String sessionId,
  }) async {
    try {
      final supabaseService = SupabaseService();

      final body = {'id': sessionId};

      // Chiama la Supabase Edge Function per controllare lo stato
      final response = await supabaseService.client.functions.invoke(
        'kyc-session-status',
        body: body,
      );

      if (response.status == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to check session status: ${response.status}');
      }
    } catch (e) {
      print('Error checking Veriff session status: $e');
      rethrow;
    }
  }

  /// Ottiene i risultati di una sessione Veriff tramite Supabase Edge Function
  Future<Map<String, dynamic>> getVeriffSessionResults({
    required String sessionId,
  }) async {
    try {
      final supabaseService = SupabaseService();

      final body = {'id': sessionId};

      // Chiama la Supabase Edge Function per ottenere i risultati
      final response = await supabaseService.client.functions.invoke(
        'kyc-session-results',
        body: body,
      );

      if (response.status == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to get session results: ${response.status}');
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
