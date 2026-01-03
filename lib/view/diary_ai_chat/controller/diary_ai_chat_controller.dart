import 'dart:convert';
import 'dart:io';

import 'package:bandi_official/analytics/log_ai_chat_send.dart';
import 'package:bandi_official/view/diary_ai_chat/model/diary_ai_chat.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as dev;

import 'package:shared_preferences/shared_preferences.dart';

class DiaryAiChatController with ChangeNotifier {
  late ChatMessage chatModel;
  // maximun number of reading documents in once
  int rememberableChatlogLimit = 10;
  // maximum number of chat log dates to load at once
  int maxChatlogDatesToLoad = 3;
  // chat message text controller
  final TextEditingController chatTextController = TextEditingController();
  // chat focus node
  FocusNode chatFocusNode = FocusNode();
  // determine whether to display the recommended message
  bool sendFirstMessage = false;
  // count chat message for one chatting
  int countMessageForAnalysis = 0;
  // count chat reset for analysis
  int countMessageResetForAnalysis = 0;
  // while the ai answering the message
  bool isChatResponsLoading = false;
  // determine whether to display the chat view
  bool isChatOpen = false;
  // Flag variable indicating whether more data needs to be loaded
  bool loadMoreData = true;
  // Flag variable to track whether the scroll listener has already been added
  bool isListenerAdded = false;
  // prevent duplication loading
  bool _isLoadingOlderChat = false;
  // View에서 상태를 확인하기 위한 Getter
  bool get isLoadingOlderChat => _isLoadingOlderChat;
  // manage the chat page scroll
  final chatScrollController = ScrollController();
  // for chat system message (today's date)
  late String todayDate = '';
  // default chatGPT system prompt
  // String chatGPTSystemPrompt =
  //     "You are a friendly chatbot offering emotional support for personal concerns. Respond warmly in Korean, focusing on empathy. Offer practical suggestions only if explicitly requested. Maintain a casual, friendly tone, like a close friend, and limit responses to 3 sentences.";

  // String chatGPTSystemPrompt =
  //     "Your name is 반디. You offer warm, empathetic support in Korean, responding as a respectful friend. Keep responses friendly and brief (max 3 sentences). Provide practical suggestions only when directly asked.";

  String getChatGPTSystemPrompt(BuildContext context) {
    return "ai_chat_system_prompt".tr(context);
  }

  // firebase user uid
  String? get userId => FirebaseAuth.instance.currentUser!.uid;

  // called on initState
  Future<void> loadDataAndSetting() async {
    if (!sendFirstMessage) {
      getChatLogFromLocal();
    } else {
      dev.log('did not read data');
    }
  }

  // toggle the chat page view
  void toggleChatOpen(value) {
    isChatOpen = value;
    if (!isChatOpen && countMessageForAnalysis != 0) {
      logAIChatSendCount(
          chatLengthCount: countMessageForAnalysis,
          chatResetCount: countMessageResetForAnalysis);
      initializeCountChatAnalysis();
      initializeCountMessageResetForAnalysisAnalysis();
    }
    notifyListeners();
  }

  // toggle the loadMoreData value
  void toggleLoadMoreData(value) {
    loadMoreData = value;
    notifyListeners();
  }

  // toggle the isListenerAdded value
  void toggleIsListenerAdded(value) {
    isListenerAdded = value;
    notifyListeners();
  }

  // make count value for analysis to 0
  void initializeCountChatAnalysis() {
    countMessageForAnalysis = 0;
    notifyListeners();
  }

  // make reset count value for analysis to 0
  void initializeCountMessageResetForAnalysisAnalysis() {
    countMessageResetForAnalysis = 0;
    notifyListeners();
  }

  // increase count value for analysis
  void countChatAnalysis() {
    countMessageForAnalysis++;
  }

  // increase reset count value for analysis
  void countMessageResetForAnalysisAnalysis() {
    countMessageResetForAnalysis++;
  }

