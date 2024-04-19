import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:study_sync/models/common.dart';
import 'package:study_sync/screens/about.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;


bool sessionsOneHour = false;
bool sessionsTwelveHours = false;
bool sessionsOneDay = false;
bool examsOneDay = false;
bool examsOneWeek = false;
bool examsTwoWeeks = false;

class SettingsScreen extends StatefulWidget {
  static const routeName = 'settings';
  static const fullPath = '/$routeName';
  static const int _currentIndex = 3;
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
                      examsOneDay = value!;
                      if (value) {
                        scheduleNotification(NotificationType.exam, NotificationTime.oneDayBefore);
                      } else {
                        clearNotification(NotificationType.exam, NotificationTime.oneDayBefore);
                      }
                    });
                    },
                  ),

                  CheckboxListTile(
                    title: const Text('1 Week Before'),
                    value: examsOneWeek,
                    onChanged: (bool? value) {
                      setState(() {
                        examsOneWeek = value!;
                        if (value) {
                          scheduleNotification(NotificationType.exam, NotificationTime.oneWeekBefore);
                        } else {
                          clearNotification(NotificationType.exam, NotificationTime.oneWeekBefore);
                        }
                      });
                    },
                  ),

                  CheckboxListTile(
                    title: const Text('2 Weeks Before'),
                    value: examsTwoWeeks,
                    onChanged: (bool? value) {
                      setState(() {
                        examsTwoWeeks = value!;
                        if (value) {
                          scheduleNotification(NotificationType.exam, NotificationTime.twoWeeksBefore);
                        } else {
                          clearNotification(NotificationType.exam, NotificationTime.twoWeeksBefore);
                        }
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
                      sessionsOneHour = value!;
                      if (value) {
                        scheduleNotification(NotificationType.groupSession, NotificationTime.oneHourBefore);
                      } else {
                        clearNotification(NotificationType.groupSession, NotificationTime.oneHourBefore);
                      }
                    });
                    },
                  ),

                  CheckboxListTile(
                    title: const Text('12 Hours Before'),
                    value: sessionsTwelveHours,
                    onChanged: (bool? value) {
                      setState(() {
                        sessionsTwelveHours = value!;
                        if (value) {
                          scheduleNotification(NotificationType.groupSession, NotificationTime.twelveHoursBefore);
                        } else {
                          clearNotification(NotificationType.groupSession, NotificationTime.twelveHoursBefore);
                        }
                      });
                    },
                  ),

                  CheckboxListTile(
                    title: const Text('1 Day Before'),
                    value: sessionsOneDay,
                    onChanged: (bool? value) {
                      setState(() {
                        sessionsOneDay = value!;
                        if (value) {
                          scheduleNotification(NotificationType.groupSession, NotificationTime.oneDayBefore);
                        } else {
                          clearNotification(NotificationType.groupSession, NotificationTime.oneDayBefore);
                        }
                      });
                    },
                  ),
                  ],
                )
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

  Future<void> scheduleNotification(NotificationType type, NotificationTime timeFrame) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'your_channel_id',
      'Your Channel Name',
      description: 'Your Channel Description',
      importance: Importance.max,
    );

    // Initialize notification settings
    const InitializationSettings initializationSettings =
        InitializationSettings(android: AndroidInitializationSettings('app_icon'));

    // Initialize FlutterLocalNotificationsPlugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Request permissions
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    late String notificationTitle;
    late String notificationBody;
    switch (type) {
      case NotificationType.exam:
        notificationTitle = 'Upcoming Exam';
        notificationBody = 'Your exam is scheduled soon.';
        break;
      case NotificationType.groupSession:
        notificationTitle = 'Upcoming Group Session';
        notificationBody = 'You have a group session coming up.';
        break;
    }

    DateTime scheduledTime;
    switch (timeFrame) {
      case NotificationTime.oneHourBefore:
        scheduledTime = DateTime.now().add(const Duration(hours: 1));
        break;
      case NotificationTime.twelveHoursBefore:
        scheduledTime = DateTime.now().add(const Duration(hours: 12));
        break;
      case NotificationTime.oneDayBefore:
        scheduledTime = DateTime.now().add(const Duration(days: 1));
        break;
      case NotificationTime.twoWeeksBefore:
        scheduledTime = DateTime.now().add(const Duration(days: 14));
        break;
      case NotificationTime.oneWeekBefore:
        scheduledTime = DateTime.now().add(const Duration(days: 7));
        break;
    }

    final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(scheduledTime, tz.local);

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      notificationTitle,
      channelDescription: notificationBody,
      importance: Importance.max,
      priority: Priority.high,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      notificationTitle,
      notificationBody,
      scheduledTZTime,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

enum NotificationType {
  exam,
  groupSession
}

enum NotificationTime {
  oneHourBefore,
  twelveHoursBefore,
  oneDayBefore,
  twoWeeksBefore,
  oneWeekBefore,
}

Future<void> clearNotification(NotificationType type, NotificationTime timeFrame) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late int notificationId;
  switch (type) {
    case NotificationType.groupSession:
      switch (timeFrame) {
        case NotificationTime.oneHourBefore:
          notificationId = 1;
          break;
        case NotificationTime.twelveHoursBefore:
          notificationId = 2;
          break;
        case NotificationTime.oneDayBefore:
          notificationId = 3;
          break;
        default:
          throw Exception('Invalid time frame for group session notification');
      }
      break;
    case NotificationType.exam:
      switch (timeFrame) {
        case NotificationTime.oneDayBefore:
          notificationId = 4;
          break;
        case NotificationTime.oneWeekBefore:
          notificationId = 5;
          break;
        case NotificationTime.twoWeeksBefore:
          notificationId = 6;
          break;
        default:
          throw Exception('Invalid time frame for group session notification');
      }
    default:
      throw Exception('Unsupported notification type');
  }

  await flutterLocalNotificationsPlugin.cancel(notificationId);
}
