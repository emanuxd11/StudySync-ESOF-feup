import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_sync/models/common.dart';
import 'package:study_sync/screens/sessionchat.dart';

class OldSessions extends StatelessWidget {
  static const routeName = 'oldSessions';
  static const fullPath = '/$routeName';
  static const int _currentIndex = 2;

  const OldSessions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
      appBar: AppBar(
        title: const Text('Old Sessions'),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      currentIndex: _currentIndex,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('sessions').where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid).snapshots(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting || snapshots.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var now = DateTime.now();
          var filteredData = snapshots.data!.docs.where((doc) {
            var timeString = doc['time'] as String;
            var dateTime = DateTime.parse(timeString);
            return dateTime.isBefore(now); // Expired sessions
          }).toList();

          if (filteredData.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "You are not a member of any sessions that have already happened.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              var data = filteredData[index];
              int memberCount = data['members'] != null ? data['members'].length : 0;

              return ListTile(
                title: Text(
                  data['topic'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
                              style: const TextStyle(fontSize: 12.0),
                            ),
                            Text(
                              data['place'],
                              style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              data['time'].toString(),
                              style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10), // Add space between session details and chat button
                      IconButton(
                        onPressed: () {
                          // Navigate to the chat screen
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
                        icon: const Icon(Icons.chat),
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10), // Add space between chat button and group info
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
                            style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20), // Add space between session details and chat button
                      ElevatedButton(
                        onPressed: () {
                          // Leave session logic
                          String sessionId = data['id'];
                          DocumentReference ref = FirebaseFirestore.instance.collection('sessions').doc(sessionId);
                          FirebaseAuth auth = FirebaseAuth.instance;
                          String userId = auth.currentUser!.uid;

                          ref.update({
                            'members': FieldValue.arrayRemove([userId])
                          }).then((_) {
                            print('User $userId removed from session $sessionId');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("You left ${data['topic']}!"),
                              ),
                            );
                          }).catchError((error) {
                            print('Failed to remove user from session: $error');
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9999),
                          foregroundColor: Colors.black,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Leave'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
