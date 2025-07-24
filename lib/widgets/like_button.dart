import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../services/like_service.dart';
import '../utils/dialog_utils.dart';

class LikeButton extends StatelessWidget {
  final String postId;
  final int likesCount;
  final bool isLiked;
  final VoidCallback onLikeChanged;

  const LikeButton({
    super.key,
    required this.postId,
    required this.likesCount,
    required this.isLiked,
    required this.onLikeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleLike(context),
      child: Row(
        children: [
          Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            size: 16,
            color: isLiked ? Colors.red : AppColors.brownFont.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
          Text(
            '$likesCount',
            style: TextStyle(
              fontFamily: 'Tommy',
              fontWeight: FontWeight.w500,
              fontSize: 10,
              color: AppColors.brownFont.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLike(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      DialogUtils.showLoginRequired(context);
      return;
    }

    final success = await LikeService.toggleLike(postId, currentUser.uid);
    
    if (success) {
      onLikeChanged();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update like status'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}