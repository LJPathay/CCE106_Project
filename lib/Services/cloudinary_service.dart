import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';

class CloudinaryService {
  // Cloudinary configuration
  static const String _cloudName = 'dzlqpn3yb';
  static const String _uploadPreset = 'verification_images';
  
  final String _uploadUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/upload';

  Future<String?> uploadImage(dynamic imageFile) async {
    try {
      // Create a unique public ID for the uploaded image
      final publicId = 'verification_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
      
      // Handle both web and mobile file inputs
      late final Uint8List bytes;
      late final String mimeType;
      late final String extension;
      
      if (kIsWeb) {
        // For web, we receive the file as XFile
        final file = imageFile as XFile;
        bytes = await file.readAsBytes();
        mimeType = lookupMimeType(file.name) ?? 'image/jpeg';
        extension = file.name.split('.').last;
      } else {
        // For mobile, we receive a File
        final file = imageFile as File;
        bytes = await file.readAsBytes();
        mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        extension = path.extension(file.path).replaceAll('.', '');
      }

      // Create the multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      
      // Add the file to the request
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'verification_$publicId.$extension',
        contentType: MediaType.parse(mimeType),
      ));
      
      // Add upload preset and public ID for unsigned upload
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['public_id'] = publicId;

      // Track upload progress
      final totalBytes = bytes.length;
      int bytesUploaded = 0;
      
      // Send the request and get the response
      final streamedResponse = await request.send();
      
      // Get the response body as a string
      final responseBody = await streamedResponse.stream.bytesToString();
      
      // Calculate upload progress
      bytesUploaded = totalBytes; // Since we've received the full response
      print('Upload complete: 100.00%');
      
      // Check if the upload was successful
      if (streamedResponse.statusCode == 200) {
        final responseData = json.decode(responseBody);
        return responseData['secure_url'] ?? responseData['url'];
      } else {
        final errorData = json.decode(responseBody);
        throw Exception('Failed to upload image: ${errorData['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      rethrow;
    }
  }
}
