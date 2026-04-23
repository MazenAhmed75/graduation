import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../services/Storage_service.dart';

class ProfileScreen extends StatelessWidget {
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

    // Step 3: Show loading dialog
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
      // Step 4: Read as bytes — works on ALL platforms (no dart:io needed)
      final imageBytes = await image.readAsBytes();

      // Step 5: Upload to Firebase Storage
      final photoUrl = await storageService.uploadProfilePicture(
        userId,
        imageBytes,
      );

      // Step 6: Save URL to Firestore
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

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();
    final AuthService authService = AuthService();
    final String userId = authService.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppTheme.neutral,

      // ======================================================
      // APP BAR
      // ======================================================
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
            // Tap the avatar in the app bar to upload a new photo
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

      // ======================================================
      // BODY
      // ======================================================
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

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).padding.bottom + 80,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // ============================================================
                // PROFILE HEADER — large avatar + name + email
                // ============================================================
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.primaryContainer, width: 3),
                        color: AppTheme.surfaceContainerLow,
                      ),
                      child: user.photoUrl.isNotEmpty
                          ? ClipOval(
                        child: Image.network(
                          user.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                          const Icon(Icons.person,
                              size: 60, color: AppTheme.primary),
                        ),
                      )
                          : const Icon(Icons.person,
                          size: 60, color: AppTheme.primary),
                    ),
                    // Camera badge — tap to change photo
                    GestureDetector(
                      onTap: () => _pickAndUploadImage(context, userId),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          border:
                          Border.all(color: AppTheme.neutral, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Color(0xFFEBFFE0), size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // ============================================================
                // ACCOUNT SECTION
                // ============================================================
                _buildSectionHeader('Account'),
                const SizedBox(height: 8),
                Container(
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      _buildListTile(
                        'FULL NAME',
                        user.name,
                        Icons.person_outline,
                        AppTheme.primaryContainer,
                        AppTheme.onPrimaryContainer,
                        onTap: () => _showEditNameDialog(
                            context, user, userService),
                      ),
                      const Divider(height: 1, indent: 72),
                      _buildListTile(
                        'EMAIL',
                        user.email,
                        Icons.email_outlined,
                        AppTheme.secondaryContainer,
                        AppTheme.onSecondaryContainer,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ============================================================
                // MEMBERSHIP SECTION
                // ============================================================
                _buildSectionHeader('Membership'),
                const SizedBox(height: 8),
                Container(
                  decoration: _cardDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.tertiaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.workspace_premium,
                              color: AppTheme.tertiary),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CURRENT PLAN',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Free',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Upgrade',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.tertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ============================================================
                // SETTINGS SECTION
                // ============================================================
                _buildSectionHeader('Settings'),
                const SizedBox(height: 8),
                Container(
                  decoration: _cardDecoration(),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        'Notifications',
                        Icons.notifications_outlined,
                        trailing: GestureDetector(
                          onTap: () {
                            userService.updateNotifications(
                                userId, !user.notificationsEnabled);
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
                      const Divider(height: 1, indent: 72),
                      _buildSettingsTile(
                          'Privacy & Security', Icons.security),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ============================================================
                // LOGOUT BUTTON
                // ============================================================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
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
                        // main.dart StreamBuilder automatically
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

  // ============================================================
  // DIALOG: Edit display name
  // ============================================================
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

  // ============================================================
  // UI HELPERS
  // ============================================================
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
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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