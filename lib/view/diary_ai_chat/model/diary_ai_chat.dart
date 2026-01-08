import 'package:bandi_official/string_extention.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  // 로딩 등 특수 메세지
  special,
}

enum MessageType {
  chat,
  image,
  link,
}

class ChatMessage {
  late String message;
  late Messenger messenger;
  late MessageType messageType;
  late Timestamp messageTime;
  bool isVisible;

  ChatMessage({
    required this.message,
    required this.messenger,
    required this.messageType,
    required this.messageTime,
    this.isVisible = true,
  });

  static List<ChatMessage> defaultChatLog(BuildContext context) {
    return [
      ChatMessage(
        message: formatTimestamp(Timestamp.now(), context),
        messenger: Messenger.system,
        messageType: MessageType.chat,
        messageTime: Timestamp.now(),
        isVisible: true,
      ),
      ChatMessage(
        message: 'ai_chat_greeting'.tr(context),
        messenger: Messenger.ai,
        messageType: MessageType.chat,
        messageTime: Timestamp.now(),
        isVisible: true,
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
      messageTime: data['messageTime'] ?? Timestamp.now(),
      isVisible: data['isVisible'] ?? true,
    );
  }

  // Map to ChatMessage model
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      message: map['message'],
      messenger: Messenger.values[map['messenger']],
      messageType: MessageType.values[map['messageType']],
      messageTime: map['messageTime'],
      isVisible: map['isVisible'] ?? true,
    );
  }

  // ChatMessage model to JSON
  Map<String, dynamic> toJson() => {
        'message': message,
        'messenger': messenger.index.toInt(),
        'messageType': messageType.index,
        'messageTime': timestampToMilliseconds(messageTime),
        'isVisible': isVisible,
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
      isVisible: json['isVisible'] ?? true,
    );
  }

  // JSON to ChatMessage model form DB
  factory ChatMessage.fromJsonDB(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'],
      messenger: Messenger.values[json['messenger']],
      messageType: MessageType.values[json['messageType']],
      messageTime: json['messageTime'],
      isVisible: json['isVisible'] ?? true,
    );
  }

  // ChatMessage to Map
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'messenger': messenger.index,
      'messageType': messageType.index,
      'messageTime': timestampToMilliseconds(messageTime),
      'isVisible': isVisible,
    };
  }

  //  Timestamp to int
  int timestampToMilliseconds(Timestamp timestamp) {
    return timestamp.millisecondsSinceEpoch;
  }

  // time stamp formatting
  static String formatTimestamp(Timestamp timestamp, BuildContext context) {
    // Timestamp to DateTime
    DateTime dateTime = timestamp.toDate();

    /*
    String formattedTime =
         DateFormat('yyyy년 MM월 dd일 EEEE', 'ko').format(dateTime);
    */
    // formate date time
    String formattedTime = DateFormat('ai_chat_date_form'.tr(context),
            'ai_chat_date_form_country'.tr(context))
        .format(dateTime);

    return formattedTime;
  }

  static int calculateDateDifference(
      Timestamp timestamp1, Timestamp timestamp2) {
    // 로컬 시간대로 변환
    DateTime d1 = timestamp1.toDate().toLocal();
    DateTime d2 = timestamp2.toDate().toLocal();

    // 시간, 분, 초를 제거하고 '연, 월, 일'만 남긴 객체 생성 (자정으로 초기화)
    DateTime dateOnly1 = DateTime(d1.year, d1.month, d1.day);
    DateTime dateOnly2 = DateTime(d2.year, d2.month, d2.day);

    return dateOnly1.difference(dateOnly2).inDays.abs();
  }
}
