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

  /// ✅ 비동기로 변경
  Future<void> initialize(BuildContext context) async {
    // 실제 비동기 작업이 없더라도 Future로 감싸줌
    await Future.delayed(Duration.zero);

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

  void toggleEmotion(String emotion) {
    if (_selectedEmotions.contains(emotion)) {
      _selectedEmotions.remove(emotion);
    } else {
      _selectedEmotions.add(emotion);
    }
    notifyListeners();
  }
}
