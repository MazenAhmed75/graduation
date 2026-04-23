import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../services/Storage_service.dart';

class ProfileScreen extends StatelessWidget {
  // Callback from MainScreen to switch tabs if needed
  final void Function(int) onNavigateToTab;

  const ProfileScreen({
    super.key,
    required this.onNavigateToTab,
  });

  // ============================================================
  // PHOTO UPLOAD: Opens camera or gallery, uploads to Firebase
  // ============================================================
  Future<void> _pickAndUploadImage(BuildContext context, String userId) async {
    final ImagePicker picker = ImagePicker();
    final StorageService storageService = StorageService();
    final UserService userService = UserService();

    // Step 1: Ask user to choose Camera or Gallery
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Photo Source'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: AppTheme.primary),
              ),
              title: const Text('Take Photo',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library,
                    color: AppTheme.secondary),
              ),
              title: const Text('Choose from Gallery',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !context.mounted) return;

    // Step 2: Pick the image
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (image == null || !context.mounted) return;

    // Step 3: Show loading dialog while uploading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading photo...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Step 4: Upload to Firebase Storage
      final photoUrl = await storageService.uploadProfilePicture(
        userId,
        File(image.path),
      );

      // Step 5: Save URL to Firestore
      await userService.updatePhotoUrl(userId, photoUrl);

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile picture updated!'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();
    final AuthService authService = AuthService();
    final String userId = authService.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppTheme.neutral,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF2),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 70,
        titleSpacing: 24,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu, color: AppTheme.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceContainerLow,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Mindful Curator',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            // Real profile photo in app bar
            StreamBuilder<UserModel?>(
              stream: userService.getUserStream(userId),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return GestureDetector(
                  onTap: () => _pickAndUploadImage(context, userId),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.primaryContainer, width: 2),
                      color: AppTheme.surfaceContainerLow,
                    ),
                    child: user?.photoUrl != null &&
                        user!.photoUrl.isNotEmpty
                        ? ClipOval(
                      child: Image.network(
                        user.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                        const Icon(Icons.person,
                            color: AppTheme.primary),
                      ),
                    )
                        : const Icon(Icons.person, color: AppTheme.primary),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<UserModel?>(
        stream: userService.getUserStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User data not found'));
          }

          final UserModel user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            child: Column(
              children: [
                // Hero Profile Section
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppTheme.surfaceContainerLowest,
                                  width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  const Color(0xFF2E342B).withOpacity(0.06),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                              color: AppTheme.surfaceContainerLow,
                            ),
                            child: user.photoUrl.isNotEmpty
                                ? ClipOval(
                              child: Image.network(
                                user.photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) =>
                                const Icon(Icons.person,
                                    size: 80,
                                    color: AppTheme.primary),
                              ),
                            )
                                : const Icon(Icons.person,
                                size: 80, color: AppTheme.primary),
                          ),
                          // Camera button — ACTUALLY WORKS NOW
                          Positioned(
                            bottom: 16,
                            right: 0,
                            child: GestureDetector(
                              onTap: () =>
                                  _pickAndUploadImage(context, userId),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.photo_camera,
                                    color: Color(0xFFEBFFE0), size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Curating mindfulness since 2024',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => _pickAndUploadImage(context, userId),
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.secondaryContainer,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'CHANGE PROFILE PICTURE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppTheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Account Details
                _buildSectionHeader('Account Details'),
                Container(
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      _buildListTile(
                        'FULL NAME',
                        user.name,
                        Icons.person,
                        AppTheme.primaryContainer.withOpacity(0.5),
                        AppTheme.primary,
                        onTap: () => _showEditNameDialog(
                            context, user, userService),
                      ),
                      _buildListTile(
                        'EMAIL ADDRESS',
                        user.email,
                        Icons.mail,
                        AppTheme.secondaryContainer,
                        AppTheme.secondary,
                        onTap: null,
                      ),
                      _buildListTile(
                        'MEMBERSHIP',
                        'Free Plan',
                        Icons.workspace_premium,
                        AppTheme.tertiaryContainer,
                        AppTheme.tertiary,
                        onTap: null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Settings
                _buildSectionHeader('Settings'),
                Container(
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        'Notifications',
                        Icons.notifications,
                        trailing: GestureDetector(
                          onTap: () {
                            userService.updateNotifications(
                              user.id,
                              !user.notificationsEnabled,
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 24,
                            decoration: BoxDecoration(
                              color: user.notificationsEnabled
                                  ? AppTheme.primaryContainer
                                  : AppTheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: user.notificationsEnabled
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            padding: const EdgeInsets.all(2),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: user.notificationsEnabled
                                    ? AppTheme.primary
                                    : AppTheme.outline,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _buildSettingsTile('Privacy & Security', Icons.security),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ============================================================
                // LOGOUT BUTTON — Calls authService.logout()
                // main.dart's StreamBuilder detects the logout and shows
                // LoginScreen automatically
                // ============================================================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // Show confirmation dialog
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Log Out'),
                          content: const Text(
                              'Are you sure you want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text('Log Out',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await authService.logout();
                        // main.dart's StreamBuilder automatically
                        // navigates back to LoginScreen
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorContainer,
                      foregroundColor: AppTheme.onErrorContainer,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'App Version 1.0.0',
                  style: TextStyle(fontSize: 12, color: AppTheme.outline),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static void _showEditNameDialog(
      BuildContext context, UserModel user, UserService userService) {
    final controller = TextEditingController(text: user.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
              labelText: 'Full Name', hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await userService.updateName(user.id, newName);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  static Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  static BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2E342B).withOpacity(0.02),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static Widget _buildListTile(
      String label,
      String value,
      IconData icon,
      Color iconBg,
      Color iconColor, {
        VoidCallback? onTap,
      }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AppTheme.onSurfaceVariant)),
        subtitle: Text(value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface)),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: AppTheme.outlineVariant)
            : null,
        onTap: onTap,
      ),
    );
  }

  static Widget _buildSettingsTile(String title, IconData icon,
      {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
              color: Color(0xFFDEE5D7), shape: BoxShape.circle),
          child: Icon(icon, color: AppTheme.onSurfaceVariant),
        ),
        title: Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface)),
        trailing: trailing ??
            const Icon(Icons.chevron_right, color: AppTheme.outlineVariant),
        onTap: trailing == null ? () {} : null,
      ),
    );
  }
}