import 'package:flutter/material.dart';
import 'menu1_screen.dart';
import 'menu2_screen.dart';
import 'home_screen.dart';
import 'menu3_screen.dart';
import 'menu4_screen.dart';

class MainMenuScreen extends StatefulWidget {
  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _selectedIndex = 2;

  final List<Widget> _pages = [
    Menu1Screen(), // Explore
    Menu2Screen(), // Kindness Walls
    HomeScreen(),  // Chatbot
    Menu3Screen(), // Bloom Board
    Menu4Screen(), // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore), // Compass
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), // Board/Walls
            label: 'Kindness Walls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble), // Chatbot
            label: 'Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist), // Flower
            label: 'Bloom Board',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Profile
            label: 'Profile',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}