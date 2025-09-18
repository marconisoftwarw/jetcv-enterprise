import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';

class CertificationUploadService {
  static const String _baseUrl = AppConfig.supabaseUrl;
  static const String _apiKey = AppConfig.supabaseAnonKey;

  static Map<String, String> get _headers => {
    'apikey': _apiKey,
    'Authorization': 'Bearer $_apiKey',
  };

  /// Create certification with media files in a single multipart request
  static Future<Map<String, dynamic>?> createCertificationWithMedia({
    required String idCertifier,
    required String idLegalEntity,
    required String idLocation,
    required int nUsers,
    required String idCertificationCategory,
    String? status,
    String? sentAt,
    String? draftAt,
    String? closedAt,
    List<Map<String, dynamic>>? certificationUsers,
    List<XFile>? mediaFiles,
    String? acquisitionType,
    String? capturedAt,
    String? description,
    String? fileTypeOverride,
  }) async {
    try {
      print('🚀 Creating certification with media upload...');
      print('📋 Certification data:');
      print('  - Certifier ID: $idCertifier');
      print('  - Legal Entity ID: $idLegalEntity');
      print('  - Location ID: $idLocation');
      print('  - N Users: $nUsers');
      print('  - Category ID: $idCertificationCategory');
      print('  - Status: ${status ?? "draft"}');
      print('  - Media files: ${mediaFiles?.length ?? 0}');

      // Se non ci sono media files, usa JSON mode
      if (mediaFiles == null || mediaFiles.isEmpty) {
        // Se non ci sono media, usa il servizio standard (certifications-compose)
        return await _createCertificationStandardMode(
          idCertifier: idCertifier,
          idLegalEntity: idLegalEntity,
          idLocation: idLocation,
          nUsers: nUsers,
          idCertificationCategory: idCertificationCategory,
          status: status,
          sentAt: sentAt,
          draftAt: draftAt,
          closedAt: closedAt,
          certificationUsers: certificationUsers,
        );
      }

      // Crea una richiesta multipart
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/functions/v1/create-media-certification'),
      );

      // Aggiungi gli headers (senza Content-Type per multipart)
      request.headers.addAll({
        'apikey': _apiKey,
        'Authorization': 'Bearer $_apiKey',
      });

      // Aggiungi i campi richiesti per certifications-compose
      request.fields['id_certifier'] = idCertifier;
      request.fields['id_legal_entity'] = idLegalEntity;
      request.fields['id_location'] = idLocation;
      request.fields['n_users'] = nUsers.toString();
      request.fields['id_certification_category'] = idCertificationCategory;

      // Aggiungi i campi opzionali
      if (sentAt != null) {
        request.fields['sent_at'] = sentAt;
      }
      if (draftAt != null) {
        request.fields['draft_at'] = draftAt;
      }
      if (closedAt != null) {
        request.fields['closed_at'] = closedAt;
      }
      if (description != null) {
        request.fields['description'] = description;
      }
      if (acquisitionType != null) {
        request.fields['acquisition_type'] = acquisitionType;
      }
      if (capturedAt != null) {
        request.fields['captured_at'] = capturedAt;
      }
      if (fileTypeOverride != null) {
        request.fields['file_type'] = fileTypeOverride;
      }
      request.fields['return_signed_url'] = 'true';

      // Aggiungi i certification_users se presenti
      if (certificationUsers != null && certificationUsers.isNotEmpty) {
        request.fields['users_json'] = json.encode(certificationUsers);
      }

      // Aggiungi i file media
      for (int i = 0; i < mediaFiles.length; i++) {
        final xFile = mediaFiles[i];

        try {
          final fileBytes = await xFile.readAsBytes();

          // Determina il content type e nome del file
          String contentType = 'application/octet-stream';
          String fileName = 'file_${DateTime.now().millisecondsSinceEpoch}_$i';

          if (xFile.name.isNotEmpty) {
            fileName = xFile.name;
          }

          if (xFile.mimeType != null && xFile.mimeType!.isNotEmpty) {
            contentType = xFile.mimeType!;
          } else {
            contentType = _getMimeTypeFromPath(fileName);
          }

          // Crea il multipart file
          final multipartFile = http.MultipartFile.fromBytes(
            'files', // Nome del campo per i file
            fileBytes,
            filename: fileName,
            contentType: MediaType.parse(contentType),
          );

          request.files.add(multipartFile);
          print(
            '📎 Added media file: $fileName (${fileBytes.length} bytes, $contentType)',
          );
        } catch (fileError) {
          print('❌ Error reading media file ${i}: $fileError');
          continue;
        }
      }

      print('🚀 Sending certification creation request...');
      print('🌐 URL: ${request.url}');
      print('📋 Fields: ${request.fields}');
      print('📁 Files: ${request.files.length}');

      // Invia la richiesta
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final result = json.decode(response.body);
        print(
          '✅ Certification created successfully with media: ${result['data']?['id_certification']}',
        );
        return result;
      } else {
        print(
          '❌ Error creating certification: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Exception creating certification with media: $e');
      return null;
    }
  }

  /// Create certification without media (standard mode using certifications-compose)
  static Future<Map<String, dynamic>?> _createCertificationStandardMode({
    required String idCertifier,
    required String idLegalEntity,
    required String idLocation,
    required int nUsers,
    required String idCertificationCategory,
    String? status,
    String? sentAt,
    String? draftAt,
    String? closedAt,
    List<Map<String, dynamic>>? certificationUsers,
  }) async {
    try {
      print(
        '🚀 Creating certification (standard mode with certification-crud)...',
      );

      // Prepara il body della richiesta per certifications-compose (JSON mode)
      final requestBody = {
        'certification': {
          'id_certifier': idCertifier,
          'id_legal_entity': idLegalEntity,
          'id_location': idLocation,
          'n_users': nUsers,
          'id_certification_category': idCertificationCategory,
        },
        'users': certificationUsers ?? [],
        'media': <Map<String, dynamic>>[],
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/functions/v1/certifications-compose'),
        headers: _headers,
        body: json.encode(requestBody),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final result = json.decode(response.body);
        print(
          '✅ Certification created successfully: ${result['data']?['id_certification']}',
        );
        return result;
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

  /// Helper method to determine MIME type from file path
  static String _getMimeTypeFromPath(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
