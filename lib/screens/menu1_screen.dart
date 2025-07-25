import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../models/challenge.dart';
import '../services/challenge_service.dart';
import '../widgets/weekly_challenge.dart';

class Menu1Screen extends StatefulWidget {
  const Menu1Screen({super.key});

  @override
  State<Menu1Screen> createState() => _Menu1ScreenState();
}

class _Menu1ScreenState extends State<Menu1Screen> {
  Challenge? challenge;
  bool isLoadingChallenge = true;
  String? challengeError;
  User? currentUser;

  final List<Map<String, String>> items = [
    {
      'title': 'Explore Nature',
      'subtitle': 'Discover beautiful places around you.',
      'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Urban Adventure',
      'subtitle': 'Find hidden gems in the city.',
      'image': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
    },
    {
      'title': 'Cultural Sites',
      'subtitle': 'Experience local culture and history.',
      'image': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Check user authentication status
    currentUser = FirebaseAuth.instance.currentUser;
    
    // Fetch challenge regardless of login status
    fetchWeeklyChallenge();
  }

  Future<void> fetchWeeklyChallenge() async {
    try {
      setState(() {
        isLoadingChallenge = true;
        challengeError = null;
      });
      
      final fetchedChallenge = await ChallengeService.fetchActiveChallenge();
      
      setState(() {
        challenge = fetchedChallenge;
        isLoadingChallenge = false;
      });
    } catch (e) {
      setState(() {
        challengeError = e.toString();
        isLoadingChallenge = false;
      });
    }
  }

  Widget _buildStatCard(String emoji, String number, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.yellowFont.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            number,
            style: const TextStyle(
              fontFamily: 'Tommy',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: AppColors.yellowFont,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Tommy',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: AppColors.brownFont.withOpacity(0.7),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKindnessIdea(String emoji, String idea) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryPink.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              idea,
              style: TextStyle(
                fontFamily: 'Tommy',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppColors.brownFont.withOpacity(0.8),
              ),
            ),
          ),
        ],
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
          'Buzz Feeds',
          style: TextStyle(
            fontFamily: 'CuteLove',
            fontWeight: FontWeight.w700,
            color: AppColors.pinkFont,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Weekly Challenge
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              child: isLoadingChallenge
                  ? const Card(
                      child: SizedBox(
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryPink,
                          ),
                        ),
                      ),
                    )
                  : challengeError != null
                      ? Card(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Failed to load challenge',
                                  style: TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: fetchWeeklyChallenge,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : challenge != null
                          ? WeeklyChallenge(challenge: challenge!)
                          : const SizedBox.shrink(),
            ),
            
            // Motivational Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.yellowFont.withOpacity(0.1),
                    AppColors.primaryPink.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.yellowFont.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.yellowFont,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Main quote
                    const Text(
                      '"Small acts of kindness create ripples of hope that can change the world"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'CuteLove',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColors.brownFont,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Text(
                      'Every kind act you share helps build a more compassionate community. You\'re making a difference! ✨',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Tommy',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.brownFont.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Stats or fun fact
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.yellowFont.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.yellowFont,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Kindness is contagious - spread it everywhere!',
                            style: TextStyle(
                              fontFamily: 'Tommy',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppColors.yellowFont,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Daily Kindness Tips
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPink.withOpacity(0.1),
                    AppColors.primaryPink.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryPink.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPink,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.tips_and_updates,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Daily Kindness Tips',
                          style: TextStyle(
                            fontFamily: 'Tommy',
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryPink,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Tip cards
                    ...[
                      '💝 Smile at a stranger - it costs nothing but can brighten their entire day',
                      '🌱 Hold the door open for someone behind you',
                      '☕ Buy coffee for the person in line behind you',
                      '📝 Write a thank you note to someone who helped you',
                    ].map((tip) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryPink.withOpacity(0.1),
                        ),
                      ),
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontFamily: 'Tommy',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: AppColors.brownFont.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            
            // Quick Kindness Ideas
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPink.withOpacity(0.1),
                    AppColors.yellowFont.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryPink.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shuffle,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Quick Kindness Ideas',
                          style: TextStyle(
                            fontFamily: 'Tommy',
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A4480), // Darker blue
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '🎲',
                            style: TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Need inspiration? Here\'s a random act of kindness:',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Tommy',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColors.brownFont,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.yellowFont.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Send a positive message to someone who inspired you recently',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Tommy',
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF1A4480), // Darker blue
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Coming Soon placeholder
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 48,
                    color: AppColors.primaryPink.withOpacity(0.6),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'More inspiring content coming soon!',
                    style: TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownFont,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stay tuned for daily inspiration and kindness tips',
                    style: TextStyle(
                      fontFamily: 'Tommy',
                      fontWeight: FontWeight.w400,
                      color: AppColors.brownFont.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
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