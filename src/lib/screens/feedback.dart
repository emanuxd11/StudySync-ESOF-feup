import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  static const routeName = 'feedback';
  static const fullPath = '/$routeName';

  @override
  // ignore: library_private_types_in_public_api
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double _rating = 0;
  String _feedback = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate our app:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            RatingBar(
              onChanged: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
              rating: _rating,
            ),
            const SizedBox(height: 20),
            const Text(
              'Tell us more:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  _feedback = value;
                });
              },
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your feedback here...',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_rating > 0 && _feedback.isNotEmpty) {
                  try {
                    String time = DateFormat('yyyy-MM-dd HH:mm').format(Timestamp.now().toDate());
                    await FirebaseFirestore.instance.collection('feedbacks').add({
                      'rating': _rating,
                      'feedback': _feedback,
                      'timestamp': time,
                    });

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Thank you!'),
                          content: const Text('Your feedback has been submitted.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: Text('Failed to submit feedback: $e'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Please provide a rating and feedback.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}

class RatingBar extends StatelessWidget {
  final double rating;
  final Function(double) onChanged;

  const RatingBar({
    Key? key,
    required this.rating,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return InkWell(
          onTap: () {
            onChanged(index + 1.0);
          },
          child: Icon(
            index < rating.floor() ? Icons.star : Icons.star_border,
            color: Colors.yellow,
          ),
        );
      }),
    );
  }
}
