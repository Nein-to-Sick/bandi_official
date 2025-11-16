import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

Future<void> logAIChatSendCount(
    {required int chatLengthCount, required int chatResetCount}) async {
  await FirebaseAnalytics.instance.logEvent(
    name: 'ai_chat_send_count',
    parameters: {
      'message_length_count': chatLengthCount,
      'message_reset_count': chatResetCount,
    },
  );
}
