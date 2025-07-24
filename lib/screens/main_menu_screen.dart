import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import '../utils/dialog_utils.dart'; 
import 'menu1_screen.dart';
import 'menu2_screen.dart';
import 'chatbot_screen.dart';
import 'menu3_screen.dart';
import 'menu4_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Menu1Screen(),
    const Menu2Screen(),
    const ChatbotScreen(),
    const Menu3Screen(),
    const Menu4Screen(),
  ];

  final List<IconData> _filledIcons = const [
    Icons.emoji_nature_rounded,
    Icons.dashboard_rounded,
    Icons.chat_bubble_rounded,
    Icons.local_florist_rounded,
    Icons.person_rounded,
  ];

  final List<IconData> _regularIcons = const [
    Icons.emoji_nature_outlined,
    Icons.dashboard_outlined,
    Icons.chat_bubble_outline,
    Icons.local_florist_outlined,
    Icons.person_outline,
  ];

  final List<Color> _secondaryColors = const [
    AppColors.secondaryPink,
    AppColors.secondaryBlue,
    AppColors.secondaryTosca,
    AppColors.secondaryYellow,
    AppColors.secondaryGreen,
  ];

  void _onItemTapped(int index) {
    final user = FirebaseAuth.instance.currentUser;
    
    // Jika fitur butuh login dan user belum login, tampilkan dialog dengan warna sesuai fitur
    if (index >= 2 && user == null) {
      DialogUtils.showLoginRequiredForFeature(
        context, 
        color: _secondaryColors[index], // ← PASS COLOR BASED ON FEATURE
      );
      return; // Jangan ubah halaman
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        selectedItemColor: _secondaryColors[_selectedIndex],
        items: List.generate(5, (index) {
          return BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == index ? _filledIcons[index] : _regularIcons[index],
              size: 28,
              color: _secondaryColors[index].withOpacity(_selectedIndex == index ? 1 : 0.5),
            ),
            label: [
              'Feeds',
              'Kindness Walls',
              'Lil Guy',
              'Bloom Board',
              'Profile'
            ][index],
          );
        }),
        backgroundColor: Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Tommy',
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryPink,
        ),
      ),
    );
  }
}