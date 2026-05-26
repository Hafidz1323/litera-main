import 'dart:io';

/// Interface for image upload services to allow easy switching between
/// providers (ImgBB, Cloudinary, etc.) without breaking the app.
abstract class BaseImageUploadService {
  /// Uploads an image and returns the direct permanent URL.
  Future<String> uploadImage(File file);
  
  /// Optional: Deletes an image if the provider supports it.
  Future<void> deleteImage(String url) async {}
}
