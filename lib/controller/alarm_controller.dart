import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/controller/navigation_toggle_provider.dart';
import 'package:bandi_official/main.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/view/mail/new_letter_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

  // This callback is fired at each app startup and whenever a new token is generated.
  void firebaseOnTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      dev.log('fcm token database update');
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': fcmToken});
    }).onError((err) {
      // Error getting token.
      dev.log(err);
    });
  }

  // foreground notification receive
  void firebaseOnMessageListen() async {
    dev.log('foreground message setting done');
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      if (message != null && message.notification != null) {
        dev.log('local message received');

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
        final likedDiaryDetail = message.data['likedDiaryId'] ?? '';

        final payload = '$screen/$letterId/$likedDiaryDetail';

        _local.show(1, message.notification!.title!,
            message.notification!.body!, details,
            payload: payload);
      }
    });
  }

  // background notification receive
  void firebaseOnMessageOpenedApp() {
    dev.log('message receive interact setting done');
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        dev.log('back ground message received');
        messageInteractionDeclaration(message);
      }
    });
  }

  // terminate notificaiton receive
  void firebaseGetInitialListen() {
    dev.log('terminate message setting done');
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null && message.notification != null) {
        dev.log('terminate message received');
      }
    });
  }

  // refactor common function for firebase messaging and local notification
  void messageInteractionDeclaration(RemoteMessage message) {
    if (message.data['screen'] == 'letter_detail') {
      dev.log('read letter_detail message');
      // 편지 데이터 읽기와 보여주기는 mailcontroller에서 구현하여 관리함
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // 포그라운드에서만 실행되는 UI 관련 작업
        MailController mailController = Provider.of<MailController>(
            navigatorKey.currentState!.context,
            listen: false);
        Tuple<dynamic, dynamic> result =
            await mailController.checkForNewLetterAndsaveLetterToLocal();
        if (result.item1) {
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
        }
      });
      WidgetsBinding.instance.ensureVisualUpdate();
    } else if (message.data['screen'] == 'liked_diary_detail') {
      dev.log('read liked_diary_detail message');
      String likedDiaryId = message.data['likedDiaryId'];
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        NavigationToggleProvider navigationToggleProvider =
            Provider.of<NavigationToggleProvider>(
                navigatorKey.currentState!.context,
                listen: false);
        HomeToWrite writeProvider = Provider.of<HomeToWrite>(
            navigatorKey.currentState!.context,
            listen: false);

        final documentSnapshot = await FirebaseFirestore.instance
            .collection('allDiary')
            .doc(likedDiaryId)
            .get();

        // 문서가 존재하면 Diary 객체로 변환 및 열람
        if (documentSnapshot.exists) {
          Diary diary = Diary.fromSnapshot(documentSnapshot);
          writeProvider.readMyDiary(diary);
          navigationToggleProvider.selectIndex(0);
          writeProvider.toggleWrite();
        }
      });
    } else {
      dev.log('message received but there is no related message');
    }
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
  // parts[2]: likedDiaryId
  // This should be a top level function
  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;

    if (payload != null) {
      dev.log('local message received');
      List<String> parts = payload.split('/');
      RemoteMessage remoteMessage = RemoteMessage(data: {
        'screen': parts[0],
        'letterId': parts[1],
        'likedDiaryId': parts[2],
      });
      messageInteractionDeclaration(remoteMessage);
    }
  }

  // send liked Diary notification
  void sendLikedDiaryNotification(
      String likedDiaryId, String fcmToken, String userId) async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('sendLikedDiaryNotification');

    try {
      final response = await callable.call(<String, dynamic>{
        'likedDiaryId': likedDiaryId,
        'fcmToken': fcmToken,
        'userId': userId,
      });

      dev.log('Notification sent: ${response.data}');
    } catch (e) {
      dev.log('Error sending notification: $e');
    }
  }
}
