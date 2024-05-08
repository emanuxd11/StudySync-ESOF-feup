// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:study_sync/models/common.dart';
import 'package:study_sync/models/entered.dart';
import 'package:study_sync/screens/profile.dart';
import 'package:study_sync/screens/notifications.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';
  const HomePage({super.key});
  static const int _currentIndex = 0;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var search = "";
  int pageIndex = 1;
  List<bool> selections = [true, false];

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
        title: const Text(
          "StudySync",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),

          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.9,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value){
                    setState(() {
                      search = value;
                    });
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      hintText: 'Search',
                      prefixIcon: Icon(
                          Icons.search
                      )),
                ),

              ),
            ),
          ),
          ToggleButtons(
            color: Colors.black,
            borderColor: Colors.transparent,
            borderRadius: BorderRadius.circular(6.0),
            selectedColor: Colors.white,
            fillColor: Colors.green,
            isSelected: selections,
            onPressed: (index) {
              setState(() {
                if (pageIndex == index && selections[index]) {
                  return;
                }

                for (int buttonIndex = 0; buttonIndex < selections.length; buttonIndex++) {
                  if (buttonIndex == index) {
                    selections[buttonIndex] = true;
                  } else {
                    selections[buttonIndex] = false;
                  }
                }
                pageIndex = index;
              });

              if (index == 1) {
                // use this later somewhere else
                /* Navigator.push(
                    context,
                    MaterialPageRoute(
                      // change here to show available ones
                        builder: (context) => const CreateSession()
                    )
                  ); */
                // done :)
              }
            },
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: MediaQuery.of(context).size.width * 0.1,
                ),
                child: const Text(
                  "Enrolled Sessions",
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: MediaQuery.of(context).size.width * 0.1,
                ),
                child: const Text(
                  "Available Sessions",
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sessions').snapshots(),
              builder: (context, snapshots) {
              if (snapshots.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              var filteredData = snapshots.data!.docs.where((doc) {
                var courseName = doc['courseName'].toString().toLowerCase();
                var topic = doc['topic'].toString().toLowerCase();
                var place = doc['place'].toString().toLowerCase();
                var time = doc['time'].toString().toLowerCase();
                return courseName.contains(search.toLowerCase()) || topic.contains(search.toLowerCase()) || place.contains(search.toLowerCase()) || time.contains(search.toLowerCase());
              }).toList();
              return ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                var data = filteredData[index];

                return ListTile(
                  title: Text(
                    data['courseName'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['topic'], style: TextStyle(fontSize: 12.0),),
                        Text(data['place'], style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold)),
                        Text(data['time'].toString(), style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                    // Join session logic
                    },
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  child: Text('Join Session')
                  ),
                );
                });
              },
            ),
          ),
        ]
      ),
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