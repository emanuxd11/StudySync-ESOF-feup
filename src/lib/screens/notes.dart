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
        .orderBy('timestamp')
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

// Example enhancement in notes.dart
Future<void> _saveNote() async {
  final noteText = _notesController.text.trim();
  if (noteText.isNotEmpty) {
    try {
      if (_editingNoteId == null) {
        await FirebaseFirestore.instance
            .collection('exams')
            .doc(widget.examId)
            .collection('notes')
            .add({
          'text': noteText,
          'type': 'text',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance
            .collection('exams')
            .doc(widget.examId)
            .collection('notes')
            .doc(_editingNoteId)
            .update({
          'text': noteText,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _editingNoteId = null;
      }
      _notesController.clear();
      _loadNotes();
    } catch (e) {
      print('Error saving note: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save note. Please try again.'),
      ));
    }
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
  if (Platform.isAndroid || Platform.isIOS) {
    try {
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
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  } else {
    // Handle other platforms or throw an error
    throw UnsupportedError('This operation is not supported on this platform');
  }
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
                if (note['type'] == 'text') {
                  return ListTile(
                    title: Text(note['text']),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editNote(note),
                    ),
                  );
                } else if (note['type'] == 'image') {
                  return ListTile(
                    title: Image.network(
                      note['imageUrl'],
                      errorBuilder: (context, error, stackTrace) {
                        return Text('Failed to load image');
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.close_rounded),
                      onPressed: () => _deleteNoteImage(note['id'], note['imageUrl']),
                    ),
                  );
                }
                return SizedBox.shrink();
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
                      hintText: 'Enter note...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _saveNote,
                ),
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: _pickImage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
