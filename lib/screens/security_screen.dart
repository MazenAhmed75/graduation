import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Controllers to capture user input
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // IMPORTANT: Check the login provider.
    // We cannot change passwords for Google users via Firebase Auth.
    final isGoogle = _authService.isGoogleUser();

    return Scaffold(
      backgroundColor: AppTheme.neutral,
      appBar: AppBar(
        title: Text(l10n.privacyAndSecurity), // Fixed missing property assignment
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.securitySettings,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isGoogle
                  ? l10n.googleAccountManaged
                  : l10n.keepAccountSecure,
              style: const TextStyle(color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),

            // Use conditional rendering to show the correct UI based on login type
            if (isGoogle)
              _buildGoogleUserCard(context) // Fixed: Passed context
            else
              _buildPasswordChangeForm(context), // Fixed: Passed context
          ],
        ),
      ),
    );
  }

  /// UI for Google Users: Prevents them from seeing an "Update Password" form
  /// that would inevitably fail because Google owns their credentials.
  Widget _buildGoogleUserCard(BuildContext context) {
    final l10n = AppLocalizations.of(context); // Fixed: Localized lookup initialization
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column( // Fixed: Removed invalid const keyword here
        children: [
          const Icon(Icons.lock_person, size: 48, color: AppTheme.primary),
          const SizedBox(height: 16),
          Text(
            l10n.signedInWithGoogle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.googlePasswordInfo,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  /// UI for Email Users: A standard form requiring current password for verification.
  Widget _buildPasswordChangeForm(BuildContext context) {
    final l10n = AppLocalizations.of(context); // Fixed: Localized lookup initialization
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Verify current password to prove the user owns the account
          _buildPasswordField(
              context, // Fixed: Passed context
              _oldPasswordController,
              l10n.currentPassword,
              _obscureOld,
                  (val) => setState(() => _obscureOld = !val)
          ),
          const SizedBox(height: 16),
          // Enter new password
          _buildPasswordField(
              context, // Fixed: Passed context
              _newPasswordController,
              l10n.newPassword,
              _obscureNew,
                  (val) => setState(() => _obscureNew = !val)
          ),
          const SizedBox(height: 16),
          // Confirm new password to catch typos
          _buildPasswordField(
              context, // Fixed: Passed context
              _confirmPasswordController,
              l10n.confirmNewPassword,
              _obscureNew,
              null,
              isConfirm: true
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleUpdatePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(l10n.updatePassword, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build consistent password text fields
  Widget _buildPasswordField(
      BuildContext context, // Fixed: Accepted context parameter
      TextEditingController controller,
      String label,
      bool obscure,
      Function(bool)? onToggle,
      {bool isConfirm = false}
      ) {
    final l10n = AppLocalizations.of(context); // Fixed: Localized lookup initialization
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: onToggle != null
            ? IconButton(
            icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
            onPressed: () => onToggle(obscure)
        )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return l10n.fieldRequired;
        // Check if the "Confirm" field matches the "New" field
        if (isConfirm && value != _newPasswordController.text) return l10n.passwordsDoNotMatch;
        // Enforce basic password length
        if (!isConfirm && value.length < 6) return l10n.passwordTooShort;
        return null;
      },
    );
  }

  /// Handles the process of re-authenticating and then updating the password.
  Future<void> _handleUpdatePassword() async {
    // Stop if the UI validation (empty fields, short passwords) fails
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Call the AuthService which re-authenticates with the old password
    // and then sets the new one.
    final error = await _authService.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        // Successful update
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password updated successfully!'))
        );
        Navigator.pop(context); // Return to profile
      } else {
        // Shows error if old password was wrong or there was a network issue
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red)
        );
      }
    }
  }
}