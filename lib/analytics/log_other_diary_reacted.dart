import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

Future<void> logOtherDiaryReacted({
  required String kind
}) async {
  await FirebaseAnalytics.instance.logEvent(
    name: 'other_diary_reacted',
    parameters: {
      'kind': kind
    }
  );
}