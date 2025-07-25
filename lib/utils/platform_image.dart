import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class PlatformImage extends StatelessWidget {
  final XFile imageFile; // Always XFile from image_picker
  final BoxFit fit;
  final double? width;
  final double? height;

  const PlatformImage({
    super.key,
    required this.imageFile,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Use FutureBuilder with readAsBytes for all platforms
    return FutureBuilder<Uint8List>(
      future: imageFile.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            fit: fit,
            width: width,
            height: height,
          );
        } else if (snapshot.hasError) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.error,
              color: Colors.grey[600],
            ),
          );
        } else {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
