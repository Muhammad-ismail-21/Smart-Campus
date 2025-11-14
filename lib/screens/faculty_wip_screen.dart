// lib/screens/faculty_wip_screen.dart
import 'package:flutter/material.dart';

class FacultyWipScreen extends StatelessWidget {
  const FacultyWipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Portal'),
      ),
      body: const Center(
        child: Text(
          'This feature is currently under development.\nComing soon!',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}