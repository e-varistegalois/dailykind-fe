import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LandingLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Login Required',
        style: TextStyle(
          fontFamily: 'Tommy',
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryPink,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        'Please login to access this feature.',
        style: TextStyle(
          fontFamily: 'Tommy',
          fontWeight: FontWeight.w400,
          color: AppColors.secondaryPink,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'Tommy',
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryPink,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/signin');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryPink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: Size(90, 40),
            elevation: 0,
          ),
          child: Text(
            'Login',
            style: TextStyle(
              fontFamily: 'Tommy',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}