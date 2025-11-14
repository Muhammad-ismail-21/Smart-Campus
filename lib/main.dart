// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hub/constants.dart';
import 'package:hub/firebase_options.dart';
import 'package:hub/screens/auth_screen.dart';
import 'package:hub/screens/faculty_wip_screen.dart';
import 'package:hub/screens/feature_page.dart';
import 'package:hub/screens/home_screen.dart';
import 'package:hub/screens/profile_screen.dart';
import 'package:hub/screens/role_selection_screen.dart';
import 'package:hub/screens/tour_mode_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KLE Tech Hub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: homeRoute,
      routes: {
        homeRoute: (context) => const HomeScreen(),
        roleSelectionRoute: (context) => const RoleSelectionScreen(),
        authRoute: (context) => const AuthScreen(),
        facultyWipRoute: (context) => const FacultyWipScreen(),
        profileRoute: (context) => const ProfileScreen(),
        tourModeRoute: (context) => const TourModeScreen(),
        // Placeholder routes for features
        attendanceRoute: (context) => const FeaturePage(title: 'Attendance'),
        timetableRoute: (context) => const FeaturePage(title: 'Timetable'),
        announcementsRoute: (context) =>
            const FeaturePage(title: 'Announcements'),
        examsRoute: (context) => const FeaturePage(title: 'Exams'),
      },
    );
  }
}