// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // to install use: flutter pub add go_router
import 'package:provider/provider.dart'; // to install use: flutter pub add provider
import 'package:study_sync/features/user_auth/presentation/pages/login_page.dart';
import 'package:study_sync/firebase_options.dart';
import 'package:study_sync/models/entered.dart';
import 'package:study_sync/screens/entered.dart';
import 'package:study_sync/screens/home.dart';
import 'package:study_sync/screens/settings.dart';
import 'package:study_sync/screens/profile.dart';
import 'package:study_sync/screens/notifications.dart';
import 'package:study_sync/screens/exams.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones();
  runApp(const App());
}

GoRouter router() {
  return GoRouter(
    routes: [
      GoRoute(
        path: HomePage.routeName,
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: SessionsPage.routeName,
            builder: (context, state) => const SessionsPage(),
          ),
          GoRoute(
            path: SettingsScreen.routeName,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: ProfileScreen.routeName,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: NotificationsScreen.routeName,
            builder: (context, state) => const NotificationsScreen(),
          ),
          /* GoRoute(
            path: SessionsScreen.routeName,
            builder: (context, state) => const SessionsScreen(),
          ), */
          GoRoute(
            path: ExamsScreen.routeName,
            builder: (context, state) => const ExamsScreen(),
          ),
        ],
      ),
    ],
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudySync',
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator while waiting for auth state to be determined
        } else {
          if (snapshot.hasData) {
            return ChangeNotifierProvider<Groups>(
              create: (context) => Groups(),
              child: MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'StudySync',
                theme: ThemeData(
                  colorSchemeSeed: Colors.green,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                routerConfig: router(),
              ),
            );
          } else {
            return const LoginPage(); // If user is not logged in, show the login page
          }
        }
      },
    );
  }
}
