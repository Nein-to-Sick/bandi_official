import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts a Timestamp to the local time zone and returns a Timestamp.
Timestamp timestampToLocal(Timestamp timestamp) {
  // Convert the Timestamp to DateTime and adjust to the local time zone
  DateTime localDateTime = timestamp.toDate().toLocal();
  return Timestamp.fromDate(localDateTime);
}
