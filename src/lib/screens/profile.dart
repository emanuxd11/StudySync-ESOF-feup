import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = 'profile';
  static const fullPath = '/$routeName';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Profile',
            style: TextStyle(fontSize: 18.0),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}