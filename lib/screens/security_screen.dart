import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';

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
  Widget build(BuildContext context) {
    // IMPORTANT: Check the login provider.
    // We cannot change passwords for Google users via Firebase Auth.
    final isGoogle = _authService.isGoogleUser();

    return Scaffold(
      backgroundColor: AppTheme.neutral,
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isGoogle
                  ? 'Your account is managed via Google.'
                  : 'Keep your account secure by updating your password regularly.',
              style: const TextStyle(color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),

            // Use conditional rendering to show the correct UI based on login type
            if (isGoogle)
              _buildGoogleUserCard()
            else
              _buildPasswordChangeForm(),
          ],
        ),
      ),
    );
  }

  /// UI for Google Users: Prevents them from seeing an "Update Password" form
  /// that would inevitably fail because Google owns their credentials.
  Widget _buildGoogleUserCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
      ),
      child: const Column(
        children: [
          Icon(Icons.lock_person, size: 48, color: AppTheme.primary),
          SizedBox(height: 16),
          Text(
            'Signed in with Google',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Because you use Google Sign-In, you can manage your password directly in your Google Account settings.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  /// UI for Email Users: A standard form requiring current password for verification.
  Widget _buildPasswordChangeForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Verify current password to prove the user owns the account
          _buildPasswordField(
              _oldPasswordController,
              'Current Password',
              _obscureOld,
                  (val) => setState(() => _obscureOld = !val)
          ),
          const SizedBox(height: 16),
          // Enter new password
          _buildPasswordField(
              _newPasswordController,
              'New Password',
              _obscureNew,
                  (val) => setState(() => _obscureNew = !val)
          ),
          const SizedBox(height: 16),
          // Confirm new password to catch typos
          _buildPasswordField(
              _confirmPasswordController,
              'Confirm New Password',
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
                  : const Text('Update Password', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build consistent password text fields
  Widget _buildPasswordField(
      TextEditingController controller,
      String label,
      bool obscure,
      Function(bool)? onToggle,
      {bool isConfirm = false}
      ) {
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
        if (value == null || value.isEmpty) return 'Field required';
        // Check if the "Confirm" field matches the "New" field
        if (isConfirm && value != _newPasswordController.text) return 'Passwords do not match';
        // Enforce basic password length
        if (!isConfirm && value.length < 6) return 'Must be at least 6 characters';
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