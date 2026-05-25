// ignore_for_file: file_names, avoid_print, unnecessary_non_null_assertion

import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';

class StorageService {
  //  Free Cloudinary credentials — sign up at cloudinary.com
  static const String _cloudName = 'dmuhbahmn';
  static const String _uploadPreset = 'mindful_curator'; // unsigned preset

  /// Upload to Cloudinary (free) and save URL to Firestore (free)
  Future<String> uploadProfilePicture(
      BuildContext context,
      String userId,
      Uint8List imageBytes,
      ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      // Convert bytes to base64
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        uri,
        body: {
          'file': 'data:image/jpeg;base64,$base64Image',
          'upload_preset': _uploadPreset,
          'public_id': 'profile_$userId', // consistent name = auto overwrites old pic
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception(
          '${l10n.cloudinaryUploadFailed}: ${response.body}',
        );
      }

      final data = jsonDecode(response.body);
      final imageUrl = data['secure_url'] as String;

      //  Save URL to Firestore (only the URL, not the image)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({'profilePicUrl': imageUrl}, SetOptions(merge: true));

      print('✅ Uploaded to Cloudinary: $imageUrl');
      return imageUrl;

    } catch (e) {
      print('❌ Upload error: $e');
      throw Exception(
        '${l10n.failedToUpload}: $e',
      );
    }
  }
}