import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class Menu2Screen extends StatelessWidget {
  const Menu2Screen({super.key});

  final List<Map<String, String>> walls = const [
    {
      'image': 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
      'title': 'Kindness Wall 1',
    },
    {
      'image': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
      'title': 'Kindness Wall 2',
    },
    {
      'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      'title': 'Kindness Wall 3',
    },
    {
      'image': 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=400&q=80',
      'title': 'Kindness Wall 4',
    },
    {
      'image': 'https://images.unsplash.com/photo-1465101178521-c1a4c8a0a8b7?auto=format&fit=crop&w=400&q=80',
      'title': 'Kindness Wall 5',
    },
    {
      'image': 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
      'title': 'Kindness Wall 6',
    },
  ];

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
      ),
      body: const Center(
        child: Text(
          'Coming Soon',
          style: TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: AppColors.brownFont,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}