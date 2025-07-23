import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class Menu3Screen extends StatelessWidget {
  const Menu3Screen({super.key});

  final List<String> flowers = const [
    'https://cdn.pixabay.com/photo/2016/03/27/21/16/flower-1283608_1280.jpg',
    'https://cdn.pixabay.com/photo/2017/01/20/00/30/rose-1997287_1280.jpg',
    'https://cdn.pixabay.com/photo/2015/04/19/08/32/rose-729509_1280.jpg',
    'https://cdn.pixabay.com/photo/2016/11/29/09/32/flower-1867539_1280.jpg',
    'https://cdn.pixabay.com/photo/2017/08/06/00/09/flowers-2589178_1280.jpg',
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