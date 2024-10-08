import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_sync/screens/profile.dart';
import 'package:study_sync/screens/sessionchat.dart';
import 'package:study_sync/screens/sessions.dart';
import 'package:study_sync/screens/editsession.dart';
import '../models/common.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';
  static const fullPath = '/';

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
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(
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
                      onChanged: (value) {
                        setState(() {
                          search = value;
                        });
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          hintText: 'Search',
                          prefixIcon: const Icon(Icons.search)),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
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

                  if (index == 1) { }
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
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: selections[1] ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('sessions')
                            .orderBy('time', descending: false)
                            .snapshots(),
                        builder: (context, snapshots) {
                          if (snapshots.connectionState ==
                                  ConnectionState.waiting ||
                              snapshots.data == null) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          var now = DateTime.now();
                          var filteredData = snapshots.data!.docs.where((doc) {
                            var courseName = doc['courseName'].toString().toLowerCase();
                            var topic = doc['topic'].toString().toLowerCase();
                            var place = doc['place'].toString().toLowerCase();
                            var timeString = doc['time'].toString(); // Ensure 'time' is retrieved as String

                            DateTime? dateTime;
                            try {
                              dateTime = DateTime.parse(timeString);
                            } catch (e) {
                              return false;
                            }

                            bool isAfterNow = dateTime.isAfter(now);

                            return (courseName.contains(search.toLowerCase()) ||
                                topic.contains(search.toLowerCase()) ||
                                place.contains(search.toLowerCase())) &&
                                isAfterNow;
                          }).toList();
                          return ListView.builder(
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              var data = filteredData[index];

                              bool isMember = false;
                              int memberCount = 0;
                              try {
                                for (var member in data['members']) {
                                  memberCount++;
                                  if (member ==
                                      FirebaseAuth.instance.currentUser?.uid) {
                                    isMember = true;
                                  }
                                }
                              } catch (e) { }

                              if (isMember) {
                                return const SizedBox.shrink();
                              }

                              final String creatorId = data['creatorId'];
                              final currentUser = FirebaseAuth.instance.currentUser;

                              return ListTile(
                                title: Text(
                                  data['topic'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['courseName'],
                                              style: const TextStyle(
                                                  fontSize: 12.0),
                                            ),
                                            Text(
                                              data['place'],
                                              style: const TextStyle(
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              data['time'].toString(),
                                              style: const TextStyle(
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                          width:
                                              10), // Add space between session details and member icon
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.group,
                                            size:
                                                20, // Adjust icon size as needed
                                            color: Colors.grey[
                                                700], // Customize icon color
                                          ),
                                          Text(
                                            memberCount.toString(),
                                            style: const TextStyle(
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: currentUser?.uid == creatorId
                                    ? IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    final String sessionId = data['id'];
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditSessionScreen(sessionId: sessionId),
                                      ),
                                    );
                                  },
                                )
                                    : ElevatedButton(
                                      onPressed: () {
                                        String sessionId = data['id'];
                                        DocumentReference ref = FirebaseFirestore.instance.collection('sessions').doc(sessionId);
                                        FirebaseAuth auth = FirebaseAuth.instance;
                                        String userId = '';
                                        if (auth.currentUser != null) {
                                          userId = auth.currentUser!.uid;
                                        }

                                        ref.update({
                                          'members': FieldValue.arrayUnion([userId])
                                        }).then((_) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("You are now a member of ${data['topic']}!"),
                                            ),
                                          );
                                        }).catchError((error) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("Failed to join ${data['topic']}!"),
                                            ),
                                          );
                                        });

                                        // Navigate to the chat screen (optional)
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              sessionId: data['id'],
                                              sessionTopic: data['topic'],
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    child: const Text('Join'),
                                ),
                              );
                            },
                          );
                        },
                      )
                    : StreamBuilder<QuerySnapshot>( // enrolled sessions here
                        stream: FirebaseFirestore.instance
                            .collection('sessions')
                            .where('members',
                                arrayContains:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .snapshots(),
                        builder: (context, snapshots) {
                          if (snapshots.connectionState ==
                                  ConnectionState.waiting ||
                              snapshots.data == null) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          var now = DateTime.now();
                          var filteredData = snapshots.data!.docs.where((doc) {
                            var courseName = doc['courseName'].toString().toLowerCase();
                            var topic = doc['topic'].toString().toLowerCase();
                            var place = doc['place'].toString().toLowerCase();
                            var timeString = doc['time'].toString(); // Ensure 'time' is retrieved as String

                            DateTime? dateTime;
                            try {
                              dateTime = DateTime.parse(timeString);
                            } catch (e) {
                              return false; // Skip this document if the date format is incorrect
                            }

                            bool isAfterNow = dateTime.isAfter(now);

                            return (courseName.contains(search.toLowerCase()) ||
                                topic.contains(search.toLowerCase()) ||
                                place.contains(search.toLowerCase())) &&
                                isAfterNow;
                          }).toList();

                          return ListView.builder(
                              itemCount: filteredData.length,
                              itemBuilder: (context, index) {
                                var data = filteredData[index];
                                int memberCount = 0;
                                try {
                                  for (var member in data['members']) {
                                    memberCount++;
                                  }
                                } catch (e) { }

                                final String creatorId = data['creatorId'];
                                final currentUser = FirebaseAuth.instance.currentUser;

                                return ListTile(
                                  title: Text(
                                    data['topic'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['courseName'],
                                                style: const TextStyle(
                                                    fontSize: 12.0),
                                              ),
                                              Text(
                                                data['place'],
                                                style: const TextStyle(
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                data['time'].toString(),
                                                style: const TextStyle(
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                            width: 10), // Add space between session details and chat button
                                        IconButton(
                                          onPressed: () {
                                            // Navigate to the chat screen
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatScreen(
                                                    sessionId: data['id'],
                                                    sessionTopic: data['topic']),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.chat),
                                          color: Colors.green,
                                        ),
                                        const SizedBox(
                                            width: 10), // Add space between chat button and group info
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.group,
                                              size: 20, // Adjust icon size as needed
                                              color: Colors.grey[700], // Customize icon color
                                            ),
                                            Text(
                                              memberCount.toString(),
                                              style: const TextStyle(
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 20), // Space between details and button
                                        currentUser?.uid == creatorId
                                            ? IconButton(
                                          icon: const Icon(Icons.edit), // Edit icon for creator
                                          onPressed: () {
                                            // Handle edit functionality for the creator
                                            final String sessionId = data['id'];
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditSessionScreen(sessionId: sessionId),
                                              ),
                                            );
                                          },
                                        )
                                            : ElevatedButton(
                                            onPressed: () {
                                              // Leave session logic
                                              String sessionId = data['id'];
                                              DocumentReference ref =
                                              FirebaseFirestore.instance
                                                  .collection('sessions')
                                                  .doc(sessionId);
                                              FirebaseAuth auth =
                                                  FirebaseAuth.instance;
                                              String userId = '';
                                              if (auth.currentUser != null) {
                                                userId = auth.currentUser!.uid;
                                              }

                                              ref.update({
                                                'members':
                                                FieldValue.arrayRemove(
                                                    [userId])
                                              }).then((_) {
                                                print(
                                                    'User $userId added to session $sessionId');
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "You left ${data['topic']}!"),
                                                  ),
                                                );
                                              }).catchError((error) {
                                                print(
                                                    'Failed to add user to session: $error');
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              const Color(0xFFFF9999),
                                              foregroundColor: Colors.black,
                                              textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            child: const Text('Leave'),
                                        ),
                                      ],
                                    ),
                                  ),

                                );
                              });
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: IconButton(
              icon: const Icon(Icons.add_circle_sharp),
              iconSize: 70,
              color: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // change here to show available ones
                    builder: (context) => const CreateSession(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
