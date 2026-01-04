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
  // 생성자에서 API Key를 한 번만 초기화합니다.
  DiaryAIAnalysisController() {
    OpenAI.apiKey = dotenv.env['OPENAI_API_KEY']!;
  }

  // 모든 분석을 병렬로 동시에 실행하여 대기 시간을 단축합니다.
  Future<void> analyzeAll(Diary diaryModel, String langCode) async {
    await Future.wait([
      analyzeDiaryKeyword(diaryModel),
      analyzeDiaryTitle(diaryModel, langCode),
      analyzeDiaryEncouragement(diaryModel, langCode),
    ]);
    notifyListeners();
  }

  // 1. Analyze Diary Keyword (개선됨)
  Future<void> analyzeDiaryKeyword(Diary diaryModel) async {
    // 1. Keyword 클래스에서 감정 단어 리스트를 문자열로 변환
    final keywordString = _generateKeywordListString();

    // 2. 개선된 시스템 프롬프트
    // - 역할 부여: 감정 분석가
    // - 제약 사항: 제공된 리스트 내에서만 선택
    // - 출력 형식: JSON
    final systemContent = """
You are an expert sentiment analyst. Analyze the user's diary entry and identify the emotions felt by the user.

[Constraint]
1. Select 1 to 3 emotion keywords that best match the diary content.
2. You MUST select keywords ONLY from the [Emotion Keyword List] provided below. Do not create new words.
3. Output format must be a valid JSON object with a single key "emotions" containing a comma-separated string of selected keywords.

[Emotion Keyword List]
$keywordString

Example Output:
{"emotions": "뿌듯하다, 행복하다"}
""";

    // 3. 요청 수행
    final responseText = await _performOpenAIRequest(
      model: "gpt-4o-mini",
      systemContent: systemContent,
      userContent: diaryModel.content,
      maxTokens: 100,
      frequencyPenalty: 0.0, // 정확한 단어 선택을 위해 페널티 제거
      presencePenalty: 0.0,
      temperature: 0.2, // 창의성 억제 -> 분류 정확도 향상
    );

    if (responseText != null) {
      diaryModel.emotion = extractKeywords(responseText);
    } else {
      diaryModel.emotion = ['없음'];
    }
    notifyListeners();
  }

  // Keyword 클래스의 Map 데이터를 프롬프트용 문자열로 변환
  String _generateKeywordListString() {
    final emotionMap = Keyword().emotionMap;
    StringBuffer buffer = StringBuffer();

    emotionMap.forEach((emotion, keywords) {
      // 예: Happiness: 감동적이다, 기쁘다, ...
      // Enum 이름에서 'Emotion.' 제거하고 대문자로 변환하거나 그대로 사용
      String category = emotion.toString().split('.').last.toUpperCase();
      buffer.writeln("- $category: ${keywords.join(', ')}");
    });

    return buffer.toString();
  }

// 2. Analyze Diary Title (개선됨)
  Future<void> analyzeDiaryTitle(Diary diaryModel, String langCode) async {
    final isKorean = langCode == 'ko';

    // [프롬프트 개선]
    // 1. 역할: 감성적인 제목 작가
    // 2. 제약: 길이 제한, 특수문자(따옴표) 제거, 불필요한 서식 금지
    final systemContent = isKorean
        ? """
너는 사용자의 하루를 함축하는 감성적인 일기 제목 작가야. 일기 내용을 읽고 다음 조건에 맞춰 제목을 지어줘.

[조건]
1. 내용을 관통하는 핵심 키워드나 감정을 포함할 것.
2. 20자 이내의 간결한 문장이나 단어 조합으로 작성할 것.
3. 따옴표(" "), 마침표(.), '제목:' 같은 불필요한 기호를 절대 포함하지 말 것.
4. 한국어로 작성할 것.
"""
        : """
You are an empathetic diary title creator. Read the diary entry and create a title based on the following constraints.

[Constraints]
1. Capture the core emotion or event of the day.
2. Keep it concise (under 10 words).
3. Do NOT use quotation marks (" "), periods (.), or prefixes like 'Title:'.
4. Write in English.
""";

    final responseText = await _performOpenAIRequest(
      model: "gpt-4o-mini", // 파인 튜닝 모델 대신 기본 모델 사용 (충분함)
      systemContent: systemContent,
      userContent: diaryModel.content,
      maxTokens: 30, // 15는 너무 짧을 수 있어 30으로 늘림 (비용 차이 미미함)
      frequencyPenalty: 0.0, // 요약 과제이므로 0.0 권장
      presencePenalty: 0.0, // -0.5는 반복을 유도할 수 있어 제거
      temperature: 0.7, // 적당한 창의성을 위해 유지
    );

    if (responseText != null) {
      // 혹시 모를 따옴표나 공백 한 번 더 제거 (안전장치)
      diaryModel.title =
          responseText.replaceAll('"', '').replaceAll("'", "").trim();
    } else {
      // 실패 시 로컬 기본값 설정 (날짜 기반)
      String tempDiaryTitle = (isKorean)
          ? "${DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()}의 일기"
          : "Diary of ${DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()}";

      diaryModel.title = tempDiaryTitle;
    }
    notifyListeners();
  }

