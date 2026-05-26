import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'base_image_upload_service.dart';

/// Cloudinary implementation for production-safe image uploads.
/// Uses Unsigned Upload Preset for mobile client safety.
class CloudinaryService implements BaseImageUploadService {
  // ── Configuration ──────────────────────────────────────────────────────────
  // TODO: Replace with your actual Cloudinary credentials
  static const String _cloudName = 'dz16g5u9x'; 
  static const String _uploadPreset = 'litera';
  
  static const String _baseUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  @override
  Future<String> uploadImage(File file) async {
    debugPrint('[CloudinaryService] 📤 Upload started for file: ${file.path}');
    
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl));
      
      // Essential fields for Unsigned Upload
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = 'profile_photos'; // Optional: organize in folder
      
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Use 'secure_url' to ensure HTTPS and avoid SSL/Handshake issues
        final secureUrl = data['secure_url'] as String;
        
        debugPrint('[CloudinaryService] ✅ Upload success! URL: $secureUrl');
        return secureUrl;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        debugPrint('[CloudinaryService] ❌ Upload failed (${response.statusCode}): $errorMessage');
        throw Exception('Cloudinary upload failed: $errorMessage');
      }
    } catch (e) {
      debugPrint('[CloudinaryService] ❌ Critical Error: $e');
      if (e is SocketException) {
        throw Exception('No Internet connection or server unreachable.');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteImage(String url) async {
    // Note: Deleting images from client-side via Cloudinary API requires 
    // a signature (Signed API) which isn't safe for mobile client hardcoding.
    // In production, deletion should be handled by a backend function or 
    // simply let the old images persist (they are small).
    debugPrint('[CloudinaryService] ℹ️ Deletion skipped (requires signed API for security)');
  }
}
