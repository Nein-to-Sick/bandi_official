import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

Future<void> logMyPastDiaryTracking() async {
  await FirebaseAnalytics.instance.logEvent(
    name: 'journal_searching',
  );
}