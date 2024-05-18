import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_sync/models/common.dart';
import 'package:study_sync/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_sync/screens/sessionchat.dart';


class SessionsScreen extends StatelessWidget {
  static const routeName = 'sessions';
  static const fullPath = '/$routeName';
  static const int _currentIndex = 2;

  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
            currentIndex: _currentIndex,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                "Study Sessions",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              leading: InkWell(
                onTap: () {
                  context.go(HomePage.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Back",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
              actions: [
                InkWell(
                  onTap: () {
                    // Define the function for the filter action
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Filter",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              ],
            ),
            body: const StudySessionList());
  }
}

class StudySessionList extends StatefulWidget {
  const StudySessionList({super.key});

  @override
  State<StudySessionList> createState() => _StudySessionListState();
}

class _StudySessionListState extends State<StudySessionList> {
  int pageIndex = 1;
  List<bool> selections = [true, false];

  @override
  Widget build(
      BuildContext context,
      ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ToggleButtons(
            color: Colors.black,
            borderColor: Colors.transparent,
            borderRadius: BorderRadius.circular(6.0),
            selectedColor: Colors.white,
            fillColor: Colors.green,
            isSelected: selections,
            onPressed: (index) {
              setState(() {
                if (pageIndex == index && selections[index]) {
                  return;
                }

                for (int buttonIndex = 0; buttonIndex < selections.length; buttonIndex++) {
                  if (buttonIndex == index) {
                    selections[buttonIndex] = true;
                  } else {
                    selections[buttonIndex] = false;
                  }
                }
                pageIndex = index;
              });

              if (index == 1) {
                // use this later somewhere else
                /* Navigator.push(
                    context,
                    MaterialPageRoute(
                      // change here to show available ones
                        builder: (context) => const CreateSession()
                    )
                  ); */
                // done :)
              }
            },
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: MediaQuery.of(context).size.width * 0.1,
                ),
                child: const Text(
                  "Enrolled Sessions",
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: MediaQuery.of(context).size.width * 0.1,
                ),
                child: const Text(
                  "Available Sessions",
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
            child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  final sessionName = "Session $index";
                  const sessionTopic = "Shaders and Textures";
                  const sessionPlace = 'Library 3rd Floor';
                  const sessionTime = '3:00 PM - 5:00 PM';
                  const sessionDay = 'Monday';
                  var isJoined = (index % 2) == 0 ? true : false;

                  if ((isJoined && selections[0]) || (!isJoined && selections[1])) {
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            sessionName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Padding(
                            padding: EdgeInsets.only(left: 32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(" $sessionTopic"),
                                Text(" $sessionPlace"),
                                Text(
                                  " $sessionDay    $sessionTime",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {},
                        ),
                        const Divider(),
                      ],
                    );
                  } else {
                    return Container();
                  }
                }))
      ],
    );
  }
}

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
              child: Text(
                "Back",
                style: TextStyle(color: Colors.green),
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
                  _buildTextField("Course Name", _sessionNameController),
                  const SizedBox(height: 16.0),
                  _buildTextField("Topic", _sessionTopicController),
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
