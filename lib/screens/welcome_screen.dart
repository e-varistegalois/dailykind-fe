import 'package:flutter/material.dart';

const Color _softGreen = Color(0xFFE9F4EF);
const Color _darkGreen = Color(0xFF406A5A);
const Color _buttonGreen = Color(0xFF588D7A);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // Logo
              Image.asset(
                'assets/images/logo.png',
                height: MediaQuery.of(context).size.height * 0.28,
              ),
              const SizedBox(height: 36),
              // Judul
              const Text(
                'Welcome to DailyKind',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tommy',
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                  color: _darkGreen,
                ),
              ),
              const SizedBox(height: 14),
              // Tagline
              Text(
                'Your digital companion for a kinder, more mindful day.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  height: 1.5,
                  color: _darkGreen.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 32),
              // Hapus Card fitur
              // Spacer diganti agar layout tetap proporsional
              const Spacer(flex: 3),
              // Tombol Get Started
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/notice');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: _buttonGreen.withOpacity(0.3),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Tommy',
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
              color: _darkGreen,
            ),
          ),
        ),
      ],
    );
  }
}