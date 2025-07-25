import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../services/post_service.dart';
import '../services/streak_service.dart';
import '../screens/complete_post_screen.dart';

class Menu3Screen extends StatefulWidget {
  const Menu3Screen({super.key});

  @override
  State<Menu3Screen> createState() => _Menu3ScreenState();
}

class _Menu3ScreenState extends State<Menu3Screen> {
  List<Map<String, dynamic>> draftPosts = [];
  List<Map<String, dynamic>> publishedPosts = [];
  Map<String, dynamic>? streakData;
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
      // Fetch posts and streak data in parallel
      final results = await Future.wait([
        PostService.getUserPosts(userId: user.uid),
        StreakService.getUserStreak(userId: user.uid),
      ]);
      
      final posts = results[0];
      final streak = results[1];
      
      debugPrint('Fetched posts from service:');
      debugPrint('Blooming: ${posts['blooming']?.length ?? 0}');
      debugPrint('Bloomed: ${posts['bloomed']?.length ?? 0}');
      debugPrint('Streak data: $streak');
      
      setState(() {
        draftPosts = posts['blooming'] ?? [];
        publishedPosts = posts['bloomed'] ?? [];
        streakData = streak;
        isLoading = false;
      });
      
      debugPrint('State updated - draftPosts: ${draftPosts.length}, publishedPosts: ${publishedPosts.length}');
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading data: ${e.toString()}';
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
                : (draftPosts.isEmpty && publishedPosts.isEmpty)
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
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
                                  'No blooms yet!\nAccept some challenges to grow your garden.',
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
                    : _buildPostsList(),
      ),
    );
  }

  Widget _buildPostsList() {
    debugPrint('Building posts list - draftPosts: ${draftPosts.length}, publishedPosts: ${publishedPosts.length}');
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak Card
          if (streakData != null) _buildStreakCard(),
          
          // Debug info
          if (draftPosts.isNotEmpty || publishedPosts.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Debug: Drafts: ${draftPosts.length}, Published: ${publishedPosts.length}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          
          // Blooming section (Drafts)
          if (draftPosts.isNotEmpty) ...[
            _buildSectionHeader('🌱 Blooming', 'Complete these to make them bloom!'),
            const SizedBox(height: 12),
            ...draftPosts.map((post) => _buildDraftCard(post)),
            const SizedBox(height: 24),
          ],
          
          // Bloomed section (Published)
          if (publishedPosts.isNotEmpty) ...[
            _buildSectionHeader('🌸 Bloomed', 'Your completed kindness acts'),
            const SizedBox(height: 12),
            ...publishedPosts.map((post) => _buildPublishedCard(post)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w700,
            color: AppColors.brownFont,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w400,
            color: AppColors.brownFont.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDraftCard(Map<String, dynamic> post) {
    // Debug: print all available keys and values
    debugPrint('🎯 Draft card data keys: ${post.keys.toList()}');
    debugPrint('🎯 challengeContent: ${post['challengeContent']}');
    debugPrint('🎯 challenge content: ${post['challenge']?['content']}');
    debugPrint('🎯 content: ${post['content']}');
    debugPrint('🎯 challengeId: ${post['challengeId']}');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryPink.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primaryPink,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Ready to complete!',
                    style: TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryPink,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '🌱 Blooming',
                    style: TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: AppColors.primaryPink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post['challenge']?['content'] ?? post['content'] ?? 'Complete this challenge',
              style: const TextStyle(
                fontFamily: 'Tommy',
                fontWeight: FontWeight.w500,
                color: AppColors.brownFont,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Navigate to complete post screen
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompletePostScreen(
                        challengeId: post['challengeId'],
                        challengeContent: post['challenge']?['content'] ?? 'Complete this challenge',
                        postId: post['id'],
                      ),
                    ),
                  );
                  
                  // Refresh if post was completed
                  if (result == true) {
                    fetchUserPosts();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Complete Challenge',
                  style: TextStyle(
                    fontFamily: 'Tommy',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishedCard(Map<String, dynamic> post) {
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
                  _formatDate(post['createdAt']),
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
                  post['content'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Tommy',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.brownFont,
                    height: 1.4,
                  ),
                ),
                if (post['imageUrl'] != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      post['imageUrl'],
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
                      '${post['likesCount'] ?? 0} likes',
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

  Widget _buildStreakCard() {
    final currentStreak = streakData?['currentStreak'] ?? 0;
    final totalChallenges = streakData?['totalChallengesParticipated'] ?? 0;
    
    String streakEmoji = _getStreakEmoji(currentStreak);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPink.withOpacity(0.15),
            AppColors.yellowFont.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryPink.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Left side - emoji and streak number
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryPink,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    streakEmoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$currentStreak',
                    style: const TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    currentStreak == 1 ? 'week' : 'weeks',
                    style: const TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            
            // Right side - info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kindness Streak',
                    style: TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.primaryPink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalChallenges total acts 💝',
                    style: TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: AppColors.brownFont.withOpacity(0.8),
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

  String _getStreakEmoji(int streak) {
    if (streak == 0) return "🌱";
    if (streak <= 3) return "🔥";
    if (streak <= 7) return "⭐";
    if (streak <= 15) return "🎉";
    if (streak <= 30) return "🏆";
    return "👑";
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    
    try {
      final dateTime = DateTime.parse(dateString);
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
    } catch (e) {
      return '';
    }
  }
}