import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/kindness_post.dart';
import 'like_button.dart';

class PostDetailDialog extends StatefulWidget {
  final KindnessPost post;
  final VoidCallback onLikeChanged;

  const PostDetailDialog({
    super.key,
    required this.post,
    required this.onLikeChanged,
  });

  @override
  State<PostDetailDialog> createState() => _PostDetailDialogState();
}

class _PostDetailDialogState extends State<PostDetailDialog> {
  void _handleLikeChanged() {
    // Call the parent's onLikeChanged callback
    widget.onLikeChanged();
    // Force rebuild of this dialog to reflect any state changes
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Kindness Post',
                      style: TextStyle(
                        fontFamily: 'Tommy',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.blueFont,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.blueFont,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image section
                    if (widget.post.imageUrl != null)
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          maxHeight: 300,
                        ),
                        child: Image.network(
                          widget.post.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  size: 48,
                                  color: AppColors.blueFont,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    // Text content section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.post.content.isNotEmpty) ...[
                            Text(
                              widget.post.content,
                              style: const TextStyle(
                                fontFamily: 'Tommy',
                                fontWeight: FontWeight.w400,
                                fontSize: 14, 
                                color: AppColors.brownFont,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          // Like button and timestamp
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LikeButton(
                                postId: widget.post.id,
                                likesCount: widget.post.likesCount,
                                isLiked: widget.post.isLiked,
                                onLikeChanged: _handleLikeChanged,
                              ),
                              Text(
                                _formatTime(widget.post.createdAt),
                                style: TextStyle(
                                  fontFamily: 'Tommy',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10,
                                  color: AppColors.brownFont.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}