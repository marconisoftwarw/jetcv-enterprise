import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class EdgeFunctionService {
  static const String _baseUrl = '${AppConfig.supabaseUrl}/functions/v1';

  /// Chiama l'edge function create-legal-entity
  static Future<Map<String, dynamic>?> createLegalEntity({
    required Map<String, dynamic> legalEntityData,
    String? accessToken,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/create-legal-entity');

      final headers = {
        'Content-Type': 'application/json',
        'apikey': AppConfig.supabaseAnonKey,
      };

      // Aggiungi Authorization header solo se abbiamo un token
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(legalEntityData),
      );

      print('🔍 Edge function response status: ${response.statusCode}');
      print('🔍 Edge function response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        print('❌ Edge function error: $errorData');
        throw Exception(
          errorData['message'] ?? 'Failed to create legal entity',
        );
      }
    } catch (e) {
      print('❌ Edge function call error: $e');
      rethrow;
    }
  }

  /// Chiama l'edge function create-user (se esiste)
  static Future<Map<String, dynamic>?> createUser({
    required Map<String, dynamic> userData,
    String? accessToken,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/create-user');

      final headers = {
        'Content-Type': 'application/json',
        'apikey': AppConfig.supabaseAnonKey,
      };

      // Aggiungi Authorization header solo se abbiamo un token
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(userData),
      );

      print(
        '🔍 Create user edge function response status: ${response.statusCode}',
      );
      print('🔍 Create user edge function response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        print('❌ Create user edge function error: $errorData');
        throw Exception(errorData['message'] ?? 'Failed to create user');
      }
    } catch (e) {
      print('❌ Create user edge function call error: $e');
      rethrow;
    }
  }

  /// Chiama l'edge function create-legal-entity-with-user
  static Future<Map<String, dynamic>?> createLegalEntityWithUser({
    required Map<String, dynamic> userData,
    required Map<String, dynamic> legalEntityData,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/create-legal-entity-with-user');

      final headers = {
        'Content-Type': 'application/json',
        'apikey': AppConfig.supabaseAnonKey,
      };

      final requestBody = {
        'userData': userData,
        'legalEntityData': legalEntityData,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print(
        '🔍 Create legal entity with user edge function response status: ${response.statusCode}',
      );
      print(
        '🔍 Create legal entity with user edge function response body: ${response.body}',
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        print(
          '❌ Create legal entity with user edge function error: $errorData',
        );
        throw Exception(
          errorData['message'] ?? 'Failed to create user and legal entity',
        );
      }
    } catch (e) {
      print('❌ Create legal entity with user edge function call error: $e');
      rethrow;
    }
  }
}
