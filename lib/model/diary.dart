import 'package:bandi_official/utils/time_utils.dart';
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
  late int otherUserReaction;
  late String otherUserLikedAt;

  Diary({
    required this.userId,
    required this.title,
    required this.content,
    required this.emotion,
    required this.createdAt,
    required this.updatedAt,
    required this.reaction,
    required this.diaryId,
    this.cheerText = '',
    this.otherUserReaction = -1,
    this.otherUserLikedAt = '',
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
      cheerText: data['cheerText'],
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
    required Timestamp updatedAt,
  }) {
    this.title = title;
    this.content = content;
    this.updatedAt = updatedAt;
  }

  // Initialize field values
  void initializeFields() {
    userId = '';
    title = '';
    content = '';
    emotion = [];
    createdAt = timestampToKst(Timestamp.now());
    updatedAt = timestampToKst(Timestamp.now());
    reaction = [0, 0, 0];
    diaryId = '';
    cheerText = '';
  }

  static List<Diary> defaultLikedDiaryList() {
    return [
      // Diary(
      //     userId: '',
      //     title: '',
      //     content: '',
      //     emotion: [],
      //     createdAt: timestampToKst(Timestamp.now()),
      //     updatedAt: timestampToKst(Timestamp.now()),
      //     reaction: [],
      //     diaryId: ''),
    ];
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'title': title,
        'content': content,
        'emotion': emotion,
        'createdAt': timestampToMilliseconds(createdAt),
        'updatedAt': timestampToMilliseconds(updatedAt),
        'reaction': reaction,
        'diaryId': diaryId,
        'otherUserReaction': otherUserReaction,
        'otherUserLikedAt': otherUserLikedAt,
      };

  factory Diary.fromJsonLocal(
    Map<String, dynamic> json,
    int otherUserReaction,
    String otherUserLikedAt,
  ) {
    return Diary(
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      emotion: json['emotion'],
      createdAt: Timestamp.fromDate(
        DateTime.fromMillisecondsSinceEpoch(json['createdAt'], isUtc: true),
      ),
      updatedAt: Timestamp.fromDate(
        DateTime.fromMillisecondsSinceEpoch(json['updatedAt'], isUtc: true),
      ),
      reaction: json['reaction'],
      diaryId: json['diaryId'],
      otherUserReaction: otherUserReaction,
      otherUserLikedAt: otherUserLikedAt,
    );
  }

  factory Diary.fromJsonDB(
    Map<String, dynamic> json,
    int otherUserReaction,
    String otherUserLikedAt,
  ) {
    return Diary(
      userId: json['userId'],
      title: json['title'],
      content: json['content'],
      emotion: json['emotion'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      reaction: json['reaction'],
      diaryId: json['diaryId'],
      otherUserReaction: otherUserReaction,
      otherUserLikedAt: otherUserLikedAt,
    );
  }

  //  Timestamp to int
  int timestampToMilliseconds(Timestamp timestamp) {
    return timestamp.millisecondsSinceEpoch;
  }
}
