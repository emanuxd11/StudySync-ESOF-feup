import 'package:flutter_adaptive_navigation/flutter_adaptive_navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_sync/screens/home.dart';
import 'package:study_sync/screens/sessions.dart';
import 'package:study_sync/screens/settings.dart';
import 'package:study_sync/screens/courses.dart';
import 'package:study_sync/screens/exams.dart';


class MainNavigationBar extends StatelessWidget {
  final Widget child;
  final int selectedIndex;

  const MainNavigationBar({
    required this.child,
    required this.selectedIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final goRouter = GoRouter.of(context);
    return Scaffold(
      body: FlutterAdaptiveNavigationScaffold(
        labelDisplayType: LabelDisplayType.all,
        drawerWidthFraction: 0.15,
        destinations: [
          NavigationElement(
            icon: const Icon(Icons.home),
            label: 'Home',
            builder: () {
              if (selectedIndex == 0) {
                return child;
              }
              else {
                goRouter.go('/');
                return SizedBox();
              }
            }
          ),
          NavigationElement(
            icon: const Icon(Icons.menu_book),
            label: 'My Courses',
            builder: () => const CoursesScreen(),
          ),
          NavigationElement(
            icon: const Icon(Icons.list_alt),
            label: 'Exams',
            builder: () => const ExamsScreen(),
          ),
          NavigationElement(
            icon: const Icon(Icons.playlist_add),
            label: 'Sessions',
            builder: () => const SessionsScreen(),
          ),
          NavigationElement(
            icon: const Icon(Icons.settings),
            label: 'Settings',
            builder: () => const SettingsScreen(),
          ),
        ],
        backgroundColor: Colors.white,
      ),
    );
  }
}