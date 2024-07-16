import 'package:cloud_firestore/cloud_firestore.dart';

enum Messenger { user, ai }

enum MessageType { chat, image }

class Chat {
  late String message;
  late Messenger messenger;
  late MessageType messageType;
  late Timestamp messageTime;

  Chat({
    required this.message,
    required this.messenger,
    required this.messageType,
    required this.messageTime,
  });
}
