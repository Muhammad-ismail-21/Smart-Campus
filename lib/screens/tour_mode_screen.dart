// lib/screens/tour_mode_screen.dart
import 'package:flutter/material.dart';

class TourModeScreen extends StatelessWidget {
  const TourModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Tour')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  leading: Icon(Icons.meeting_room_outlined),
                  title: Text('Indoor Navigation'),
                  subtitle: Text('Navigate inside buildings (coming soon)'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.directions_walk_outlined),
                  title: const Text('Outdoor Navigation'),
                  subtitle: const Text('Open Google Maps for directions'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Outdoor navigation tapped'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}