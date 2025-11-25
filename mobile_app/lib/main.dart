import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SmartCampusApp());
}

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Campus Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // We use a professional "College Blue" color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Deep Indigo
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFFFFC107), // Amber for highlights
        ),
        useMaterial3: true,
        // Apply Google Fonts globally
        textTheme: GoogleFonts.poppinsTextTheme(), 
      ),
      // We will create this screen next
      home: const LoginScreen(),
    );
  }
}
