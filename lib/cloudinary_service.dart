import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudinaryService {
  static const String cloudName = 'dfslzepiy';
  static const String uploadPreset = 'fitmind_images';

  static final CloudinaryPublic _cloudinary =
      CloudinaryPublic(cloudName, uploadPreset, cache: false);

  /// Upload a profile image to Cloudinary and save URL to Firebase
  static Future<String?> uploadProfileImage(
    List<int> imageBytes,
    String fileName,
  ) async {
    try {
      // Upload to Cloudinary
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          imageBytes,
          identifier: fileName,
          folder: 'profile_images',
        ),
      );

      String imageUrl = response.secureUrl;

      // Update Firebase with the image URL
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'profileImageUrl': imageUrl,
          'profileImageUpdatedAt': DateTime.now().toIso8601String(),
        });
      }

      return imageUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      rethrow;
    }
  }

  /// Retrieve profile image URL from Firebase
  static Future<String?> getProfileImageUrl() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        return data?['profileImageUrl'];
      }
    } catch (e) {
      print('Error retrieving profile image URL: $e');
    }
    return null;
  }

  /// Delete profile image from Cloudinary (optional)
  static Future<void> deleteProfileImage(String publicId) async {
    try {
      // Note: Deleting from Cloudinary requires authenticated requests
      // This is a placeholder - implement according to your needs
      print('Delete functionality would require API key in backend');
    } catch (e) {
      print('Error deleting profile image: $e');
      rethrow;
    }
  }
}
