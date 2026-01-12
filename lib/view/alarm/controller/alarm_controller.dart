import 'dart:io';

import 'package:bandi_official/analytics/log_notification_open.dart';
import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:bandi_official/controller/navigation_toggle_provider.dart';
import 'package:bandi_official/main.dart';
import 'package:bandi_official/model/alarm.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:bandi_official/localization/string_extention.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

import '../../mail/detail_view.dart';

class NotificationTestType {
  static const String letter = "letter";
  static const String liked = "liked";
  static const String other = "other";
}

class NotificationType {
  static const String letterDetail = 'letter_detail';
  static const String likedDiaryDetail = 'liked_diary_detail';
  static const String otherDiaryDetail = 'other_diary_detail';
}

class NotificationTopic {
  static const String dailyReminderKo = 'daily_reminder_ko';
  static const String dailyReminderEn = 'daily_reminder_en';
}

class NotificationConfig {
  static const String channelId = '1';
  static const String channelName = 'local notification';
  static const String defaultCampaignId = 'notification_open_v1';
  static const Color backgroundColor = Colors.black;
}

class AlarmController with ChangeNotifier {
  // initalize once
  bool _isInitialized = false;

  // local notification setting
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // determine whether to display the alarm view
  bool isAlarmOpen = false;

  // Get current user from FirebaseAuth
  String? get userId => FirebaseAuth.instance.currentUser!.uid;

  // Firebase messaging setting
  final fcmToken = FirebaseMessaging.instance.getToken();

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

