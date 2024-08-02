import 'package:flutter/material.dart';

class EmotionProvider with ChangeNotifier {
  String _selectedEmotion = "기쁨";
  List<String> _emotionOptions = [];
  List<String> _selectedEmotions = [];

  final Map<String, List<String>> _emotionChipOptions = {
    "기쁨": ["행복", "만족", "즐거움"],
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
