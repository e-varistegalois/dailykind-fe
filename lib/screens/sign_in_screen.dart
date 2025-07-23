import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/google_sign_in_service.dart';
import '../constants/app_colors.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
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

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome ${result.user?.displayName ?? 'User'}!'),
            backgroundColor: Colors.green,
          ),
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/mainmenu');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign in was cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Sign In',
          style: TextStyle(
            fontFamily: 'CuteLove',
            fontWeight: FontWeight.w700,
            color: AppColors.pinkFont,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.pinkFont,
          size: 24,
        ),
        leading: Navigator.canPop(context) 
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.pinkFont,
                  weight: 700,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              // Icon dengan background soft
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.waving_hand,
                  size: 60,
                  color: AppColors.pinkFont,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'DailyKind',
                    style: TextStyle(
                      fontFamily: 'CuteLove',
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pinkFont,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Your digital companion for a kinder, more mindful day.',
                style: TextStyle(
                  fontFamily: 'Tommy',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brownFont,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              _isLoading
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      child: const CircularProgressIndicator(
                        color: AppColors.pinkFont,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPink.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: const FaIcon(
                          FontAwesomeIcons.google, 
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontFamily: 'Tommy',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pinkFont,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              Text(
                'By signing in, you agree to our Terms of Service and Privacy Policy',
                style: TextStyle(
                  fontFamily: 'Tommy',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.brownFont.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}