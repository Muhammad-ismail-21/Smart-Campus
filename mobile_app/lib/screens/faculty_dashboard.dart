// lib/screens/faculty_dashboard.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class FacultyDashboard extends StatelessWidget {
  final Map<String, dynamic> user;
  const FacultyDashboard({super.key, required this.user});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final name = user['first_name'] ?? user['username'] ?? 'Faculty';
    final dept = user['department_name'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Hub'),
        backgroundColor: const Color(0xFF1A237E),
        actions: [
          IconButton(onPressed: () => _logout(context), icon: const Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1A237E), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF1A237E), size: 30)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hello, $name', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(dept, style: const TextStyle(color: Colors.white70)),
              ])
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(spacing: 12, runSpacing: 12, children: [
            ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.calendar_today), label: const Text('My Timetable')),
            ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.campaign), label: const Text('Announcements')),
            ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.check), label: const Text('Mark Attendance')),
          ]),
        ]),
      ),
    );
  }
}
