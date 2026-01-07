import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

// 알람 수신 시 (미사용)
Future<void> logNotificationReceive({required String campaignId}) async {
  await analytics.logEvent(
    name: 'custom_notification_received',
    parameters: {'campaign_id': campaignId},
  );
}

// 알람 클릭 시 (앱이 열릴 때)
Future<void> logNotificationOpen({
  required String campaignId,
  required String destination,
}) async {
  await analytics.logEvent(
    name: 'custom_notification_opened',
    parameters: {
      'campaign_id': campaignId,
      'destination': destination, // e.g. 'letter_detail', 'liked_diary_detail'
    },
  );
}

// 딥링크 진입 시 (미사용)
Future<void> logPushDeeplinkOpen({
  required String campaignId,
  required String destination,
}) async {
  await analytics.logEvent(
    name: 'custom_push_deeplink_opened',
    parameters: {
      'campaign_id': campaignId,
      'destination': destination // e.g. 'letter_detail', 'liked_diary_detail'
    },
  );
}