  // toggle the message send button while the gpt respoonse loading
  void toggleChatResponseLodaing(bool state) {
    isChatResponsLoading = state;

    if (isChatResponsLoading) {
      // 로딩 메시지 추가
      chatlog.add(
        chatModel = ChatMessage(
          message: '!&[loading]&!',
          messenger: Messenger.special,
          messageType: MessageType.chat,
          messageTime: Timestamp.now(),
        ),
      );
    } else {
      chatlog.removeWhere((msg) => msg.message == '!&[loading]&!');
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

  // recommanded system message
  static List<ChatMessage> assistantMessage(BuildContext context) {
    return [
      ChatMessage(
        message: 'ai_chat_assistant_message_1'.tr(context),
        messenger: Messenger.assistant,
        messageType: MessageType.chat,
        messageTime: Timestamp.now(),
      ),
      ChatMessage(
        message: 'ai_chat_assistant_message_2'.tr(context),
        messenger: Messenger.assistant,
        messageType: MessageType.chat,
        messageTime: Timestamp.now(),
      ),
      // TODO: 추후 업데이트 예정
      // ChatMessage(
      //   message: 'ai_chat_assistant_message_3'.tr(context),
      //   messenger: Messenger.assistant,
      //   messageType: MessageType.chat,
      //   messageTime: Timestamp.now(),
      // ),
    ];
  }

  // current chat log that till displayed on screen
  late List<ChatMessage> chatlog = [];

  // current loaded chat log dates
  List<String> chatlogDates = [];

  void chatLogInitialization(BuildContext context) {
    chatlogDates.clear();
    chatlog = ChatMessage.defaultChatLog(context);
  }

  void chatMemorySystemInitialization(BuildContext context) {
    chatMemory.clear();
    chatMemory = [
      OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
              getChatGPTSystemPrompt(context)),
        ],
        role: OpenAIChatMessageRole.system,
      ),
    ];
  }

  // update user chatting
  void updateUserChat() {
    chatModel = ChatMessage(
      message: chatTextController.text.trim(),
      messenger: Messenger.user,
      messageType: MessageType.chat,
      messageTime: Timestamp.now(),
    );
    chatlog.add(chatModel);
  }

  // update ai chatting
  void updateAIChat(String message) {
    chatModel = ChatMessage(
      message: message,
      messenger: Messenger.ai,
      messageType: MessageType.chat,
      messageTime: Timestamp.now(),
    );
    chatlog.add(chatModel);
  }

  // update system chatting
  void updateSystemChat(BuildContext context) {
    chatModel = ChatMessage(
      message: ChatMessage.formatTimestamp(Timestamp.now(), context),
      messenger: Messenger.system,
      messageType: MessageType.chat,
      messageTime: Timestamp.now(),
    );
    chatlog.add(chatModel);
  }

  // when user message has submitted
  void onMessageSubmitted(BuildContext context) {
    if (!sendFirstMessage) {
      sendFirstMessage = true;
    }

    if (ChatMessage.calculateDateDifference(
            (chatlog.last.messageTime), Timestamp.now()) >=
        1) {
      updateSystemChat(context);
    }

    updateUserChat();
    chatTextController.clear();
    scrollChatScreenToBottom();
    countChatAnalysis();
    getAIResponse(context).then((value) {
      scrollChatScreenToBottom();
      saveChatLogToLocal();
    });
    notifyListeners();
  }

  // when assistant message has submitted
  void onAssistantMessageSubmitted(
      String submittedMessage, BuildContext context) {
    chatTextController.text = submittedMessage;
    onMessageSubmitted(context);
  }

  // when diary message has submitted
  void onMyDiarytMessageSubmitted(
      String submittedMessage, BuildContext context) {
    chatTextController.text = submittedMessage;
    onMessageSubmitted(context);
  }

  void resetTheChat(BuildContext context) {
    if (sendFirstMessage && !isChatResponsLoading) {
      sendFirstMessage = false;
      countMessageResetForAnalysisAnalysis();
      chatLogInitialization(context);
      chatMemorySystemInitialization(context);
      deleteChatLogFromLocal();
    }
    notifyListeners();
  }

  // make modle able to remember the past chat log
  List<OpenAIChatCompletionChoiceMessageModel> chatMemory = [];

  // send and get response from chatGPT (chatting model)
  Future<void> getAIResponse(BuildContext context) async {
    toggleChatResponseLodaing(true);
    updateChatMemory(context);

    try {
      // Initializes the package with that API key
      OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;

      // the actual request.
      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
        model: "gpt-4o-mini",
        messages: chatMemory,
        n: 1,
        maxTokens: 350,
        frequencyPenalty: 0.3,
        presencePenalty: 0.0,
        temperature: 0.7,
        topP: 1.0,
      );

      updateAIChat(chatCompletion.choices.first.message.content!.first.text!);
    } on SocketException catch (e) {
      dev.log(e.toString());
      updateAIChat("ai_chat_error_message_1".tr(context));
    } on RequestFailedException catch (e) {
      dev.log(e.toString());
      updateAIChat("ai_chat_error_message_2".tr(context));
    } catch (e) {
      dev.log(e.toString());
      updateAIChat("ai_chat_error_message_3".tr(context));
    } finally {
      toggleChatResponseLodaing(false);
    }
    notifyListeners();
  }

  // AI에게 보낼 대화 내역(Context) 준비
  void updateChatMemory(BuildContext context) {
    chatMemorySystemInitialization(context);

    // 2. [필터링] AI와 관련된 유효한 대화(User, AI)만 골라내기
    final validMessages = chatlog
        .where((msg) =>
            msg.messenger == Messenger.ai || msg.messenger == Messenger.user)
        .toList();

    // 3. [개수 제한] 설정한 한계(limit)만큼 '최근' 대화만 자르기
    final messagesToSend = (validMessages.length > rememberableChatlogLimit)
        ? validMessages.sublist(validMessages.length - rememberableChatlogLimit)
        : validMessages;

    // 4. [변환 및 주입] OpenAI 포맷으로 변환하여 메모리에 추가
    for (var msg in messagesToSend) {
      chatMemory.add(
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              msg.message,
            ),
          ],
          role: (msg.messenger == Messenger.user)
              ? OpenAIChatMessageRole.user
              : OpenAIChatMessageRole.assistant,
        ),
      );
    }

    // dev.log('Updated chat memory with ${messagesToSend.length} messages.');
  }

  // 로컬 저장소에서 최신 채팅 로그 불러오기 (초기 로딩용)
  Future<void> getChatLogFromLocal() async {
    // 1. 유저 ID 체크
    if (userId == null || userId!.isEmpty) {
      dev.log('there is no firebase uid');
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // 2. 실제 파일 기반으로 날짜 키 리스트 재구축 (Self-healing)
      // 저장소에 있는 모든 채팅 로그 키를 스캔하여 가져옵니다.
      Set<String> allKeys = prefs.getKeys();
      String prefix = '${userId}_chatLog_';

      // 필터링 및 날짜순 정렬 (과거 -> 최신)
      List<String> validKeys =
          allKeys.where((key) => key.startsWith(prefix)).toList();
      validKeys.sort();

      // 전역 변수 chatlogDates를 실제 데이터와 동기화
      chatlogDates = List.from(validKeys);

      if (chatlogDates.isEmpty) {
        dev.log('there is no chat data');
        notifyListeners();
        return;
      }

      // 3. 로딩할 최신 데이터 범위 계산
      // 전체 날짜 중 가장 최근 n일치(maxChatlogDatesToLoad)만 가져옵니다.
      int totalDates = chatlogDates.length;
      int startIndex = 0;
      if (totalDates > maxChatlogDatesToLoad) {
        startIndex = totalDates - maxChatlogDatesToLoad;
      }

      // 이번에 로딩할 키 리스트 (최신 데이터들)
      List<String> keysToLoad = chatlogDates.sublist(startIndex);

      // 4. 데이터 파싱 및 메모리 로드
      chatlog.clear(); // 기존 메모리 초기화

      for (String key in keysToLoad) {
        List<String>? jsonList = prefs.getStringList(key);

        if (jsonList != null) {
          List<ChatMessage> messages = jsonList
              .map((j) => ChatMessage.fromJsonLocal(jsonDecode(j)))
              .toList();

          chatlog.addAll(messages);
          sendFirstMessage = true;

          dev.log(
              'read chat log from local for date ${key.split('_').skip(1).join('_')}');
        }
      }

      dev.log(
          'Initial chat logs loaded: ${chatlog.length} messages from ${keysToLoad.length} days.');
    } catch (e) {
      dev.log('Error loading initial chat logs: $e');
    } finally {
      notifyListeners();
    }
  }

