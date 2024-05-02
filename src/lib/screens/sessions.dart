import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:study_sync/models/common.dart';
import 'package:study_sync/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SessionsScreen extends StatelessWidget {
  static const routeName = 'sessions';
  static const fullPath = '/$routeName';
  static const int _currentIndex = 2;

  const SessionsScreen({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
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
  @override
  Widget build(
    BuildContext context,
  ) {
    int pageIndex = 1;
    final List<bool> selections = [true, false];
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
                for (int buttonIndex = 0;
                    buttonIndex < selections.length;
                    buttonIndex++) {
                  if (buttonIndex == index) {
                    selections[buttonIndex] = true;
                  } else {
                    selections[buttonIndex] = false;
                  }
                }
                pageIndex = index;
              });
              if (index == 1) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateSession()));
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
                  "Create Sessions",
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
                  const sessionPalce = 'Library 3rd Floor';
                  const sessionTime = '3:00 PM - 5:00 PM';
                  const sessionDay = 'Monday';

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
                              Text(" $sessionPalce"),
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
            "Study Sessions",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SessionsScreen()),
              );
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
                  _buildTextField("Time", _sessionTimeController),
                  const SizedBox(height: 16.0),
                  _buildTextField("Day", _sessionDayController),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      createSession();
                    },
                    child: const Text('Create'),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
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

  void createSession() async {
    try {
      await FirebaseFirestore.instance.collection('sessions').add({
        'courseName': _sessionNameController.text,
        'topic': _sessionTopicController.text,
        'place': _sessionPlaceController.text,
        'time': _sessionTimeController.text,
        'day': _sessionDayController.text,
      });

      _sessionNameController.clear();
      _sessionTopicController.clear();
      _sessionPlaceController.clear();
      _sessionTimeController.clear();
      _sessionDayController.clear();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Session created successfully!'),
      ));
    } catch (e) {
      print('Error creating session: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to create session. Please try again.'),
      ));
    }
  }

}


