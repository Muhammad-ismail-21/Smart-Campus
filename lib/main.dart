// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constants.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/feature_page.dart';
import 'screens/profile_screen.dart';
import 'screens/tour_mode_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NexusApp());
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      initialRoute: homeRoute,
      routes: {
        homeRoute: (_) => const HomeScreen(),
        tourModeRoute: (_) => const TourModeScreen(),
        profileRoute: (_) => const ProfileScreen(),
        authRoute: (_) => const AuthScreen(),
        attendanceRoute: (_) => const FeaturePage(title: 'Attendance'),
        timetableRoute: (_) => const FeaturePage(title: 'Timetable'),
        announcementsRoute: (_) => const FeaturePage(title: 'Announcements'),
        examsRoute: (_) => const FeaturePage(title: 'Exams'),
      },
    );
  }
}
