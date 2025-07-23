import 'package:dailykind_fe/screens/main_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/sign_in_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/notice_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// Tambahkan warna brownFont
const Color brownFont = Color(0xFF584839);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign In Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Tommy',
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Tommy',
          bodyColor: brownFont,
          displayColor: brownFont,
        ).copyWith(
          bodyLarge: const TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: brownFont,
          ),
          bodyMedium: const TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: brownFont,
          ),
          bodySmall: const TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: brownFont,
          ),
          titleLarge: const TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: brownFont,
          ),
          titleMedium: const TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: brownFont,
          ),
          titleSmall: const TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: brownFont,
          ),
        ),
      ),
      home: const WelcomeScreen(),
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/mainmenu': (context) => const MainMenuScreen(),
        '/chatbot': (context) => const ChatbotScreen(),
        '/notice': (context) => const NoticeScreen(),
      },
    );
  }
}