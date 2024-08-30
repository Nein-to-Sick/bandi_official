import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:bandi_official/controller/diary_ai_analysis_controller.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/utils/time_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
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
    createdAt: timestampToKst(Timestamp.now()),
    updatedAt: timestampToKst(Timestamp.now()),
    reaction: [0, 0, 0],
    diaryId: 'diaryId',
  );

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final userId = "21jPhIHrf7iBwVAh92ZW"; // 실제 사용자 ID로 교체 필요

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
    await otherDiaries(diaryModel.emotion);
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

      diaryModel.userId = userId;
      diaryModel.diaryId = newDiaryId;
      notifyListeners();

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

  bool otherDiaryOpen = false;
  String otherDiaryTitle = "";
  String otherDiaryContent = "";
  String otherDiaryDay = "";
  late Timestamp otherDiaryCreatedDay;
  late Timestamp otherDiaryUpdatedDay;
  String otherDiaryId = "";
  List<dynamic> otherDiaryReaction = [];
  List<dynamic> otherDiaryEmotion = [];

  void offDiaryOpen() {
    otherDiaryOpen = false;
    otherDiaryTitle = "";
    otherDiaryContent = "";
    otherDiaryDay = "";
    otherDiaryId = "";
    otherDiaryReaction = [];
    notifyListeners();
  }

  Future<void> otherDiaries(List emotionList) async {
    // 1차적으로 emotionList 중 하나라도 포함된 일기들을 가져옵니다.
    QuerySnapshot allDiarySnapshot = await firestore
        .collection('allDiary')
        .where('userId', isNotEqualTo: userId)
        .where('emotion', arrayContainsAny: emotionList)
        .get();
    List<QueryDocumentSnapshot> matchingDiaries;
    if (allDiarySnapshot.docs.isEmpty) {
      // 2차적으로 emotion 리스트가 정확히 일치하는지 필터링합니다.
      //TODO: 나중에 알고 즘 수정, 받은 일기 제외 추가
      matchingDiaries = allDiarySnapshot.docs.where((doc) {
        List<String> diaryEmotions = List<String>.from(doc['emotion']);
        return _listsAreEqual(diaryEmotions, emotionList);
      }).toList();
    } else {
      matchingDiaries = allDiarySnapshot.docs;
    }
    if (matchingDiaries.isNotEmpty) {
      // 무작위로 일기 하나 선택
      var randomIndex = Random().nextInt(matchingDiaries.length);
      var selectedDiary = matchingDiaries[randomIndex];

      otherDiaryId = selectedDiary['diaryId'];

      // //ToDo: combinationDiaryId 조합하기
      // String combinationDiaryId = otherDiaryId;

      // // user 컬렉션의 userId 문서의 otherDiary 컬렉션에 추가
      // await firestore.collection('users').doc(userId).update({
      //   'likedDiaryId': FieldValue.arrayUnion([combinationDiaryId]),
      // });

      otherDiaryOpen = true;
      otherDiaryTitle = selectedDiary['title'];
      otherDiaryContent = selectedDiary['content'];
      otherDiaryDay =
          DateFormat('yyyy년 M월 d일').format(selectedDiary['createdAt'].toDate());
      otherDiaryReaction = selectedDiary['reaction'];
      otherDiaryEmotion = selectedDiary['emotion'];
      otherDiaryUpdatedDay = selectedDiary['updatedAt'];
      otherDiaryCreatedDay = selectedDiary['createdAt'];
      notifyListeners();

      print("일기가 성공적으로 추가되었습니다.");
    } else {
      print("해당 감정에 해당하는 일기가 없습니다.");
    }
  }

  // 두 리스트가 동일한지 비교하는 함수
  bool _listsAreEqual(List list1, List list2) {
    if (list1.length != list2.length) {
      return false;
    }
    list1.sort();
    list2.sort();
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }
    return true;
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
  Future<void> modifyDatabaseDiaryValue(
      String titleText, String contentText, String diaryId) async {
    diaryModel.update(
        title: titleText,
        content: contentText,
        updatedAt: timestampToKst(Timestamp.now()));
    try {
      final diaryData = {
        'title': diaryModel.title,
        'content': diaryModel.content,
        'emotion': diaryModel.emotion,
        'updatedAt': diaryModel.updatedAt,
      };
      await firestore.collection('allDiary').doc(diaryId).update(diaryData);
    } catch (e) {
      developer.log("Error modifying diary: $e");
    }
  }
}
