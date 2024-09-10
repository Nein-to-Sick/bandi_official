import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/main.dart';
import 'package:bandi_official/view/mail/new_letter_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class AlarmController with ChangeNotifier {
  // determine whether to display the alarm view
  bool isAlarmOpen = false;
  // Firebase messaging setting
  final fcmToken = FirebaseMessaging.instance.getToken();
  // local notification setting
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // manage the page scroll
  final alarmScrollController = ScrollController();

  // toggle the chat page view
  void toggleAlarmOpen(value) {
    isAlarmOpen = value;
    notifyListeners();
  }

  void firebaseOnTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      dev.log('fcm token database update');
      // Note: This callback is fired at each app startup and whenever a new token is generated.
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': fcmToken});
    }).onError((err) {
      // Error getting token.
    });
  }

  // foreground notification receive
  void firebaseOnMessageListen() async {
    dev.log('foreground message setting done');
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      if (message != null) {
        if (message.notification != null) {
          dev.log('local message receive');

          // local notification update
          NotificationDetails details = const NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
            android: AndroidNotificationDetails(
              "1",
              "test",
              importance: Importance.max,
              priority: Priority.high,
            ),
          );

          final screen = message.data['screen'];
          final letterId = message.data['letterId'] ?? '';
          final likedDiaryDetail = message.data['liked_diary_detail'] ?? '';

          final payload = '$screen/$letterId/$likedDiaryDetail';

          _local.show(1, message.notification!.title!,
              message.notification!.body!, details,
              payload: payload);
        }
      }
    });
  }

  // background notification receive
  void firebaseOnMesageOpenedListen() {
    dev.log('background message setting done');
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      if (message != null) {
        if (message.notification != null) {
          dev.log('background message receive');
          dev.log(message.notification!.title!);
          dev.log(message.notification!.body!);
        }
      }
    });
  }

  // terminate notificaiton receive
  void firebaseGetInitialListen() {
    dev.log('terminate message setting done');
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        if (message.notification != null) {
          dev.log('terminate message receive');
          dev.log(message.notification!.title!);
          dev.log(message.notification!.body!);
        }
      }
    });
  }

  // refactor common function for firebase messaging and local notification
  void messageInteractionDeclaration(RemoteMessage message) {
    if (message.data['screen'] == 'letter_detail') {
      dev.log('letter_detail message received');

      // 편지 데이터 읽기와 보여주기는 mailcontroller에서 구현하여 관리함
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        MailController mailController = Provider.of<MailController>(
            navigatorKey.currentState!.context,
            listen: false);
        Tuple<dynamic, dynamic> result =
            await mailController.checkForNewLetterAndsaveLetterToLocal();
        if (result.item1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigatorKey.currentState?.push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    NewLetterPopuView(newLetter: result.item2),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          });
        }
      });
    } else if (message.data['screen'] == 'liked_diary_detail') {
      dev.log('liked_diary_detail message received');
      String diaryId = message.data['diaryId'];
      // TODO: 화면 이동 및 공감 일기 전달 함수 구현
    } else {
      dev.log('message received but there is no related message');
    }
  }

  // Navigate to the letter detail screen with the provided letterId
  void setupInteractedMessage() {
    dev.log('message receive interact setting done');
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      dev.log('message read!');
      messageInteractionDeclaration(message);
    });
  }

  // local notification setting
  void localNotificationInitialization() {
    dev.log('local message receive interact setting done');
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings android =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios);
    flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  // parts[0]: screen
  // parts[1]: letterId
  // parts[2]: liked_diary_detail
  // This should be a top level function
  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;

    if (payload != null) {
      dev.log('local message read!');
      List<String> parts = payload.split('/');
      RemoteMessage remoteMessage = RemoteMessage(data: {
        'screen': parts[0],
        'letterId': parts[1],
        'liked_diary_detail': parts[2],
      });
      messageInteractionDeclaration(remoteMessage);
    }
  }

  Future<void> _onSelectNotification(String? payload) async {
    if (payload != null) {
      dev.log('Notification payload received: $payload');
      List<String> parts = payload.split('/');
      RemoteMessage remoteMessage = RemoteMessage(data: {
        'screen': parts[0],
        'letterId': parts[1],
        'liked_diary_detail': parts[2],
      });
      messageInteractionDeclaration(remoteMessage);
    }
  }
}
