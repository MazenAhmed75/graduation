import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserService _userService = UserService();
    final AuthService _authService = AuthService();

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

            // ========================================================
            // STEAMBUILDER #1: Profile picture in app bar
            // Shows user's photo or default icon
            // ========================================================
            StreamBuilder<UserModel?>(
              stream: _userService.getUserStream(_authService.currentUser!.uid),
              builder: (context, snapshot) {
                final user = snapshot.data;
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryContainer, width: 2),
                    color: AppTheme.surfaceContainerLow,
                  ),
                  child: user?.photoUrl != null && user!.photoUrl.isNotEmpty
                      ? ClipOval(
                    child: Image.network(
                      user.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                      const Icon(Icons.person, color: AppTheme.primary),
                    ),
                  )
                      : const Icon(Icons.person, color: AppTheme.primary),
                );
              },
            ),
          ],
        ),
      ),

      // ========================================================
      // STREAMBUILDER #2: Main content area
      // This is where ALL the profile data comes from Firebase
      // ========================================================
      body: StreamBuilder<UserModel?>(
        stream: _userService.getUserStream(_authService.currentUser!.uid),
        builder: (context, snapshot) {
          // Show loading spinner while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error if something went wrong
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // If no user data found, show error
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User data not found'));
          }

          // ✅ THIS IS THE KEY: user comes from Firebase now
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
                                  color: AppTheme.surfaceContainerLowest, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2E342B).withOpacity(0.06),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                              color: AppTheme.surfaceContainerLow,
                            ),
                            // ← CHANGED: Show real photo or default icon
                            child: user.photoUrl.isNotEmpty
                                ? ClipOval(
                              child: Image.network(
                                user.photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) =>
                                const Icon(Icons.person,
                                    size: 80, color: AppTheme.primary),
                              ),
                            )
                                : const Icon(Icons.person,
                                size: 80, color: AppTheme.primary),
                          ),
                          Positioned(
                            bottom: 16,
                            right: 0,
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
                        ],
                      ),
                      // ← CHANGED: Show real name from Firebase
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
                        onPressed: () {
                          // TODO: Implement photo upload later
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Photo upload coming soon!'),
                            ),
                          );
                        },
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

                // Account Details Component
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: Text(
                      'Account Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E342B).withOpacity(0.02),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ← CHANGED: Show real name
                      _buildListTile(
                        'FULL NAME',
                        user.name,
                        Icons.person,
                        AppTheme.primaryContainer.withOpacity(0.5),
                        AppTheme.primary,
                        onTap: () => _showEditNameDialog(context, user, _userService),
                      ),
                      // ← CHANGED: Show real email
                      _buildListTile(
                        'EMAIL ADDRESS',
                        user.email,
                        Icons.mail,
                        AppTheme.secondaryContainer,
                        AppTheme.secondary,
                        onTap: null, // Email can't be changed
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

                // Settings Component
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E342B).withOpacity(0.02),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ← CHANGED: Real toggle that saves to Firebase
                      _buildSettingsTile(
                        'Notifications',
                        Icons.notifications,
                        trailing: GestureDetector(
                          onTap: () {
                            _userService.updateNotifications(
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

                // Logout Action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    // ← CHANGED: Actually logs out now
                    onPressed: () async {
                      await _authService.logout();
                      // App will automatically navigate to LoginScreen
                      // because of the StreamBuilder in main.dart
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout',
                        style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  'App Version 2.4.0 • Build 882',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.outline,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ========================================================
  // HELPER: Show dialog to edit name
  // ========================================================
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
            labelText: 'Full Name',
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurface,
          ),
        ),
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
            color: Color(0xFFDEE5D7),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.onSurfaceVariant),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurface,
          ),
        ),
        trailing: trailing ??
            const Icon(Icons.chevron_right, color: AppTheme.outlineVariant),
        onTap: trailing == null ? () {} : null,
      ),
    );
  }
}