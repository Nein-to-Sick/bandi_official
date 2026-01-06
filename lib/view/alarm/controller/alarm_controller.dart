import 'package:bandi_official/analytics/log_notification_open.dart';
import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:bandi_official/controller/navigation_toggle_provider.dart';
import 'package:bandi_official/main.dart';
import 'package:bandi_official/model/alarm.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

import '../../mail/detail_view.dart';

class AlarmController with ChangeNotifier {
  // determine whether to display the alarm view
  bool isAlarmOpen = false;

  // Get current user from FirebaseAuth
  String? get userId => FirebaseAuth.instance.currentUser!.uid;

  // Firebase messaging setting
  final fcmToken = FirebaseMessaging.instance.getToken();

  // local notification setting
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // manage the page scroll
  final alarmScrollController = ScrollController();

  // List of Alarm model
  List<Alarm> alarmList = Alarm.defaultAlarm();

  // update navigation BuildContext;
  late BuildContext navigationContext;

  // toggle the chat page view
  void toggleAlarmOpen(value) {
    isAlarmOpen = value;
    notifyListeners();
  }

  void updateContext(BuildContext context) {
    navigationContext = context;
  }

  void firebaseLanguageSetting(String langCode) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'language': langCode});
  }

  void firebaseOnTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      dev.log('FCM Token Refreshed: $fcmToken');

      // 1. 로그인 상태 확인 (안전장치)
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          // 2. DB 업데이트
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'fcmToken': fcmToken}, SetOptions(merge: true));

          dev.log('FCM Token updated in Firestore for user: ${user.uid}');
        } catch (e) {
          dev.log('Failed to update FCM token in Firestore: $e');
          // 필요 시 Crashlytics 기록: FirebaseCrashlytics.instance.recordError(e, stack);
        }
      } else {
        dev.log('User is not logged in. Token refresh ignored.');
      }
    }).onError((err) {
      dev.log('Error getting refresh token: $err');
    });
  }

  // foreground notification receive
  void firebaseOnMessageListen() async {
    dev.log('foreground message setting done');
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
      if (message != null && message.notification != null) {
        dev.log('local message received');
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          MailController mailController = Provider.of<MailController>(
              navigatorKey.currentState!.context,
              listen: false);

          mailController.updateIsNewNotifications(true);
        });

        // local notification update
        NotificationDetails details = const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          android: AndroidNotificationDetails(
            "1",
            "local notification",
            importance: Importance.max,
            priority: Priority.high,
            channelShowBadge: true,
          ),
        );

        final screen = message.data['screen'];
        final letterId = message.data['letterId'] ?? '';
        final likedDiaryDetail = message.data['likedDiaryId'] ?? '';
        const campaignId = "notification_open_v1";

        final payload = '$screen/$letterId/$likedDiaryDetail/$campaignId';

        // 알람 송신 여부 로깅
        /*
          await logNotificationReceive(campaignId: campaignId);
        */
        _local.show(1, message.notification!.title!,
            message.notification!.body!, details,
            payload: payload);
      }
    });
  }

  // background notification receive
  void firebaseOnMessageOpenedApp() {
    dev.log('message receive interact setting done');
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.notification != null) {
        dev.log('back ground message received');
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          MailController mailController = Provider.of<MailController>(
              navigatorKey.currentState!.context,
              listen: false);

          mailController.updateIsNewNotifications(true);
        });

        // 알람 클릭 여부 로깅
        final campaignId = message.data['campaignId'] ?? '';
        final destination = message.data['screen'] ?? '';
        if (campaignId.isNotEmpty) {
          await logNotificationOpen(
            campaignId: campaignId,
            destination: destination,
          );
        }
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
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          MailController mailController = Provider.of<MailController>(
              navigatorKey.currentState!.context,
              listen: false);

          mailController.updateIsNewNotifications(true);
        });
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
        Tuple<dynamic, dynamic> result = await mailController
            .checkForNewLetterNewNotificationsAndSaveLetterToLocal();
        if (result.item1) {
          navigatorKey.currentState?.push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  DetailView(
                item: result.item2,
                mailController: mailController,
              ),
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
    }
    // other_diary 추가
    else if (message.data['screen'] == 'other_diary_detail') {
      dev.log('read other_diary_detail message');

      final String diaryId = message.data['likedDiaryId'] ?? '';
      if (diaryId.isEmpty) return;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final nav = Provider.of<NavigationToggleProvider>(
          navigatorKey.currentState!.context,
          listen: false,
        );
        final writeProvider = Provider.of<HomeToWrite>(
          navigatorKey.currentState!.context,
          listen: false,
        );

        final snap = await FirebaseFirestore.instance
            .collection('allDiary')
            .doc(diaryId)
            .get();

        if (!snap.exists) return;

        final diary = Diary.fromSnapshot(snap);

        writeProvider.setOtherDiary(diary);
        nav.selectIndex(0);
      });
    } else {
      dev.log('message received but there is no related message');
    }
  }

  // local notification setting
  void localNotificationInitialization() {
    dev.log('local message receive interact setting done');
    const AndroidInitializationSettings android =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios);
    _local.initialize(
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
      dev.log('local message opend');
      List<String> parts = payload.split('/');
      RemoteMessage remoteMessage = RemoteMessage(data: {
        'screen': parts[0],
        'letterId': parts[1],
        'likedDiaryId': parts[2],
        'campaignId': parts.length > 3 ? parts[3] : '',
      });
      // 알람 클릭 여부 로깅
      final campaignId = parts.length > 3 ? parts[3] : '';
      final destination = parts[0];
      if (campaignId.isNotEmpty) {
        logNotificationOpen(
          campaignId: campaignId,
          destination: destination,
        );
      }
      messageInteractionDeclaration(remoteMessage);
    }
  }

  // send liked Diary notification
  void sendLikedDiaryNotification(
      String likedDiaryId, String userId, int reactionValue) async {
    // 리전(Region)을 'asia-northeast3'로 명시
    final HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'asia-northeast3')
            .httpsCallable('sendLikedDiaryNotification');

    try {
      final response = await callable.call(<String, dynamic>{
        'likedDiaryId': likedDiaryId,
        'userId': userId,
        'reactionValue': reactionValue,
      });

      dev.log('Notification sent: ${response.data}');
    } catch (e) {
      dev.log('Error sending notification: $e');
    }
  }

  Stream<QuerySnapshot<Object?>>? alarmStreamQuery() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('date', descending: true)
        .limit(15)
        .snapshots();
  }

  Future<void> deleteNotification(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  String formatTimeAgo(Timestamp timestamp, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());

    if (difference.inDays > 0) {
      return '${difference.inDays}${'notification_time_form_day'.tr(context)}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${'notification_time_form_hour'.tr(context)}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${'notification_time_form_minute'.tr(context)}';
    } else {
      return 'notification_time_form_second'.tr(context); // 1분 이내일 경우
    }
  }

  Future<Letter> readLetterDataFromDB(String letterId) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('letters')
        .doc(letterId) // 문서 ID를 doc() 메서드로 전달
        .get();

    if (documentSnapshot.exists) {
      return Letter.fromSnapshot(documentSnapshot); // DocumentSnapshot을 바로 전달
    } else {
      throw Exception('Letter not found');
    }
  }

  Future<Diary> readLikedDiaryDataFromDB(String likedDiaryId) async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('allDiary')
        .doc(likedDiaryId)
        .get();
    return Diary.fromSnapshot(documentSnapshot);
  }

  Future<void> subscribeToDailyReminder(String langCode) async {
    // langCode: 'ko' 또는 'en'

    // 1. 기존 구독 취소 (언어 변경 시 이전 언어 구독 해제)
    // (필요하다면 로직 추가: ko -> en 변경 시 daily_reminder_ko는 unsubscribe)
    await FirebaseMessaging.instance.unsubscribeFromTopic('daily_reminder_ko');
    await FirebaseMessaging.instance.unsubscribeFromTopic('daily_reminder_en');

    // 2. 현재 언어에 맞는 토픽 구독
    String topic =
        (langCode == 'ko') ? 'daily_reminder_ko' : 'daily_reminder_en';
    await FirebaseMessaging.instance.subscribeToTopic(topic);

    dev.log("Subscribed to topic: $topic");
  }

  Future<Diary> readOtherDiaryDataFromDB(String diaryId) async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('allDiary')
        .doc(diaryId)
        .get();

    if (!documentSnapshot.exists) {
      throw Exception('Other diary not found: $diaryId');
    }
    return Diary.fromSnapshot(documentSnapshot);
  }

  // AlarmController 안에 추가
  Future<void> showLocalOtherDiaryNotification({
    required String diaryId,
  }) async {
    const details = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      android: AndroidNotificationDetails(
        "1",
        "local notification",
        importance: Importance.max,
        priority: Priority.high,
        channelShowBadge: true,
      ),
    );

    const campaignId = "notification_other_diary_v1";
    final payload = "other_diary_detail//$diaryId/$campaignId";

    final int notifId =
        DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);

    await _local.show(
      notifId,
      "나와 비슷한 친구를 찾았어요!",
      "탭하여 확인해보세요.",
      details,
      payload: payload,
    );
  }

  Future<void> dismissAlarm(String notificationId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}