// 3. Analyze Diary Encouragement (개선됨)
  Future<void> analyzeDiaryEncouragement(
      Diary diaryModel, String langCode) async {
    final isKorean = langCode == 'ko';

    // [프롬프트 개선]
    // 1. 역할: 따뜻한 심리 상담가 '반디'
    // 2. 어조: 해요체 (한국어), Warm & Supportive (영어)
    // 3. 내용: 일기의 구체적 상황 반영, 따옴표 금지
    final systemContent = isKorean
        ? """
너는 사용자의 마음을 어루만져주는 따뜻한 심리 상담가 AI '반디'야. 일기 내용을 바탕으로 다음 조건에 맞춰 격려의 말을 건네줘.

[조건]
1. 일기에 담긴 구체적인 감정이나 사건을 언급하며 공감해줄 것.
2. 말투는 부드럽고 다정한 '해요체'(~해요, ~네요)를 사용할 것.
3. 50자 이내의 짧은 한 문장으로 작성할 것.
4. 따옴표(" ")나 '격려:', '반디:' 같은 불필요한 수식어를 붙이지 말 것.
5. 한국어로 작성할 것.
"""
        : """
You are 'Bandi', a warm and empathetic psychological counselor. Read the diary entry and offer words of encouragement based on the following constraints.

[Constraints]
1. Specifically acknowledge the emotion or event in the diary to show empathy.
2. Maintain a warm, supportive, and gentle tone.
3. Write exactly one concise sentence (under 20 words).
4. Do NOT use quotation marks (" ") or prefixes.
5. Write in English.
""";

    final responseText = await _performOpenAIRequest(
      model: "gpt-4o-mini",
      systemContent: systemContent,
      userContent: diaryModel.content,
      maxTokens: 100, // 문장이 잘리지 않도록 여유 있게 설정 (비용 영향 미미함)
      frequencyPenalty: 0.1, // 약간의 페널티로 상투적인 표현 반복 방지
      presencePenalty: 0.0,
      temperature: 0.7, // 감성적인 위로를 위해 창의성 수치를 약간 높임
    );

    if (responseText != null) {
      // 따옴표나 불필요한 공백 제거
      diaryModel.cheerText =
          responseText.replaceAll('"', '').replaceAll("'", "").trim();
    } else {
      // [UX 개선] API 실패 시 빈 값보다는 기본 위로 문구 제공
      diaryModel.cheerText = isKorean
          ? "오늘 하루도 정말 수고 많았어요. 당신은 충분히 잘하고 있어요."
          : "You did great today. I'm always cheering for you.";
    }
    notifyListeners();
  }

  // 중복 코드를 제거하기 위한 공통 요청 처리 메서드
  Future<String?> _performOpenAIRequest({
    required String model,
    required String systemContent,
    required String userContent,
    required int maxTokens,
    double frequencyPenalty = 0.0,
    double presencePenalty = 0.0,
    double temperature = 0.7,
  }) async {
    try {
      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(systemContent),
        ],
        role: OpenAIChatMessageRole.system,
      );

      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(userContent),
        ],
        role: OpenAIChatMessageRole.user,
      );

      OpenAIChatCompletionModel completion = await OpenAI.instance.chat.create(
        model: model,
        messages: [systemMessage, userMessage],
        n: 1,
        maxTokens: maxTokens,
        frequencyPenalty: frequencyPenalty,
        presencePenalty: presencePenalty,
        temperature: temperature,
      );

      final resultText = completion.choices.first.message.content!.first.text;
      dev.log("Model: $model / Result: $resultText");
      return resultText;
    } on SocketException catch (e) {
      dev.log("SocketException: ${e.toString()}");
      return null;
    } on RequestFailedException catch (e) {
      dev.log("RequestFailedException: ${e.toString()}");
      return null;
    } catch (e) {
      dev.log("Unknown Error: ${e.toString()}");
      return null;
    }
  }

  List<String> extractKeywords(String jsonString) {
    try {
      // [Improvement] LLM이 가끔 ```json ... ``` 형태의 마크다운을 포함할 때를 대비
      String cleanJson =
          jsonString.replaceAll(RegExp(r'^```json|```$'), '').trim();

      // JSON 문자열을 Map으로 변환
      Map<String, dynamic> jsonMap = jsonDecode(cleanJson);

      // 'emotions' 필드 값을 가져와서 문자열로 저장
      String emotionsString = jsonMap['emotions'] ?? "";

      // 문자열을 ','로 분리하고, 공백을 제거하여 리스트로 변환
      List<String> emotionsList =
          emotionsString.split(',').map((e) => e.trim()).toList();

      final Set<String> allEmotionsSet =
          Keyword().emotionMap.values.expand((list) => list).toSet();

      final List<String> commonEmotions = emotionsList
          .where((emotion) => allEmotionsSet.contains(emotion))
          .toList();

      return commonEmotions;
    } catch (e) {
      dev.log("JSON Parsing Error: $e");
      return ['없음']; // 파싱 실패 시 빈 리스트 반환
    }
  }
}