  void firebaseOnTokenRefresh() async {
    // [추가] iOS의 경우 APNs 토큰이 설정될 때까지 대기
    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) {
        dev.log('APNs token is not set yet. Waiting...');
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      dev.log('FCM Token Refreshed: $fcmToken');

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'fcmToken': fcmToken}, SetOptions(merge: true));

          dev.log('FCM Token updated in Firestore for user: ${user.uid}');
        } catch (e) {
          dev.log('Failed to update FCM token in Firestore: $e');
        }
      } else {
        dev.log('User is not logged in. Token refresh ignored.');
      }
    }).onError((err) {
      dev.log('Error getting refresh token: $err');
    });
  }

  // 통합 초기화 함수 (main.dart에서는 이 함수 하나만 호출하면 됩니다)
  Future<void> initializeAlarmSystem() async {
    if (_isInitialized) return; // 이미 초기화되었다면 중복 실행 방지

    // 1. 로컬 알림 초기화 (가장 먼저)
    await localNotificationInitialization();

    // 2. Firebase 리스너 등록
    firebaseOnMessageListen();
    firebaseOnMessageOpenedApp();

    // 3. 앱 종료 상태에서 알림 클릭으로 켜졌는지 확인
    // (약간의 딜레이를 주어 네비게이터가 준비된 후 실행되도록 함)
    Future.delayed(const Duration(milliseconds: 500), () {
      firebaseGetInitialListen();
    });

    _isInitialized = true;
  }

  // 1. 로컬 알림 초기화 (기존 로직 유지 + 클릭 리스너 보강)
  Future<void> localNotificationInitialization() async {
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('ic_notification');
    const DarwinInitializationSettings ios = DarwinInitializationSettings();
    const InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios);

    await _local.initialize(
      settings,
      // [개선] 앱 실행 중 로컬 알림 클릭 시 동작 처리
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _handleNotificationPayload(response.payload!);
        }
      },
    );
  }

  // parts[0]: screen
  // parts[1]: letterId
  // parts[2]: likedDiaryId
  // payload 처리 핸들러
  void _handleNotificationPayload(String payload) {
    dev.log('local message opened');
    // 구분자(|)를 사용하여 페이로드 분리
    List<String> parts = payload.split('|');

    // 데이터 맵핑
    RemoteMessage remoteMessage = RemoteMessage(data: {
      'screen': parts.isNotEmpty ? parts[0] : '',
      'letterId': parts.length > 1 ? parts[1] : '',
      'likedDiaryId': parts.length > 2 ? parts[2] : '',
      'campaignId': parts.length > 3 ? parts[3] : '',
    });

    // 알람 클릭 여부 로깅
    final campaignId = parts.length > 3 ? parts[3] : '';
    final destination = parts.isNotEmpty ? parts[0] : '';

    if (campaignId.isNotEmpty) {
      logNotificationOpen(
        campaignId: campaignId,
        destination: destination,
      );
    }

    messageInteractionDeclaration(remoteMessage);
  }

  // foreground notification receive
  void firebaseOnMessageListen() {
    dev.log('foreground message setting done');

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
      if (message != null && message.notification != null) {
        dev.log('local message received: ${message.notification!.title}');

        // 1. UI 업데이트 (새 알림 표시)
        // 안전하게 Context 접근: navigatorKey가 현재 연결된 상태인지 확인
        final context = navigatorKey.currentContext;
        if (context != null) {
          // addPostFrameCallback 불필요: 이벤트 루프에서 실행되므로 바로 접근 가능
          try {
            MailController mailController =
                Provider.of<MailController>(context, listen: false);
            mailController.updateIsNewNotifications(true);
          } catch (e) {
            dev.log('Error updating MailController: $e');
          }
        }

        // 2. Local Notification 표시 설정
        const NotificationDetails details = NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
          android: AndroidNotificationDetails(
            NotificationConfig.channelId,
            NotificationConfig.channelName,
            importance: Importance.max,
            priority: Priority.high,
            channelShowBadge: true,
            color: NotificationConfig.backgroundColor,
          ),
        );

        // 3. Payload 구성
        final screen = message.data['screen'] ?? '';
        final letterId = message.data['letterId'] ?? '';
        final likedDiaryDetail = message.data['likedDiaryId'] ?? '';
        const campaignId = NotificationConfig.defaultCampaignId;

        // 구분자(|)를 사용하여 페이로드 생성
        final payload = '$screen|$letterId|$likedDiaryDetail|$campaignId';

        // 4. 알림 표시
        try {
          await _local.show(
            // message.hashCode를 사용하여 각 알림에 고유 ID 부여 (덮어쓰기 방지)
            message.hashCode,
            message.notification!.title ?? '',
            message.notification!.body ?? '',
            details,
            payload: payload,
          );
        } catch (e) {
          dev.log('Error showing local notification: $e');
        }

        // (선택사항) 알림 수신 로그 전송
        await logNotificationReceive(campaignId: campaignId);
      }
    });
  }

  // background notification receive
  void firebaseOnMessageOpenedApp() {
    dev.log('message receive interact setting done (openedApp)');

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // 1. 메시지 유효성 확인
      if (message.notification != null || message.data.isNotEmpty) {
        dev.log('background message opened: ${message.notification?.title}');

        // 2. UI 업데이트 (새 알림 표시)
        // navigatorKey를 통해 안전하게 Provider 접근
        final context = navigatorKey.currentContext;
        if (context != null) {
          try {
            MailController mailController =
                Provider.of<MailController>(context, listen: false);
            mailController.updateIsNewNotifications(true);
          } catch (e) {
            dev.log('Error updating MailController in openedApp: $e');
          }
        }

        // 3. 알람 클릭 로깅
        final campaignId = message.data['campaignId'] ?? '';
        final destination = message.data['screen'] ?? '';

        if (campaignId.isNotEmpty) {
          try {
            await logNotificationOpen(
              campaignId: campaignId,
              destination: destination,
            );
          } catch (e) {
            dev.log('Error logging notification open: $e');
          }
        }

        // 4. 네비게이션 처리 (통합 핸들러 사용 권장)
        messageInteractionDeclaration(message);
      }
    });
  }

  // terminate notificaiton receive (App Cold Start)
  Future<void> firebaseGetInitialListen() async {
    dev.log('terminate message setting done');

    // getInitialMessage는 앱이 종료된 상태에서 알림을 눌러 열었을 때만 메시지를 반환합니다.
    RemoteMessage? message =
        await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      dev.log('terminate message received: ${message.notification?.title}');

      // 1. UI 업데이트 (새 알림 표시) - 선택 사항
      final context = navigatorKey.currentContext;
      if (context != null) {
        try {
          MailController mailController =
              Provider.of<MailController>(context, listen: false);
          mailController.updateIsNewNotifications(true);
        } catch (e) {
          dev.log('Error updating MailController in initialListen: $e');
        }
      }

      // 2. 알람 클릭 로깅
      final campaignId = message.data['campaignId'] ?? '';
      final destination = message.data['screen'] ?? '';

      if (campaignId.isNotEmpty) {
        try {
          await logNotificationOpen(
            campaignId: campaignId,
            destination: destination,
          );
        } catch (e) {
          dev.log('Error logging notification open: $e');
        }
      }

      // 3. 네비게이션 처리 (통합 핸들러 사용)
      Future.delayed(const Duration(milliseconds: 500), () {
        messageInteractionDeclaration(message);
      });
    }
  }

  // refactor common function for firebase messaging and local notification
  void messageInteractionDeclaration(RemoteMessage message) async {
    final String screenType = message.data['screen'] ?? '';

    final context = navigatorKey.currentContext;
    if (context == null) {
      dev.log('Navigator context is null. Cannot navigate.');
      return;
    }

    dev.log('Processing notification for screen: $screenType');

    final navToggle =
        Provider.of<NavigationToggleProvider>(context, listen: false);
    final homeWrite = Provider.of<HomeToWrite>(context, listen: false);
    final mailController = Provider.of<MailController>(context, listen: false);

    try {
      switch (screenType) {
        // 1. 편지 상세 화면
        case NotificationType.letterDetail:
          dev.log('Navigating to letter_detail');

          var (isSuccess, item) = await mailController
              .checkForNewLetterNewNotificationsAndSaveLetterToLocal();

          if (isSuccess && item != null) {
            navigatorKey.currentState?.push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => DetailView(
                  item: item,
                  mailController: mailController,
                ),
                transitionsBuilder: (_, animation, __, child) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          }
          break;

        // 2. 공감 일기 상세 화면
        case NotificationType.likedDiaryDetail:
          final String likedDiaryId = message.data['likedDiaryId'] ?? '';
          if (likedDiaryId.isEmpty) return;

          dev.log('Navigating to liked_diary_detail: $likedDiaryId');

          // [Refactored] 공통 함수 사용
          try {
            Diary diary = await readDiaryDataFromDB(likedDiaryId);
            homeWrite.readMyDiary(diary);
            navToggle.selectIndex(0);
            homeWrite.toggleWrite();
          } catch (e) {
            dev.log('Failed to load liked diary: $e');
          }
          break;

        // 3. 다른 사람 일기 상세 화면
        case NotificationType.otherDiaryDetail:
          final String diaryId = message.data['likedDiaryId'] ?? '';
          if (diaryId.isEmpty) return;

          dev.log('Navigating to other_diary_detail: $diaryId');

          try {
            final diary = await readDiaryDataFromDB(diaryId);
            homeWrite.setOtherDiary(diary);
            navToggle.selectIndex(0);
          } catch (e) {
            dev.log('Failed to load other diary: $e');
          }
          break;

        default:
          dev.log('Unknown screen type or no related action');
          break;
      }
    } catch (e) {
      dev.log('Error handling notification navigation: $e');
    }
  }

  Future<Letter> readLetterDataFromDB(String letterId) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('letters')
        .doc(letterId)
        .get();

    if (documentSnapshot.exists) {
      return Letter.fromSnapshot(documentSnapshot);
    } else {
      throw Exception('Letter not found');
    }
  }

  Future<Diary> readDiaryDataFromDB(String diaryId) async {
    final documentSnapshot = await FirebaseFirestore.instance
        .collection('allDiary')
        .doc(diaryId)
        .get();

    if (!documentSnapshot.exists) {
      throw Exception('Diary not found');
    }
    return Diary.fromSnapshot(documentSnapshot);
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

  Future<void> subscribeToDailyReminder(String langCode) async {
    // langCode: 'ko' 또는 'en'

    // 1. 기존 구독 취소 (언어 변경 시 이전 언어 구독 해제)
    // (필요하다면 로직 추가: ko -> en 변경 시 daily_reminder_ko는 unsubscribe)
    await FirebaseMessaging.instance
        .unsubscribeFromTopic(NotificationTopic.dailyReminderKo);
    await FirebaseMessaging.instance
        .unsubscribeFromTopic(NotificationTopic.dailyReminderEn);

    // 2. 현재 언어에 맞는 토픽 구독
    String topic = (langCode == 'ko')
        ? NotificationTopic.dailyReminderKo
        : NotificationTopic.dailyReminderEn;
    await FirebaseMessaging.instance.subscribeToTopic(topic);

    dev.log("Subscribed to topic: $topic");
  }

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
          NotificationConfig.channelId, NotificationConfig.channelName,
          importance: Importance.max,
          priority: Priority.high,
          channelShowBadge: true,
          color: NotificationConfig.backgroundColor),
    );

    const campaignId = "notification_other_diary_v1";
    // 구분자(|)를 사용하여 페이로드 생성
    final payload = "other_diary_detail||$diaryId|$campaignId";

    // 32비트 정수 범위 내에서 ID 생성 (Int32 Max: 2147483647)
    final int notifId =
        DateTime.now().millisecondsSinceEpoch.remainder(2147483647);

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

