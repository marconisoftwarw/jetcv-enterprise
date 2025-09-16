import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';

class CertificationMediaService {
  static const String _baseUrl = AppConfig.supabaseUrl;
  static const String _apiKey = AppConfig.supabaseAnonKey;

  static Map<String, String> get _headers => {
    'apikey': _apiKey,
    'Authorization': 'Bearer $_apiKey',
    'Content-Type': 'application/json',
  };

  /// Upload media files to certification using multipart/form-data
  static Future<Map<String, dynamic>?> uploadMedia({
    required String certificationId,
    required List<XFile> mediaFiles,
    String? acquisitionType,
    String? capturedAt,
    String? idLocation,
    String? description,
    String? fileTypeOverride,
  }) async {
    return await uploadMediaFromXFiles(
      certificationId: certificationId,
      mediaFiles: mediaFiles,
      acquisitionType: acquisitionType,
      capturedAt: capturedAt,
      idLocation: idLocation,
      description: description,
      fileTypeOverride: fileTypeOverride,
    );
  }

  /// Upload media files using XFile objects with multipart/form-data
  static Future<Map<String, dynamic>?> uploadMediaFromXFiles({
    required String certificationId,
    required List<XFile> mediaFiles,
    String? acquisitionType,
    String? capturedAt,
    String? idLocation,
    String? description,
    String? fileTypeOverride,
  }) async {
    try {
      print('📸 Starting media upload for certification: $certificationId');
      print('📁 Files to upload: ${mediaFiles.length}');

      // Crea una richiesta multipart
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/functions/v1/certifications/media'),
      );

      // Aggiungi gli headers
      request.headers.addAll(_headers);

      // Aggiungi i parametri del form
      request.fields['id_certification'] = certificationId;
      request.fields['acquisition_type'] = acquisitionType ?? 'deferred';
      request.fields['return_signed_url'] = 'true'; // Per ottenere URL firmati

      if (capturedAt != null) {
        request.fields['captured_at'] = capturedAt;
      }
      if (idLocation != null) {
        request.fields['id_location'] = idLocation;
      }
      if (description != null) {
        request.fields['description'] = description;
      }
      if (fileTypeOverride != null) {
        request.fields['file_type'] = fileTypeOverride;
      }

      // Aggiungi i file
      for (int i = 0; i < mediaFiles.length; i++) {
        final xFile = mediaFiles[i];

        try {
          final fileBytes = await xFile.readAsBytes();

          // Determina il content type del file
          String contentType = 'application/octet-stream';
          String fileName = 'file_${DateTime.now().millisecondsSinceEpoch}';

          // Usa il nome del file da XFile
          if (xFile.name.isNotEmpty) {
            fileName = xFile.name;
          }

          // Determina il content type dal nome del file o dal mime type di XFile
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
            '📎 Added file: $fileName (${fileBytes.length} bytes, $contentType)',
          );
        } catch (fileError) {
          print('❌ Error reading file ${i}: $fileError');
          // Continua con gli altri file
          continue;
        }
      }

      if (request.files.isEmpty) {
        print('❌ No valid files to upload');
        return null;
      }

      print('🚀 Sending multipart request...');
      print('🌐 URL: ${request.url}');
      print('🔑 Headers: ${request.headers}');
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
          '✅ Media uploaded successfully: ${result['data']?.length ?? 0} files',
        );
        return result;
      } else {
        print(
          '❌ Error uploading media: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Exception uploading media: $e');
      return null;
    }
  }

  /// Upload a single media file
  static Future<Map<String, dynamic>?> uploadSingleMedia({
    required String certificationId,
    required XFile mediaFile,
    String? acquisitionType,
    String? capturedAt,
    String? idLocation,
    String? description,
    String? fileTypeOverride,
  }) async {
    return await uploadMedia(
      certificationId: certificationId,
      mediaFiles: [mediaFile],
      acquisitionType: acquisitionType,
      capturedAt: capturedAt,
      idLocation: idLocation,
      description: description,
      fileTypeOverride: fileTypeOverride,
    );
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
