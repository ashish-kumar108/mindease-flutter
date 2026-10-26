import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'screens/splash_screen.dart';
import 'theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/meditation_screen.dart';
import 'screens/yoga_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/profile_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('Firebase initialized successfully');
  } catch (e) {
    developer.log('Firebase initialization error: $e');
  }
  runApp(const MindEaseApp());
} 

class MindEaseApp extends StatelessWidget {
  const MindEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindEase',
      theme: buildAppTheme(),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/meditation': (context) => const MeditationScreen(),
        '/yoga': (context) => const YogaScreen(),
        '/journal': (context) => const JournalScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
