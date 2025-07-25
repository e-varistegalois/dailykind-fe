import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io' if (dart.library.html) 'dart:html';

class ImagePickerUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Show dialog to choose image source (camera or gallery)
  /// Returns XFile for web compatibility, File for mobile
  static Future<dynamic> showImageSourceDialog(BuildContext context) async {
    final ImageSource? source = await showDialog<ImageSource?>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Select Image Source',
            style: TextStyle(
              fontFamily: 'Tommy',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(dialogContext).pop(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(dialogContext).pop(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (source != null) {
      return _pickImage(source);
    }
    return null;
  }

  /// Pick image from specified source
  /// Returns XFile for web compatibility, File for mobile
  static Future<dynamic> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // Return XFile for web
          return pickedFile;
        } else {
          // Return File for mobile/desktop
          return File(pickedFile.path);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      // If permission is denied, show a helpful message
      if (e.toString().contains('photo_access_denied') || 
          e.toString().contains('camera_access_denied')) {
        debugPrint('Permission denied. Please enable camera/photo access in Settings.');
      }
      return null;
    }
  }

  /// Pick image directly from gallery
  static Future<dynamic> pickImageFromGallery() async {
    return _pickImage(ImageSource.gallery);
  }

  /// Pick image directly from camera
  static Future<dynamic> pickImageFromCamera() async {
    return _pickImage(ImageSource.camera);
  }
}
