import 'dart:developer' as developer;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeToWrite with ChangeNotifier {
  //--------------step 1--------------------------------------------------------

  bool _write = false;
  int step = 1;

  bool get write => _write;

  void toggleWrite() {
    _write = !_write;
    notifyListeners();
  }

  void nextWrite(int next) {
    step = next;
    notifyListeners();
  }

  //--------------step 2--------------------------------------------------------

  String title = "";
  List emotion = [];
  String content = "";
  String cheerText = "";
  void initialize() {
    title = "";
    emotion = [];
    content = "";
    cheerText = "";
    step = 1;
    notifyListeners();
  }

  Future<void> aiAndSaveDairy(String content) async {
    // TODO: content를 넣고 title과 emotion을 chatCPT로 추출
    aiDiary(content);

    await saveDiary(title, content, emotion);

    randomCheerText();
  }

  void aiDiary(String content) {
    // TODO: title, content, emotion update 해줘요~
    title = "커피 한 잔이 가져다 준 작은 행복";
    emotion.add("기쁘다");
    emotion.add("열정적이다");
    this.content = content;
    notifyListeners();
  }

  Future<void> saveDiary(String title, String content, List emotion) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final userId = "21jPhIHrf7iBwVAh92ZW"; // 실제 사용자 ID로 교체 필요

    try {
      // Get the current user's document
      DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();

      // Check if the document exists
      if (!userDoc.exists) {
        developer.log("User document does not exist.");
        return;
      }

      // Cast the document data to a Map
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Get the current number of diaries
      List<dynamic> myDiaryId = userData['myDiaryId'] ?? [];
      int diaryCount = myDiaryId.length;

      // Generate a new diary ID
      String newDiaryId = "${userId}${diaryCount + 1}";

      // Create the diary data
      final diaryData = {
        'userId': userId,
        'title': title,
        'content': content,
        'emotion': emotion,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'reaction': [0, 0, 0],
        'diaryId': newDiaryId,
      };

      // Add the new diary to the allDiary collection
      await firestore.collection('allDiary').doc(newDiaryId).set(diaryData);

      // Update the user's document in the users collection
      await firestore.collection('users').doc(userId).update({
        'myDiaryId': FieldValue.arrayUnion([newDiaryId]),
      });

    } catch (e) {
      developer.log("Error saving diary: $e");
    }
  }

  void randomCheerText() {
    final List<String> lst = ["너무 걱정하지마 할 수 있어! 넌 잘 해낼 수 있을거야:)"];
    cheerText = lst[Random().nextInt(lst.length)];
    notifyListeners();
  }

  //--------------step 3--------------------------------------------------------

  List<String> emotionOptions = ["감동적이다", "감탄하다", "고맙다", "괜찮다", "궁금하다", "기쁘다", "다행스럽다", "든든하다", "만족스럽다", "반갑다", "뿌듯하다", "사랑스럽다", "상쾌하다", "설레다", "신기하다", "신나다", "여유롭다", "열정적이다", "유쾌하다", "자랑스럽다", "자신있다", "좋다", "통쾌하다", "편안하다", "행복하다", "홀가분하다", "활기차다", "훈훈하다", "흠뻑취하다"];
  List<String> selectedEmotions = [];

  void addEmotion(String emotion) {
    selectedEmotions.add(emotion);
    notifyListeners();
  }

  void removeEmotion(String emotion) {
    selectedEmotions.remove(emotion);
    notifyListeners();
  }
}
