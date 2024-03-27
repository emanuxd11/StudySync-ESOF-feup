// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // to install use: flutter pub add go_router
import 'package:provider/provider.dart';  // to install use: flutter pub add provider
import 'package:study_sync/features/app/splash_screen.dart';
import 'package:study_sync/features/user_auth/presentation/pages/login_page.dart';
import 'package:study_sync/firebase_options.dart';
import 'package:study_sync/models/entered.dart';
import 'package:study_sync/screens/entered.dart';
import 'package:study_sync/screens/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
            path: GroupsPage.routeName,
            builder: (context, state) => const GroupsPage(),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Sync',
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator while waiting for auth state to be determined
        } else {
          if (snapshot.hasData) {
            return ChangeNotifierProvider<Groups>(
              create: (context) => Groups(),
              child: MaterialApp.router(
                title: 'Groups',
                theme: ThemeData(
                  colorSchemeSeed: Colors.green,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                routerConfig: router(),
              ),
            );
          } else {
            return LoginPage(); // If user is not logged in, show the login page
          }
        }
      },
    );
  }
}

