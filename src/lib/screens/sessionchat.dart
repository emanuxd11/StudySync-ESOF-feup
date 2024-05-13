import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ChatScreen extends StatelessWidget {
  final String sessionId;
  final String sessionTopic;
  final TextEditingController _messageController = TextEditingController();

  ChatScreen({super.key, required this.sessionId, required this.sessionTopic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat in $sessionTopic'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('sessions')
                  .doc(sessionId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No messages'),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    bool isCurrentUser = doc['senderId'] == FirebaseAuth.instance.currentUser?.uid;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.docs[index]['senderId']).get(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // You can replace this with a loading indicator widget
                        }
                        if (userSnapshot.hasError) {
                          return Text('Error fetching user data: ${userSnapshot.error}');
                        }

                        // Extract sender's name from user document
                        String senderName = 'Unknown';
                        if (userSnapshot.data != null && userSnapshot.data!.exists) {
                          Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                          if (userData.containsKey('username')) {
                            senderName = userData['username'];
                          } else {
                            print("Name field not found in user document for sender ID: ${doc['senderId']}");
                          }
                        } else {
                          print("User document not found for sender ID: ${doc['senderId']}");
                        }

                        return Align(
                          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            padding: const EdgeInsets.all(12.0),
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7, // Limiting message width
                            ),
                            decoration: BoxDecoration(
                              color: isCurrentUser ? Colors.green : Colors.grey[300],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(isCurrentUser ? 12.0 : 0),
                                topRight: Radius.circular(isCurrentUser ? 0 : 12.0),
                                bottomLeft: Radius.circular(12.0),
                                bottomRight: Radius.circular(12.0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data!.docs[index]['text'],
                                  style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black, fontSize: 16.0),
                                ),
                                const SizedBox(height: 4.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isCurrentUser ? 'You' : senderName,
                                      style: TextStyle(color: isCurrentUser ? Colors.white70 : Colors.black54, fontSize: 12.0),
                                    ),
                                    Text(
                                      DateFormat('HH:mm').format(doc['timestamp'].toDate()), // Display message timestamp
                                      style: TextStyle(color: isCurrentUser ? Colors.white70 : Colors.black54, fontSize: 12.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          // Widget for sending messages
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(fontSize: 16.0),
              textInputAction: TextInputAction.send,
              maxLines: null, // Allow text to wrap to next line
              onSubmitted: (value) {
                _sendMessage(value.trim());
                _messageController.clear();
              },
            ),
          ),
          SizedBox(width: 8.0), // Add padding between text field and send button
          GestureDetector(
            onTap: () {
              String message = _messageController.text.trim();
              if (message.isNotEmpty) {
                _sendMessage(message);
                _messageController.clear();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 24.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    // Get the current user ID (you need to implement this)

    FirebaseAuth auth = FirebaseAuth.instance;
    String senderId = '';
    if (auth.currentUser != null) {
      senderId = auth.currentUser!.uid;
    }

    print("USER ID = $senderId");
    // Call the createMessage function from the MessageService class to send the message to Firestore
    MessageService.createMessage(sessionId, senderId, message);
  }

  @override
  void dispose() {
    _messageController.dispose();
  }
}

class MessageService {
  static Future<void> createMessage(String sessionId, String senderId, String text) async {
    try {
      // Reference to the messages subcollection under the session document
      CollectionReference messagesRef = FirebaseFirestore.instance.collection('sessions').doc(sessionId).collection('messages');

      // Add a new document to the messages subcollection
      await messagesRef.add({
        'senderId': senderId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating message: $e');
      // Handle error
    }
  }
}
