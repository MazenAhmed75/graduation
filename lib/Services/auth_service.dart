import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  // These are the Firebase tools we use
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // -------------------------------------------------------
  // Get the currently logged-in user (null if not logged in)
  // -------------------------------------------------------
  User? get currentUser => _auth.currentUser;

  // -------------------------------------------------------
  // A stream that tells us whenever login state changes.
  // Used to decide: show Login screen or Home screen?
  // -------------------------------------------------------
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // -------------------------------------------------------
  // REGISTER: Create a new account
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

      // Step 2: Save user profile in Firestore
      UserModel newUser = UserModel(
        id: result.user!.uid,
        name: name,
        email: email,
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(newUser.toMap());

      return null; // null means success — no error message

    } on FirebaseAuthException catch (e) {
      // Return a readable error message to show in the UI
      if (e.code == 'email-already-in-use') return 'This email is already registered.';
      if (e.code == 'weak-password') return 'Password must be at least 6 characters.';
      return 'Registration failed. Please try again.';
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
      return null; // Success

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'No account found with this email.';
      if (e.code == 'wrong-password') return 'Incorrect password.';
      return 'Login failed. Please try again.';
    }
  }

  // -------------------------------------------------------
  // LOGOUT: Sign out
  // -------------------------------------------------------
  Future<void> logout() async {
    await _auth.signOut();
  }
}