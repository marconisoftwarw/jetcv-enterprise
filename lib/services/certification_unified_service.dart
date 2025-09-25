import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/certification.dart';
import '../models/media_item.dart';

/// Servizio unificato per la creazione di certificazioni con OTP e media
class CertificationUnifiedService {
  static const String _baseUrl = AppConfig.supabaseUrl;
  static const String _apiKey = AppConfig.supabaseAnonKey;

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'apikey': _apiKey,
    'Authorization': 'Bearer $_apiKey',
  };

  /// Crea una certificazione completa con utenti, OTP e media
  static Future<Map<String, dynamic>?> createCertificationUnified({
    required String idCertifier,
    required String idLegalEntity,
    required String idLocation,
    required int nUsers,
    required String idCertificationCategory,
    String? status,
    String? draftAt,
    String? sentAt,
    String? closedAt,
    int? durationH,
    String? startTimestamp,
    String? endTimestamp,
    List<Map<String, dynamic>>? certificationUsers,
    List<MediaItem>? mediaFiles,
    List<Map<String, dynamic>>? mediaMetadata,
    List<Map<String, dynamic>>? certificationInformationValues,
  }) async {
    try {
      print(
        '🚀 CertificationUnifiedService: Creating unified certification...',
      );
      print('📝 Certifier: $idCertifier');
      print('📝 Legal Entity: $idLegalEntity');
      print('📝 Location: $idLocation');
      print('📝 Category: $idCertificationCategory');
      print('📝 Users: ${certificationUsers?.length ?? 0}');
      print('📝 Media: ${mediaFiles?.length ?? 0}');
      print(
        '📝 Information Values: ${certificationInformationValues?.length ?? 0}',
      );

      // Prepara i dati della certificazione
      final certificationData = {
        'id_certifier': idCertifier,
        'id_legal_entity': idLegalEntity,
        'id_location': idLocation,
        'n_users': nUsers,
        'id_certification_category': idCertificationCategory,
        'status': status ?? 'sent',
        'draft_at': draftAt ?? DateTime.now().toIso8601String(),
        'sent_at': sentAt ?? DateTime.now().toIso8601String(),
        'closed_at': closedAt,
        'duration_h': durationH,
        'start_timestamp': startTimestamp,
        'end_timestamp': endTimestamp,
      };

      // Prepara i dati degli utenti
      final usersData = certificationUsers ?? [];

      // Prepara i dati dei media
      final mediaData = <Map<String, dynamic>>[];
      if (mediaFiles != null) {
        for (int i = 0; i < mediaFiles.length; i++) {
          final media = mediaFiles[i];
          final metadata = i < (mediaMetadata?.length ?? 0)
              ? mediaMetadata![i]
              : {};

          // Converti il file in base64 se presente
          String? fileDataBase64;
          try {
            final bytes = await media.file.readAsBytes();
            fileDataBase64 = base64Encode(bytes);
          } catch (e) {
            print('⚠️ Error reading file ${media.file.name}: $e');
          }

          mediaData.add({
            'id_media_hash': _generateMediaHash(),
            'name': media.file.name,
            'description': metadata['description'] ?? media.description,
            'acquisition_type': 'realtime', // Default value
            'captured_at': DateTime.now().toIso8601String(),
            'id_location': null, // Default value
            'file_type': _inferFileType(media.file.name, null),
            'file_data': fileDataBase64,
            'mime_type': _getMimeType(media.file.name),
            'title': metadata['title'] ?? media.title,
          });
        }
      }

      // Prepara i metadati dei media
      final mediaMetadataData = mediaMetadata ?? [];

      // Prepara i certification information values
      final certificationInformationValuesData =
          certificationInformationValues ?? [];

      // Prepara il payload completo
      final payload = {
        'certification': certificationData,
        'certification_users': usersData,
        'media': mediaData,
        'media_metadata': mediaMetadataData,
        'certification_information_values': certificationInformationValuesData,
      };

      print('📦 Payload prepared:');
      print('  - Certification: ${certificationData.keys.join(', ')}');
      print('  - Users: ${usersData.length}');
      print('  - Media: ${mediaData.length}');
      print('  - Media Metadata: ${mediaMetadataData.length}');
      print(
        '  - Certification Information Values: ${certificationInformationValuesData.length}',
      );

      // Chiama la Edge Function
      final response = await http.post(
        Uri.parse('$_baseUrl/functions/v1/create-certification-unified'),
        headers: _headers,
        body: json.encode(payload),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Certification created successfully via unified service');
        return data['data'];
      } else {
        final errorData = json.decode(response.body);
        print('❌ Error creating certification: ${errorData['error']}');
        throw Exception(
          'Failed to create certification: ${errorData['error']}',
        );
      }
    } catch (e) {
      print('❌ Error in createCertificationUnified: $e');
      rethrow;
    }
  }

  /// Genera un hash per il media
  static String _generateMediaHash() {
    return 'media_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }

  /// Infers file type from filename and mime type
  static String? _inferFileType(String? filename, String? mimeType) {
    if (mimeType != null) {
      if (mimeType.startsWith('image/')) return 'image';
      if (mimeType.startsWith('video/')) return 'video';
      if (mimeType.startsWith('audio/')) return 'audio';
      if (mimeType == 'application/pdf' ||
          mimeType.startsWith('application/msword') ||
          mimeType.startsWith('text/'))
        return 'document';
    }

    if (filename != null) {
      final ext = filename.toLowerCase().split('.').last;
      const imageExts = [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'avif',
        'heic',
        'bmp',
        'svg',
      ];
      const videoExts = ['mp4', 'mov', 'avi', 'mkv', 'webm', 'mpeg', 'mpg'];
      const audioExts = ['mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a'];
      const docExts = ['pdf', 'doc', 'docx', 'txt', 'rtf', 'csv'];

      if (imageExts.contains(ext)) return 'image';
      if (videoExts.contains(ext)) return 'video';
      if (audioExts.contains(ext)) return 'audio';
      if (docExts.contains(ext)) return 'document';
    }

    return null;
  }

  /// Gets MIME type from filename
  static String? _getMimeType(String? filename) {
    if (filename == null) return null;

    final ext = filename.toLowerCase().split('.').last;
    switch (ext) {
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
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}
