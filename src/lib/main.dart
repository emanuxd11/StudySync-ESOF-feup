// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // to instal use: flutter pub add go_router
import 'package:provider/provider.dart';  // to install use: flutter pub add provider
import 'package:study_sync/models/entered.dart';
import 'package:study_sync/screens/entered.dart';
import 'package:study_sync/screens/home.dart';

void main() {
  runApp(const TestingApp());
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

class TestingApp extends StatelessWidget {
  const TestingApp({super.key});

  @override
  Widget build(BuildContext context) {
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
  }
}