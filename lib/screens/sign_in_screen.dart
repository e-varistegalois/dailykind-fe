import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/google_sign_in_service.dart';
import '../constants/app_colors.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GoogleSignInService _signInService = GoogleSignInService();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential? result = await _signInService.signInWithGoogle();

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome ${result.user?.displayName ?? 'User'}!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(context, '/mainmenu');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in was cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Google Sign In',
          style: TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryPink,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryPink,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 100,
              color: AppColors.secondaryPink.withOpacity(0.5),
            ),
            SizedBox(height: 32),
            Text(
              'Welcome!',
              style: TextStyle(
                fontFamily: 'Tommy',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryPink,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Please sign in to continue',
              style: TextStyle(
                fontFamily: 'Tommy',
                fontSize: 16,
                color: AppColors.secondaryPink.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 48),
            _isLoading
                ? CircularProgressIndicator(
                    color: AppColors.secondaryPink,
                  )
                : ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: FaIcon(FontAwesomeIcons.google, color: AppColors.secondaryPink),
                    label: Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontFamily: 'Tommy',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryPink,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPink,
                      foregroundColor: AppColors.secondaryPink,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}