// test/chat_screen_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:study_sync/screens/sessionchat.dart';

import 'chat_screen_test.mocks.dart';

// Mock classes
@GenerateMocks([FirebaseAuth, FirebaseFirestore, CollectionReference, DocumentReference, DocumentSnapshot, QuerySnapshot, User])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockSessionsCollection;
  late MockDocumentReference mockSessionDocument;
  late MockCollectionReference mockMessagesCollection;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockSessionsCollection = MockCollectionReference();
    mockSessionDocument = MockDocumentReference();
    mockMessagesCollection = MockCollectionReference();
    mockUser = MockUser();

    when(mockFirestore.collection('sessions')).thenReturn(mockSessionsCollection as CollectionReference<Map<String, dynamic>>);
    when(mockSessionsCollection.doc(any)).thenReturn(mockSessionDocument);
    when(mockSessionDocument.collection('messages')).thenReturn(mockMessagesCollection as CollectionReference<Map<String, dynamic>>);
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('testUserId');
  });

  group('ChatScreen', () {
    testWidgets('displays loading indicator when messages are loading', (WidgetTester tester) async {
      when(mockMessagesCollection.orderBy('timestamp', descending: true))
          .thenAnswer((_) => mockMessagesCollection);
      when(mockMessagesCollection.snapshots())
          .thenAnswer((_) => Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(sessionId: 'testSessionId', sessionTopic: 'Test Topic'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('sends a message when send button is tapped', (WidgetTester tester) async {
      when(mockMessagesCollection.add(any)).thenAnswer((_) => Future.value(mockSessionDocument));

      await tester.pumpWidget(
        MaterialApp(
          home: ChatScreen(sessionId: 'testSessionId', sessionTopic: 'Test Topic'),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello!');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      verify(mockMessagesCollection.add({
        'senderId': 'testUserId',
        'text': 'Hello!',
        'timestamp': FieldValue.serverTimestamp(),
      })).called(1);
    });
  });

  group('MessageService', () {
    test('createMessage adds a new message to the Firestore collection', () async {
      when(mockMessagesCollection.add(any)).thenAnswer((_) => Future.value(mockSessionDocument));

      await MessageService.createMessage('testSessionId', 'testUserId', 'Hello!');

      verify(mockMessagesCollection.add({
        'senderId': 'testUserId',
        'text': 'Hello!',
        'timestamp': FieldValue.serverTimestamp(),
      })).called(1);
    });

    test('createMessage handles errors gracefully', () async {
      when(mockMessagesCollection.add(any)).thenThrow(Exception('Firestore error'));

      try {
        await MessageService.createMessage('testSessionId', 'testUserId', 'Hello!');
      } catch (e) {
        expect(e.toString(), contains('Firestore error'));
      }

      verify(mockMessagesCollection.add({
        'senderId': 'testUserId',
        'text': 'Hello!',
        'timestamp': FieldValue.serverTimestamp(),
      })).called(1);
    });
  });
}

