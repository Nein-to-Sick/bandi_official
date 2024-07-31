import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

enum Messenger {
  // 유저 메세지
  user,
  // ai 메세지
  ai,
  // 날짜 등 시스템 메세지
  system,
  // 추천 메세지 등
  assistant,
}

enum MessageType {
  chat,
  image,
}

class ChatMessage {
  late String message;
  late Messenger messenger;
  late MessageType messageType;
  late Timestamp messageTime;

  ChatMessage({
    required this.message,
    required this.messenger,
    required this.messageType,
    required this.messageTime,
  });

  // make ChatMessage from Firestore documents
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ChatMessage(
      message: data['message'] ?? '',
      messenger: Messenger.values[data['messenger']],
      messageType: MessageType.values[data['messageType']],
      messageTime: data['messageTime'] ?? Timestamp.now(),
    );
  }

  // Map to ChatMessage model
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      message: map['message'],
      messenger: Messenger.values[map['messenger']],
      messageType: MessageType.values[map['messageType']],
      messageTime: map['messageTime'],
    );
  }

  // ChatMessage model to JSON
  Map<String, dynamic> toJson() => {
        'message': message,
        'messenger': messenger.index.toInt(),
        'messageType': messageType.index,
        'messageTime': timestampToMilliseconds(messageTime),
      };

  // JSON to ChatMessage model
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'],
      messenger: Messenger.values[json['messenger']],
      messageType: MessageType.values[json['messageType']],
      messageTime: Timestamp.fromDate(
        DateTime.fromMillisecondsSinceEpoch(json['messageTime'], isUtc: true),
      ),
    );
  }

  // ChatMessage to Map
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'messenger': messenger.index,
      'messageType': messageType.index,
      'messageTime': timestampToMilliseconds(messageTime),
    };
  }

  //  Timestamp to int
  int timestampToMilliseconds(Timestamp timestamp) {
    return timestamp.millisecondsSinceEpoch;
  }
}
