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

  // Firestore의 DocumentSnapshot을 바탕으로 Letter 인스턴스를 생성하는 메서드
  factory Letter.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Letter(
      title: data['title'] as String,
      content: data['content'] as String,
      date: data['date'] as Timestamp,
      letterId: data['letterId'] as String,
    );
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
