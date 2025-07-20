import 'package:dailykind_fe/screens/main_menu_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/sign_in_screen.dart';
import 'screens/chatbot_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

// Tambahkan warna brownFont
const Color brownFont = Color(0xFF584839);

class MyApp extends StatelessWidget {
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
          bodyLarge: TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: brownFont,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: brownFont,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: brownFont,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: brownFont,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: brownFont,
          ),
          titleSmall: TextStyle(
            fontFamily: 'Tommy',
            fontWeight: FontWeight.w600,
            color: brownFont,
          ),
        ),
      ),
      home: MainMenuScreen(),
      routes: {
        '/signin': (context) => SignInScreen(),
        '/mainmenu': (context) => MainMenuScreen(),
        '/chatbot': (context) => ChatbotScreen(),
      },
    );
  }
}