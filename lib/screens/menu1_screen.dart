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
      body: Padding(
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
            // Coming Soon placeholder
            const Expanded(
              child: Center(
                child: Text(
                  'More content coming soon!',
                  style: TextStyle(
                    fontFamily: 'Tommy',
                    fontWeight: FontWeight.w600,
                    color: AppColors.brownFont,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}