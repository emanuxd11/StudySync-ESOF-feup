import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class NotesScreen extends StatefulWidget {
  final String examId;
  final String examName;

  const NotesScreen({Key? key, required this.examId, required this.examName}) : super(key: key);

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _notesController = TextEditingController();
  final List<Map<String, dynamic>> _notes = [];
  final ImagePicker _picker = ImagePicker();
  String? _editingNoteId;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notesSnapshot = await FirebaseFirestore.instance
        .collection('exams')
        .doc(widget.examId)
        .collection('notes')
        .orderBy('order')
        .get();
    setState(() {
      _notes.clear();
      for (var doc in notesSnapshot.docs) {
        _notes.add({
          'id': doc.id,
          ...doc.data(),
        });
      }
    });
  }

  Future<void> _saveNote() async {
    final noteText = _notesController.text.trim();
    if (noteText.isNotEmpty) {
      if (_editingNoteId == null) {
        // Adding a new note
        int newOrder = _notes.isEmpty ? 0 : _notes.map((e) => e['order'] as int).reduce((a, b) => a > b ? a : b) + 1;
        await FirebaseFirestore.instance
            .collection('exams')
            .doc(widget.examId)
            .collection('notes')
            .add({
          'text': noteText,
          'type': 'text',
          'timestamp': FieldValue.serverTimestamp(),
          'order': newOrder,
        });
      } else {
        // Updating an existing note
        await FirebaseFirestore.instance
            .collection('exams')
            .doc(widget.examId)
            .collection('notes')
            .doc(_editingNoteId)
            .update({
          'text': noteText,
        });
        _editingNoteId = null;
      }
      _notesController.clear();
      _loadNotes();
    }
  }

  Future<String?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      // User canceled image selection
      return null;
    }

    File? imageFile = File(pickedFile.path);

    if (imageFile == null) {
      // Image file not found
      return null;
    }

    try {
      final imageUrl = await _uploadImageToStorage(imageFile);
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<String?> _uploadImageToStorage(File imageFile) async {
    final storage = FirebaseStorage.instance;
    final storageRef = storage.ref();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.png'; // Generate a unique filename
    final imageRef = storageRef.child('images/$fileName');

    // Upload the image file to Firebase Storage
    final uploadTask = imageRef.putFile(imageFile);

    // Wait for the upload task to complete
    final snapshot = await uploadTask;

    // Get the download URL for the uploaded image
    final imageUrl = await snapshot.ref.getDownloadURL();

    return imageUrl;
  }

  void _editNote(Map<String, dynamic> note) {
    setState(() {
      _editingNoteId = note['id'];
      if (note['type'] == 'text') {
        _notesController.text = note['text'];
      }
    });
  }

  Future<void> _deleteNoteImage(String noteId, String imageUrl) async {
    try {
      // Ensure the imageUrl starts with 'http' or 'https'
      if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
        // Delete image from Firebase Storage
        final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await storageRef.delete();
      } else {
        throw Exception('Invalid image URL format.');
      }

      // Delete note from Firestore
      await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examId)
          .collection('notes')
          .doc(noteId)
          .delete();

      _loadNotes();
    } catch (e) {
      print('Error deleting image note: $e');
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.examName} - Notes"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return ListTile(
                  title: note['type'] == 'text'
                      ? Text(note['text'])
                      : Image.network(
                          note['imageUrl'],
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editNote(note),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded),
                        onPressed: () {
                          if (note['type'] == 'image') {
                            _deleteNoteImage(note['id'], note['imageUrl']);
                          } else {
                            FirebaseFirestore.instance
                                .collection('exams')
                                .doc(widget.examId)
                                .collection('notes')
                                .doc(note['id'])
                                .delete();
                            _loadNotes();
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText: 'Enter note',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _saveNote,
                ),
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: () async {
                    final imageUrl = await _pickImage();
                    if (imageUrl != null) {
                      await FirebaseFirestore.instance
                          .collection('exams')
                          .doc(widget.examId)
                          .collection('notes')
                          .add({
                        'imageUrl': imageUrl,
                        'type': 'image',
                        'timestamp': FieldValue.serverTimestamp(),
                        'order': _notes.isEmpty
                            ? 0
                            : _notes.map((e) => e['order'] as int).reduce((a, b) => a > b ? a : b) + 1,
                      });
                      _loadNotes();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
