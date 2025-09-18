import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class PasswordService {
  static const String _baseUrl = AppConfig.supabaseUrl;
  static const String _apiKey = AppConfig.supabaseAnonKey;

  // Valida il token di impostazione password
  Future<bool> validatePasswordSetupToken(String token) async {
    try {
      print('🔐 Validating password setup token: $token');

      final response = await http.post(
        Uri.parse('$_baseUrl/functions/v1/validate-password-token'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({'token': token}),
      );

      print(
        '📡 Token validation response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['valid'] == true;
      }

      return false;
    } catch (e) {
      print('❌ Error validating password setup token: $e');
      return false;
    }
  }

  // Imposta la password per l'utente
  Future<bool> setPassword({
    required String token,
    required String password,
  }) async {
    try {
      print('🔐 Setting password for token: $token');

      final response = await http.post(
        Uri.parse('$_baseUrl/functions/v1/set-password'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({'token': token, 'password': password}),
      );

      print(
        '📡 Set password response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      return false;
    } catch (e) {
      print('❌ Error setting password: $e');
      return false;
    }
  }
}
