import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/challenge.dart';
import '../constants/app_colors.dart';

class WeeklyChallenge extends StatelessWidget {
  final Challenge challenge;

  const WeeklyChallenge({
    super.key,
    required this.challenge,
  });

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
                        // User is logged in, accept the challenge
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Challenge accepted! Good luck! 🌟'),
                            backgroundColor: AppColors.primaryPink,
                          ),
                        );
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