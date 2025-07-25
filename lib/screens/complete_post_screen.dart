import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_colors.dart';
import '../services/post_service.dart';
import '../utils/image_picker_utils.dart';
import '../utils/platform_image.dart';

class CompletePostScreen extends StatefulWidget {
  final String? challengeId;
  final String? challengeContent;
  final String? postId; // For updating existing draft

  const CompletePostScreen({
    super.key,
    this.challengeId,
    this.challengeContent,
    this.postId,
  });

  @override
  State<CompletePostScreen> createState() => _CompletePostScreenState();
}

class _CompletePostScreenState extends State<CompletePostScreen> {
  final TextEditingController _textController = TextEditingController();
  XFile? _selectedImage; // Always XFile from image_picker
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final image = await ImagePickerUtils.showImageSourceDialog(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _submitPost() async {
    final hasImage = _selectedImage != null;
    final hasText = _textController.text.trim().isNotEmpty;
    
    // At least one of image or text must be provided
    if (!hasImage && !hasText) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add either an image or some text to share your story'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.postId != null) {
        // Updating existing draft
        await PostService.updateDraftPost(
          postId: widget.postId!,
          userId: user.uid,
          challengeId: widget.challengeId!,
          text: _textController.text,
          image: _selectedImage,
        );
      } else {
        // Creating new post
        if (hasImage) {
          // Post with image
          await PostService.completePost(
            userId: user.uid,
            challengeId: widget.challengeId!,
            text: _textController.text,
            image: _selectedImage!,
          );
        } else {
          // Post with text only
          await PostService.completeTextPost(
            userId: user.uid,
            challengeId: widget.challengeId!,
            text: _textController.text,
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your kindness has bloomed! 🌸 Post shared successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Go back to bloom board and refresh
      Navigator.of(context).pop(true); // Return true to indicate success
    } catch (e) {

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
                      '${e.toString()}',
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
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          'Complete Your Kindness',
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
                    'Post',
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPink.withOpacity(0.1),
                    AppColors.primaryPink.withOpacity(0.05),
                  ],
                ),
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Challenge',
                        style: TextStyle(
                          fontFamily: 'Tommy',
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryPink,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.challengeContent ?? 'Complete this challenge',
                    style: const TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w500,
                      color: AppColors.brownFont,
                      fontSize: 14,
                      height: 1.4,
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
            const SizedBox(height: 8),
            Text(
              'Show the world your act of kindness! 📸',
              style: TextStyle(
                fontFamily: 'Tommy',
                color: AppColors.brownFont.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _selectImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: _selectedImage != null 
                      ? Colors.transparent 
                      : AppColors.primaryPink.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedImage != null 
                        ? AppColors.primaryPink.withOpacity(0.3)
                        : AppColors.primaryPink.withOpacity(0.2),
                    width: 2,
                    style: _selectedImage != null 
                        ? BorderStyle.solid 
                        : BorderStyle.solid,
                  ),
                ),
                child: _selectedImage != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: PlatformImage(
                              imageFile: _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IconButton(
                                onPressed: _selectImage,
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 48,
                            color: AppColors.primaryPink.withOpacity(0.6),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to add photo',
                            style: TextStyle(
                              fontFamily: 'Tommy',
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryPink.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Add photo or text below to complete',
                            style: TextStyle(
                              fontFamily: 'Tommy',
                              color: AppColors.brownFont.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Story Text Field
            Row(
              children: [
                const Text(
                  'Share Your Story',
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
            const SizedBox(height: 8),
            Text(
              'Share your experience, thoughts, or describe how you completed this challenge ✨',
              style: TextStyle(
                fontFamily: 'Tommy',
                color: AppColors.brownFont.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe your act of kindness, share what you learned, or tell your story...',
                hintStyle: TextStyle(
                  fontFamily: 'Tommy',
                  color: AppColors.brownFont.withOpacity(0.5),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryPink.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryPink.withOpacity(0.3)),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(
                fontFamily: 'Tommy',
                color: AppColors.brownFont,
                fontSize: 14,
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
                      'Add a photo OR write about your experience (or both!) to complete your post',
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
            const SizedBox(height: 8),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitPost,
                icon: _isLoading 
                    ? const SizedBox.shrink()
                    : const Icon(Icons.local_florist, color: Colors.white),
                label: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Sharing your kindness...',
                            style: TextStyle(
                              fontFamily: 'Tommy',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Share Your Kindness 🌸',
                        style: TextStyle(
                          fontFamily: 'Tommy',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
