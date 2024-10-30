import 'dart:convert';
import 'dart:io';

import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/model/keyword.dart';
import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as dev;

import 'package:intl/intl.dart';

class DiaryAIAnalysisController with ChangeNotifier {
  //  analyze diary emotion keywords
  Future<void> analyzeDiaryKeyword(Diary diaryModel) async {
    try {
      // Initializes the package with that API key
      OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;

      // the system message that will be sent to the request.
      final systemMessageForKeyword = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "Given a diary entry, analyze the text and provide the following fields in a JSON dict: \"emotions\" (comma-separated list of emotion words).",
          ),
        ],
        role: OpenAIChatMessageRole.system,
      );

      final userMessageForKeyword = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            diaryModel.content,
          ),
        ],
        role: OpenAIChatMessageRole.user,
      );

      // all messages to be sent.
      final requestMessages = [
        systemMessageForKeyword,
        userMessageForKeyword,
      ];

      // the actual request.
      OpenAIChatCompletionModel keywordCompletion =
          await OpenAI.instance.chat.create(
        model:
            "ft:gpt-4o-mini-2024-07-18:personal:emotion-analysis-model002:9zJC7AS6",
        messages: requestMessages,
        // 답변할 종류의 수
        n: 1,
        // 답변에 사용할 최대 토큰의 크기
        maxTokens: 75,
        // 같은 답변 반복 (0.1~1.0일 수록 감소)
        frequencyPenalty: 0.5,
        // 새로운 주제 제시 (>0 수록 새로운 주제 확률 상승)
        presencePenalty: -0.5,
        // 답변의 일관성 (낮을 수록 집중됨)
        temperature: 0.8,
      );

      dev.log(keywordCompletion.choices.first.message.content!.first.text!);
      diaryModel.emotion = extractKeywords(
          keywordCompletion.choices.first.message.content!.first.text!);
    } on SocketException catch (e) {
      dev.log(e.toString());
    } on RequestFailedException catch (e) {
      dev.log(e.toString());
      diaryModel.emotion = [''];
    }
    notifyListeners();
  }

  //  analyze diary title
  Future<void> analyzeDiaryTitle(Diary diaryModel) async {
    try {
      // Initializes the package with that API key
      OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;

      // the system message that will be sent to the request.
      final systemMessageForKeyword = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "Given a diary entry, analyze the text and summarize it with a title.",
          ),
        ],
        role: OpenAIChatMessageRole.system,
      );

      final userMessageForKeyword = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            diaryModel.content,
          ),
        ],
        role: OpenAIChatMessageRole.user,
      );

      // all messages to be sent.
      final requestMessages = [
        systemMessageForKeyword,
        userMessageForKeyword,
      ];

      // the actual request.
      OpenAIChatCompletionModel titleCompletion =
          await OpenAI.instance.chat.create(
        model:
            "ft:gpt-4o-mini-2024-07-18:personal:title-summary-model001:9zJ0yNAC",
        messages: requestMessages,
        // 답변할 종류의 수
        n: 1,
        // 답변에 사용할 최대 토큰의 크기
        maxTokens: 15,
        // 같은 답변 반복 (0.1~1.0일 수록 감소)
        frequencyPenalty: 0.5,
        // 새로운 주제 제시 (>0 수록 새로운 주제 확률 상승)
        presencePenalty: -0.5,
        // 답변의 일관성 (낮을 수록 집중됨)
        temperature: 0.8,
      );

      dev.log(titleCompletion.choices.first.message.content!.first.text!);
      diaryModel.title =
          titleCompletion.choices.first.message.content!.first.text!;
    } on SocketException catch (e) {
      dev.log(e.toString());
    } on RequestFailedException catch (e) {
      dev.log(e.toString());
      String tempDiaryTitle =
          "${DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()}의 일기";
      diaryModel.title = tempDiaryTitle;
    }
    notifyListeners();
  }

  //  analyze diary encouragement
  Future<void> analyzeDiaryEncouragement(Diary diaryModel) async {
    try {
      // Initializes the package with that API key
      OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;

      // the system message that will be sent to the request.
      final systemMessageForKeyword = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "Please limit your response to a single complete sentence(within 50 token) and provide encouragement in Korean based on the content of the diary entry.",
          ),
        ],
        role: OpenAIChatMessageRole.system,
      );

      final userMessageForKeyword = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            diaryModel.content,
          ),
        ],
        role: OpenAIChatMessageRole.user,
      );

      // all messages to be sent.
      final requestMessages = [
        systemMessageForKeyword,
        userMessageForKeyword,
      ];

      // the actual request.
      OpenAIChatCompletionModel encouragementCompletion =
          await OpenAI.instance.chat.create(
        model: "gpt-4o-mini",
        messages: requestMessages,
        // 답변할 종류의 수
        n: 1,
        // 답변에 사용할 최대 토큰의 크기
        maxTokens: 60,
        // 같은 답변 반복 (0.1~1.0일 수록 감소)
        frequencyPenalty: 0.1,
        // 새로운 주제 제시 (>0 수록 새로운 주제 확률 상승)
        presencePenalty: 0.5,
        // 답변의 일관성 (낮을 수록 집중됨)
        temperature: 0.5,
      );

      dev.log(
          encouragementCompletion.choices.first.message.content!.first.text!);
      diaryModel.cheerText =
          encouragementCompletion.choices.first.message.content!.first.text!;
    } on SocketException catch (e) {
      dev.log(e.toString());
    } on RequestFailedException catch (e) {
      dev.log(e.toString());
      // 비어있을 경우 화면에 보이지 않음
      diaryModel.cheerText = "";
    }
    notifyListeners();
  }

  List<String> extractKeywords(String jsonString) {
    // JSON 문자열을 Map으로 변환
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    // 'emotions' 필드 값을 가져와서 문자열로 저장
    String emotionsString = jsonMap['emotions'];

    // 문자열을 ','로 분리하고, 공백을 제거하여 리스트로 변환
    List<String> emotionsList =
        emotionsString.split(',').map((e) => e.trim()).toList();

    final Set<String> allEmotionsSet =
        Keyword().emotionMap.values.expand((list) => list).toSet();
    final List<String> commonEmotions = emotionsList
        .where((emotion) => allEmotionsSet.contains(emotion))
        .toList();

    return commonEmotions;
  }
}
