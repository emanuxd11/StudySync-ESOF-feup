// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_sync/models/common.dart';
import 'package:study_sync/models/entered.dart';
import 'package:study_sync/screens/profile.dart';
import 'package:study_sync/screens/notifications.dart';
import 'package:study_sync/screens/sessions.dart';


class HomePage extends StatefulWidget {
  static const routeName = '/';
  const HomePage({super.key});
  static const int _currentIndex = 0;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return CommonScreen(
      currentIndex: HomePage._currentIndex,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go(ProfileScreen.fullPath);
          },
          icon: const Icon(Icons.account_circle),
          iconSize: 45,
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.go(NotificationsScreen.fullPath);
            },
            icon: const Icon(Icons.notifications),
            iconSize: 45,
          ),
        ],
      ),
      body: const StudySessionList() // TEMPORARY

    );
  }
}

class ItemTile extends StatelessWidget {
  final int itemNo;

  const ItemTile(this.itemNo, {super.key});

  @override
  Widget build(BuildContext context) {
    final groupsList = context.watch<Groups>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.primaries[itemNo % Colors.primaries.length],
        ),
        title: Text(
          'Group $itemNo',
          key: Key('text_$itemNo'),
        ),
        trailing: IconButton(
          key: Key('icon_$itemNo'),
          icon: groupsList.items.contains(itemNo)
              ? const Icon(Icons.event_busy)
              : const Icon(Icons.event_note),
          onPressed: () {
            !groupsList.items.contains(itemNo)
                ? groupsList.add(itemNo)
                : groupsList.remove(itemNo);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(groupsList.items.contains(itemNo)
                    ? 'Group entered.'
                    : 'Group exited.'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}