// ---------------------------------------------------------------------------

  // [TEST] 모든 종류의 알림을 테스트하는 함수
  Future<void> testAllNotificationTypes() async {
    dev.log('🔔 [Test] Starting notification test...');

    String testLetterId = dotenv.env['TEST_LETTER_ID']!;
    String testLikedDiaryId = dotenv.env['TEST_LIKED_DIARY_ID']!;
    String testMyDiaryId = dotenv.env['TEST_OTHER_DIARY_ID']!;

    // 1. 편지 도착 알림 (Letter Detail)
    await _showTestNotification(
      id: 1001,
      title: '새로운 편지가 도착했어요 💌',
      body: '반디가 보낸 마음을 확인해보세요.',
      screen: NotificationType.letterDetail,
      letterId: testLetterId,
    );

    // 2. 공감 알림 (Liked Diary Detail)
    await _showTestNotification(
      id: 1002,
      title: '누군가 내 일기에 공감했어요 ❤️',
      body: '어떤 마음을 남겼는지 확인해보세요.',
      screen: NotificationType.likedDiaryDetail,
      likedDiaryId: testLikedDiaryId,
    );

    // 3. 다른 사람 일기 추천 알림 (Other Diary Detail)
    await _showTestNotification(
      id: 1003,
      title: '나와 비슷한 친구를 찾았어요! 🤝',
      body: '다른 사람의 일기를 읽어보세요.',
      screen: NotificationType.otherDiaryDetail,
      // other_diary_detail은 likedDiaryId 자리에 diaryId를 넣음 (구조상)
      likedDiaryId: testMyDiaryId,
    );

    dev.log('✅ [Test] All notifications dispatched.');
  }

  // 내부 헬퍼 함수: 테스트용 로컬 알림 표시
  Future<void> _showTestNotification({
    required int id,
    required String title,
    required String body,
    required String screen,
    String letterId = '',
    String likedDiaryId = '',
  }) async {
    // 실제 운영 코드와 동일한 Payload 형식 생성 (구분자: |)
    // screen | letterId | likedDiaryId | campaignId
    final payload = '$screen|$letterId|$likedDiaryId|test_campaign_v1';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      NotificationConfig.channelId,
      NotificationConfig.channelName,
      importance: Importance.max,
      priority: Priority.high,
      channelShowBadge: true,
      color: NotificationConfig.backgroundColor,
    );

    const NotificationDetails details = NotificationDetails(
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
      android: androidDetails,
    );

    // 2초 간격으로 알림을 띄워 겹치지 않게 함
    await Future.delayed(const Duration(seconds: 2));

    await _local.show(
      id,
      '[Local테스트] $title', // 테스트임을 알리기 위해 prefix 추가
      body,
      details,
      payload: payload,
    );

    dev.log('🚀 Sent test notification: $screen');
  }

  // AlarmController 내부에 임시 테스트 함수 추가
  Future<void> sendTestFCM(String type) async {
    // 현재 로그인 중인 계정에 알림을 보냄
    String? token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    final HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'asia-northeast3')
            .httpsCallable('testNotification');

    try {
      await callable.call({
        'token': token,
        'type': type,
      });
      dev.log("FCM Sent: $type");
    } catch (e) {
      dev.log("Error: $e");
    }
  }

  // FCM Notification Test
  Future<void> runFcmTest() async {
    // 테스트할 알림 타입 리스트 정의
    final List<String> typeList = [
      NotificationTestType.letter, // 편지 알림
      NotificationTestType.liked, // 공감 알림
      NotificationTestType.other, // 추천 일기 알림
    ];

    dev.log('🚀 Starting FCM Test Sequence...');

    for (String type in typeList) {
      dev.log('📤 Sending test FCM: $type');

      // 알림 전송 요청 (비동기)
      await sendTestFCM(type);

      // 2초 대기 (알림이 겹치지 않게 시간차 두기)
      await Future.delayed(const Duration(seconds: 2));
    }

    dev.log('✅ FCM Test Sequence Completed.');
  }
}
