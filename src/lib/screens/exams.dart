import 'package:flutter/material.dart';
import 'package:study_sync/models/common.dart';

class ExamsScreen extends StatelessWidget {
  static const routeName = 'exams';
  static const fullPath = '/$routeName';
  static const int _currentIndex = 1;

  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Exams",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      currentIndex: _currentIndex,
      body: Stack(
        children: [
          // Column containing "Exams" text
          Positioned(
            top: 0,
            left: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Some exams',
                    style: TextStyle(fontSize: 18.0),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // IconButton at bottom right corner
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
                );
              },
            ),
          ),
        ],
      ),

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
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.labelText,
              style: TextStyle(fontSize: 18.0),
            ),
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: widget.selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      widget.onDateChanged(pickedDate);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.selectedDate != null
                          ? '${widget.selectedDate!.day}/${widget.selectedDate!.month}/${widget.selectedDate!.year}'
                          : 'Date',
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: widget.selectedTime ?? TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      widget.onTimeChanged(pickedTime);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.selectedTime != null
                          ? '${widget.selectedTime!.hour}:${widget.selectedTime!.minute}'
                          : 'Time',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
