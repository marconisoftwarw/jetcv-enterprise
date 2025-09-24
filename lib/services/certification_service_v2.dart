import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class CertificationServiceV2 {
  static const String _baseUrl = AppConfig.supabaseUrl;
  static const String _apiKey = AppConfig.supabaseAnonKey;

  // Headers per le chiamate alla Edge Function
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
    'apikey': _apiKey,
  };

  /// Test della connessione alla Edge Function
  static Future<bool> testConnection() async {
    try {
      print('🧪 Testing certifications Edge Function connection...');
      print('🌐 URL: $_baseUrl/functions/v1/certification-crud');
      print('🔑 Headers: $_headers');

      final response = await http.get(
        Uri.parse('$_baseUrl/functions/v1/certification-crud'),
        headers: _headers,
      );

      print('📡 Test Response Status: ${response.statusCode}');
      print('📄 Test Response Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('💥 Test connection failed: $e');
      return false;
    }
  }

  /// Ottiene le certificazioni con filtri opzionali
  static Future<Map<String, dynamic>?> getCertifications({
    String? status,
    String? idLegalEntity,
    String? idCertifier,
    String? idLocation,
    String? serialNumber,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (idLegalEntity != null) queryParams['id_legal_entity'] = idLegalEntity;
      if (idCertifier != null) queryParams['id_certifier'] = idCertifier;
      if (idLocation != null) queryParams['id_location'] = idLocation;
      if (serialNumber != null) queryParams['serial_number'] = serialNumber;

      final uri = Uri.parse(
        '$_baseUrl/functions/v1/certification-crud',
      ).replace(queryParameters: queryParams);

      print('🔍 GET Certifications: $uri');
      print('🔑 Headers: $_headers');

      final response = await http.get(uri, headers: _headers);

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
          '❌ Error getting certifications: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Exception getting certifications: $e');
      return null;
    }
  }

  /// Crea una nuova certificazione
  static Future<Map<String, dynamic>?> createCertification({
    required String idCertifier,
    required String idLegalEntity,
    required String idLocation,
    required int nUsers,
    required String idCertificationCategory,
    String? status,
    String? sentAt,
    String? draftAt,
    String? closedAt,
    List<Map<String, dynamic>>? media,
    List<Map<String, dynamic>>? certificationUsers,
    String? esitoValue,
    String? titoloValue,
  }) async {
    try {
      print('🔍 Creating certification with params:');
      print('  - idCertifier: $idCertifier');
      print('  - idLegalEntity: $idLegalEntity');
      print('  - idLocation: $idLocation');
      print('  - nUsers: $nUsers');
      print('  - idCertificationCategory: $idCertificationCategory');
      print('  - status: $status');
      print('  - sentAt: $sentAt');
      print('  - draftAt: $draftAt');

      final body = {
        'id_certifier': idCertifier,
        'id_legal_entity': idLegalEntity,
        'id_location': idLocation,
        'n_users': nUsers,
        'id_certification_category': idCertificationCategory,
        if (status != null) 'status': status,
        if (sentAt != null) 'sent_at': sentAt,
        if (draftAt != null) 'draft_at': draftAt,
        if (closedAt != null) 'closed_at': closedAt,
        if (media != null && media.isNotEmpty) 'media': media,
        if (certificationUsers != null && certificationUsers.isNotEmpty)
          'certification_users': certificationUsers,
        if (esitoValue != null) 'esito_value': esitoValue,
        if (titoloValue != null) 'titolo_value': titoloValue,
      };

      print('🚀 POST Certification: $_baseUrl/functions/v1/certification-crud');
      print('🔑 Headers: $_headers');
      print('📄 Body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/functions/v1/certification-crud'),
        headers: _headers,
        body: json.encode(body),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print(
          '❌ Error creating certification: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Exception creating certification: $e');
      return null;
    }
  }

  /// Ottiene una singola certificazione con i suoi media
  static Future<Map<String, dynamic>?> getCertification(String id) async {
    try {
      final url = '$_baseUrl/functions/v1/certification-crud?id=$id';
      print('🔍 GET Certification: $url');
      print('🔑 Headers: $_headers');

      final response = await http.get(Uri.parse(url), headers: _headers);

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
          '❌ Error getting certification: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Exception getting certification: $e');
      return null;
    }
  }

  /// Aggiorna una certificazione
  static Future<Map<String, dynamic>?> updateCertification({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    try {
      print('🔍 Updating certification: $id');
      print('📄 Updates: ${json.encode(updates)}');

      final response = await http.patch(
        Uri.parse('$_baseUrl/functions/v1/certification-crud?id=$id'),
        headers: _headers,
        body: json.encode(updates),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
          '❌ Error updating certification: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Exception updating certification: $e');
      return null;
    }
  }

  /// Elimina una certificazione
  static Future<bool> deleteCertification(String id) async {
    try {
      print('🔍 Deleting certification: $id');

      final response = await http.delete(
        Uri.parse('$_baseUrl/functions/v1/certification-crud?id=$id'),
        headers: _headers,
      );

      print('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 204) {
        print('✅ Certification deleted successfully');
        return true;
      } else {
        print(
          '❌ Error deleting certification: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Exception deleting certification: $e');
      return false;
    }
  }
}
