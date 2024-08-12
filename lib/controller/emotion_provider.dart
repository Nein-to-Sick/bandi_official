import 'package:bandi_official/model/keyword.dart';
import 'package:flutter/material.dart';

class EmotionProvider with ChangeNotifier {
  String _selectedEmotion = "기쁨";
  List<String> _emotionOptions = [];
  final List<String> _selectedEmotions = [];

  final _emotionChipOptions = Keyword().getEmotionChipOptions();

  String get selectedEmotion => _selectedEmotion;
  List<String> get emotionOptions => _emotionOptions;
  List<String> get selectedEmotions => _selectedEmotions;
  List<String> get emotionKeys =>
      _emotionChipOptions.keys.toList(); // Public getter for keys

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
