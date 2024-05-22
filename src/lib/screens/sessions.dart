import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class CreateSession extends StatefulWidget {
  const CreateSession({super.key});

  @override
  _CreateSessionState createState() => _CreateSessionState();
}

class _CreateSessionState extends State<CreateSession> {
  List<String> list = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final TextEditingController _sessionNameController = TextEditingController();
  final TextEditingController _sessionTopicController = TextEditingController();
  final TextEditingController _sessionPlaceController = TextEditingController();
  final TextEditingController _sessionTimeController = TextEditingController();
  final TextEditingController _sessionDayController = TextEditingController();

  @override
  void dispose() {
    _sessionNameController.dispose();
    _sessionTopicController.dispose();
    _sessionPlaceController.dispose();
    _sessionTimeController.dispose();
    _sessionDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Create Session",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              child: Column(
                children: [
                  _buildTextField("Topic", _sessionTopicController),
                  const SizedBox(height: 16.0),
                  _buildTextField("Course Name", _sessionNameController),
                  const SizedBox(height: 16.0),
                  _buildTextField("Place", _sessionPlaceController),
                  const SizedBox(height: 16.0),
                  _buildTimeField("Time", _sessionTimeController),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      createSession();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.green,
                    ),
                    child: const Text("Create"),
                  )
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildTimeField(
      String label,
      TextEditingController controller,
      ) {
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

  void createSession() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      String userId = '';
      if (auth.currentUser != null) {
        userId = auth.currentUser!.uid;
      }

      DocumentReference ref = await FirebaseFirestore.instance.collection('sessions').add({
        'courseName': _sessionNameController.text,
        'topic': _sessionTopicController.text,
        'place': _sessionPlaceController.text,
        'time': _sessionTimeController.text,
        'members': [userId], // Add the current user as a member
      });
      await ref.update({'id': ref.id});

      // Show session created successfully snack bar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session created successfully!'),
        ),
      );

      // Show joined session snack bar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are now a member of ${_sessionTopicController.text}'),
        ),
      );
    } catch (e) {
      print('Error creating session: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create session. Please try again.'),
        ),
      );

    }

    _sessionNameController.clear();
    _sessionTopicController.clear();
    _sessionPlaceController.clear();
    _sessionTimeController.clear();
  }

  // Define the selected date and time
  DateTime selectedDateTime = DateTime.now();

  // Function to show date picker
  void _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _sessionTimeController.text =
              DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime);
        });
      }
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
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
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
