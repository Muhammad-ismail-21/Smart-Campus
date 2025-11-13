// lib/screens/profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hub/constants.dart';

class _Feature {
  final String title;
  final IconData icon;
  final String route;

  const _Feature({required this.title, required this.icon, required this.route});
}

const _features = [
  _Feature(title: 'Attendance', icon: Icons.check_circle_outline, route: attendanceRoute),
  _Feature(title: 'Timetable', icon: Icons.calendar_today_outlined, route: timetableRoute),
  _Feature(title: 'Announcements', icon: Icons.campaign_outlined, route: announcementsRoute),
  _Feature(title: 'Exams', icon: Icons.school_outlined, route: examsRoute),
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      // Go back to the home screen after signing out.
      Navigator.pushNamedAndRemoveUntil(context, homeRoute, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          Text(
            'Welcome,',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.grey.shade600),
          ),
          Text(
            _user?.isAnonymous == true ? 'Guest' : _user?.email ?? 'User',
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _features.length,
            itemBuilder: (context, index) {
              final feature = _features[index];
              return _FeatureCard(feature: feature);
            },
          ),
        ],
      ),
    );
  }
}
        

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature});

  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // Ensures the InkWell ripple is contained within the card's rounded corners.
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, feature.route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(feature.icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(feature.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}