import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../services/like_service.dart';
import '../utils/dialog_utils.dart';

class LikeButton extends StatefulWidget {
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
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late bool _isLiked;
  late int _likesCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likesCount = widget.likesCount;
  }

  @override
  void didUpdateWidget(LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state when widget properties change
    if (oldWidget.isLiked != widget.isLiked || oldWidget.likesCount != widget.likesCount) {
      _isLiked = widget.isLiked;
      _likesCount = widget.likesCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleLike(context),
      child: Row(
        children: [
          Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            size: 16,
            color: _isLiked ? Colors.red : AppColors.brownFont.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
          Text(
            '$_likesCount',
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

    setState(() {
      _isLiked = !_isLiked;
      _likesCount = _isLiked ? _likesCount + 1 : _likesCount - 1;
    });

    final success = await LikeService.toggleLike(widget.postId, currentUser.uid);
    
    if (success) {
      widget.onLikeChanged();
    } else {
      setState(() {
        _isLiked = !_isLiked;
        _likesCount = _isLiked ? _likesCount + 1 : _likesCount - 1;
      });
      
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