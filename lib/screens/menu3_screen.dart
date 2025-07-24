import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../constants/globals.dart';
import '../models/kindness_post.dart';

class Menu3Screen extends StatefulWidget {
  const Menu3Screen({super.key});

  @override
  State<Menu3Screen> createState() => _Menu3ScreenState();
}

class _Menu3ScreenState extends State<Menu3Screen> {
  List<KindnessPost> userPosts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserPosts();
  }

  Future<void> fetchUserPosts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'User not logged in';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/post/user/${user.uid}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        
        // Handle single object response
        if (data is Map) {
          // If the response contains a list of posts
          if (data['posts'] != null && data['posts'] is List) {
            final postsData = data['posts'] as List;
            setState(() {
              userPosts = postsData.map((json) => KindnessPost.fromJson(json as Map<String, dynamic>)).toList();
              isLoading = false;
            });
          } else {
            // If it's a single post object
            setState(() {
              userPosts = [KindnessPost.fromJson(data as Map<String, dynamic>)];
              isLoading = false;
            });
          }
        } else if (data is List) {
          setState(() {
            userPosts = data.map((json) => KindnessPost.fromJson(json as Map<String, dynamic>)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Unexpected response format';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load your kindness posts';
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
    await fetchUserPosts();
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
          'Bloom Board',
          style: TextStyle(
            fontFamily: 'CuteLove',
            fontWeight: FontWeight.w700,
            color: AppColors.yellowFont,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: refreshPosts,
        color: AppColors.primaryBlue,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                ),
              )
            : errorMessage != null
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
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
                            const SizedBox(height: 24),
                            Text(
                              'Pull to refresh',
                              style: TextStyle(
                                fontFamily: 'Tommy',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: AppColors.brownFont.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : userPosts.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.local_florist,
                                  size: 64,
                                  color: AppColors.yellowFont,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No blooms yet!\nComplete some challenges to grow your garden.',
                                  style: TextStyle(
                                    fontFamily: 'Tommy',
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brownFont,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: userPosts.length,
                          itemBuilder: (context, index) {
                            return _buildCompletedChallengeCard(userPosts[index]);
                          },
                        ),
                      ),
      ),
    );
  }

  Widget _buildCompletedChallengeCard(KindnessPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.yellowFont.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.yellowFont.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with completion badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.yellowFont.withOpacity(0.1),
                  AppColors.yellowFont.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.yellowFont,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_florist,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Challenge Completed!',
                    style: TextStyle(
                      fontFamily: 'CuteLove',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.yellowFont,
                    ),
                  ),
                ),
                Text(
                  _formatDate(post.createdAt),
                  style: TextStyle(
                    fontFamily: 'Tommy',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: AppColors.brownFont.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.content,
                  style: const TextStyle(
                    fontFamily: 'Tommy',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.brownFont,
                    height: 1.4,
                  ),
                ),
                if (post.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      post.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.yellowFont.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: AppColors.yellowFont,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Stats row
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: Colors.red.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likesCount} likes',
                      style: TextStyle(
                        fontFamily: 'Tommy',
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.brownFont.withOpacity(0.8),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.yellowFont.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '🌸 Bloomed',
                        style: TextStyle(
                          fontFamily: 'Tommy',
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: AppColors.yellowFont,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}