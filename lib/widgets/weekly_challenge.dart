import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/challenge.dart';
import '../constants/app_colors.dart';
import '../services/post_service.dart';
import '../screens/complete_post_screen.dart';

class WeeklyChallenge extends StatelessWidget {
  final Challenge challenge;

  const WeeklyChallenge({
    super.key,
    required this.challenge,
  });

  Future<void> _showChallengeOptionsDialog(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Accept Challenge',
            style: TextStyle(
              fontFamily: 'Tommy',
              fontWeight: FontWeight.w700,
              color: AppColors.brownFont,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Great! You\'ve decided to take on this challenge. When would you like to start?',
                style: TextStyle(
                  fontFamily: 'Tommy',
                  fontWeight: FontWeight.w400,
                  color: AppColors.brownFont.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Do it now button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // Show form immediately for "Do it now"
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompletePostScreen(
                          challengeId: challenge.id,
                          challengeContent: challenge.content,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text(
                    'Do it right now!',
                    style: TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Do it later button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _acceptChallenge(context, 'DRAFT');
                  },
                  icon: Icon(Icons.schedule, color: AppColors.primaryPink),
                  label: Text(
                    'Save for later',
                    style: TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryPink,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryPink),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Tommy',
                  fontWeight: FontWeight.w500,
                  color: AppColors.brownFont.withOpacity(0.6),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _acceptChallenge(BuildContext context, String action) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (action == 'DO_NOW') {
      // For "Do it now", go directly to the form without creating a draft
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Let\'s create your post! 🚀'),
          backgroundColor: AppColors.primaryPink,
          duration: Duration(seconds: 1),
        ),
      );
      
      // Navigate to create post screen immediately
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompletePostScreen(
              challengeId: challenge.id,
              challengeContent: challenge.content,
            ),
          ),
        );
      });
      return;
    }

    // For "Save for later", create a draft
    try {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Saving challenge...'),
            ],
          ),
          backgroundColor: AppColors.primaryPink,
          duration: Duration(seconds: 2),
        ),
      );

      // Call API to create draft with challenge content
      await PostService.createDraftPost(
        userId: user.uid,
        challengeId: challenge.id,
        text: '', // Empty text for now
        challengeContent: challenge.content, // Pass the real challenge content
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Challenge saved to your Bloom Board! You can complete it anytime 📝'),
          backgroundColor: AppColors.primaryPink,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oops! Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryPink.withOpacity(0.1),
                AppColors.secondaryPink.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weekly Challenge',
                            style: TextStyle(
                              fontFamily: 'Tommy',
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryPink,
                              fontSize: 18,
                            ),
                          ),
                          if (challenge.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Content
                Text(
                  challenge.cleanContent,
                  style: TextStyle(
                    fontFamily: 'Tommy',
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryPink.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Check if user is logged in
                      final currentUser = FirebaseAuth.instance.currentUser;
                      
                      if (currentUser == null) {
                        // User not logged in, show dialog to sign in
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(16)),
                              ),
                              title: const Text(
                                'Login Required',
                                style: TextStyle(
                                  fontFamily: 'Tommy',
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondaryPink,
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              content: const Text(
                                'Please login to accept challenges.',
                                style: TextStyle(
                                  fontFamily: 'Tommy',
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.secondaryPink,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              actionsAlignment: MainAxisAlignment.center,
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontFamily: 'Tommy',
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryPink,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushNamed(context, '/signin');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondaryPink,
                                    foregroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                    ),
                                    minimumSize: const Size(90, 40),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontFamily: 'Tommy',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // User is logged in, show challenge options dialog
                        _showChallengeOptionsDialog(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPink,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Accept Challenge',
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
  }
}