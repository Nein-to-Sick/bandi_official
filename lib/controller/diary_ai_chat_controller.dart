import 'package:bandi_official/model/diary_ai_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as dev;

import 'package:intl/intl.dart';

class DiaryAiChatController with ChangeNotifier {
  late ChatMessage chatModel;
  // maximun number of reading documents in once
  int readDocumentsLimit = 10;
  // chat message text controller
  final TextEditingController chatTextController = TextEditingController();
  // chat focus node
  FocusNode chatFocusNode = FocusNode();
  // determine whether to display the recommended message
  bool sendFirstMessage = false;
  // while the ai answering the message
  bool isChatResponsLoading = false;
  // determine whether to display the chat view
  bool isChatOpen = false;
  // manage the chat page scroll
  final chatScrollController = ScrollController();
  // for chat system message (today's date)
  late String todayDate = '';

  // // called on initState
  // void loadDataAndSetting() {
  //   todayDate = formatTimestamp(Timestamp.now())
  // }

  // toggle the chat page view
  void toggleChatOpen() {
    isChatOpen = !isChatOpen;
    notifyListeners();
  }

  // toggle the message send button while the gpt respoonse loading
  void toggleChatResponseLodaing(bool state) {
    isChatResponsLoading = state;
    notifyListeners();
  }

  void updateTexfieldMessage() {
    dev.log(chatTextController.text);
    notifyListeners();
  }

  // unfocus screen
  void unfocusScreen() {
    if (chatFocusNode.hasFocus) {
      chatFocusNode.unfocus();
    }
  }

  // scroll chat screen to newest message
  void scrollChatScreenToBottom() {
    chatScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

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

  // recommanded system message
  List<ChatMessage> assistantMessage = [
    // TODO: assistant message 정리하기
    ChatMessage(
      message: 'wow',
      messenger: Messenger.assistant,
      messageType: MessageType.chat,
      messageTime: Timestamp.now(),
    ),
  ];

  // current chat log
  List<ChatMessage> chatlog = [
    ChatMessage(
      message: formatTimestamp(Timestamp.now()),
      messenger: Messenger.system,
      messageType: MessageType.chat,
      messageTime: Timestamp.now(),
    ),
    ChatMessage(
      message: '안녕! 무슨 일이야?',
      messenger: Messenger.ai,
      messageType: MessageType.chat,
      messageTime: Timestamp.now(),
    ),
  ];

  // update user chatting
  void updateUserChat() {
    chatModel = ChatMessage(
      message: chatTextController.text.trim(),
      messenger: Messenger.user,
      messageType: MessageType.chat,
      messageTime: Timestamp.now(),
    );
  }

  // update ai chatting
  void updateAIChat(String message) {
    chatModel = ChatMessage(
      message: message,
      messenger: Messenger.ai,
      messageType: MessageType.chat,
      messageTime: Timestamp.now(),
    );
  }

  // when user message has submitted
  void onMessageSubmitted() {
    // make user message to ChatMessage model
    updateUserChat();
    sendFirstMessage = true;
    scrollChatScreenToBottom();
    chatlog.add(chatModel);
    chatTextController.clear();

    // call chatGPT response
    getResponse();
  }

  // when assistant message has submitted
  void onAssistantMessageSubmitted(String submittedMessage) {
    // TODO: assistant message 초기화 주기 결정 필요
    chatTextController.text = submittedMessage;
    onMessageSubmitted();
  }

  // make modle albe to remember the past chat log
  List<OpenAIChatCompletionChoiceMessageModel> chatMemory = [
    OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          // TODO: fine-tuning 이후 prompt 수정
          "사용자의 감정 상태를 파악하고, 그에 맞는 위로와 공감을 표현하며, 필요한 경우 조언도 제공해 주세요. 사용자가 표현하는 감정과 상황에 따라 적절한 반응을 선택해 주세요. 친근하고 따뜻한 어투로 답해주세요.",
        ),
      ],
      role: OpenAIChatMessageRole.system,
    ),
  ];

  // send and get response from chatGPT (chatting model)
  // 추후 stream으로 답변 받아오기로 변경 고려
  void getResponse() async {
    toggleChatResponseLodaing(true);
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

      updateAIChat(chatCompletion.choices.first.message.content!.first.text!);
      chatlog.add(chatModel);
    } on RequestFailedException catch (e) {
      dev.log(e.toString());
      updateAIChat("이해가 안됐어. 다시 설명해 줄 수 있을까?");
      chatlog.add(chatModel);
    }
    toggleChatResponseLodaing(false);
    notifyListeners();
  }

  // put past chat log into the chatMemory
  void updateChatMemory() {
    // TODO: 최대로 기억할 메세지 개수 지정 필요
    for (int i = 0; i < chatlog.length; i++) {
      if (chatlog[i].messenger != Messenger.system &&
          chatlog[i].messenger != Messenger.assistant) {
        chatMemory.add(
          OpenAIChatCompletionChoiceMessageModel(
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  chatlog[i].message),
            ],
            role: (chatlog[i].messenger == Messenger.user)
                ? OpenAIChatMessageRole.user
                : OpenAIChatMessageRole.assistant,
          ),
        );
      }
    }
  }

  /*
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
  */
}
