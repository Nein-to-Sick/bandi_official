import 'package:cloud_firestore/cloud_firestore.dart';

class Letter {
  late String title;
  late String content;
  late Timestamp date;
  late String letterId;

  Letter({
    required this.title,
    required this.content,
    required this.date,
    required this.letterId,
  });

  static List<Letter> defaultLetterList() {
    return [];
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'date': timestampToMilliseconds(date),
        'letterId': letterId,
      };

  factory Letter.fromJsonLocal(Map<String, dynamic> json) {
    return Letter(
      title: json['title'],
      content: json['content'],
      date: Timestamp.fromDate(
        DateTime.fromMillisecondsSinceEpoch(json['date'], isUtc: true),
      ),
      letterId: json['letterId'],
    );
  }

  factory Letter.fromJsonDB(Map<String, dynamic> json) {
    return Letter(
      title: json['title'],
      content: json['content'],
      date: json['date'],
      letterId: json['letterId'],
    );
  }

  //  Timestamp to int
  int timestampToMilliseconds(Timestamp timestamp) {
    return timestamp.millisecondsSinceEpoch;
  }
}
