import 'dart:io';

import 'package:bandi_official/model/diary.dart';
import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as dev;

import 'package:intl/intl.dart';

class DiaryAIAnalysisController with ChangeNotifier {
  late Diary userDairyModel;

  //  TODO: diary controller로 향후 전환 필요?
  updateUserDiaryContent(String content) {
    userDairyModel.content = content.trim();
    notifyListeners();
  }

  updateUserDiaryTitle(String title) {
    userDairyModel.title = title.trim();
    notifyListeners();
  }

  updateUserDiaryKeyword(List<String> keyword) {
    userDairyModel.keyword = keyword;
    notifyListeners();
  }

  updateUserDiaryDate(String date) {
    userDairyModel.date = date;
    notifyListeners();
  }

  //  analyze diary emotion keywords
  void analyzeDiaryKeyword() async {
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
            userDairyModel.content,
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
        model: "ft:gpt-3.5-turbo-0125:personal:second-fine-tuned:9k5K0x2W",
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

      //  TODO: keyword update 함수 호출
      dev.log(keywordCompletion.choices.first.message.content!.first.text!);
    } on SocketException catch (e) {
      dev.log(e.toString());
    } on RequestFailedException catch (e) {
      dev.log(e.toString());
      // TODO: keyword update > 비워서 호출
    }
  }

  //  analyze diary title
  void analyzeDiaryTitle() async {
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
            userDairyModel.content,
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
        model: "ft:gpt-3.5-turbo-0125:personal:title-summary-01:9l7qOBbh",
        messages: requestMessages,
        // 답변할 종류의 수
        n: 1,
        // 답변에 사용할 최대 토큰의 크기
        maxTokens: 25,
        // 같은 답변 반복 (0.1~1.0일 수록 감소)
        frequencyPenalty: 0.5,
        // 새로운 주제 제시 (>0 수록 새로운 주제 확률 상승)
        presencePenalty: -0.5,
        // 답변의 일관성 (낮을 수록 집중됨)
        temperature: 0.8,
      );

      //  TODO: title update 함수 호출
      dev.log(titleCompletion.choices.first.message.content!.first.text!);
    } on SocketException catch (e) {
      dev.log(e.toString());
    } on RequestFailedException catch (e) {
      dev.log(e.toString());
      String tempDiaryTitle =
          "${DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()}의 일기";
      updateUserDiaryTitle(tempDiaryTitle);
    }
  }

  //  analyze diary encouragement
  void analyzeDiaryEncouragement() async {
    try {
      // Initializes the package with that API key
      OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;

      // the system message that will be sent to the request.
      final systemMessageForKeyword = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "Given a diary entry, provide encouragement based on its content in Korean.",
          ),
        ],
        role: OpenAIChatMessageRole.system,
      );

      final userMessageForKeyword = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            userDairyModel.content,
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
        model: "gpt-3.5-turbo",
        messages: requestMessages,
        // 답변할 종류의 수
        n: 1,
        // 답변에 사용할 최대 토큰의 크기
        maxTokens: 50,
        // 같은 답변 반복 (0.1~1.0일 수록 감소)
        frequencyPenalty: 0.1,
        // 새로운 주제 제시 (>0 수록 새로운 주제 확률 상승)
        presencePenalty: 0.5,
        // 답변의 일관성 (낮을 수록 집중됨)
        temperature: 0.5,
      );

      dev.log(
          encouragementCompletion.choices.first.message.content!.first.text!);
    } on SocketException catch (e) {
      dev.log(e.toString());
    } on RequestFailedException catch (e) {
      dev.log(e.toString());
      // TODO: 임시 문구 or 예외 처리 방법 고안
    }
  }
}
