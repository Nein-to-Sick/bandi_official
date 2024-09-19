import 'package:bandi_official/utils/time_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AlarmType {
  likedDiary,
  letter,
}

class Alarm {
  late String dataId;
  late String notificationId;
  late String title;
  late AlarmType type;
  late Timestamp alarmTime;

  Alarm({
    required this.dataId,
    required this.notificationId,
    required this.title,
    required this.type,
    required this.alarmTime,
  });

  static List<Alarm> defaultAlarm() {
    return [];
  }

  factory Alarm.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Alarm(
      dataId: data['dataId'] ?? '',
      notificationId: data['notificationId'] ?? '',
      title: data['title'] ?? '',
      type: AlarmType.values.firstWhere(
          (e) => e.toString() == 'AlarmType.${data['type']}',
          orElse: () => AlarmType.letter),
      alarmTime: data['alarmTime'] ?? Timestamp.now(),
    );
  }
}
