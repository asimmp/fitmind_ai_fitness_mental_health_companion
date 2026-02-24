import 'package:fitmind_ai_fitness_mental_health_companion/homescreen.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/login.dart';
import 'package:fitmind_ai_fitness_mental_health_companion/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0BEE16),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0BEE16),
          primary: const Color(0xFF0BEE16),
          secondary: const Color(0xFF0BEE16),
          surface: const Color(0xFFF4FFF7),
        ),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0BEE16),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: FirebaseAuth.instance.currentUser != null
          ? const Homescreen()
          : const Login(),
    );
  }
}
