import 'dart:developer' as developer;
import 'dart:math';

import 'package:bandi_official/controller/diary_ai_analysis_controller.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

/*
gpt 호출의 경우 Diary 모델을 인수로 전달해주시면 됩니다!
(이미 diary의 변수가 초기화(content 내용 등)된 이후에 호출되어야 합니다)

D:\flutter project\bandi_official\lib\model\diary.dart
diary 모델은 아래 코드에서 사용하는 변수 기준으로 수정했으며,
toMap, update, intialize 등 초기화 함수도 작성해놨습니다
아마 gpt 물어보시면 어떻게 쓰는지 알아서 짜줄겁니다
*/

class HomeToWrite with ChangeNotifier {
  Diary diaryModel = Diary(
    userId: 'userId',
    title: 'title',
    content: 'content',
    emotion: ['emotion'],
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
    reaction: [0, 0, 0],
    diaryId: 'diaryId',
  );

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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

  void initialize() {
    // model을 빈 변수로 초기화
    diaryModel.initializeFields();
    step = 1;
    gotoDirectListPage = false;
    notifyListeners();
  }

  Future<void> aiAndSaveDairy(BuildContext context) async {
    await aiDiary(context);
    await saveDiary();
  }

  Future<void> aiDiary(BuildContext context) async {
    DiaryAIAnalysisController diaryAIAnalysisController =
        context.read<DiaryAIAnalysisController>();

    // 각 analysis 함수에서 diary 모델의 변수를 초기화 하고 notifyListeners()를 호출합니다.
    // 화면에 보여지는 변수를 model의 변수로 변경하면 됩니다.
    await diaryAIAnalysisController.analyzeDiaryKeyword(diaryModel);
    await diaryAIAnalysisController.analyzeDiaryTitle(diaryModel);
    await diaryAIAnalysisController.analyzeDiaryEncouragement(diaryModel);

    notifyListeners();
  }

  Future<void> saveDiary() async {
    final userId = "21jPhIHrf7iBwVAh92ZW"; // 실제 사용자 ID로 교체 필요

    try {
      // Get the current user's document
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();

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
      String newDiaryId = "$userId${diaryCount + 1}";

      // Create the diary data
      final diaryData = {
        'userId': userId,
        'title': diaryModel.title,
        'content': diaryModel.content,
        'emotion': diaryModel.emotion,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'reaction': [0, 0, 0],
        'diaryId': newDiaryId,
        'cheerText': diaryModel.cheerText
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

  //--------------나의 일기--------------------------------------------------------

  bool gotoDirectListPage = false;
  Future<void> readMyDiary(Diary dairy) async {
    step = 2;
    diaryModel = dairy;
    gotoDirectListPage = true;
    notifyListeners();
  }

  //--------------수정하기--------------------------------------------------------
  // diaryModel 값 변경
  int flag = 0;
  void changeDiaryValue(List<String> newEmotions) {
    diaryModel.emotion = newEmotions;
    flag = 1;
    notifyListeners();
  }

  // DB 변경
  Future<void> modifyDatabaseDiaryValue(String titleText, String contentText, String diaryId) async {
    diaryModel.update(title: titleText, content: contentText, updatedAt: Timestamp.now());
    try {
      final diaryData = {
        'title': diaryModel.title,
        'content': diaryModel.content,
        'emotion': diaryModel.emotion,
        'updatedAt': diaryModel.updatedAt,
      };
      await firestore.collection('allDiary').doc(diaryId).update(diaryData);
    } catch (e) {
      developer.log("Error saving diary: $e");
    }
  }
}
