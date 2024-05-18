import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:study_sync/models/common.dart';
import 'package:study_sync/screens/about.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
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

  @override
  void initState() {
    super.initState();
    loadOptions();
    fetchUserSettings();
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
    });
  }

  void configureStudyBreaks() {
    FirebaseFirestore.instance
        .collection('sessions')
        .where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      for (var document in snapshot.docs) {
        final breakTime = (document['time'] as Timestamp).toDate();
        NotificationService().scheduleNotification(NotificationType.studyBreak, breakTime, NotificationTime.studyBreak);
      }
    });
  }

  void configureSessions(NotificationTime type) {
    FirebaseFirestore.instance
        .collection('sessions')
        .where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      for (var document in snapshot.docs) {
        final breakTime = (document['time'] as Timestamp).toDate();
        NotificationService().scheduleNotification(NotificationType.groupSession, breakTime, type);
      }
    });
  }

  void configureExams(NotificationTime type) {
    FirebaseFirestore.instance
        .collection('exams')
        .where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      for (var document in snapshot.docs) {
        final breakTime = (document['time'] as Timestamp).toDate();
        NotificationService().scheduleNotification(NotificationType.exam, breakTime, type);
      }
    });
  }

  Future<void> fetchUserSettings() async {
    if (sessionsOneHour) {
      configureSessions(NotificationTime.oneHourBefore);
    } else {
      NotificationService().clearNotification(1);
    }
    if (sessionsTwelveHours) {
      configureSessions(NotificationTime.twelveHoursBefore);
    } else {
      NotificationService().clearNotification(2);
    }
    if (sessionsOneDay) {
      configureSessions(NotificationTime.oneDayBefore);
    } else {
      NotificationService().clearNotification(3);
    }
    if (examsOneDay) {
      configureExams(NotificationTime.oneDayBefore);
    } else {
      NotificationService().clearNotification(4);
    }
    if (examsOneWeek) {
      configureExams(NotificationTime.oneWeekBefore);
    } else {
      NotificationService().clearNotification(5);
    }
    if (examsTwoWeeks) {
      configureExams(NotificationTime.twoWeeksBefore);
    } else {
      NotificationService().clearNotification(6);
    }
    if (studyBreaks) {
      configureStudyBreaks();
    } else {
      NotificationService().clearNotification(7);
    }
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

enum NotificationType {
  exam,
  groupSession,
  studyBreak
}

enum NotificationTime {
  oneHourBefore,
  twelveHoursBefore,
  oneDayBefore,
  twoWeeksBefore,
  oneWeekBefore,
  studyBreak,
}

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await notificationsPlugin.initialize(
      initializationSettings,
    );
  }

  notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails('1', 'Notificações', importance: Importance.max)
    );
  }

  Future showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    return notificationsPlugin.show(
      id,
      title,
      body,
      await notificationDetails(),
    );
  }

  Future scheduleNotification(NotificationType type, DateTime dateTime, NotificationTime notificationTime) async {
    tz.TZDateTime notificationDateTime;
    int notificationId = 1;

    String notificationTitle;
    String notificationBody;
    switch (type) {
      case NotificationType.exam:
        notificationTitle = 'Upcoming Exam';
        notificationBody = 'Your exam is scheduled soon.';
        switch (notificationTime) {
          case NotificationTime.oneDayBefore:
            notificationDateTime = tz.TZDateTime.from(
                dateTime.subtract(const Duration(days: 1)),
                tz.local);
            notificationId = 4;
            break;
          case NotificationTime.oneWeekBefore:
            notificationDateTime = tz.TZDateTime.from(
                dateTime.subtract(const Duration(days: 7)),
                tz.local);
            notificationId = 5;
            break;
          case NotificationTime.twoWeeksBefore:
            notificationDateTime = tz.TZDateTime.from(
                dateTime.subtract(const Duration(days: 14)),
                tz.local);
            notificationId = 6;
            break;
          default:
            return;
        }
        break;
      case NotificationType.groupSession:
        notificationTitle = 'Upcoming Group Session';
        notificationBody = 'You have a group session coming up.';
        switch (notificationTime) {
          case NotificationTime.oneHourBefore:
            notificationDateTime = tz.TZDateTime.from(
                dateTime.subtract(const Duration(hours: 1)),
                tz.local);
            notificationId = 1;
            break;
          case NotificationTime.twelveHoursBefore:
            notificationDateTime = tz.TZDateTime.from(
                dateTime.subtract(const Duration(hours: 12)),
                tz.local);
            notificationId = 2;
            break;
          case NotificationTime.oneDayBefore:
            notificationDateTime = tz.TZDateTime.from(
                dateTime.subtract(const Duration(days: 1)),
                tz.local);
            notificationId = 3;
            break;
          default:
            return;
        }
        break;
      case NotificationType.studyBreak:
        notificationTitle = 'Study Break';
        notificationBody =
        'Take a break from your study. For example, go get a coffee or drink some water.';
        notificationId = 7;
        notificationDateTime = tz.TZDateTime.from(
            dateTime.add(const Duration(hours: 1)),
            tz.local);
        break;
    }
    return notificationsPlugin.zonedSchedule(
        notificationId,
        notificationTitle,
        notificationBody,
        notificationDateTime,
        await notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
            .absoluteTime
    );
  }

  Future<void> clearNotification(int notificationId) async {
    await notificationsPlugin.cancel(notificationId);
  }
}
