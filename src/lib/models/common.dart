import 'package:flutter/material.dart';
import 'package:study_sync/screens/sessions.dart';
import 'package:study_sync/screens/settings.dart';
import 'package:study_sync/screens/exams.dart';
import 'package:study_sync/screens/home.dart';
import 'package:go_router/go_router.dart';

class CommonScreen extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final AppBar? appBar;

  const CommonScreen({super.key, required this.appBar, required this.body, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green,
        //selectedItemColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Exams',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add),
            label: 'Sessions',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.green,
          ),
        ],
        onTap: (int index) {
          switch(index) {
            case 0:
              context.go(HomePage.routeName);
            case 1:
              context.go(ExamsScreen.fullPath);
            case 2:
              context.go(SessionsScreen.fullPath);
            case 3:
              context.go(SettingsScreen.fullPath);
          }
        },
      ),
    );
  }
}
