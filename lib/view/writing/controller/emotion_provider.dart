import 'package:bandi_official/model/keyword.dart';
import 'package:bandi_official/localization/string_extention.dart';
import 'package:flutter/material.dart';

class EmotionProvider with ChangeNotifier {
  // (구 탭 UI용) 선택된 감정 카테고리
  late String _selectedEmotion;

  // (구 탭 UI용) 현재 탭의 옵션들
  List<String> _emotionOptions = [];

  // ✅ 선택된 키워드(칩)
  final List<String> _selectedEmotions = [];

  bool _initialized = false;
  bool get isInitialized => _initialized;

  // ✅ 섹션(감정 카테고리) -> 키워드 리스트
  late Map<String, List<String>> _emotionChipOptions;

  // ---- getters ----
  String get selectedEmotion => _selectedEmotion;

  /// (탭 UI 호환용) 현재 선택 탭의 옵션
  List<String> get emotionOptions => _emotionOptions;

  /// ✅ 선택된 키워드 리스트
  List<String> get selectedEmotions => _selectedEmotions;

  /// ✅ 섹션 타이틀 리스트 (예: ["기쁨", "두려움", ...] 번역된 문자열)
  List<String> get emotionKeys => _emotionChipOptions.keys.toList();

  /// ✅ (새 UI용) 섹션별 키워드 Map 제공
  Map<String, List<String>> get optionsByEmotion => _emotionChipOptions;

  /// 키워드 갱신 여부 변수
  bool isLoading = false;

  /// ✅ 초기화
  Future<void> initialize(BuildContext context) async {
    // 실제 비동기 작업이 없더라도 Future로 감싸 줌
    await Future.delayed(Duration.zero);

    // 기본 탭(호환용)
    _selectedEmotion = 'emotion_category_happiness'.tr(context);

    // 섹션별 키워드 데이터 생성 (하드코딩 X: Keyword에서 가져옴)
    _emotionChipOptions = Keyword().getEmotionChipOptions(context);

    // 기본 탭 옵션 (호환용)
    _emotionOptions = _emotionChipOptions[_selectedEmotion] ?? [];

    _initialized = true;
    notifyListeners();
  }

  /// isLaoding toggle
  void toggleIsLoading(value) {
    isLoading = value;
    notifyListeners();
  }

  // ---------------------------
  // (구 탭 UI 호환용)
  // ---------------------------
  void selectEmotion(String emotionCategoryTitle) {
    _selectedEmotion = emotionCategoryTitle;
    _emotionOptions = _emotionChipOptions[emotionCategoryTitle] ?? [];
    notifyListeners();
  }

  // ---------------------------
  // ✅ 새 UI(섹션 나열형)용
  // ---------------------------

  /// ✅ 시트 열릴 때: 기존 선택 키워드들을 반영
  /// - 중복 제거
  /// - 빈 값 제거
  void setInitialSelected(List<dynamic> initialSelected) {
    _selectedEmotions
      ..clear()
      ..addAll(
        initialSelected
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty),
      );

    // 중복 제거(순서 유지)
    final seen = <String>{};
    _selectedEmotions.retainWhere((e) => seen.add(e));

    notifyListeners();
  }

  void addEmotion(String keyword) {
    if (_selectedEmotions.contains(keyword)) return;
    _selectedEmotions.add(keyword);
    notifyListeners();
  }

  void removeEmotion(String keyword) {
    _selectedEmotions.remove(keyword);
    notifyListeners();
  }

  /// ✅ 선택 토글 (수정됨)
  void toggleEmotion(String keyword, BuildContext context) {
    const String noneKeyword = '없음';
    const String unknownKeyword = '모름';

    if (_selectedEmotions.contains(keyword)) {
      _selectedEmotions.remove(keyword);
    } else {
      if (keyword == noneKeyword || keyword == unknownKeyword) {
        _selectedEmotions.clear();
        _selectedEmotions.add(keyword);
      } else {
        if (_selectedEmotions.contains(noneKeyword)) {
          _selectedEmotions.remove(noneKeyword);
        }
        if (_selectedEmotions.contains(unknownKeyword)) {
          _selectedEmotions.remove(unknownKeyword);
        }

        _selectedEmotions.add(keyword);
      }
    }
    notifyListeners();
  }

  /// ✅ 새로고침 버튼: 전체 초기화
  void resetSelected(BuildContext context) {
    _selectedEmotions.clear();
    _selectedEmotions.add('없음');
    notifyListeners();
  }

  // 감정 키워드 수정 여부 확인
  bool listEquals(List list1, List list2) {
    if (list1.length != list2.length) return false;
    return Set.from(list1).containsAll(list2) &&
        Set.from(list2).containsAll(list1);
  }
}
