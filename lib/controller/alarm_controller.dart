import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

          _local.show(1, message.notification!.title!,
              message.notification!.body!, details);
        }
      }
    });
  }

  // background notification receive
  void firebaseOnMesageOpenedListen() {
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

  // local notification setting
  void localNotificationInitialization() async {
    AndroidInitializationSettings android =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    DarwinInitializationSettings ios = const DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios);
    await _local.initialize(settings);
  }
}
