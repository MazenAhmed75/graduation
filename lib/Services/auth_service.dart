import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👈 Added for background token synchronization
import '../models/user_model.dart';

class AuthService {
  // ── Singleton Configuration ─────────────────────────────────────────
  AuthService._internal() {
    // Automatically manage caching the userId safely whenever auth state changes
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.uid);
        print('💾 Centralized Auth: Cached userId locally (${user.uid})');
      }
    });
  }

  static final AuthService instance = AuthService._internal();

  // Factory constructor returns the exact same instance every single time
  factory AuthService() => instance;
  // ────────────────────────────────────────────────────────────────────

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '196484785411-ikp1vrohbp45o0ib9vkqqllarpfhsih3.apps.googleusercontent.com',
  );

  // -------------------------------------------------------
  // Get the currently logged-in user (null if not logged in)
  // -------------------------------------------------------
  User? get currentUser => _auth.currentUser;

  // -------------------------------------------------------
  // A stream that tells us whenever login state changes
  // -------------------------------------------------------
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // -------------------------------------------------------
  // REGISTER: Create a new account with email/password
  // -------------------------------------------------------
  Future<AuthResult?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Step 1: Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Create user profile in Firestore
      // THIS IS THE CRITICAL PART THAT WAS MISSING
      UserModel newUser = UserModel(
        id: result.user!.uid,
        name: name,
        email: email,
        photoUrl: '',
        monthlySavingsGoal: 2000.0, // Default goal
        savingsCurrentAmount: 0.0,
        notificationsEnabled: true,
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(newUser.toMap());

      print('✅ User created in Firestore: ${result.user!.uid}');
      return AuthResult(success: true); // Success

    } on FirebaseAuthException catch (e) {
      print('❌ Registration error: ${e.code}');
      if (e.code == 'email-already-in-use') {
        return AuthResult(success: false, errorKey: 'email_already_in_use');
      }
      if (e.code == 'weak-password') {
        return AuthResult(success: false, errorKey: 'weak_password');
      }
      if (e.code == 'invalid-email') {
        return AuthResult(success: false, errorKey: 'invalid_email');
      }
      return AuthResult(
        success: false,
        errorKey: 'registration_failed', // Removed errorArgs to block English leaks
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      return AuthResult(success: false, errorKey: 'unexpected_error');
    }
  }

  // -------------------------------------------------------
  // LOGIN: Sign in with email and password
  // -------------------------------------------------------
  Future<AuthResult?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Login successful');
      return AuthResult(success: true);

    } on FirebaseAuthException catch (e) {
      print('❌ Login error: ${e.code}');

      // Handle the modern Firebase unified error code
      if (e.code == 'invalid-credential' ||
          e.code == 'user-not-found' ||
          e.code == 'wrong-password') {
        return AuthResult(success: false, errorKey: 'invalid_credential');
      }
      if (e.code == 'invalid-email') {
        return AuthResult(success: false, errorKey: 'invalid_email');
      }

      // Fallback: Do NOT pass e.message to the UI if you want full localization control
      return AuthResult(
        success: false,
        errorKey: 'login_failed',
        errorArgs: [], // Keep console logs in English, but keep UI clean
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      return AuthResult(success: false, errorKey: 'unexpected_error');
    }
  }
  // -------------------------------------------------------
  // GOOGLE SIGN-IN: Sign in with Google account
  // -------------------------------------------------------
  Future<AuthResult?> signInWithGoogle() async {
    try {
      // Step 1: Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult(success: false, errorKey: 'google_sign_in_cancelled');
      }
      // Step 2: Get Google auth credentials
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // Step 3: Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase with Google credentials
      UserCredential result = await _auth.signInWithCredential(credential);

      // Step 5: Check if this is a new user
      // If so, create their Firestore profile
      final userDoc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (!userDoc.exists) {
        // New user - create Firestore profile
        UserModel newUser = UserModel(
          id: result.user!.uid,
          name: result.user!.displayName ?? 'User',
          email: result.user!.email ?? '',
          photoUrl: result.user!.photoURL ?? '',
          monthlySavingsGoal: 2000.0,
          savingsCurrentAmount: 0.0,
          notificationsEnabled: true,
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(newUser.toMap());

        print('✅ New Google user created in Firestore');
      } else {
        print('✅ Existing Google user logged in');
      }

      return AuthResult(success: true);

    } catch (e) {
      print('❌ Google sign-in error: $e');
      return AuthResult(success: false, errorKey: 'google_sign_in_failed');
    }
  }
// -------------------------------------------------------
// FORGOT PASSWORD: Send a password reset email
// -------------------------------------------------------
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent to $email');
      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      print('❌ Password reset error: ${e.code}');
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        return AuthResult(success: false, errorKey: 'user_not_found');
      }
      if (e.code == 'invalid-email') {
        return AuthResult(success: false, errorKey: 'invalid_email');
      }
      return AuthResult(
        success: false,
        errorKey: 'password_reset_failed', // Removed errorArgs
      );
    } catch (e) {
      print('❌ Unexpected error: $e');
      return AuthResult(success: false, errorKey: 'unexpected_error');
    }
  }
  // ------------------------------------------------------------------------
// WANT TO CHANGE PASSWORD : CHECK IF ITS A GOOGLE SIGN IN OR NOT FIRST
// --------------------------------------------------------------------------

// Check if the user signed in with Google
  bool isGoogleUser() {
    final user = _auth.currentUser;
    if (user == null) return false;

    // Check provider data for 'google.com'
    for (final profile in user.providerData) {
      if (profile.providerId == 'google.com') return true;
    }
    return false;
  }

// Change Password Logic
  Future<AuthResult?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user == null || user.email == null) {
        return AuthResult(
            success: false, errorKey: 'change_password_user_not_found');
      }

      // 1. Re-authenticate the user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // 2. Update the password
      await user.updatePassword(newPassword);

      return AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      print('❌ Change password error: ${e.code}');
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return AuthResult(
            success: false, errorKey: 'change_password_wrong_password');
      }
      return AuthResult(
        success: false,
        errorKey: 'auth_generic_message', // Removed errorArgs
      );
    } catch (e) {
      return AuthResult(success: false, errorKey: 'unexpected_error');
    }
  }
  // -------------------------------------------------------
  // LOGOUT: Sign out from both Firebase and Google
  // -------------------------------------------------------
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    print('✅ Logout successful');
  }
}


// helper class for localizing back end errors
class AuthResult {
  final bool success;
  final String? errorKey;
  final List<String>? errorArgs;

  AuthResult({required this.success, this.errorKey, this.errorArgs});
}