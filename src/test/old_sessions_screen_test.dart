import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:study_sync/screens/oldsessions.dart';
import 'package:study_sync/screens/sessionchat.dart';

import 'old_sessions_screen_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  Query,
  User
])
void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockSessionsCollection;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockSessionsCollection = MockCollectionReference();
    mockUser = MockUser();

    when(mockFirestore.collection('sessions')).thenReturn(mockSessionsCollection);
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('testUserId');
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: Scaffold(
        body: OldSessions(),
      ),
    );
  }

  group('OldSessions', () {
    testWidgets('displays loading indicator when data is loading', (WidgetTester tester) async {
      when(mockSessionsCollection.where('members', arrayContains: anyNamed('arrayContains')))
          .thenReturn(mockSessionsCollection);
      when(mockSessionsCollection.snapshots())
          .thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays message when no old sessions are available', (WidgetTester tester) async {
      final mockQuerySnapshot = MockQuerySnapshot();

      when(mockSessionsCollection.where('members', arrayContains: anyNamed('arrayContains')))
          .thenReturn(mockSessionsCollection);
      when(mockSessionsCollection.snapshots())
          .thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(mockQuerySnapshot.docs).thenReturn([]);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text("You are not a member of any sessions that are no longer active."), findsOneWidget);
    });

    testWidgets('displays old sessions when data is available', (WidgetTester tester) async {
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockDocumentSnapshot = MockDocumentSnapshot();

      when(mockSessionsCollection.where('members', arrayContains: anyNamed('arrayContains')))
          .thenReturn(mockSessionsCollection);
      when(mockSessionsCollection.snapshots())
          .thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(mockQuerySnapshot.docs).thenReturn([mockDocumentSnapshot]);
      when(mockDocumentSnapshot['time']).thenReturn(DateTime.now().subtract(const Duration(days: 1)).toIso8601String());
      when(mockDocumentSnapshot['topic']).thenReturn('Test Topic');
      when(mockDocumentSnapshot['courseName']).thenReturn('Test Course');
      when(mockDocumentSnapshot['place']).thenReturn('Test Place');
      when(mockDocumentSnapshot['id']).thenReturn('testSessionId');
      when(mockDocumentSnapshot['members']).thenReturn(['testUserId']);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Test Topic'), findsOneWidget);
    });

    testWidgets('navigates to chat screen when chat button is pressed', (WidgetTester tester) async {
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockDocumentSnapshot = MockDocumentSnapshot();

      when(mockSessionsCollection.where('members', arrayContains: anyNamed('arrayContains')))
          .thenReturn(mockSessionsCollection);
      when(mockSessionsCollection.snapshots())
          .thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(mockQuerySnapshot.docs).thenReturn([mockDocumentSnapshot]);
      when(mockDocumentSnapshot['time']).thenReturn(DateTime.now().subtract(const Duration(days: 1)).toIso8601String());
      when(mockDocumentSnapshot['topic']).thenReturn('Test Topic');
      when(mockDocumentSnapshot['courseName']).thenReturn('Test Course');
      when(mockDocumentSnapshot['place']).thenReturn('Test Place');
      when(mockDocumentSnapshot['id']).thenReturn('testSessionId');
      when(mockDocumentSnapshot['members']).thenReturn(['testUserId']);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('removes user from session when leave button is pressed', (WidgetTester tester) async {
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockDocumentSnapshot = MockDocumentSnapshot();
      final mockDocumentReference = MockDocumentReference();

      when(mockSessionsCollection.where('members', arrayContains: anyNamed('arrayContains')))
          .thenReturn(mockSessionsCollection);
      when(mockSessionsCollection.snapshots())
          .thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(mockQuerySnapshot.docs).thenReturn([mockDocumentSnapshot]);
      when(mockDocumentSnapshot['time']).thenReturn(DateTime.now().subtract(const Duration(days: 1)).toIso8601String());
      when(mockDocumentSnapshot['topic']).thenReturn('Test Topic');
      when(mockDocumentSnapshot['courseName']).thenReturn('Test Course');
      when(mockDocumentSnapshot['place']).thenReturn('Test Place');
      when(mockDocumentSnapshot['id']).thenReturn('testSessionId');
      when(mockDocumentSnapshot['members']).thenReturn(['testUserId']);
      when(mockSessionsCollection.doc('testSessionId')).thenReturn(mockDocumentReference);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text('Leave'));
      await tester.pump();

      verify(mockDocumentReference.update({
        'members': FieldValue.arrayRemove(['testUserId']),
      })).called(1);
      expect(find.text("You left Test Topic!"), findsOneWidget);
      });
  });
}