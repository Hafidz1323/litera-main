import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/image_upload_service.dart';
import '../services/profile_service.dart';

class ProfileController extends ChangeNotifier {
  final _picker = ImagePicker();
  final _imageService = ImageUploadService();
  final _profileService = ProfileService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Cache stream agar tidak membuat instance baru setiap kali diakses
  late final Stream<User?> userStream = _profileService.userStream;
  User? get currentUser => _profileService.currentUser;

  // --- Validasi & Pengambilan Gambar ---
  Future<File?> pickImageFromSource(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 70, // Slightly higher quality for Storage
        maxWidth: 1000,   // Resize for efficiency
        maxHeight: 1000,
      );
      if (picked == null) return null;

      final file = File(picked.path);
      final sizeInBytes = await file.length();

      // Validasi ukuran max 5MB
      if (sizeInBytes > 5 * 1024 * 1024) {
        throw Exception('Ukuran file melebihi batas 5MB.');
      }

      return file;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  // --- Upload Foto Profil ---
  Future<bool> uploadProfilePhoto(File file) async {
    _setLoading(true);
    try {
      // 1. Upload to free-tier provider (Cloudinary)
      final url = await _imageService.uploadImage(file);
      
      // 2. Update Firebase Auth Profile
      await _profileService.updatePhoto(url);
      
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal upload foto: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- Hapus Foto Profil ---
  Future<bool> deleteProfilePhoto() async {
    _setLoading(true);
    try {
      final user = _profileService.currentUser;
      if (user?.photoURL != null) {
        await _imageService.deleteImage(user!.photoURL!);
      }
      await _profileService.removePhoto();
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus foto: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- Update Nama ---
  Future<bool> updateName(String name) async {
    _setLoading(true);
    try {
      await _profileService.updateName(name);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal update nama: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- Kirim Ulang Email Verifikasi ---
  Future<void> sendVerificationEmail() async {
    await _profileService.sendVerificationEmail();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}