import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageUploadService {
  // TODO: Replace with your actual image upload endpoint or cloud storage service
  static const String uploadEndpoint = 'https://your-api.com/upload';
  
  /// Upload image to server/cloud storage and return the public URL
  /// 
  /// For production, you should integrate with:
  /// - AWS S3
  /// - Cloudinary
  /// - Firebase Storage
  /// - Your own backend upload endpoint
  static Future<String> uploadProfilePhoto({
    required File imageFile,
    required String userId,
    required String authToken,
  }) async {
    try {
      if (kDebugMode) {
        print('📤 Uploading profile photo...');
        print('File path: ${imageFile.path}');
        print('File size: ${await imageFile.length()} bytes');
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(uploadEndpoint),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $authToken';

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'profilePhoto',
          imageFile.path,
        ),
      );

      // Add additional fields
      request.fields['userId'] = userId;
      request.fields['type'] = 'profile';

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('Upload response: ${response.statusCode}');
        print('Upload body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final imageUrl = data['url'] ?? data['data']?['url'];
        
        if (imageUrl == null) {
          throw Exception('No image URL in response');
        }
        
        if (kDebugMode) {
          print('✅ Image uploaded successfully: $imageUrl');
        }
        
        return imageUrl;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Upload error: $e');
      }
      rethrow;
    }
  }

  /// Example: Upload to Cloudinary
  static Future<String> uploadToCloudinary({
    required File imageFile,
    required String cloudName,
    required String uploadPreset,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'profile_photos';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'];
      } else {
        throw Exception('Cloudinary upload failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Cloudinary upload error: $e');
      }
      rethrow;
    }
  }

  /// Example: Upload to Firebase Storage
  /// Note: Requires firebase_storage package
  /// 
  /// ```dart
  /// import 'package:firebase_storage/firebase_storage.dart';
  /// 
  /// static Future<String> uploadToFirebase({
  ///   required File imageFile,
  ///   required String userId,
  /// }) async {
  ///   try {
  ///     final ref = FirebaseStorage.instance
  ///         .ref()
  ///         .child('profile_photos')
  ///         .child('$userId.jpg');
  ///     
  ///     await ref.putFile(imageFile);
  ///     final url = await ref.getDownloadURL();
  ///     return url;
  ///   } catch (e) {
  ///     print('Firebase upload error: $e');
  ///     rethrow;
  ///   }
  /// }
  /// ```
}
