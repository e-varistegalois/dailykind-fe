import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';
import '../models/challenge.dart';
import '../services/post_service.dart';
import '../utils/image_picker_utils.dart';
import '../utils/platform_image.dart';

class CreatePostScreen extends StatefulWidget {
  final Challenge challenge;

  const CreatePostScreen({
    super.key,
    required this.challenge,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  XFile? _selectedImage; // Always XFile from image_picker
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    try {
      final image = await ImagePickerUtils.showImageSourceDialog(context);
      if (image != null && mounted) {
        debugPrint('Image selected: ${image.runtimeType}');
        
        // Check file properties safely
        try {
          // Check if it has length method (both XFile and File have this)
          if (image.runtimeType.toString().contains('XFile')) {
            final size = await image.length();
            debugPrint('XFile size: $size bytes');
            debugPrint('XFile path: ${image.path}');
          } else {
            // For File or other types that might have these methods
            try {
              final size = await image.length();
              debugPrint('Image size: $size bytes');
              debugPrint('Image path: ${image.path}');
            } catch (e) {
              debugPrint('Could not get size: $e');
            }
          }
        } catch (e) {
          debugPrint('Error checking image properties: $e');
        }
        
        if (mounted) {
          setState(() {
            _selectedImage = image as XFile;
          });
        }
      } else {
        debugPrint('No image selected or widget unmounted');
      }
    } catch (e) {
      debugPrint('Error in _selectImage: $e');
      if (mounted) {
        String message = 'Unable to access camera or photo library.';
        
        // Handle specific error messages
        if (e.toString().contains('Photo library access denied') || 
            e.toString().contains('Camera access denied')) {
          message = e.toString();
        } else if (e.toString().contains('Image picker service unavailable')) {
          message = e.toString();
        } else if (e.toString().contains('channel-error') || 
                   e.toString().contains('Unable to establish connection')) {
          message = 'Image picker service unavailable. Please restart the app and try again.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  Future<void> _submitPost() async {
    final hasImage = _selectedImage != null;
    final hasText = _textController.text.trim().isNotEmpty;
    
    debugPrint('Submit post - hasImage: $hasImage, hasText: $hasText');
    if (hasImage) {
      debugPrint('Selected image path: ${_selectedImage!.path}');
      try {
        final exists = await _selectedImage!.exists();
        debugPrint('Image exists: $exists');
      } catch (e) {
        debugPrint('Error checking image: $e');
      }
    }
    debugPrint('Text content: "${_textController.text}"');
    
    // At least one of image or text must be provided
    if (!hasImage && !hasText) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add either an image or some text to share your story'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      if (hasImage) {
        // Post with image (and optional text)
        await PostService.uploadPost(
          userId: user.uid,
          challengeId: widget.challenge.id,
          text: _textController.text,
          image: _selectedImage!,
        );
      } else {
        // Post with text only (no image)
        await PostService.uploadTextPost(
          userId: user.uid,
          challengeId: widget.challenge.id,
          text: _textController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post shared successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      String errorMessage = e.toString();
      
      if (mounted) {
        showDialog(
          context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.shade50,
                  Colors.red.shade100.withOpacity(0.5),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Error Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  const Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: AppColors.brownFont,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  
                  // Error Message
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$errorMessage',
                      style: const TextStyle(
                        fontFamily: 'Tommy',
                        fontSize: 14,
                        color: AppColors.brownFont,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // OK Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontFamily: 'Tommy',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Share Your Kindness',
          style: TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: AppColors.brownFont,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
                    ),
                  )
                : const Text(
                    'Share',
                    style: TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryPink,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Challenge Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryPink.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: AppColors.primaryPink,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Challenge',
                        style: TextStyle(
                          fontFamily: 'Tommy',
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryPink,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.challenge.content,
                    style: const TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownFont,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Image Selection
            Row(
              children: [
                const Text(
                  'Add a Photo',
                  style: TextStyle(
                    fontFamily: 'Tommy',
                    fontWeight: FontWeight.w600,
                    color: AppColors.brownFont,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Optional',
                    style: TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryPink,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _selectImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: PlatformImage(
                          imageFile: _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add photo',
                            style: TextStyle(
                              fontFamily: 'Tommy',
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add photo or text below to complete',
                            style: TextStyle(
                              fontFamily: 'Tommy',
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Caption
            Row(
              children: [
                const Text(
                  'Tell Your Story',
                  style: TextStyle(
                    fontFamily: 'Tommy',
                    fontWeight: FontWeight.w600,
                    color: AppColors.brownFont,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Optional',
                    style: TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryPink,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share how you completed this challenge...',
                hintStyle: TextStyle(
                  fontFamily: 'Tommy',
                  color: Colors.grey[500],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryPink),
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Tommy',
                color: AppColors.brownFont,
              ),
            ),
            const SizedBox(height: 24),
            
            // Info section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.yellowFont.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.yellowFont.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.yellowFont,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add a photo OR write about your experience (or both!) to share your post',
                      style: TextStyle(
                        fontFamily: 'Tommy',
                        fontWeight: FontWeight.w500,
                        color: AppColors.yellowFont,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}