import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/supabase_service.dart';

class LegalEntityImageService {
  static const String _baseUrl = '${AppConfig.supabaseUrl}/functions/v1';
  final SupabaseService _supabaseService = SupabaseService();

  /// Uploads a logo picture for a legal entity using the edge function
  static Future<String?> uploadLegalEntityLogoPicture({
    required File imageFile,
    required String legalEntityId,
    String? filename,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/update-legal-entity-logo-picture');

      // Get access token from current session
      final session = SupabaseService().client.auth.currentSession;
      if (session?.accessToken == null) {
        throw Exception('No valid session found. User must be authenticated.');
      }

      final request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer ${session!.accessToken}',
        'apikey': AppConfig.supabaseAnonKey,
      });

      // Add form fields
      request.fields['id_legal_entity'] = legalEntityId;
      if (filename != null) {
        request.fields['filename'] = filename;
      }

      // Add file
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: filename ?? imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      print('🖼️ Uploading logo picture for legal entity: $legalEntityId');
      print('🖼️ File: ${imageFile.path} (${fileLength} bytes)');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🖼️ Logo upload response status: ${response.statusCode}');
      print('🖼️ Logo upload response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          print('✅ Logo uploaded successfully: ${data['publicUrl']}');
          return data['publicUrl'];
        } else {
          throw Exception(data['message'] ?? 'Logo upload failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Logo upload failed');
      }
    } catch (e) {
      print('❌ Error uploading logo picture: $e');
      rethrow;
    }
  }

  /// Uploads a company picture for a legal entity using the edge function
  static Future<String?> uploadLegalEntityCompanyPicture({
    required File imageFile,
    required String legalEntityId,
    String? filename,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/update-legal-entity-company-picture');

      // Get access token from current session
      final session = SupabaseService().client.auth.currentSession;
      if (session?.accessToken == null) {
        throw Exception('No valid session found. User must be authenticated.');
      }

      final request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer ${session!.accessToken}',
        'apikey': AppConfig.supabaseAnonKey,
      });

      // Add form fields
      request.fields['id_legal_entity'] = legalEntityId;
      if (filename != null) {
        request.fields['filename'] = filename;
      }

      // Add file
      final fileStream = http.ByteStream(imageFile.openRead());
      final fileLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: filename ?? imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      print('🏢 Uploading company picture for legal entity: $legalEntityId');
      print('🏢 File: ${imageFile.path} (${fileLength} bytes)');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print(
        '🏢 Company picture upload response status: ${response.statusCode}',
      );
      print('🏢 Company picture upload response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          print(
            '✅ Company picture uploaded successfully: ${data['publicUrl']}',
          );
          return data['publicUrl'];
        } else {
          throw Exception(data['message'] ?? 'Company picture upload failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Company picture upload failed',
        );
      }
    } catch (e) {
      print('❌ Error uploading company picture: $e');
      rethrow;
    }
  }

  /// Validates image file
  static bool validateImageFile(File imageFile) {
    try {
      final filePath = imageFile.path;
      print('🔍 LegalEntityImageService: Validating file path: $filePath');

      // Check if it's a blob URL (web platform)
      if (filePath.startsWith('blob:')) {
        print(
          '🔍 LegalEntityImageService: Detected blob URL, using XFile validation',
        );
        // For blob URLs, we need to validate using the XFile name instead
        // This will be handled by the calling code
        return true; // Assume valid for blob URLs, let the calling code handle it
      }

      final fileName = filePath.split('/').last.toLowerCase();
      print('🔍 LegalEntityImageService: File name: $fileName');

      final validExtensions = [
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.webp',
        '.avif',
        '.heic',
        '.bmp',
        '.tiff',
      ];

      final isValid = validExtensions.any((ext) => fileName.endsWith(ext));
      print('🔍 LegalEntityImageService: File validation result: $isValid');

      if (!isValid) {
        print(
          '❌ LegalEntityImageService: File does not match any valid extension',
        );
        print('❌ Valid extensions: $validExtensions');
        print('❌ File name: $fileName');
      }

      return isValid;
    } catch (e) {
      print('❌ LegalEntityImageService: Error validating file: $e');
      return false;
    }
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(File imageFile) async {
    try {
      final bytes = await imageFile.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      return 0.0;
    }
  }

  /// Check if file size is within limits (default: 50MB for edge functions)
  static Future<bool> isFileSizeValid(
    File imageFile, {
    double maxSizeMB = 50.0,
  }) async {
    final fileSize = await getFileSizeInMB(imageFile);
    return fileSize <= maxSizeMB;
  }
}
