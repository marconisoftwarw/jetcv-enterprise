import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class DefaultIdsService {
  static const String _baseUrl = '${AppConfig.supabaseUrl}/rest/v1';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'apikey': AppConfig.supabaseAnonKey,
    'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
  };

  /// Ottiene o crea un ID di default per un certifier
  static Future<String?> getDefaultCertifierId() async {
    try {
      print('🔍 Getting default certifier ID...');
      print('🔍 URL: $_baseUrl/certifier?limit=1');
      print('🔍 Headers: $_headers');

      // Prima prova a ottenere un certifier esistente
      final response = await http.get(
        Uri.parse('$_baseUrl/certifier?limit=1'),
        headers: _headers,
      );

      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final certifierId = data[0]['id_certifier'] as String?;
          print('✅ Found existing certifier: $certifierId');
          return certifierId;
        }
      }

      // Se non ci sono certifier, crea uno di default
      print('📝 No certifiers found, creating default...');
      return await _createDefaultCertifier();
    } catch (e) {
      print('❌ Error getting default certifier ID: $e');
      return null;
    }
  }

  /// Ottiene o crea un ID di default per una legal entity
  static Future<String?> getDefaultLegalEntityId() async {
    try {
      print('🔍 Getting default legal entity ID...');

      // Prima prova a ottenere una legal entity esistente
      final response = await http.get(
        Uri.parse('$_baseUrl/legal_entity?limit=1'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final legalEntityId = data[0]['id_legal_entity'] as String?;
          print('✅ Found existing legal entity: $legalEntityId');
          return legalEntityId;
        }
      }

      // Se non ci sono legal entities, crea una di default
      print('📝 No legal entities found, creating default...');
      return await _createDefaultLegalEntity();
    } catch (e) {
      print('❌ Error getting default legal entity ID: $e');
      return null;
    }
  }

  /// Ottiene o crea un ID di default per una location
  static Future<String?> getDefaultLocationId() async {
    try {
      print('🔍 Getting default location ID...');

      // Prima prova a ottenere una location esistente
      final response = await http.get(
        Uri.parse('$_baseUrl/location?limit=1'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final locationId = data[0]['id_location'] as String?;
          print('✅ Found existing location: $locationId');
          return locationId;
        }
      }

      // Se non ci sono locations, crea una di default
      print('📝 No locations found, creating default...');
      return await _createDefaultLocation();
    } catch (e) {
      print('❌ Error getting default location ID: $e');
      return null;
    }
  }

  /// Crea un certifier di default
  static Future<String?> _createDefaultCertifier() async {
    try {
      final data = {
        'id_certifier_hash': 'default-certifier-hash',
        'id_legal_entity':
            await getDefaultLegalEntityId() ??
            '550e8400-e29b-41d4-a716-446655440002',
        'id_user': null,
        'active': true,
        'role': 'default_certifier',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/certifier'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final result = json.decode(response.body);
        final certifierId = result['id_certifier'] as String?;
        print('✅ Created default certifier: $certifierId');
        return certifierId;
      } else {
        print(
          '❌ Error creating default certifier: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Exception creating default certifier: $e');
      return null;
    }
  }

  /// Crea una legal entity di default
  static Future<String?> _createDefaultLegalEntity() async {
    try {
      final data = {
        'id_legal_entity_hash': 'default-legal-entity-hash',
        'legal_name': 'Default Legal Entity',
        'identifier_code': 'DEFAULT001',
        'operational_address': 'Default Address',
        'operational_city': 'Default City',
        'operational_postal_code': '00000',
        'operational_state': 'Default State',
        'operational_country': 'IT',
        'headquarter_address': 'Default HQ Address',
        'headquarter_city': 'Default HQ City',
        'headquarter_postal_code': '00000',
        'headquarter_state': 'Default HQ State',
        'headquarter_country': 'IT',
        'legal_rapresentative': 'Default Representative',
        'email': 'default@example.com',
        'phone': '+39000000000',
        'pec': 'default@pec.example.com',
        'website': 'https://default.example.com',
        'status': 'approved',
        'created_by_id_user': '550e8400-e29b-41d4-a716-446655440001',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/legal_entity'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final result = json.decode(response.body);
        final legalEntityId = result['id_legal_entity'] as String?;
        print('✅ Created default legal entity: $legalEntityId');
        return legalEntityId;
      } else {
        print(
          '❌ Error creating default legal entity: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Exception creating default legal entity: $e');
      return null;
    }
  }

  /// Crea una location di default
  static Future<String?> _createDefaultLocation() async {
    try {
      final data = {
        'id_user': '550e8400-e29b-41d4-a716-446655440001',
        'aquired_at': DateTime.now().toIso8601String(),
        'latitude': 41.9028,
        'longitude': 12.4964,
        'accuracy_m': 10.0,
        'is_moked': false,
        'altitude': 50.0,
        'altitude_accuracy_m': 5.0,
        'name': 'Default Location',
        'street': 'Default Street',
        'locality': 'Default Locality',
        'sub_locality': 'Default Sub Locality',
        'administrative_area': 'Default Administrative Area',
        'sub_administrative_area': 'Default Sub Administrative Area',
        'postal_code': '00000',
        'iso_country_code': 'IT',
        'country': 'Italy',
        'thoroughfare': 'Default Thoroughfare',
        'sub_thoroughfare': 'Default Sub Thoroughfare',
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/location'),
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final result = json.decode(response.body);
        final locationId = result['id_location'] as String?;
        print('✅ Created default location: $locationId');
        return locationId;
      } else {
        print(
          '❌ Error creating default location: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Exception creating default location: $e');
      return null;
    }
  }
}
