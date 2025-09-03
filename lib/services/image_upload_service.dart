import 'dart:io';
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

  // Unified upload function for both profile and company photos
  Future<String?> uploadEntityPicture(
    File imageFile, {
    required String pictureType, // 'profile' or 'company'
    String? legalEntityId,
  }) async {
    try {
      String folder;
      String type;
      
      switch (pictureType) {
        case 'profile':
          folder = 'entity-profile-pictures';
          type = 'entity-profile';
          break;
        case 'company':
          folder = 'entity-company-pictures';
          type = 'entity-company';
          break;
        default:
          throw Exception('Invalid picture type: $pictureType');
      }

      return await _uploadImage(
        imageFile,
        folder,
        type,
        legalEntityId: legalEntityId,
      );
    } catch (e) {
      print('❌ Error uploading entity $pictureType picture: $e');
      return null;
    }
  }

  // Generic upload method - Direct database access
  Future<String?> _uploadImage(
    File imageFile,
    String folder,
    String type, {
    String? legalEntityId,
  }) async {
    try {
      // Get file name and type
      final fileName = imageFile.path.split('/').last;
      final fileType = _getMimeType(fileName);

      // Generate unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';

      // Determine storage bucket and path
      String bucketName;
      String filePath;
      
      if (type == 'profile') {
        bucketName = 'profile-pictures';
        filePath = uniqueFileName;
      } else if (type == 'entity-profile') {
        bucketName = 'entity-profile-pictures';
        filePath = legalEntityId != null ? '$legalEntityId/$uniqueFileName' : uniqueFileName;
      } else if (type == 'entity-company') {
        bucketName = 'entity-company-pictures';
        filePath = legalEntityId != null ? '$legalEntityId/$uniqueFileName' : uniqueFileName;
      } else {
        bucketName = 'company-pictures';
        filePath = legalEntityId != null ? '$legalEntityId/$uniqueFileName' : uniqueFileName;
      }

      // Upload directly to Supabase Storage
      final response = await _supabaseService.uploadFileToStorage(
        bucketName: bucketName,
        filePath: filePath,
        file: imageFile,
        contentType: fileType,
      );

      if (response != null) {
        print('✅ Image uploaded successfully: $response');
        return response;
      } else {
        throw Exception('Upload failed - no URL returned');
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
  Future<bool> deleteImage(String imagePath, String bucketName) async {
    try {
      final response = await _supabaseService.client.storage
          .from(bucketName)
          .remove([imagePath]);

      return response.isNotEmpty;
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }

  // Get image URL from path
  String getImageUrl(String imagePath, String bucketName) {
    return _supabaseService.client.storage
        .from(bucketName)
        .getPublicUrl(imagePath);
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
