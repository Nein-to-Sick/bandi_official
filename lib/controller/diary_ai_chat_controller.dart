import 'package:bandi_official/model/diary_ai_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as dev;

class DiaryAiChatController with ChangeNotifier {
  late ChatMessage chatModel;
  int readDocumentsLimit = 10; // 한 번에 로드할 문서 수
  final TextEditingController chatTextController = TextEditingController();
  FocusNode chatFocusNode = FocusNode();
  bool sendFirstMessage = false;
  bool isChatResponsloading = false;

  // recommanded system message
  List<ChatMessage> assistantMessage = [
    ChatMessage(
        message: 'wow',
        messenger: Messenger.assistant,
        messageType: MessageType.chat,
        messageTime: Timestamp.now()),
  ];

  // past chat log form firebase (cannot remember)
  List<ChatMessage> pastChatlog = [];

  // current chat log (can remember)
  List<ChatMessage> currentChatlog = [
    ChatMessage(
      message: "안녕! 무슨 일이야?",
      messenger: Messenger.ai,
      messageType: MessageType.chat,
      messageTime: Timestamp.now(),
    ),
  ];

  // make modle albe to remember the past chat log
  // all messages to be sent
  List<OpenAIChatCompletionChoiceMessageModel> chatMemory = [
    OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          // TODO: fine-tuning 이후 prompt 수정
          "fine tuning prompt goes in here!",
        ),
      ],
      role: OpenAIChatMessageRole.system,
    ),
  ];

  // update user chatting
  void updateUserChat(String message) {
    chatModel.message = message;
    chatModel.messenger = Messenger.user;
    chatModel.messageType = MessageType.chat;
    chatModel.messageTime = Timestamp.now();
    notifyListeners();
  }

  // update ai chatting
  void updateAIChat(String message) {
    chatModel.message = message;
    chatModel.messenger = Messenger.ai;
    chatModel.messageType = MessageType.chat;
    chatModel.messageTime = Timestamp.now();
    notifyListeners();
  }

  // unfocus screen >> 다른 함수 호출 시에 사용하기!
  void unfocusScreen() {
    if (chatFocusNode.hasFocus) {
      chatFocusNode.unfocus();
    }
  }

  // creat message in Firebase
  Future<void> sendMessage(ChatMessage message) async {
    await FirebaseFirestore.instance
        .collection('userChatCollection')
        .add(message.toMap());
  }

  // read chat log form firebase
  Stream<List<ChatMessage>> getMessagesFromFirebase() {
    dev.log('처음으로 읽기!!!');
    return FirebaseFirestore.instance
        .collection('userChatCollection')
        .orderBy('messageTime', descending: true)
        .limit(readDocumentsLimit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }

  // read older chat log form firebase
  Future<List<ChatMessage>> getOlderMessagesFromFirebase(
      Timestamp lastTimestamp) async {
    dev.log('오래된거 읽기!!!');
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('userChatCollection')
        .orderBy('messageTime', descending: true)
        .startAfter([lastTimestamp])
        .limit(readDocumentsLimit)
        .get();

    return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
  }

  // send and get response from chatGPT (chatting model)
  void getResponse() async {
    updateChatMemory();

    try {
      // Initializes the package with that API key
      OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;

      // the actual request.
      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
        // TODO: 향후 모델 결정 및 수정 필요
        model: "gpt-4o",
        messages: chatMemory,
        // 답변할 종류의 수
        n: 1,
        // 답변에 사용할 최대 토큰의 크기
        maxTokens: 350,
        // 같은 답변 반복 (0.1~1.0일 수록 감소)
        frequencyPenalty: 0.5,
        // 새로운 주제 제시 (>0 수록 새로운 주제 확률 상승)
        presencePenalty: 0.5,
        // 답변의 일관성 (낮을 수록 집중됨)
        temperature: 0.9,
      );

      dev.log(chatCompletion.choices.first.message.content!.first.text!);
    } on RequestFailedException catch (e) {
      dev.log(e.toString());
      // TODO: 채팅 오류시 예외 처리 추가
    }
  }

  // put past chat log into the chatMemory
  void updateChatMemory() {
    chatMemory.add(
      OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text("temp"),
        ],
        role: OpenAIChatMessageRole.user,
      ),
    );
  }
}
