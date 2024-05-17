import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:study_sync/models/common.dart';
import 'notes.dart'; // Import the NotesScreen

class ExamsScreen extends StatelessWidget {
  static const routeName = 'exams'; // Define the route name
  static const fullPath = '/$routeName';
  static const int _currentIndex = 1;

  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "My Exams",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      currentIndex: 1,
      body: Stack(
        children: [
          const ExamList(),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: IconButton(
              icon: Icon(Icons.add_circle_sharp),
              iconSize: 70,
              color: Colors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateExam(
                      labelText: 'New Exam',
                      selectedDate: null,
                      onDateChanged: (DateTime? date) {},
                      selectedTime: null,
                      onTimeChanged: (TimeOfDay? time) {},
                    ),
                  ),
                ).then((_) {
                  // Refresh the exam list when returning from the create exam screen
                  (context as Element).reassemble();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExamList extends StatefulWidget {
  const ExamList({Key? key}) : super(key: key);

  @override
  _ExamListState createState() => _ExamListState();
}

class _ExamListState extends State<ExamList> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('exams').snapshots(),
      builder: (context, snapshots) {
        if (snapshots.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshots.hasData || snapshots.data!.docs.isEmpty) {
          return Center(child: Text('No exams found'));
        }
        var filteredData = snapshots.data!.docs.where((doc) {
          var examName = doc['examName'].toString().toLowerCase();
          var time = doc['time'].toString().toLowerCase();
          return examName.contains(search.toLowerCase()) || time.contains(search.toLowerCase());
        }).toList();
        return ListView.builder(
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            var data = filteredData[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(
                  data['examName'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['time'], style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.note_add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotesScreen(
                          examId: data['id'],
                          examName: data['examName'],
                        ),
                      ),
                    );
                  },
                  color: Colors.green,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class CreateExam extends StatefulWidget {
  final String labelText;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateChanged;
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?> onTimeChanged;

  const CreateExam({
    Key? key,
    required this.labelText,
    required this.selectedDate,
    required this.onDateChanged,
    required this.selectedTime,
    required this.onTimeChanged,
  }) : super(key: key);

  @override
  _CreateExamState createState() => _CreateExamState();
}

// Temporary design, just to have the '+' button working
class _CreateExamState extends State<CreateExam> {
  final TextEditingController _examNameController = TextEditingController();
  final TextEditingController _examTimeController = TextEditingController();

  @override
  void dispose() {
    _examNameController.dispose();
    _examTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Exam",
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
                _buildTextField("Exam Name", _examNameController),
                const SizedBox(height: 16.0),
                _buildTimeField("Time", _examTimeController),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    createExam();
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

  void createExam() async {
  try {
    DocumentReference ref = await FirebaseFirestore.instance.collection('exams').add({
      'examName': _examNameController.text,
      'time': _examTimeController.text,
    });
    await ref.update({'id': ref.id});

    _examNameController.clear();
    _examTimeController.clear();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Exam created successfully!'),
    ));

    Navigator.pop(context);
  } catch (e) {
    print('Error creating exam: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Failed to create exam. Please try again.'),
    ));
  }
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
                  child: Icon(Icons.calendar_today),
                ),
              ],
            ),
          ),
        ),
      ],
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

  Future<void> _selectDateTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        widget.onTimeChanged(pickedTime);
        final localizations = MaterialLocalizations.of(context);
        final formattedTimeOfDay = localizations.formatTimeOfDay(pickedTime);
        _examTimeController.text = formattedTimeOfDay;
      });
    }
  }
}
