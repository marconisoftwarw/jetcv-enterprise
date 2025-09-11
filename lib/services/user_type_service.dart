import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class UserTypeService {
  /// Chiama l'edge function per ottenere il tipo di utente
  static Future<String?> getUserType(String email) async {
    final url = '${AppConfig.supabaseUrl}/functions/v1/get-type-user';
    print('🔍 Calling edge function: $url');
    print('📧 Email: $email');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
        },
        body: jsonEncode({'email': email}),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ User type received: ${data['type']}');
        return data['type'] as String?;
      } else if (response.statusCode == 404) {
        // Utente non trovato, restituisce tipo di default
        print('⚠️ User not found, returning default type: user');
        return 'user';
      } else {
        print(
          '❌ Error getting user type: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Exception getting user type: $e');
      return null;
    }
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
