// lib/screens/dashboard_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hub/constants.dart';
import 'package:hub/screens/alerts_page.dart';
import 'package:hub/screens/schedule_page.dart';

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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = [
    _HomePage(),
    SchedulePage(),
    AlertsPage(),
    _ProfilePage(),
  ];

  static const List<String> _appBarTitles = <String>[
    'Dashboard',
    'Schedule',
    'Alerts',
    'Profile'
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
        title: Text(_appBarTitles.elementAt(_selectedIndex)),
        actions: [
          // Show logout button only on the profile tab
          if (_selectedIndex == 3)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: _signOut,
            ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // These properties are important for making the bottom nav bar look good with more than 3 items
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  _HomePage();

  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return ListView(
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
            _user?.isAnonymous == true
                ? 'Guest'
                : _user?.email?.split('@').first ?? 'User',
            style: Theme.of(context)
                .textTheme
                .headlineLarge?.copyWith(fontWeight: FontWeight.bold),
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
    );
  }
}

class _ProfilePage extends StatelessWidget {
  _ProfilePage();

  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile for:\n${_user?.email?.split('@').first ?? "User"}\n\n(More settings here)',
        textAlign: TextAlign.center,
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