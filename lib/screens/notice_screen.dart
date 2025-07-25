import 'package:flutter/material.dart';

const Color _softYellow = Color(0xFFFFF8E1);
const Color _darkOrange = Color(0xFFB26A00);
const Color _buttonGreen = Color(0xFF588D7A);

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softYellow,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Image.asset(
                'assets/images/warning.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),
              // Card warning
              Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
                  child: Column(
                    children: [
                      const Text(
                        'Important Reminder',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Tommy',
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          color: _darkOrange,
                        ),
                      ),
                      const SizedBox(height: 14),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'DailyKind',
                              style: TextStyle(
                                fontFamily: 'CuteLove',
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                height: 1.5,
                                color: _darkOrange,
                              ),
                            ),
                            TextSpan(
                              text: ' is not a replacement for psychologists or medical professionals. If you need help, please reach out to a qualified expert. This app is here as a friendly companion, not a substitute for professional care.',
                              style: TextStyle(
                                fontFamily: 'Tommy',
                                fontWeight: FontWeight.w600,
                                fontSize: 15.5,
                                height: 1.5,
                                color: _darkOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/mainmenu');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 6,
                  shadowColor: _buttonGreen.withOpacity(0.25),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'Tommy',
                    fontWeight: FontWeight.w700,
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