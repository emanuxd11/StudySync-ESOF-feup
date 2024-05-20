import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:study_sync/screens/notes.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}

void main() {
  final mockFirestore = MockFirebaseFirestore();
  final mockCollectionReference = MockCollectionReference();
  final mockQuery = MockQuery();
  final mockQuerySnapshot = MockQuerySnapshot();
  final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
  final mockDocumentReference = MockDocumentReference();

  setUp(() {
    when(mockFirestore.collection('exams')).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
    when(mockDocumentReference.collection('notes')).thenReturn(mockCollectionReference);
    when(mockCollectionReference.orderBy('timestamp')).thenReturn(mockQuery);
    when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
    when(mockQueryDocumentSnapshot.id).thenReturn('testNoteId');
    when(mockQueryDocumentSnapshot.data()).thenReturn({
      'text': 'Test Note',
      'type': 'text',
      'timestamp': Timestamp.now(),
    });
  });

  testWidgets('NotesScreen displays a list of notes', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: NotesScreen(examId: 'testExamId', examName: 'Test Exam'),
    ));

    // Verify that the note is displayed
    expect(find.text('Test Note'), findsOneWidget);
  });

  testWidgets('NotesScreen displays message when no notes are found', (WidgetTester tester) async {
    when(mockQuerySnapshot.docs).thenReturn([]);

    await tester.pumpWidget(const MaterialApp(
      home: NotesScreen(examId: 'testExamId', examName: 'Test Exam'),
    ));

    // Verify that the message is displayed
    expect(find.text('No notes found'), findsOneWidget);
  });

  testWidgets('NotesScreen shows loading indicator while fetching notes', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: NotesScreen(examId: 'testExamId', examName: 'Test Exam'),
    ));

    // Verify that the loading indicator is displayed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
