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
    
    // Only fetch challenge if user is logged in
    if (currentUser != null) {
      fetchWeeklyChallenge();
    } else {
      // User not logged in, set loading to false
      setState(() {
        isLoadingChallenge = false;
      });
    }
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
      appBar: AppBar(
        backgroundColor: AppColors.primaryPink,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Explore',
          style: TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryPink,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: currentUser != null ? items.length + 1 : items.length, // +1 for challenge if logged in
        itemBuilder: (context, index) {
          // First item is challenge (if user is logged in)
          if (currentUser != null && index == 0) {
            return Container(
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
            );
          }
          
          // Adjust index for explore items
          final itemIndex = currentUser != null ? index - 1 : index;
          final item = items[itemIndex];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  item['image']!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: const TextStyle(
                          fontFamily: 'Tommy',
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryPink,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['subtitle']!,
                        style: TextStyle(
                          fontFamily: 'Tommy',
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryPink.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}