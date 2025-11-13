// lib/screens/feature_page.dart
import 'package:flutter/material.dart';

class FeaturePage extends StatelessWidget {
  final String title;

  const FeaturePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('Content for $title goes here.'),
      ),
    );
  }
}