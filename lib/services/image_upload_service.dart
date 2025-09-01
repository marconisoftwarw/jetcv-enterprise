import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/supabase_service.dart';

class ImageUploadService {
  final SupabaseService _supabaseService = SupabaseService();

  // Upload profile picture
  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      return await _uploadImage(imageFile, 'profile-pictures', 'profile');
    } catch (e) {
      print('❌ Error uploading profile picture: $e');
      return null;
    }
  }

  // Upload entity profile picture (logo)
  Future<String?> uploadEntityProfilePicture(
    File imageFile, {
    String? legalEntityId,
  }) async {
    try {
      return await _uploadImage(
        imageFile,
        'entity-profile-pictures',
        'entity-profile',
        legalEntityId: legalEntityId,
      );
    } catch (e) {
      print('❌ Error uploading entity profile picture: $e');
      return null;
    }
  }

  // Upload entity company picture
  Future<String?> uploadEntityCompanyPicture(
    File imageFile, {
    String? legalEntityId,
  }) async {
    try {
      return await _uploadImage(
        imageFile,
        'entity-company-pictures',
        'entity-company',
        legalEntityId: legalEntityId,
      );
    } catch (e) {
      print('❌ Error uploading entity company picture: $e');
      return null;
    }
  }

  // Generic upload method
  Future<String?> _uploadImage(
    File imageFile,
    String folder,
    String type, {
    String? legalEntityId,
  }) async {
    try {
      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      // Convert to base64
      final base64File = base64Encode(bytes);

      // Get file name and type
      final fileName = imageFile.path.split('/').last;
      final fileType = _getMimeType(fileName);

      // Prepare request body
      final requestBody = {
        'file': base64File,
        'fileName': fileName,
        'fileType': fileType,
        'folder': folder,
        if (legalEntityId != null) 'legalEntityId': legalEntityId,
      };

      // Get access token
      final accessToken = await _supabaseService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token available');
      }

      // Determine which edge function to use
      String endpoint;
      if (type == 'profile') {
        endpoint = 'uploadProfilePicture';
      } else {
        endpoint = 'uploadCompanyPicture';
      }

      // Make request to edge function
      final response = await http.post(
        Uri.parse('${AppConfig.supabaseUrl}/functions/v1/$endpoint'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          print('✅ Image uploaded successfully: ${responseData['url']}');
          return responseData['url'];
        } else {
          throw Exception(responseData['error'] ?? 'Upload failed');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error in _uploadImage: $e');
      rethrow;
    }
  }

  // Get MIME type from file extension
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
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
      default:
        return 'image/jpeg';
    }
  }

  // Delete image from storage
  Future<bool> deleteImage(String imagePath) async {
    try {
      final accessToken = await _supabaseService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token available');
      }

      final response = await http.delete(
        Uri.parse(
          '${AppConfig.supabaseUrl}/storage/v1/object/images/$imagePath',
        ),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }

  // Get image URL from path
  String getImageUrl(String imagePath) {
    return '${AppConfig.supabaseUrl}/storage/v1/object/public/images/$imagePath';
  }

  // Validate image file
  bool validateImageFile(File imageFile) {
    try {
      final fileName = imageFile.path.split('/').last.toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];

      return validExtensions.any((ext) => fileName.endsWith(ext));
    } catch (e) {
      return false;
    }
  }

  // Get file size in MB
  Future<double> getFileSizeInMB(File imageFile) async {
    try {
      final bytes = await imageFile.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      return 0.0;
    }
  }

  // Check if file size is within limits (default: 5MB)
  Future<bool> isFileSizeValid(File imageFile, {double maxSizeMB = 5.0}) async {
    final fileSize = await getFileSizeInMB(imageFile);
    return fileSize <= maxSizeMB;
  }
}
