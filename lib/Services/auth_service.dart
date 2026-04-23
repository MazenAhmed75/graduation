import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
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
  Future<String?> register({
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
      return null; // Success

    } on FirebaseAuthException catch (e) {
      print('❌ Registration error: ${e.code}');
      if (e.code == 'email-already-in-use') {
        return 'This email is already registered.';
      }
      if (e.code == 'weak-password') {
        return 'Password must be at least 6 characters.';
      }
      if (e.code == 'invalid-email') {
        return 'Please enter a valid email address.';
      }
      return 'Registration failed: ${e.message}';
    } catch (e) {
      print('❌ Unexpected error: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // -------------------------------------------------------
  // LOGIN: Sign in with email and password
  // -------------------------------------------------------
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Login successful');
      return null; // Success

    } on FirebaseAuthException catch (e) {
      print('❌ Login error: ${e.code}');
      if (e.code == 'user-not-found') {
        return 'No account found with this email.';
      }
      if (e.code == 'wrong-password') {
        return 'Incorrect password.';
      }
      if (e.code == 'invalid-email') {
        return 'Please enter a valid email address.';
      }
      return 'Login failed: ${e.message}';
    } catch (e) {
      print('❌ Unexpected error: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // -------------------------------------------------------
  // GOOGLE SIGN-IN: Sign in with Google account
  // -------------------------------------------------------
  Future<String?> signInWithGoogle() async {
    try {
      // Step 1: Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return 'Google sign-in cancelled.';
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

      return null; // Success

    } catch (e) {
      print('❌ Google sign-in error: $e');
      return 'Google sign-in failed. Please try again.';
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