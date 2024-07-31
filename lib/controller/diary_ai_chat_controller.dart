import 'dart:convert';
import 'dart:io';

import 'package:bandi_official/model/diary_ai_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as dev;

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryAiChatController with ChangeNotifier {
  late ChatMessage chatModel;
  // maximun number of reading documents in once
  int rememberableChatlogLimit = 10;
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
  // default chatGPT system prompt
  // TODO: fine-tuning 이후 prompt 수정
  String chatGPTSystemPrompt =
      "사용자의 감정 상태를 파악하고, 그에 맞는 위로와 공감을 표현하며, 필요한 경우 조언도 제공해 주세요. 사용자가 표현하는 감정과 상황에 따라 적절한 반응을 선택해 주세요. 친근하고 따뜻한 어투로 답해주세요.";

  // called on initState
  void loadDataAndSetting() {
    if (!sendFirstMessage) {
      getChatLogFromLocal();
    } else {
      dev.log('did not read data');
    }
  }

  // toggle the chat page view
  void toggleChatOpen() {
    isChatOpen = !isChatOpen;
    notifyListeners();
  }

  // toggle the message send button while the gpt respoonse loading
  void toggleChatResponseLodaing(bool state) {
    isChatResponsLoading = state;
    if (isChatResponsLoading) {
      chatlog.add(
        chatModel = ChatMessage(
          message: '. . .',
          messenger: Messenger.ai,
          messageType: MessageType.chat,
          messageTime: Timestamp.now(),
        ),
      );
    } else {
      chatlog.removeLast();
    }
    notifyListeners();
  }

  void updateTexfieldMessage() {
    // dev.log(chatTextController.text);
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
    ChatMessage(
      message: '오늘 기분이 좋은데 넌 어때?',
      messenger: Messenger.assistant,
      messageType: MessageType.chat,
      messageTime: Timestamp.now(),
    ),
    ChatMessage(
      message: '오늘 기분이 별로야 응원해 줘',
      messenger: Messenger.assistant,
      messageType: MessageType.chat,
      messageTime: Timestamp.now(),
    ),
    ChatMessage(
      message: '지난 내 기록을 보여줘',
      messenger: Messenger.assistant,
      messageType: MessageType.chat,
      messageTime: Timestamp.now(),
    ),
  ];

  List<ChatMessage> defaultChatLog = [
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
    if (!sendFirstMessage) {
      sendFirstMessage = true;
    }
    chatlog.add(chatModel);
    scrollChatScreenToBottom();
    chatTextController.clear();

    // call chatGPT response
    getResponse().then((value) {
      // save the chat log to the local storage
      saveChatLogToLocal();
    });

    notifyListeners();
  }

  // when assistant message has submitted
  void onAssistantMessageSubmitted(String submittedMessage) {
    chatTextController.text = submittedMessage;
    onMessageSubmitted();
  }

  void resetTheChat(BuildContext context) {
    if (sendFirstMessage && !isChatResponsLoading) {
      Navigator.pop(context);
      sendFirstMessage = false;

      // reset the chatlog (visible chat)
      chatlog.clear();
      chatlog = defaultChatLog;

      // reset the chat memory (for gpt prompt)
      chatMemory.clear();
      chatMemory = [
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              chatGPTSystemPrompt,
            ),
          ],
          role: OpenAIChatMessageRole.system,
        ),
      ];

      deleteChatLogFromLocal();

      // for (int i = 0; i < chatMemory.length; i++) {
      //   dev.log(chatMemory[i].content!.first.text.toString());
      // }
      // for (int i = 0; i < chatlog.length; i++) {
      //   dev.log(chatlog[i].message);
      // }
    }
    notifyListeners();
  }

  // make modle albe to remember the past chat log
  List<OpenAIChatCompletionChoiceMessageModel> chatMemory = [];

  // send and get response from chatGPT (chatting model)
  // 추후 stream으로 답변 받아오기로 변경 고려
  Future<void> getResponse() async {
    toggleChatResponseLodaing(true);
    updateChatMemory();

    try {
      // Initializes the package with that API key
      OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;

      // the actual request.
      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
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

      toggleChatResponseLodaing(false);
      updateAIChat(chatCompletion.choices.first.message.content!.first.text!);
    } on SocketException catch (e) {
      dev.log(e.toString());
      toggleChatResponseLodaing(false);
      updateAIChat("인터넷 연결이 없는 것 같아. 확인해 줄 수 있을까?");
    } on RequestFailedException catch (e) {
      dev.log(e.toString());
      toggleChatResponseLodaing(false);
      updateAIChat("이해가 안됐어. 다시 설명해 줄 수 있을까?");
    }

    chatlog.add(chatModel);
    notifyListeners();
  }

  // put past chat log into the chatMemory
  void updateChatMemory() {
    chatMemory.clear();
    chatMemory = [
      OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            chatGPTSystemPrompt,
          ),
        ],
        role: OpenAIChatMessageRole.system,
      ),
    ];

    for (int i = (chatlog.length > rememberableChatlogLimit)
            ? chatlog.length - rememberableChatlogLimit
            : 0;
        i < chatlog.length;
        i++) {
      if (chatlog[i].messenger == Messenger.ai ||
          chatlog[i].messenger == Messenger.user) {
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

  // read chat log from local storage
  // TODO: 향후 단위 별로 채팅 기록을 읽어올 수 있도록 개선
  void getChatLogFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonMessages = prefs.getStringList('localChatLog');

    if (jsonMessages != null) {
      dev.log('read chat log from local');
      sendFirstMessage = true;
      chatlog = jsonMessages
          .map((jsonMessage) => ChatMessage.fromJson(jsonDecode(jsonMessage)))
          .toList();
    } else {
      dev.log('there is no chat data');
    }

    notifyListeners();
  }

  // update chat log to local storage
  void saveChatLogToLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonMessages =
        chatlog.map((message) => jsonEncode(message.toJson())).toList();
    await prefs.setStringList('localChatLog', jsonMessages);
    dev.log('save chat log to local');
  }

  // delete chat log from local storage
  void deleteChatLogFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('localChatLog');
    dev.log('delete chat log from local');
  }

  // DB 저장은 향후 유료 기능 등으로 고려하기, 현재로는 로컬에 대화 기록 저장
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
        .limit(rememberableChatlogLimit)
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
        .limit(rememberableChatlogLimit)
        .get();

    return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
  }
  */
}
