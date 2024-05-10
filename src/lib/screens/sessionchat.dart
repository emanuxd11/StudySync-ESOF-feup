import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ChatScreen extends StatelessWidget {
  final String sessionId;
  final String sessionTopic;
  final TextEditingController _messageController = TextEditingController();

  ChatScreen({required this.sessionId, required this.sessionTopic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat in ' + this.sessionTopic),
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
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No messages'),
                  );
                }
                return ListView(
                  reverse: true,
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  children: snapshot.data!.docs.map((doc) {
                    bool isCurrentUser = doc['senderId'] == FirebaseAuth.instance.currentUser?.uid;
                    return Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.green : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['text'],
                              style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black, fontSize: 16.0),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              'Sender: ${isCurrentUser ? 'You' : 'Other User'}', // Replace with actual sender information
                              style: TextStyle(color: isCurrentUser ? Colors.white70 : Colors.black54, fontSize: 12.0),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
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
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Background color for the input area
        borderRadius: BorderRadius.circular(16.0), // Rounded corners
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController, // Bind the controller
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none, // Remove default border
              ),
              style: TextStyle(fontSize: 16.0), // Font size of the input text
              textInputAction: TextInputAction.none, // Disable the "done" button
              // Implement logic to send message when user taps enter
              onSubmitted: (value) {
                // Do nothing when the "done" button is pressed
              },
            ),
          ),
          SizedBox(width: 8.0), // Add some space between the text field and send button
          GestureDetector(
            onTap: () {
              // Get the message text from the text field
              String message = _messageController.text.trim();

              // Check if the message is not empty
              if (message.isNotEmpty) {
                // Send the message
                _sendMessage(message);

                // Clear the text field after sending the message
                _messageController.clear();
              }
            },
            child: Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.green, // Green background color for the send button
                borderRadius: BorderRadius.circular(12.0), // Rounded corners
              ),
              child: Icon(
                Icons.send,
                color: Colors.white, // Set the icon color to white
                size: 24.0, // Icon size
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
