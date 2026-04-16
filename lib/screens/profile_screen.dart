import 'package:flutter/material.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryContainer, width: 2),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAuesGY15IOAcmh8K-KWr6K5Fz_e5e3kCBm2y2P9Y96hjEW7zBb8sIA8dactkct_syX1ZFZaDZ4MZU5p1GaeBQUe5dC05kWvFEB0r5thwXCaWKbjT-Z-yc4t-R2laaf0K6Sc9mJrXFqUvtWvifODvMM1d2sugtIbilhuwhQ9Xyfz7IFwBXtoTbEQyQT3rYavbtYDkW3b41H9XasCzD4-XZP5dALhlkSAj6Y-7eGJFwjiOWrk0oOZ6Ei7WUlcV7ghBV8cV6aUPi1pVmV',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
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
                          border: Border.all(color: AppTheme.surfaceContainerLowest, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E342B).withOpacity(0.06),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDwRQ0PESKI69gLBzSGGiSrexF3Oc7M6vyqCdgyPGcItVdPJw9Sk0KpTmSnHpVZ9ga2_Z3W2jMvp42OWYyV6ipPB3Djo68-EikLvQC-TSRIqygjvsBb7nTIVKAsHz2_4DwTyFqp5UgR718VYH_kcJfVDLoAyWpLjLsSqQR5aJCDXNGkVbPMg0k_93vtaRuVFjdmqEL7avLkhncrbi3loTyoLqi_B0Fb9nMixpLIUQesRodlT5IvPf4_Jwkie-DsdHKoGzWBdx2svNJA',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
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
                          child: const Icon(Icons.photo_camera, color: Color(0xFFEBFFE0), size: 18),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Eleanor Vance',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Curating mindfulness since 2022',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.secondaryContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                  _buildListTile(
                    'FULL NAME', 'Eleanor Vance', Icons.person, 
                    AppTheme.primaryContainer.withOpacity(0.5), AppTheme.primary
                  ),
                  _buildListTile(
                    'EMAIL ADDRESS', 'eleanor.v@mindfulcurator.io', Icons.mail, 
                    AppTheme.secondaryContainer, AppTheme.secondary
                  ),
                  _buildListTile(
                    'MEMBERSHIP', 'Premium Curator', Icons.workspace_premium, 
                    AppTheme.tertiaryContainer, AppTheme.tertiary
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
                  _buildSettingsTile(
                    'Notifications', Icons.notifications, 
                    trailing: Container(
                      width: 44,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.all(2),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
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
                onPressed: () {},
                icon: const Icon(Icons.logout),
                label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
      ),
    );
  }

  Widget _buildListTile(String label, String value, IconData icon, Color iconBg, Color iconColor) {
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
        trailing: const Icon(Icons.chevron_right, color: AppTheme.outlineVariant),
        onTap: () {},
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, {Widget? trailing}) {
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
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.outlineVariant),
        onTap: () {},
      ),
    );
  }
}
