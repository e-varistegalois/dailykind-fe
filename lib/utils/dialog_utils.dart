import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class DialogUtils {
  // Private method untuk reuse dialog styling
  static void _showLoginDialog(
    BuildContext context, {
    required Color titleColor,
    required Color contentColor,
    required Color buttonColor,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 280, 
              maxWidth: 320, 
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Login Required',
                      style: TextStyle(
                        fontFamily: 'Tommy',
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Content
                    Text(
                      content,
                      style: TextStyle(
                        fontFamily: 'Tommy',
                        fontWeight: FontWeight.w500,
                        color: contentColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Tommy',
                              fontWeight: FontWeight.w600,
                              color: contentColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushNamed(context, '/signin');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontFamily: 'Tommy',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static void showLoginRequired(BuildContext context) {
    _showLoginDialog(
      context,
      titleColor: AppColors.blueFont,
      contentColor: AppColors.brownFont,
      buttonColor: AppColors.primaryBlue,
      content: 'You need to be logged in to like posts. Please sign in to continue.',
    );
  }

  static void showLoginRequiredForFeature(
    BuildContext context, {
    Color color = AppColors.secondaryPink,
  }) {
    _showLoginDialog(
      context,
      titleColor: color,                   
      contentColor: AppColors.brownFont,   
      buttonColor: color,                  
      content: 'Please login to access this feature.',
    );
  }
}