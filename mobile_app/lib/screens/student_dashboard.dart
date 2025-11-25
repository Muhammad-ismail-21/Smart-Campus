// lib/screens/student_dashboard.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class StudentDashboard extends StatelessWidget {
  final Map<String, dynamic> user;

  const StudentDashboard({super.key, required this.user});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Delete tokens

    // Go back to Login Screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstName = (user['first_name'] ?? user['username'] ?? 'Student').toString();
    final classGroup = (user['class_group_name'] ?? user['class_group_name'] ?? 'No Class Assigned').toString();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Student Hub"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Welcome Card (compact)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 28, color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, $firstName",
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        classGroup,
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Text(
              "Quick Access",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // 2. Grid — responsive and compact
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                // Choose columns by width
                final width = constraints.maxWidth;
                int crossAxisCount = 2;
                double childAspect = 1.3; // width / height

                if (width > 1000) {
                  crossAxisCount = 4;
                  childAspect = 1.1;
                } else if (width > 700) {
                  crossAxisCount = 3;
                  childAspect = 1.2;
                } else {
                  crossAxisCount = 2;
                  childAspect = 1.25;
                }

                // Keep cards reasonably sized by limiting the grid height per tile
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: childAspect,
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuCard(
                      icon: Icons.calendar_today,
                      title: "Time Table",
                      subtitle: "View your classes",
                      color: Colors.blue,
                      onTap: () {
                        // TODO: push timetable screen
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening Timetable...")));
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.check_circle_outline,
                      title: "Attendance",
                      subtitle: "View / Mark",
                      color: Colors.green,
                      onTap: () {
                        // TODO: push attendance screen
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.campaign_outlined,
                      title: "Notices",
                      subtitle: "Announcements",
                      color: Colors.orange,
                      onTap: () {
                        // TODO: push announcements screen
                      },
                    ),
                    _buildMenuCard(
                      icon: Icons.map_outlined,
                      title: "Campus Map",
                      subtitle: "Floor maps & rooms",
                      color: Colors.purple,
                      onTap: () {
                        // TODO: push floor maps screen
                      },
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
              const SizedBox(height: 12),
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              Text(subtitle, style: GoogleFonts.poppins(color: Colors.black54, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
