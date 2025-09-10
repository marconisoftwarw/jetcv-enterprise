import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class LegalEntityService {
  static Future<List<Map<String, dynamic>>?> getLegalEntities() async {
    try {
      print('🔍 Fetching legal entities from Edge Function...');
      
      // Get the current user's access token
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        print('❌ No active session found');
        return null;
      }
      
      final url = '${AppConfig.supabaseUrl}/functions/v1/get-legal-entities';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true && data['data'] != null) {
          print('✅ Successfully fetched ${data['count']} legal entities');
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          print('❌ Error in response: ${data['message']}');
          return null;
        }
      } else {
        print('❌ HTTP error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching legal entities: $e');
      return null;
    }
  }
  
  static Future<String?> getLegalEntityName(String legalEntityId) async {
    try {
      final legalEntities = await getLegalEntities();
      if (legalEntities != null) {
        final legalEntity = legalEntities.firstWhere(
          (entity) => entity['id_legal_entity'] == legalEntityId,
          orElse: () => {},
        );
        return legalEntity['legal_name'] as String?;
      }
      return null;
    } catch (e) {
      print('❌ Error getting legal entity name: $e');
      return null;
    }
  }
}
