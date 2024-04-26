import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  static const routeName = '/about';

  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('About the App'),
      ),
      // Add the logo to the body
      body: Container(
        padding: EdgeInsets.all(screenWidth * 0.1),
        child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          style: TextStyle(fontSize: 16.0, color: Colors.black),
          children: [
            TextSpan(
              text: 'A study management app for everyone.\n\n',
              style: TextStyle(fontSize: 20)
            ),
            TextSpan(
              text: 'StudySync',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: ' was developed as part of the Software Engineering subject of the Degree in Informatics and Computer Engineering at the Faculty of Engineering of the University of Porto (FEUP).\n\n',
            ),
            TextSpan(
              text: 'Visit our ',
            ),
            TextSpan(
              text: 'GitHub',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              // Add a gesture recognizer to open the URL when tapped.
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchUrl(Uri.parse('https://github.com/FEUP-LEIC-ES-2023-24/2LEIC02T2'));
                },
            ),
            TextSpan(
              text: ' for more information.\n\n\n',
            ),
            TextSpan(
              text: 'Team Members\n\n',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: 'Emanuel Maia\n',
            ),
            TextSpan(
              text: 'Gonçalo Ferros\n',
            ),
            TextSpan(
              text: 'Irene Scarion\n',
            ),
            TextSpan(
              text: 'Oleksandr Aleshchenko\n',
            ),
          ],
        ),
      ),
    ),
    );
  }
}
