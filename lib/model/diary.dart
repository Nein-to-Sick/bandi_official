import 'package:cloud_firestore/cloud_firestore.dart';

class Diary {
  late String userId;
  late String title;
  late String content;
  late List<dynamic> emotion;
  late Timestamp createdAt;
  late Timestamp updatedAt;
  late List<dynamic> reaction;
  late String diaryId;
  late String cheerText;

  Diary({
    required this.userId,
    required this.title,
    required this.content,
    required this.emotion,
    required this.createdAt,
    required this.updatedAt,
    required this.reaction,
    required this.diaryId,
  });

  // Factory constructor to create a Diary instance from a Firestore snapshot
  factory Diary.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    return Diary(
      userId: data['userId'],
      title: data['title'],
      content: data['content'],
      emotion: data['emotion'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
      reaction: data['reaction'],
      diaryId: snap.id,
    );
  }

  // Method to convert a Diary instance to a map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'emotion': emotion,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'reaction': reaction,
    };
  }

  // Method to update a Diary instance
  void update({
    required String title,
    required String content,
    required List<dynamic> emotion,
    required Timestamp updatedAt,
    required List<dynamic> reaction,
  }) {
    this.title = title;
    this.content = content;
    this.emotion = emotion;
    this.updatedAt = updatedAt;
    this.reaction = reaction;
  }

  // Initialize field values
  void initializeFields() {
    userId = '';
    title = '';
    content = '';
    emotion = [];
    createdAt = Timestamp.now();
    updatedAt = Timestamp.now();
    reaction = [0, 0, 0];
    diaryId = '';
  }
}
