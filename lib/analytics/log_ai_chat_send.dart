import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

Future<void> logAIChatSend(
    {required bool chatSend, required int chatLength}) async {
  log('$chatSend and $chatLength');
  await FirebaseAnalytics.instance.logEvent(
    name: 'ai_chat_send',
    parameters: {
      'message_send': chatSend ? 'yes' : 'no',
      'message_length': chatLength,
    },
  );
}
