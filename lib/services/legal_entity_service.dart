import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class LegalEntityService {
  static const String _baseUrl = AppConfig.supabaseUrl;
  static const String _apiKey = AppConfig.supabaseAnonKey;

  // Ottiene le legal entities per un utente
  Future<List<LegalEntityInfo>> getLegalEntitiesByUser(String userId) async {
    try {
      print('🔍 Getting legal entities for user: $userId');

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/functions/v1/get-legal-entities-by-user?id_user=$userId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Origin': 'http://localhost:8080',
        },
      );

      print(
        '📊 Legal entities response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true) {
          final legalEntitiesData = data['data'] as List<dynamic>? ?? [];
          return legalEntitiesData
              .map((item) => LegalEntityInfo.fromJson(item))
              .toList();
        } else {
          print('❌ Error in response: ${data['error']}');
          return [];
        }
      } else {
        print(
          '❌ Error getting legal entities: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('❌ Error getting legal entities: $e');
      return [];
    }
  }

  // Ottiene una mappa di ID -> Nome per le legal entities
  Future<Map<String, String>> getLegalEntityNamesMap(
    List<String> legalEntityIds,
  ) async {
    try {
      print('🔍 Getting legal entity names for IDs: $legalEntityIds');

      // Per ora, restituisco una mappa vuota
      // In futuro si potrebbe creare una Edge Function specifica per questo
      return {};
    } catch (e) {
      print('❌ Error getting legal entity names: $e');
      return {};
    }
  }
}

class LegalEntityInfo {
  final String idLegalEntity;
  final String? legalName;
  final String? identifierCode;
  final String? status;

  LegalEntityInfo({
    required this.idLegalEntity,
    this.legalName,
    this.identifierCode,
    this.status,
  });

  factory LegalEntityInfo.fromJson(Map<String, dynamic> json) {
    return LegalEntityInfo(
      idLegalEntity: json['id_legal_entity'] ?? '',
      legalName: json['legal_name'],
      identifierCode: json['identifier_code'],
      status: json['status'],
    );
  }

  String get displayName {
    if (legalName?.isNotEmpty == true) {
      return legalName!;
    } else if (identifierCode?.isNotEmpty == true) {
      return identifierCode!;
    } else {
      return 'Legal Entity ${idLegalEntity.substring(0, 8)}...';
    }
  }
}
