import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/google_sign_in_service.dart';
import '../constants/app_colors.dart';

class Menu4Screen extends StatefulWidget {
  const Menu4Screen({super.key});

  @override
  State<Menu4Screen> createState() => _Menu4ScreenState();
}

class _Menu4ScreenState extends State<Menu4Screen> {
  final GoogleSignInService _signInService = GoogleSignInService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _signInService.currentUser;
  }

  Future<void> _signOut() async {
    try {
      await _signInService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/mainmenu');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          'Profile',
          style: TextStyle(
            fontFamily: 'CuteLove',
            fontWeight: FontWeight.w700,
            color: AppColors.greenFont,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              CircleAvatar(
                radius: 50,
                backgroundImage: _user?.photoURL != null
                    ? NetworkImage(_user!.photoURL!)
                    : null,
                backgroundColor: AppColors.primaryGreen.withOpacity(0.4),
                child: _user?.photoURL == null
                    ? const Icon(Icons.person, size: 50, color: AppColors.secondaryGreen)
                    : null,
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'User Information',
                        style: TextStyle(
                          fontFamily: 'Tommy',
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryGreen,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoField('Name', _user?.displayName ?? 'N/A'),
                      const SizedBox(height: 16),
                      _buildInfoField('Email', _user?.email ?? 'N/A')
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    onPressed: _signOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(100, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontFamily: 'Tommy',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32), // Extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Tommy',
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryGreen,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Tommy',
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryGreen,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}