import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

Future<void> logOtherDiaryReceived() async {
  await FirebaseAnalytics.instance.logEvent(
    name: 'other_diary_received',
  );
}