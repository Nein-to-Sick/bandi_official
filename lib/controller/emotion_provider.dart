import 'package:flutter/material.dart';

class EmotionProvider with ChangeNotifier {
  String _selectedEmotion = "기쁨";
  List<String> _emotionOptions = [];
  List<String> _selectedEmotions = [];

  final Map<String, List<String>> _emotionChipOptions = {
    "기쁨": ["감동적이다", "감탄하다", "고맙다", "괜찮다", "궁금하다", "기쁘다", "다행스럽다", "든든하다", "만족스럽다", "반갑다", "뿌듯하다", "사랑스럽다", "상쾌하다", "설레다", "신기하다", "신나다", "여유롭다", "열정적이다", "유쾌하다", "자랑스럽다", "자신있다", "좋다", "통쾌하다", "편안하다", "행복하다", "홀가분하다", "활기차다", "훈훈하다", "흠뻑취하다"],
    "두려움": ["불안", "공포", "긴장"],
    "분노": ["화남", "짜증", "불쾌"],
    "불쾌": ["싫음", "불쾌", "혐오"],
    "슬픔": ["우울", "비통", "슬픔"],
    "모름": ["알수없음"]
  };

  String get selectedEmotion => _selectedEmotion;
  List<String> get emotionOptions => _emotionOptions;
  List<String> get selectedEmotions => _selectedEmotions;
  List<String> get emotionKeys => _emotionChipOptions.keys.toList(); // Public getter for keys

  EmotionProvider() {
    _emotionOptions = _emotionChipOptions[_selectedEmotion] ?? [];
  }

  void selectEmotion(String emotion) {
    _selectedEmotion = emotion;
    _emotionOptions = _emotionChipOptions[emotion] ?? [];
    _selectedEmotions.clear();
    notifyListeners();
  }

  void addEmotion(String emotion) {
    _selectedEmotions.add(emotion);
    notifyListeners();
  }

  void removeEmotion(String emotion) {
    _selectedEmotions.remove(emotion);
    notifyListeners();
  }
}
