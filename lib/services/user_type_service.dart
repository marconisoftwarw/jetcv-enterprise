import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'supabase_service.dart';

class UserTypeService {
  /// Chiama l'edge function per ottenere il tipo di utente
  static Future<String?> getUserType(String email) async {
    final url = '${AppConfig.supabaseUrl}/functions/v1/get-type-user';
    print('🔍 Calling edge function: $url');
    print('📧 Email: $email');

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
              'apikey': AppConfig.supabaseAnonKey,
              'x-client-info': 'jetcv-enterprise',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('❌ UserTypeService: Request timeout after 10 seconds');
              throw Exception('Request timeout');
            },
          );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');
      print('📋 Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ UserTypeService: User type received: ${data['type']}');
        print('✅ UserTypeService: Full response data: $data');
        return data['type'] as String?;
      } else if (response.statusCode == 204) {
        // CORS preflight response
        print('🛡️ UserTypeService: CORS preflight response received');
        return null;
      } else if (response.statusCode == 404) {
        // Utente non trovato, restituisce tipo di default
        print(
          '⚠️ UserTypeService: User not found, returning default type: user',
        );
        return 'user';
      } else if (response.statusCode == 405) {
        // Method not allowed - potrebbe essere un problema CORS
        print(
          '❌ UserTypeService: Method not allowed (405) - possible CORS issue',
        );
        return null;
      } else if (response.statusCode == 500) {
        // Server error
        print('❌ UserTypeService: Server error (500) - ${response.body}');
        return null;
      } else {
        print(
          '❌ UserTypeService: Error getting user type: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('❌ UserTypeService: Exception getting user type: $e');
      if (e.toString().contains('CORS')) {
        print('❌ UserTypeService: CORS error detected');
      } else if (e.toString().contains('timeout')) {
        print('❌ UserTypeService: Timeout error detected');
      } else if (e.toString().contains('SocketException')) {
        print('❌ UserTypeService: Network error detected');
      }
      return null;
    }
  }

  /// Metodo alternativo per ottenere il tipo utente direttamente dal database
  /// Usato come fallback quando l'edge function non funziona a causa di CORS
  static Future<String?> getUserTypeFromDatabase(String email) async {
    try {
      print('🔍 UserTypeService: Getting user type from database for: $email');

      final supabaseService = SupabaseService();
      final user = await supabaseService.getUserByEmail(email);

      if (user != null) {
        print('✅ UserTypeService: User found in database, type: ${user.type}');
        return user.type.toString().split('.').last; // Convert enum to string
      } else {
        print('⚠️ UserTypeService: User not found in database');
        return 'user'; // Default type
      }
    } catch (e) {
      print('❌ UserTypeService: Error getting user type from database: $e');
      return 'user'; // Default type
    }
  }

  /// Metodo principale che prova prima l'edge function, poi il database
  static Future<String?> getUserTypeWithFallback(String email) async {
    // Prima prova l'edge function
    final edgeResult = await getUserType(email);
    if (edgeResult != null) {
      return edgeResult;
    }

    // Se l'edge function fallisce, usa il database
    print('🔄 UserTypeService: Edge function failed, trying database...');
    return await getUserTypeFromDatabase(email);
  }
}

enum AppUserType { admin, legalEntity, certifier, user }

extension UserTypeExtension on String {
  AppUserType get toUserType {
    switch (this.toLowerCase()) {
      case 'admin':
      case 'administrator':
        return AppUserType.admin;
      case 'legal_entity':
      case 'legalentity':
        return AppUserType.legalEntity;
      case 'certifier':
      case 'certificatore':
        return AppUserType.certifier;
      default:
        return AppUserType.user;
    }
  }
}
