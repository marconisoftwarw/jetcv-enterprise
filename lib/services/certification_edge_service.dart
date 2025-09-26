import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class CertificationEdgeService {
  static const String _baseUrl =
      '${AppConfig.supabaseUrl}/functions/v1/certification-crud';

  // Headers per le chiamate alla Edge Function
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AppConfig.supabaseAnonKey}',
    'apikey': AppConfig.supabaseAnonKey,
  };

  /// Test della connessione alla Edge Function
  static Future<bool> testConnection() async {
    try {
      print('🧪 Testing Edge Function connection...');
      print('🌐 URL: $_baseUrl');
      print('🔑 Headers: $_headers');

      final response = await http.get(Uri.parse(_baseUrl), headers: _headers);

      print('📡 Test Response Status: ${response.statusCode}');
      print('📄 Test Response Body: ${response.body}');

      return response.statusCode == 200 ||
          response.statusCode ==
              405; // 405 = Method Not Allowed is OK for GET on POST endpoint
    } catch (e) {
      print('💥 Test connection failed: $e');
      return false;
    }
  }

  // ========================= CERTIFICATION CRUD =========================

  /// Ottiene una singola certificazione con i suoi media
  static Future<Map<String, dynamic>?> getCertification(String id) async {
    try {
      final url = '$_baseUrl?id=$id';
      print('🔍 GET Certification: $url');
      print('🔑 Headers: $_headers');

      final response = await http.get(Uri.parse(url), headers: _headers);

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        print(
          '❌ Error getting certification: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('💥 Exception getting certification: $e');
      return null;
    }
  }

  /// Ottiene la lista delle certificazioni con filtri opzionali
  static Future<Map<String, dynamic>?> getCertifications({
    String? status,
    String? idLegalEntity,
    String? idCertifier,
    String? idLocation,
    String? serialNumber,
    String? idUser,
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
      if (idUser != null) queryParams['id_user'] = idUser;

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);

      print('🔍 GET Certifications: $uri');
      print('🔑 Headers: $_headers');
      print('📋 Query Params: $queryParams');

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
      print('💥 Exception getting certifications: $e');
      return null;
    }
  }

  /// Crea una nuova certificazione con media opzionali
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
        if (media != null) 'media': media,
        if (esitoValue != null) 'esito_value': esitoValue,
        if (titoloValue != null) 'titolo_value': titoloValue,
      };

      print('📤 Sending POST request to: $_baseUrl');
      print('📤 Headers: $_headers');
      print('📤 Body: ${json.encode(body)}');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: json.encode(body),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        print(
          'Error creating certification: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Exception creating certification: $e');
      return null;
    }
  }

  /// Aggiorna una certificazione esistente
  static Future<Map<String, dynamic>?> updateCertification(
    String id, {
    String? status,
    String? sentAt,
    String? draftAt,
    String? closedAt,
    int? nUsers,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (status != null) body['status'] = status;
      if (sentAt != null) body['sent_at'] = sentAt;
      if (draftAt != null) body['draft_at'] = draftAt;
      if (closedAt != null) body['closed_at'] = closedAt;
      if (nUsers != null) body['n_users'] = nUsers;

      final response = await http.patch(
        Uri.parse('$_baseUrl?id=$id'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        print(
          'Error updating certification: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Exception updating certification: $e');
      return null;
    }
  }

  /// Elimina una certificazione
  static Future<bool> deleteCertification(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl?id=$id'),
        headers: _headers,
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Exception deleting certification: $e');
      return false;
    }
  }

  // ========================= MEDIA CRUD =========================

  /// Ottiene i media di una certificazione
  static Future<List<Map<String, dynamic>>> getCertificationMedia(
    String certificationId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/media?certification_id=$certificationId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        print(
          'Error getting certification media: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Exception getting certification media: $e');
      return [];
    }
  }

  /// Ottiene un singolo media
  static Future<Map<String, dynamic>?> getMedia(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/media?id=$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']?.isNotEmpty == true ? data['data'][0] : null;
      } else {
        print('Error getting media: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception getting media: $e');
      return null;
    }
  }

  /// Aggiunge media a una certificazione
  static Future<List<Map<String, dynamic>>> addCertificationMedia({
    required String certificationId,
    required List<Map<String, dynamic>> media,
  }) async {
    try {
      final body = {'id_certification': certificationId, 'media': media};

      final response = await http.post(
        Uri.parse('$_baseUrl/media'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        print(
          'Error adding certification media: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Exception adding certification media: $e');
      return [];
    }
  }

  /// Aggiorna un media esistente
  static Future<Map<String, dynamic>?> updateMedia(
    String id, {
    String? name,
    String? description,
    String? acquisitionType,
    String? capturedAt,
    String? fileType,
    String? idLocation,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (acquisitionType != null) body['acquisition_type'] = acquisitionType;
      if (capturedAt != null) body['captured_at'] = capturedAt;
      if (fileType != null) body['file_type'] = fileType;
      if (idLocation != null) body['id_location'] = idLocation;

      final response = await http.patch(
        Uri.parse('$_baseUrl/media?id=$id'),
        headers: _headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        print(
          'Error updating media: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Exception updating media: $e');
      return null;
    }
  }

  /// Elimina un media
  static Future<bool> deleteMedia(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/media?id=$id'),
        headers: _headers,
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Exception deleting media: $e');
      return false;
    }
  }

  /// Elimina multiple media
  static Future<bool> deleteMultipleMedia(List<String> ids) async {
    try {
      final body = {'ids': ids};

      final response = await http.delete(
        Uri.parse('$_baseUrl/media'),
        headers: _headers,
        body: json.encode(body),
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Exception deleting multiple media: $e');
      return false;
    }
  }
}
