import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageService {
  // ============================================================
  // CLOUDINARY CONFIGURATION
  // Free Cloudinary account credentials.
  // Images are uploaded using an unsigned upload preset.
  // ============================================================
  static const String _cloudName = 'dmuhbahmn';
  static const String _uploadPreset = 'mindful_curator';

  // -------------------------------------------------------
  // UPLOAD: Sends image to Cloudinary and returns the URL
  //
  // This service ONLY handles storage operations.
  // The caller (typically ProfileScreen) is responsible
  // for saving the returned URL to Firestore through
  // UserService.updatePhotoUrl().
  // -------------------------------------------------------
  Future<String> uploadProfilePicture(
      String userId,
      Uint8List imageBytes,
      ) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      // Convert image bytes to Base64 so they can be
      // sent inside the HTTP request body.
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        uri,
        body: {
          'file': 'data:image/jpeg;base64,$base64Image',
          'upload_preset': _uploadPreset,

          // Consistent name = automatically overwrites
          // the previous profile picture for this user.
          'public_id': 'profile_$userId',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('cloudinary_upload_failed');
      }

      final data = jsonDecode(response.body);

      // Cloudinary returns a public HTTPS URL that can be
      // stored in Firestore and displayed in the app.
      final imageUrl = data['secure_url'] as String;

      // We intentionally DO NOT write to Firestore here.
      // Returning the URL keeps StorageService focused on
      // storage responsibilities only.
      return imageUrl;
    } catch (e) {
      throw Exception('failed_to_upload');
    }
  }

  // -------------------------------------------------------
  // DELETE PROFILE PHOTO
  //
  // Cloudinary deletions require a secure backend because
  // the API secret must never be exposed in Flutter client
  // code.
  //
  // Therefore, we do not delete the file directly from the
  // mobile app.
  //
  // Instead:
  // 1. ProfileScreen calls this method.
  // 2. UserService.updatePhotoUrl('') clears Firestore.
  // 3. The Cloudinary image becomes unreferenced.
  // 4. The next upload automatically overwrites the old file
  //    because the same public_id is reused.
  // -------------------------------------------------------
  Future<void> deleteProfilePicture(String userId) async {
    // No client-side Cloudinary deletion required.
    // Firestore cleanup is handled by UserService.
    return;
  }
}