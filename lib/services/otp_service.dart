import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class OtpService {
  static const String _baseUrl = AppConfig.supabaseUrl;
  static const String _apiKey = AppConfig.supabaseAnonKey;

  // Headers per le chiamate alla Edge Function
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
    'apikey': _apiKey,
  };

  /// Blocca un OTP dopo l'uso associandolo a una certificazione
  static Future<bool> blockOtpAfterUse({
    required String otpId,
    required String userId,
    required String certificationId,
    required String certifierId,
    required String legalEntityId,
  }) async {
    try {
      print('🔒 Blocking OTP after certification creation...');
      print('  - OTP ID: $otpId');
      print('  - User ID: $userId');
      print('  - Certification ID: $certificationId');
      print('  - Certifier ID: $certifierId');
      print('  - Legal Entity ID: $legalEntityId');

      final response = await http.patch(
        Uri.parse('$_baseUrl/functions/v1/otp-crud?id=$otpId'),
        headers: _headers,
        body: json.encode({
          'used_by_id_user': userId,
          'id_legal_entity': legalEntityId,
        }),
      );

      print('📡 Block OTP Response Status: ${response.statusCode}');
      print('📄 Block OTP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ OTP blocked successfully');
        return true;
      } else {
        print(
          '❌ Error blocking OTP: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Exception blocking OTP: $e');
      return false;
    }
  }

  /// Verifica e ottiene i dati dell'utente tramite OTP
  static Future<Map<String, dynamic>?> verifyOtpAndGetUser({
    required String otp,
  }) async {
    try {
      print('🔍 Verifying OTP: $otp');

      final response = await http.post(
        Uri.parse('$_baseUrl/functions/v1/verify-otp-and-get-user'),
        headers: _headers,
        body: json.encode({'otp': otp}),
      );

      print('📡 Verify OTP Response Status: ${response.statusCode}');
      print('📄 Verify OTP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true) {
          print('✅ OTP verified successfully');
          return data;
        } else {
          print('❌ OTP verification failed: ${data['error']}');
          return null;
        }
      } else {
        print(
          '❌ Error verifying OTP: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Exception verifying OTP: $e');
      return null;
    }
  }
}
