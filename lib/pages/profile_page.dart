import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:litera2/l10n/app_localizations.dart';

import '../auth_service.dart';
import '../controllers/profile_controller.dart';
import '../core/app_colors.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/stat_card.dart';
import '../services/user_service.dart';
import 'admin/admin_dashboard_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        centerTitle: false,
        toolbarHeight: 70,
      ),
      body: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        // Tampilkan error dari controller jika ada
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (controller.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(controller.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
            controller.clearError();
          }
        });

        return StreamBuilder<User?>(
          stream: controller.userStream,
          initialData: controller.currentUser,
          builder: (context, snapshot) {
            final user = snapshot.data;

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildAvatarSection(context, controller, user, l10n, isDark),
                const SizedBox(height: 32),
                _buildSectionTitle(l10n.readingStats),
                const SizedBox(height: 16),
                _buildStats(context, l10n),
                const SizedBox(height: 32),
                _buildSectionTitle(l10n.accountSection),
                const SizedBox(height: 8),
                _buildAccountSection(context, controller, user, l10n),
                const SizedBox(height: 24),
                _buildSectionTitle(l10n.appearanceSection),
                const SizedBox(height: 8),
                _buildThemeSwitch(context, l10n),
                _buildLanguageSelector(context, l10n),
                const SizedBox(height: 24),
                _buildSectionTitle(l10n.otherSection),
                const SizedBox(height: 8),
                _buildOtherSection(context, l10n),
                const SizedBox(height: 24),
                _buildAdminSection(context),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                _buildLogoutButton(context, l10n),
                const SizedBox(height: 20),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAvatarSection(BuildContext context, ProfileController controller, User? user, AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          ProfileAvatar(
            photoUrl: user?.photoURL,
            isLoading: controller.isLoading,
            onTap: () => _showImageSourceSheet(context, controller, user, l10n),
          ),
          const SizedBox(height: 20),
          Text(
            user?.displayName ?? 'Pengguna Litera', 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(user?.email ?? '-', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: (user?.emailVerified == true ? AppColors.success : Colors.orange).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user?.emailVerified == true ? Icons.verified_rounded : Icons.warning_amber_rounded,
                  size: 16,
                  color: user?.emailVerified == true ? AppColors.success : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  user?.emailVerified == true ? l10n.emailVerified : l10n.emailNotVerified,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: user?.emailVerified == true ? AppColors.success : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, AppLocalizations l10n) {
    return Consumer<HistoryProvider>(
      builder: (context, historyProv, _) {
        final finishedCount = historyProv.finishedBooks.length;
        final historyCount = historyProv.history.length;
        
        return Row(
          children: [
            StatCard(label: l10n.statBooksRead, value: finishedCount.toString(), icon: Icons.auto_stories_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            StatCard(label: l10n.statReadingHours, value: (historyCount * 1.5).toInt().toString(), icon: Icons.timer_rounded, color: Colors.blueAccent),
            const SizedBox(width: 12),
            StatCard(label: l10n.statStreak, value: '7', icon: Icons.local_fire_department_rounded, color: Colors.orangeAccent),
          ],
        );
      },
    );
  }

  Widget _buildAccountSection(BuildContext context, ProfileController controller, User? user, AppLocalizations l10n) {
    return Column(
      children: [
        ProfileMenuTile(
          icon: Icons.person_rounded,
          iconColor: AppColors.primary,
          title: l10n.editName,
          subtitle: user?.displayName ?? 'Belum diatur',
          onTap: () => _showEditNameDialog(context, controller, l10n),
        ),
        ProfileMenuTile(
          icon: Icons.email_rounded, 
          iconColor: Colors.blueAccent, 
          title: l10n.email, 
          subtitle: user?.email ?? '-', 
          trailing: const SizedBox.shrink()
        ),
        if (user?.emailVerified == false)
          ProfileMenuTile(
            icon: Icons.mark_email_unread_rounded,
            iconColor: Colors.orangeAccent,
            title: l10n.resendVerification,
            onTap: () async {
              await controller.sendVerificationEmail();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.verificationSent)));
            },
          ),
      ],
    );
  }

  Widget _buildThemeSwitch(BuildContext context, AppLocalizations l10n) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDark;

    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.indigoAccent.withValues(alpha: 0.12), shape: BoxShape.circle),
        child: Icon(isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: Colors.indigoAccent, size: 22),
      ),
      title: Text(l10n.darkMode, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: Text(isDarkMode ? l10n.darkModeOn : l10n.darkModeOff, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      value: isDarkMode,
      activeThumbColor: AppColors.primary,
      onChanged: (value) => themeProvider.toggle(),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, AppLocalizations l10n) {
    final languageProvider = context.watch<LanguageProvider>();
    final currentLocale = languageProvider.locale.languageCode;

    return ProfileMenuTile(
      icon: Icons.translate_rounded,
      iconColor: Colors.purpleAccent,
      title: l10n.language,
      subtitle: currentLocale == 'id' ? l10n.languageId : l10n.languageEn,
      onTap: () => _showLanguageDialog(context, languageProvider, l10n),
    );
  }

  Widget _buildOtherSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        ProfileMenuTile(icon: Icons.help_center_rounded, iconColor: Colors.orangeAccent, title: l10n.helpCenter, onTap: () {}),
        ProfileMenuTile(
          icon: Icons.info_rounded,
          iconColor: Colors.blueGrey,
          title: l10n.aboutApp,
          subtitle: l10n.appVersion,
          onTap: () => showAboutDialog(
            context: context,
            applicationName: l10n.appName,
            applicationVersion: '1.0.0',
            applicationLegalese: '© 2025 Litera App',
          ),
        ),
      ],
    );
  }

  Widget _buildAdminSection(BuildContext context) {
    return StreamBuilder(
      stream: UserService.watchProfile(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        if (profile == null || !profile.isAdmin) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('ADMIN PANEL'),
            const SizedBox(height: 8),
            ProfileMenuTile(
              icon: Icons.admin_panel_settings_rounded,
              iconColor: AppColors.primary,
              title: 'Admin Dashboard',
              subtitle: 'Manage books and application data',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context, l10n),
        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        label: Text(l10n.logout, style: const TextStyle(fontSize: 16, color: AppColors.error, fontWeight: FontWeight.w800)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(), 
      style: const TextStyle(
        fontSize: 12, 
        fontWeight: FontWeight.w800, 
        color: AppColors.primary,
        letterSpacing: 1.2
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context, ProfileController controller, User? user, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(l10n.profilePhotoTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: Text(l10n.camera, style: const TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndPreview(context, controller, ImageSource.camera, l10n);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: Text(l10n.gallery, style: const TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndPreview(context, controller, ImageSource.gallery, l10n);
              },
            ),
            if (user?.photoURL != null)
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: AppColors.error),
                title: Text(l10n.deletePhoto, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context, controller, l10n);
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndPreview(BuildContext context, ProfileController controller, ImageSource source, AppLocalizations l10n) async {
    final file = await controller.pickImageFromSource(source);
    if (file == null || !context.mounted) return;
    _showPreviewDialog(context, controller, file, l10n);
  }

  void _showPreviewDialog(BuildContext context, ProfileController controller, File file, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.previewPhoto, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 4),
              ),
              child: ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.file(file, height: 200, width: 200, fit: BoxFit.cover)),
            ),
            const SizedBox(height: 16),
            Text(l10n.useThisPhoto, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel, style: const TextStyle(color: AppColors.textSecondary))),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await controller.uploadProfilePhoto(file);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? l10n.photoUpdated : (controller.errorMessage ?? l10n.errorGeneral)),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProfileController controller, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.deletePhotoTitle, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(l10n.deletePhotoConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.deleteProfilePhoto();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.photoDeleted)));
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, ProfileController controller, AppLocalizations l10n) {
    final nameController = TextEditingController(text: controller.currentUser?.displayName ?? '');
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              Text(l10n.editName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                autofocus: true,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: l10n.nameLabel,
                  prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.nameEmpty : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(ctx);
                      final success = await controller.updateName(nameController.text.trim());
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? l10n.nameUpdated : (controller.errorMessage ?? l10n.errorGeneral)),
                            backgroundColor: success ? AppColors.success : AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(l10n.save, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider languageProvider, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(l10n.language, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            ),
            ListTile(
              leading: const Text('🇮🇩', style: TextStyle(fontSize: 24)),
              title: Text(l10n.languageId, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: languageProvider.locale.languageCode == 'id' ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
              onTap: () {
                languageProvider.setLocale('id');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: Text(l10n.languageEn, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: languageProvider.locale.languageCode == 'en' ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
              onTap: () {
                languageProvider.setLocale('en');
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.logoutConfirmTitle, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(l10n.logoutConfirmContent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              AuthService().signOut();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}
