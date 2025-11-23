import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

Future<void> logJournalCreate({
  required bool usedAI
}) async {
  await FirebaseAnalytics.instance.logEvent(
    name: 'journal_create',
    parameters: {
      'use_ai': usedAI ? 'yes' : 'no',
    },
  );
}