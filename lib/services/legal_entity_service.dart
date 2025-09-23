import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/legal_entity.dart';

class LegalEntityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Ottiene le legal entity associate a un utente tramite l'edge function get-legal-of-user
  Future<List<LegalEntity>> getLegalEntitiesByUser(String userId) async {
    try {
      print('LegalEntityService: Getting legal entities for user: $userId');

      final response = await _supabase.functions.invoke(
        'get-legal-of-user',
        body: {'id_user': userId},
      );

      print(
        'LegalEntityService: Edge function response status: ${response.status}',
      );
      print(
        'LegalEntityService: Edge function response data: ${response.data}',
      );

      if (response.status != 200) {
        print('LegalEntityService: Error response: ${response.data}');
        return [];
      }

      final data = response.data;
      if (data == null || data['ok'] != true) {
        print('LegalEntityService: Invalid response format: $data');
        return [];
      }

      final List<dynamic> legalEntitiesData =
          data['data'] as List<dynamic>? ?? [];
      print(
        'LegalEntityService: Found ${legalEntitiesData.length} legal entities',
      );

      return legalEntitiesData
          .map((json) => LegalEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('LegalEntityService: Error getting legal entities by user: $e');
      return [];
    }
  }
}
