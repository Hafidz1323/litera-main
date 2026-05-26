import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/profile_controller.dart';
import '../core/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Widget avatar profil yang reaktif terhadap perubahan URL dan loading state.
/// Menggunakan cache buster agar gambar selalu segar setelah diupdate.
class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final bool isLoading;
  final VoidCallback onTap;
  final double radius;

  const ProfileAvatar({
    super.key,
    required this.photoUrl,
    required this.isLoading,
    required this.onTap,
    this.radius = 55,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Stack(
        children: [
          // ── Lingkaran Foto ──
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: isLoading
                  ? const _LoadingPlaceholder()
                  : _buildImage(),
            ),
          ),
          // ── Ikon Kamera ──
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    // Pastikan photoUrl tidak null dan tidak kosong
    if (photoUrl == null || photoUrl!.trim().isEmpty) {
      return const Icon(Icons.person, size: 64, color: AppColors.primary);
    }

    // Use direct URL only - ImgBB rejects query parameters like ?v=timestamp
    final url = photoUrl!.trim();

    return Image.network(
      url,
      fit: BoxFit.cover,
      key: ValueKey(url),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const _LoadingPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('[ProfileAvatar] Gagal memuat gambar ($url): $error');
        return const Icon(Icons.person, size: 64, color: AppColors.primary);
      },
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

/// Versi kecil ProfileAvatar untuk digunakan di Navbar/AppBar
class SmallProfileAvatar extends StatelessWidget {
  final double radius;

  const SmallProfileAvatar({super.key, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        return StreamBuilder<User?>(
          stream: controller.userStream,
          initialData: controller.currentUser,
          builder: (context, snapshot) {
            final user = snapshot.data;
            final url = user?.photoURL;

            // Use direct URL only
            String? finalUrl;
            if (url != null && url.trim().isNotEmpty) {
              finalUrl = url.trim();
              debugPrint('[SmallProfileAvatar] 🖼️ Loading URL: $finalUrl');
            }

            return CircleAvatar(
              radius: radius,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              child: ClipOval(
                child: (finalUrl != null)
                    ? Image.network(
                        finalUrl,
                        key: ValueKey(finalUrl),
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: radius,
                              height: radius,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('[SmallProfileAvatar] Error: $error');
                          return Icon(Icons.person, size: radius * 1.3, color: Colors.white);
                        },
                      )
                    : Icon(Icons.person, size: radius * 1.3, color: Colors.white),
              ),
            );
          },
        );
      },
    );
  }
}