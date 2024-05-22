import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:study_sync/models/common.dart';
import 'package:study_sync/screens/about.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsScreen extends StatefulWidget {
  static const routeName = 'settings';
  static const fullPath = '/$routeName';
  static const int _currentIndex = 3;
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool sessionsOneHour = false;
  bool sessionsTwelveHours = false;
  bool sessionsOneDay = false;
  bool examsOneDay = false;
  bool examsOneWeek = false;
  bool examsTwoWeeks = false;
  bool studyBreaks = false;
  bool chatMessages = false;

  @override
  void initState() {
    super.initState();
    loadOptions();
  }

  Future<void> saveOptions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('studyBreaks', studyBreaks);
    await prefs.setBool('sessionsOneHour', sessionsOneHour);
    await prefs.setBool('sessionsTwelveHours', sessionsTwelveHours);
    await prefs.setBool('sessionsOneDay', sessionsOneDay);
    await prefs.setBool('examsOneDay', examsOneDay);
    await prefs.setBool('examsOneWeek', examsOneWeek);
    await prefs.setBool('examsTwoWeeks', examsTwoWeeks);
    await prefs.setBool('chatMessages', chatMessages);
  }

  Future<void> loadOptions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      studyBreaks = prefs.getBool('studyBreaks') ?? false;
      sessionsOneHour = prefs.getBool('sessionsOneHour') ?? false;
      sessionsTwelveHours = prefs.getBool('sessionsTwelveHours') ?? false;
      sessionsOneDay = prefs.getBool('sessionsOneDay') ?? false;
      examsOneDay = prefs.getBool('examsOneDay') ?? false;
      examsOneWeek = prefs.getBool('examsOneWeek') ?? false;
      examsTwoWeeks = prefs.getBool('examsTwoWeeks') ?? false;
      chatMessages = prefs.getBool('chatMessages') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
      currentIndex: SettingsScreen._currentIndex,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ExpansionTile(
            title: const Text('Notifications'),
            children: [
              ExpansionTile(
                title: const Text('Incoming Exams'),
                children: [
                  CheckboxListTile(
                    title: const Text('1 Day Before'),
                    value: examsOneDay,
                    onChanged: (bool? value) {
                      setState(() {
                        examsOneDay = value ?? false;
                        saveOptions();
                      });
                    },
                  ),

                  CheckboxListTile(
                    title: const Text('1 Week Before'),
                    value: examsOneWeek,
                    onChanged: (bool? value) {
                      setState(() {
                        examsOneWeek = value ?? false;
                        saveOptions();
                      });
                    },
                  ),

                  CheckboxListTile(
                    title: const Text('2 Weeks Before'),
                    value: examsTwoWeeks,
                    onChanged: (bool? value) {
                      setState(() {
                        examsTwoWeeks = value ?? false;
                        saveOptions();
                      });
                    },
                  ),
                ],
              ),

              ExpansionTile(
                title: const Text('Incoming Group Sessions'),
                children: [
                  CheckboxListTile(
                    title: const Text('1 Hour Before'),
                    value: sessionsOneHour, // Add a boolean variable to track if it's checked or not
                    onChanged: (bool? value) {
                      setState(() {
                        sessionsOneHour = value ?? false;
                        saveOptions();
                      });
                    },
                  ),

                  CheckboxListTile(
                    title: const Text('12 Hours Before'),
                    value: sessionsTwelveHours,
                    onChanged: (bool? value) {
                      setState(() {
                        sessionsTwelveHours = value ?? false;
                        saveOptions();
                      });
                    },
                  ),

                  CheckboxListTile(
                    title: const Text('1 Day Before'),
                    value: sessionsOneDay,
                    onChanged: (bool? value) {
                      setState(() {
                        sessionsOneDay = value ?? false;
                        saveOptions();
                      });
                    },
                  ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child:
                CheckboxListTile(
                  title: const Text('Study breaks'),
                  value: studyBreaks,
                  onChanged: (bool? value) {
                    setState(() {
                      studyBreaks = value ?? false;
                      saveOptions();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child:
                CheckboxListTile(
                  title: const Text('Chat messages'),
                  value: chatMessages,
                  onChanged: (bool? value) {
                    setState(() {
                      chatMessages = value ?? false;
                      saveOptions();
                    });
                  },
                ),
              ),
              ],
            ),
          ListTile(
            title: const Text('About the app'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
            },
            trailing: const Icon(Icons.arrow_forward),
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              try {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  GoRouter.of(context).go('/login');
                  //Navigator.of(context).pushNamed(LoginPage.routeName);
                  print('Signed out successfully!');
                } catch (e) {
                  print('Error signing out: $e');
                }
            },
            trailing: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
