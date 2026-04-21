import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper: Get the path to a user's document
  DocumentReference _userDoc(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  // -------------------------------------------------------
  // STREAM: Listen to user profile in real-time
  // -------------------------------------------------------
  Stream<UserModel?> getUserStream(String userId) {
    return _userDoc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    });
  }

  // -------------------------------------------------------
  // READ: Get user profile once (not a stream)
  // -------------------------------------------------------
  Future<UserModel?> getUser(String userId) async {
    DocumentSnapshot doc = await _userDoc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  // -------------------------------------------------------
  // UPDATE: Change user name
  // -------------------------------------------------------
  Future<void> updateName(String userId, String newName) async {
    await _userDoc(userId).update({'name': newName});
  }

  // -------------------------------------------------------
  // UPDATE: Change monthly savings goal
  // -------------------------------------------------------
  Future<void> updateSavingsGoal(String userId, double newGoal) async {
    await _userDoc(userId).update({'monthlySavingsGoal': newGoal});
  }

  // -------------------------------------------------------
  // UPDATE: Change current savings amount
  // -------------------------------------------------------
  Future<void> updateCurrentSavings(String userId, double amount) async {
    await _userDoc(userId).update({'savingsCurrentAmount': amount});
  }

  // -------------------------------------------------------
  // UPDATE: Toggle notifications on/off
  // -------------------------------------------------------
  Future<void> updateNotifications(String userId, bool enabled) async {
    await _userDoc(userId).update({'notificationsEnabled': enabled});
  }

  // -------------------------------------------------------
  // UPDATE: Change profile photo URL
  // -------------------------------------------------------
  Future<void> updatePhotoUrl(String userId, String photoUrl) async {
    await _userDoc(userId).update({'photoUrl': photoUrl});
  }
}