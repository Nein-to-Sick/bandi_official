import 'package:cloud_firestore/cloud_firestore.dart';

class Diary {
  late String title;
  late String content;
  late List<dynamic> keyword;
  late String date;

  Diary({
    required this.title,
    required this.content,
    required this.keyword,
    required this.date,
  });

  static Diary fromSnapshot(DocumentSnapshot snap) {
    Diary diary = Diary(
      title: snap['title'],
      content: snap['content'],
      keyword: snap['keyword'],
      date: snap['date'],
    );
    return diary;
  }
}
