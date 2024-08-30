import 'package:bandi_official/utils/time_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  static List<ChatMessage> defaultChatLog() {
    return [
      ChatMessage(
        message: formatTimestamp(timestampToKst(Timestamp.now())),
        messenger: Messenger.system,
        messageType: MessageType.chat,
        messageTime: timestampToKst(Timestamp.now()),
      ),
      ChatMessage(
        message: '안녕! 무슨 일이야?',
        messenger: Messenger.ai,
        messageType: MessageType.chat,
        messageTime: timestampToKst(Timestamp.now()),
      ),
    ];
  }

  // make ChatMessage from Firestore documents
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return ChatMessage(
      message: data['message'] ?? '',
      messenger: Messenger.values[data['messenger']],
      messageType: MessageType.values[data['messageType']],
      messageTime: data['messageTime'] ?? timestampToKst(Timestamp.now()),
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

  // JSON to ChatMessage model from local
  factory ChatMessage.fromJsonLocal(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'],
      messenger: Messenger.values[json['messenger']],
      messageType: MessageType.values[json['messageType']],
      messageTime: Timestamp.fromDate(
        DateTime.fromMillisecondsSinceEpoch(json['messageTime'], isUtc: true),
      ),
    );
  }

  // JSON to ChatMessage model form DB
  factory ChatMessage.fromJsonDB(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'],
      messenger: Messenger.values[json['messenger']],
      messageType: MessageType.values[json['messageType']],
      messageTime: json['messageTime'],
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

  // time stamp formatting
  static String formatTimestamp(Timestamp timestamp) {
    // Timestamp to DateTime
    DateTime dateTime = timestamp.toDate();

    /*
    String formattedTime =
         DateFormat('yyyy년 MM월 dd일 EEEE', 'ko').format(dateTime);
    */
    // formate date time
    String formattedTime = DateFormat('MM월 dd일 EEEE', 'ko').format(dateTime);

    return formattedTime;
  }

  // Function to calculate the difference in days between two timestamps
  static int calculateDateDifference(
      Timestamp timestamp1, Timestamp timestamp2) {
    DateTime date1 = timestamp1.toDate();
    DateTime date2 = timestamp2.toDate();
    return (date1.difference(date2).inDays.abs());
  }
}