// 과거 채팅 로그 더 불러오기 (Pagination)
  Future<bool> loadOlderChatLogs() async {
    // 1. 유저 ID 체크
    if (userId == null || userId!.isEmpty) {
      dev.log('there is no firebase uid');
      return false;
    }

    // [Guard 1] 이미 로딩 중이라면 요청 무시 (중복 호출 방지)
    if (_isLoadingOlderChat) {
      dev.log('이미 로딩 중입니다. 요청을 무시합니다.');
      return false;
    }

    // [Guard 2] 불러올 전체 날짜 리스트가 비어있거나, 현재 로딩된 채팅이 없으면 종료
    if (chatlogDates.isEmpty || chatlog.isEmpty) {
      dev.log('더 이상 불러올 과거 채팅 기록이 없습니다 (데이터 없음).');
      return false;
    }

    // [Lock] 로딩 시작 -> 잠금 걸기
    _isLoadingOlderChat = true;
    notifyListeners();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // chatlog는 시간순(과거->최신) 정렬이므로 0번 인덱스가 가장 오래된 메시지입니다.
      DateTime oldestMsgDate = chatlog.first.messageTime.toDate().toLocal();
      String dateKey = oldestMsgDate.toIso8601String().substring(0, 10);
      String currentKey = '${userId}_chatLog_$dateKey';

      // 전체 날짜 리스트(chatlogDates)에서 현재 키의 위치(Index)를 찾음
      // chatlogDates는 오름차순(과거 -> 최신)으로 정렬되어 있다고 가정 (getChatLogFromLocal에서 정렬함)
      int currentIndex = chatlogDates.indexOf(currentKey);

      // 만약 currentIndex를 못 찾았다면(예: 오늘 작성한 채팅이라 파일 저장이 안 된 경우),
      // chatlogDates의 가장 마지막(최신)부터 탐색하도록 설정
      if (currentIndex == -1) {
        currentIndex = chatlogDates.length;
      }

      // currentIndex가 0이면 이미 가장 과거 데이터(리스트의 처음)까지 다 본 상태
      if (currentIndex <= 0) {
        dev.log('Reached the beginning of chat logs (No more history).');
        return false;
      }

      // 한 번에 maxChatlogDatesToLoad(예: 3일치)만큼 불러옴
      int endIndex = currentIndex;
      int startIndex = (endIndex - maxChatlogDatesToLoad) > 0
          ? (endIndex - maxChatlogDatesToLoad)
          : 0;

      // 불러올 키 리스트 추출 (startIndex 부터 endIndex 직전까지)
      List<String> keysToLoad = chatlogDates.sublist(startIndex, endIndex);
      List<ChatMessage> olderMessages = [];

      for (String key in keysToLoad) {
        List<String>? jsonList = prefs.getStringList(key);
        if (jsonList != null) {
          List<ChatMessage> dailyMessages = jsonList
              .map((j) => ChatMessage.fromJsonLocal(jsonDecode(j)))
              .toList();

          // olderMessages에 순서대로 쌓음
          // keysToLoad가 [1일, 2일, 3일] 순서이므로 메시지도 [1일치, 2일치, 3일치] 순으로 쌓임
          olderMessages.addAll(dailyMessages);

          dev.log('Read older chat log: ${key.split('_').skip(1).join('_')}');
        }
      }

      if (olderMessages.isNotEmpty) {
        // 기존 채팅 로그의 맨 앞(과거)에 통째로 삽입
        chatlog.insertAll(0, olderMessages);

        dev.log(
            'Loaded ${olderMessages.length} older messages from ${keysToLoad.length} days.');
        return true;
      }

      return false;
    } catch (e) {
      dev.log('Error loading older chat logs: $e');
      return false;
    } finally {
      // [Unlock] 잠금 해제
      _isLoadingOlderChat = false;
      notifyListeners();
    }
  }

  // 채팅 로그를 날짜별로 그룹화하여 로컬에 저장
  void saveChatLogToLocal() async {
    if (userId == null || userId!.isEmpty) {
      dev.log('there is no firebase uid');
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // 1. 메모리에 있는 전체 채팅 로그를 '날짜별(yyyy-MM-dd)'로 그룹화
      // Map<날짜키, List<메시지>>
      Map<String, List<ChatMessage>> groupedMessages = {};

      for (var message in chatlog) {
        // 메시지의 실제 시간(Local)을 기준으로 날짜 키 생성
        // 예: 2024-09-09
        DateTime date = message.messageTime.toDate().toLocal();
        String dateKey = date.toIso8601String().substring(0, 10);
        String fullKey = '${userId}_chatLog_$dateKey';

        if (!groupedMessages.containsKey(fullKey)) {
          groupedMessages[fullKey] = [];
        }
        groupedMessages[fullKey]!.add(message);
      }

      // 2. 그룹화된 데이터를 각각 저장
      for (var entry in groupedMessages.entries) {
        String key = entry.key;
        List<ChatMessage> messagesOfDay = entry.value;

        // JSON 직렬화
        List<String> jsonMessages = messagesOfDay
            .map((message) => jsonEncode(message.toJson()))
            .toList();

        await prefs.setStringList(key, jsonMessages);

        // 3. 날짜 리스트(chatlogDates) 관리
        // 새로운 날짜가 생겼다면 리스트에 추가하고 정렬
        if (!chatlogDates.contains(key)) {
          chatlogDates.add(key);
          // 날짜순 정렬 (최신 날짜가 뒤로 오거나 앞으로 오도록 정책에 맞게 정렬)
          chatlogDates.sort();
        }
      }

      dev.log('Saved chat logs grouped by dates.');
    } catch (e) {
      dev.log('Error saving chat log: $e');
    }
  }

  // 로컬 저장소 및 메모리에서 채팅 로그 삭제
  void deleteChatLogFromLocal() async {
    if (userId == null || userId!.isEmpty) {
      dev.log('there is no firebase uid');
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // 해당 유저의 채팅 로그 키 찾기
      Set<String> keys = prefs.getKeys();
      String prefix = '${userId}_chatLog_';

      List<String> targetKeys =
          keys.where((key) => key.startsWith(prefix)).toList();

      // 로컬 파일 삭제
      for (String key in targetKeys) {
        await prefs.remove(key);
      }

      dev.log('Deleted all chat logs from local and memory.');
    } catch (e) {
      dev.log('Error deleting chat log: $e');
    }
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
