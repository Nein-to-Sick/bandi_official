import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

Future<void> logJournalShare() async {
  await FirebaseAnalytics.instance.logEvent(
    name: 'journal_share',
  );
}