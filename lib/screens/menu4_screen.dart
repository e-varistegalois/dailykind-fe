import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/google_sign_in_service.dart';
import '../constants/app_colors.dart';

class Menu4Screen extends StatefulWidget {
  @override
  _Menu4ScreenState createState() => _Menu4ScreenState();
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
      Navigator.pushReplacementNamed(context, '/mainmenu');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryGreen,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 32),
            CircleAvatar(
              radius: 50,
              backgroundImage: _user?.photoURL != null
                  ? NetworkImage(_user!.photoURL!)
                  : null,
              backgroundColor: AppColors.primaryGreen.withOpacity(0.3),
              child: _user?.photoURL == null
                  ? Icon(Icons.person, size: 50, color: AppColors.secondaryGreen)
                  : null,
            ),
            SizedBox(height: 24),
            Card(
              color: AppColors.primaryGreen.withOpacity(0.2),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.primaryGreen, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        'User Information',
                        style: TextStyle(
                          fontFamily: 'Tommy',
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryGreen,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildInfoField('Name', _user?.displayName ?? 'N/A'),
                    SizedBox(height: 12),
                    _buildInfoField('Email', _user?.email ?? 'N/A'),
                    SizedBox(height: 12),
                    _buildInfoField('User ID', _user?.uid ?? 'N/A'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: _signOut,
                child: Text(
                  'Sign Out',
                  style: TextStyle(
                    fontFamily: 'Tommy',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: Size(100, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Tommy',
          fontWeight: FontWeight.w500,
          color: AppColors.secondaryGreen,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.secondaryGreen, width: 2),
        ),
      ),
      style: TextStyle(
        fontFamily: 'Tommy',
        fontWeight: FontWeight.w400,
        color: AppColors.secondaryGreen,
        fontSize: 15,
      ),
    );
  }
}