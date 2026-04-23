import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile picture to Firebase Storage
  /// Returns the download URL of the uploaded image
  /// Updated to accept Uint8List for cross-platform support
  Future<String> uploadProfilePicture(String userId, Uint8List imageBytes) async {
    try {
      // Create a reference to the storage location
      // Path: profile_pictures/{userId}/profile.jpg
      final ref = _storage.ref().child('profile_pictures/$userId/profile.jpg');

      // Upload the bytes directly using putData
      // Added SettableMetadata to ensure the file is recognized as an image
      final uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ Profile picture uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading profile picture: $e');
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Delete profile picture from Firebase Storage
  Future<void> deleteProfilePicture(String userId) async {
    try {
      final ref = _storage.ref().child('profile_pictures/$userId/profile.jpg');
      await ref.delete();
      print('✅ Profile picture deleted');
    } catch (e) {
      print('⚠️ Error deleting profile picture: $e');
      // Don't throw error - it's okay if file doesn't exist
    }
  }
}