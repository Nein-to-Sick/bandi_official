import 'package:bandi_official/model/keyword.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:flutter/material.dart';

class EmotionProvider with ChangeNotifier {
  late String _selectedEmotion;
  List<String> _emotionOptions = [];
  final List<String> _selectedEmotions = [];
  bool _initialized = false;
  bool get isInitialized => _initialized;


  late Map<String, List<String>> _emotionChipOptions;

  String get selectedEmotion => _selectedEmotion;
  List<String> get emotionOptions => _emotionOptions;
  List<String> get selectedEmotions => _selectedEmotions;
  List<String> get emotionKeys => _emotionChipOptions.keys.toList();

  void initialize(BuildContext context) {
    _selectedEmotion = 'emotion_category_happiness'.tr(context);

    _emotionChipOptions = Keyword().getEmotionChipOptions(context);
    _emotionOptions = _emotionChipOptions[_selectedEmotion] ?? [];
    _initialized = true;
    notifyListeners();
  }


  void selectEmotion(String emotion) {
    _selectedEmotion = emotion;
    _emotionOptions = _emotionChipOptions[emotion] ?? [];
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
