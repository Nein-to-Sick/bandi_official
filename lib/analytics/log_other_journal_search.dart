import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

Future<void> logOtherJournalSearch({required String journalType}) async {
  await analytics.logEvent(
    name: 'other_journal_search',
    parameters: {
      'journal_type': journalType, // e.g. 'others', 'letters'
    },
  );
}
