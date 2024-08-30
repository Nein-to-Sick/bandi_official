import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts a Timestamp to Korea Standard Time (KST) and returns a Timestamp.
Timestamp timestampToKst(Timestamp timestamp) {
  // Convert the Timestamp to DateTime, add 9 hours for KST, and convert back to Timestamp
  DateTime kstDateTime = timestamp.toDate().add(const Duration(hours: 9));
  return Timestamp.fromDate(kstDateTime);
}

/// Example for converting to another timezone, like PST (Pacific Standard Time).
Timestamp timestampToPst(Timestamp timestamp) {
  // Convert the Timestamp to DateTime, subtract 8 hours for PST, and convert back to Timestamp
  DateTime pstDateTime = timestamp.toDate().subtract(const Duration(hours: 8));
  return Timestamp.fromDate(pstDateTime);
}
