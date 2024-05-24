import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_sync/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditSessionScreen extends StatefulWidget {
  final String sessionId;

  const EditSessionScreen({Key? key, required this.sessionId}) : super(key: key);

  static const routeName = 'edit-session';
  static const fullPath = '/$routeName';

  @override
  _EditSessionScreenState createState() => _EditSessionScreenState();
}

class _EditSessionScreenState extends State<EditSessionScreen> {
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  Map<String, dynamic> _updateData = {};
  List<String> _enrolledUsers = [];
  final sessionsCollection = FirebaseFirestore.instance.collection('sessions');

  @override
  void initState() {
    super.initState();
    _loadSessionData();
    _loadEnrolledUsers();
  }

  Future<void> _loadSessionData() async {
    final sessionDoc = await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).get();
    if (sessionDoc.exists) {
      setState(() {
        _courseNameController.text = sessionDoc.data()?['courseName'] ?? '';
        _topicController.text = sessionDoc.data()?['topic'] ?? '';
        _placeController.text = sessionDoc.data()?['place'] ?? '';
        _timeController.text = sessionDoc.data()?['time'] ?? '';
      });
    }
  }

  Future<void> _loadEnrolledUsers() async {
    final sessionDoc = await sessionsCollection.doc(widget.sessionId).get();

    if (sessionDoc.exists) {
      final memberIds = sessionDoc.data()?['members']?.cast<String>() ?? [];
      final usernames = List<String>.empty(growable: true);

      for (final memberId in memberIds) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(memberId).get();
        if (userDoc.exists) {
          final username = userDoc.data()?['username'] ?? 'Unknown User';
          usernames.add(username);
        }
      }
      setState(() {
        _enrolledUsers = usernames;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Edit Session',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Are you sure you want to delete this session?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).delete();
                        Navigator.pop(context, true);
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              color: Colors.red,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildTextField(
              controller: _courseNameController,
              labelText: 'Course Name',
              icon: Icons.book,
              hintText: 'Enter course name',
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
              controller: _topicController,
              labelText: 'Topic',
              icon: Icons.description,
              hintText: 'Enter topic',
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
              controller: _placeController,
              labelText: 'Place',
              icon: Icons.place,
              hintText: 'Enter place',
              ),
              const SizedBox(height: 16.0),
              _buildTimeField('Time', _timeController),
              const SizedBox(height: 24.0),
              const Text(
                'Enrolled Users:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              _enrolledUsers.isEmpty
                  ? const Text('No enrolled users yet.')
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: _enrolledUsers.length,
                itemBuilder: (context, index) {
                  final userId = _enrolledUsers[index];
                  return ListTile(
                    title: Text(userId),
                  );
                },
              ),
              const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: () async {
              try {
                await sessionsCollection.doc(widget.sessionId).update({
                  'courseName': _courseNameController.text,
                  'topic': _topicController.text,
                  'place': _placeController.text,
                  'time': _timeController.text,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Session updated successfully!'),
                  ),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('Error updating session: $e'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required IconData icon,
    required String hintText,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: (value) {
        if (value != controller.text) {
          _updateData[labelText.toLowerCase()] = value;
        } else {
          _updateData.remove(labelText.toLowerCase());
        }
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green),
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.green),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        hintText: hintText,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget _buildTimeField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _selectDateTime(context);
                  },
                  child: const Icon(Icons.calendar_today),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final sessionsCollection = FirebaseFirestore.instance.collection('sessions');
    final sessionDoc = await sessionsCollection.doc(widget.sessionId).get();

    if (sessionDoc.exists) {
      final String sessionTimeString = sessionDoc.data()?['time'] ?? '';
      DateTime selectedDateTime;
      try {
        selectedDateTime = DateFormat('yyyy-MM-dd HH:mm').parse(sessionTimeString);
      } catch (e) {
        return;
      }

      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
        );

        if (pickedTime != null) {
          setState(() {
            selectedDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            _timeController.text =
                DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime);
          });
        }
      }
    } else {
    }
  }
}

