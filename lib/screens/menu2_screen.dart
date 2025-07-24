import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../constants/app_colors.dart';
import '../constants/globals.dart';
import '../models/kindness_post.dart';
import '../models/challenge.dart';
import '../services/challenge_service.dart';
import '../widgets/like_button.dart';
import '../widgets/post_detail_dialog.dart'; 

class Menu2Screen extends StatefulWidget {
  const Menu2Screen({super.key});

  @override
  State<Menu2Screen> createState() => _Menu2ScreenState();
}

class _Menu2ScreenState extends State<Menu2Screen> {
  List<KindnessPost> posts = [];
  bool isLoading = true;
  String? errorMessage;
  Challenge? currentChallenge;
  User? currentUser;
  
  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser; 
    fetchCurrentChallengeAndPosts();
  }

  Future<void> fetchCurrentChallengeAndPosts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final challenge = await ChallengeService.fetchActiveChallenge();
      
      if (challenge != null) {
        setState(() {
          currentChallenge = challenge;
        });

        await fetchPostsForChallenge(challenge.id);
      } else {
        setState(() {
          errorMessage = 'No active challenge found';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading challenge: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> fetchPostsForChallenge(String challengeId) async {
    try {
      String url = '$apiBaseUrl/post/$challengeId';
      if (currentUser != null) {
        url += '/?userId=${currentUser!.uid}';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        
        List<dynamic> postsData;
        if (data is List) {
          postsData = data;
        } else if (data is Map && data['posts'] != null) {
          postsData = data['posts'] as List;
        } else {
          postsData = [data];
        }
        
        setState(() {
          posts = postsData.map((json) => KindnessPost.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load posts';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading posts: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> refreshPosts() async {
    currentUser = FirebaseAuth.instance.currentUser;
    await fetchCurrentChallengeAndPosts();
  }

  // Simple callback untuk refresh posts setelah like
  void _onLikeChanged() {
    if (currentChallenge != null) {
      fetchPostsForChallenge(currentChallenge!.id);
    }
  }

  // Show post detail dialog
  void _showPostDetail(KindnessPost post) {
    showDialog(
      context: context,
      builder: (context) => PostDetailDialog(
        post: post,
        onLikeChanged: _onLikeChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Kindness Walls',
          style: TextStyle(
            fontFamily: 'CuteLove',
            fontWeight: FontWeight.w700,
            color: AppColors.blueFont,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: currentUser != null 
                      ? AppColors.primaryBlue.withOpacity(0.1)
                      : AppColors.brownFont.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  currentUser != null ? 'Logged In' : 'Guest',
                  style: TextStyle(
                    fontFamily: 'Tommy',
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: currentUser != null 
                        ? AppColors.blueFont
                        : AppColors.brownFont,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshPosts,
        color: AppColors.primaryBlue,
        child: Column(
          children: [
            // Sticky challenge section
            if (currentChallenge != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Challenge',
                            style: TextStyle(
                              fontFamily: 'Tommy',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppColors.blueFont,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentChallenge!.cleanContent,
                            style: const TextStyle(
                              fontFamily: 'Tommy',
                              fontWeight: FontWeight.w400,
                              fontSize: 11,
                              color: AppColors.brownFont,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            // Main content
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    )
                  : errorMessage != null
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: AppColors.brownFont.withOpacity(0.6),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    errorMessage!,
                                    style: const TextStyle(
                                      fontFamily: 'Tommy',
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.brownFont,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : posts.isEmpty
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.6,
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'No posts yet!\nBe the first to share your kindness.',
                                        style: TextStyle(
                                          fontFamily: 'Tommy',
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.brownFont,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GridView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  return _buildPostCard(posts[index]);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildPostCard(KindnessPost post) {
  return GestureDetector(
    onTap: () => _showPostDetail(post),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                color: AppColors.primaryBlue.withOpacity(0.1),
              ),
              child: post.imageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        post.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            child: const Icon(
                              Icons.image,
                              size: 48,
                              color: AppColors.blueFont,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryBlue.withOpacity(0.2),
                            AppColors.secondaryBlue.withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite,
                          size: 32,
                          color: AppColors.blueFont,
                        ),
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Content with "tap to read more" hint
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            post.content,
                            style: const TextStyle(
                              fontFamily: 'Tommy',
                              fontWeight: FontWeight.w400,
                              fontSize: 12, 
                              color: AppColors.brownFont,
                              height: 1.3,
                            ),
                            maxLines: 3, 
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (post.content.length > 50)
                          const Text(
                            'Tap to read more...',
                            style: TextStyle(
                              fontFamily: 'Tommy',
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              color: AppColors.primaryBlue,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Bottom row with like and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LikeButton(
                        postId: post.id,
                        likesCount: post.likesCount,
                        isLiked: post.isLiked,
                        onLikeChanged: _onLikeChanged, 
                      ),
                      Text(
                        _formatTime(post.createdAt),
                        style: TextStyle(
                          fontFamily: 'Tommy',
                          fontWeight: FontWeight.w400,
                          fontSize: 9,
                          color: AppColors.brownFont.withOpacity(0.6),
                        ),
                      ),
                    ],
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
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}