import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class NotesScreen extends StatefulWidget {
  final String examId;
  final String examName;

  const NotesScreen({super.key, required this.examId, required this.examName});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _notesController = TextEditingController();
  final List<Map<String, dynamic>> _notes = [];
  final ImagePicker _picker = ImagePicker();
  String? _editingNoteId;
  static const double maxImageSizeMB = 2.39;
  static const int notesBatchSize = 20;
  bool isLoadingMore = false;
  DocumentSnapshot? lastDocument;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes({bool loadMore = false}) async {
    if (loadMore && isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    Query notesQuery = FirebaseFirestore.instance
        .collection('exams')
        .doc(widget.examId)
        .collection('notes')
        .orderBy('order')
        .limit(notesBatchSize);

    if (loadMore && lastDocument != null) {
      notesQuery = notesQuery.startAfterDocument(lastDocument!);
    }

    final notesSnapshot = await notesQuery.get();
    setState(() {
      if (!loadMore) {
        _notes.clear();
      }
      if (notesSnapshot.docs.isNotEmpty) {
        lastDocument = notesSnapshot.docs.last;
        for (var doc in notesSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final int order = data['order'] != null ? data['order'] as int : 0;
          _notes.add({
            'id': doc.id,
            ...data,
            'order': order,
          });
        }
      }
      isLoadingMore = false;
    });
  }

  Future<void> _saveNote() async {
    final noteText = _notesController.text.trim();
    if (noteText.isNotEmpty || _selectedImage != null) {
      int newOrder = _notes.isEmpty ? 0 : _notes.map((e) => e['order'] as int).reduce((a, b) => a > b ? a : b) + 1;

      if (_selectedImage != null) {
        final localImagePath = await _saveImageLocally(_selectedImage!);
        if (localImagePath != null) {
          await FirebaseFirestore.instance
              .collection('exams')
              .doc(widget.examId)
              .collection('notes')
              .add({
            'imagePath': localImagePath,
            'type': 'image',
            'text': noteText,
            'timestamp': FieldValue.serverTimestamp(),
            'order': newOrder,
          });
          setState(() {
            _selectedImage = null;
            _notesController.clear();
          });
          _loadNotes();
        }
      } else {
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
        _notesController.clear();
        _loadNotes();
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        // Do not add a temporary image to the notes list
      });
    }
  }

  Future<String?> _saveImageLocally(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(imageFile.path);
      final localPath = path.join(directory.path, fileName);
      await imageFile.copy(localPath);
      return localPath;
    } catch (e) {
      print('Error saving image locally: $e');
      return null;
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

  Future<void> _deleteNoteImage(String noteId, String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      } else {
        throw Exception('File not found.');
      }

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
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!isLoadingMore && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadNotes(loadMore: true);
          }
          return false;
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return ListTile(
                    title: note['type'] == 'text'
                        ? Text(note['text'], style: TextStyle(fontSize: 14))
                        : Image.file(
                            File(note['imagePath']),
                            fit: BoxFit.contain,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                          ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (note['type'] == 'text')
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editNote(note),
                          ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            if (note['type'] == 'image') {
                              _deleteNoteImage(note['id'], note['imagePath']);
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
                      decoration: const InputDecoration(
                        hintText: 'Enter note',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _saveNote,
                  ),
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _pickImage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
