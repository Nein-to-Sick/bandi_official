import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ChatMessage(
      message: data['message'] ?? '',
      messenger: Messenger.values[data['messenger']],
      messageType: MessageType.values[data['messageType']],
      messageTime: data['messageTime'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'messenger': messenger.index,
      'messageType': messageType.index,
      'messageTime': messageTime,
    };
  }
}
