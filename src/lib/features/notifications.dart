import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart' as not;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  bool sessionsOneHour = false;
  bool sessionsTwelveHours = false;
  bool sessionsOneDay = false;
  bool examsOneDay = false;
  bool examsOneWeek = false;
  bool examsTwoWeeks = false;
  bool studyBreaks = false;
  bool chatMessages = false;

  Future<void> loadOptions() async {
    final prefs = await SharedPreferences.getInstance();
    studyBreaks = prefs.getBool('studyBreaks') ?? false;
    sessionsOneHour = prefs.getBool('sessionsOneHour') ?? false;
    sessionsTwelveHours = prefs.getBool('sessionsTwelveHours') ?? false;
    sessionsOneDay = prefs.getBool('sessionsOneDay') ?? false;
    examsOneDay = prefs.getBool('examsOneDay') ?? false;
    examsOneWeek = prefs.getBool('examsOneWeek') ?? false;
    examsTwoWeeks = prefs.getBool('examsTwoWeeks') ?? false;
    chatMessages = prefs.getBool('chatMessages') ?? false;
  }

  Future<void> fetchUserSettings() async {
    await loadOptions();
    if (sessionsOneHour) {
      configureSessions(NotificationTime.oneHourBefore);
    } else {
      clearNotification(1);
    }
    if (sessionsTwelveHours) {
      configureSessions(NotificationTime.twelveHoursBefore);
    } else {
      clearNotification(2);
    }
    if (sessionsOneDay) {
      configureSessions(NotificationTime.oneDayBefore);
    } else {
      clearNotification(3);
    }
    if (examsOneDay) {
      configureExams(NotificationTime.oneDayBefore);
    } else {
      clearNotification(4);
    }
    if (examsOneWeek) {
      configureExams(NotificationTime.oneWeekBefore);
    } else {
      clearNotification(5);
    }
    if (examsTwoWeeks) {
      configureExams(NotificationTime.twoWeeksBefore);
    } else {
      clearNotification(6);
    }
    if (studyBreaks) {
      configureStudyBreaks();
    } else {
      clearNotification(7);
    }
    if (chatMessages) {
      listenForChatMessages();
    } else {
      clearNotification(10);
    }
  }

  void configureStudyBreaks() {
    FirebaseFirestore.instance
        .collection('sessions')
        .where('members', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      for (var document in snapshot.docs) {
        final breakTime = DateTime.parse(document['time']).toLocal();
        scheduleNewNotification(NotificationType.studyBreak, breakTime, NotificationTime.studyBreak);
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
        final breakTime = DateTime.parse(document['time']).toLocal();
        scheduleNewNotification(NotificationType.groupSession, breakTime, type);
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
        final breakTime = DateTime.parse(document['time']).toLocal();
        scheduleNewNotification(NotificationType.exam, breakTime, type);
      }
    });
  }

  Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
              channelKey: 'Notifications',
              channelName: 'Notifications',
              channelDescription: 'General notification service',
              playSound: true,
              onlyAlertOnce: true,
              groupAlertBehavior: not.GroupAlertBehavior.Children,
              importance: NotificationImportance.High,
              defaultPrivacy: NotificationPrivacy.Private,
              criticalAlerts: true
            ),
          NotificationChannel(
              channelKey: 'Chat',
              channelName: 'Chat',
              channelDescription: 'Notifications for session chats',
              playSound: true,
              onlyAlertOnce: true,
              groupAlertBehavior: not.GroupAlertBehavior.Children,
              importance: NotificationImportance.High,
              defaultPrivacy: NotificationPrivacy.Private,
              criticalAlerts: true
          )
        ],
        debug: true);

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
      } else {
        await fetchUserSettings();
      }
    });
  }

  static Future<bool> scheduleNewNotification(NotificationType type, DateTime dateTime, NotificationTime time) async {
    int notificationId = 1;
    String notificationTitle = "";
    String notificationBody = "";
    DateTime scheduledTime;
    switch (type) {
      case NotificationType.groupSession:
        notificationTitle = "Upcoming Group Session";
        notificationBody = "You have a group session coming up.";
        switch (time) {
          case NotificationTime.oneHourBefore:
            notificationId = 1;
            scheduledTime = dateTime.subtract(const Duration(hours: 1));
          case NotificationTime.twelveHoursBefore:
            notificationId = 2;
            scheduledTime = dateTime.subtract(const Duration(hours: 12));
          case NotificationTime.oneDayBefore:
            notificationId = 3;
            scheduledTime = dateTime.subtract(const Duration(days: 1));
          default:
            return false;
        }
      case NotificationType.exam:
        notificationTitle = "Upcoming Exam";
        notificationBody = "Your exam is scheduled soon.";
        switch (time) {
          case NotificationTime.oneDayBefore:
            notificationId = 4;
            scheduledTime = dateTime.subtract(const Duration(days: 1));
          case NotificationTime.oneWeekBefore:
            notificationId = 5;
            scheduledTime = dateTime.subtract(const Duration(days: 1));
          case NotificationTime.twoWeeksBefore:
            notificationId = 6;
            scheduledTime = dateTime.subtract(const Duration(days: 1));
          default:
            return false;
        }
      case NotificationType.studyBreak:
        notificationTitle = "Study Break";
        notificationBody = "Take a break from your study. For example, go get a coffee or drink some water.";
        notificationId = 7;
        scheduledTime = dateTime.add(const Duration(hours: 1));
      default:
        return false;
    }
    return await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: notificationId,
            channelKey: 'Notifications',
            title: notificationTitle,
            body: notificationBody,
          criticalAlert: true,
          wakeUpScreen: true
            ),
        schedule: NotificationCalendar.fromDate(
            date: scheduledTime));
  }

  Future<bool> getChatNotification(String sessionName, String senderId, String messageContent) async {
    final AwesomeNotifications awesomeNotifications = AwesomeNotifications();
    final senderName = await getUserName(senderId);
    return await awesomeNotifications.createNotification(
      content: NotificationContent(
        id: 10,
        title: sessionName,
        body: '$senderName : $messageContent',
        channelKey: 'Chat',
        criticalAlert: true,
        wakeUpScreen: true
      ),
    );
  }

  Future<void> clearNotification(int notificationId) async {
    await AwesomeNotifications().cancel(notificationId);
  }

  Set<String> processedMessageIds = {};

  Future<void> listenForChatMessages() async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    processedMessageIds = prefs.getStringList('processedMessageIds')?.toSet() ?? {};

    FirebaseFirestore.instance
        .collection('sessions')
        .where('members', arrayContains: currentUserId)
        .snapshots()
        .listen((snapshot) async {
      for (var document in snapshot.docs) {
        final String sessionName = document['topic'];
        final String sessionId = document.id;

        FirebaseFirestore.instance
            .collection('sessions')
            .doc(sessionId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limitToLast(1)
            .snapshots()
            .listen((messageSnapshot) async {
          for (var messageDoc in messageSnapshot.docs) {
            final String messageId = messageDoc.id;
            final String senderId = messageDoc['senderId'];
            final String messageContent = messageDoc['text'];
            if (senderId != currentUserId && !processedMessageIds.contains(messageId)) {
              await getChatNotification(sessionName, senderId, messageContent);
              processedMessageIds.add(messageId);
              await prefs.setStringList('processedMessageIds', processedMessageIds.toList());
            }
          }
        });
      }
    });
  }


  Future<String> getUserName(String userId) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      return snapshot.data()!['username'];
    } else {
      return "";
    }
  }

}