import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:bandi_official/controller/diary_ai_analysis_controller.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/utils/time_utils.dart';
import 'package:bandi_official/model/keyword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    createdAt: timestampToLocal(Timestamp.now()),
    updatedAt: timestampToLocal(Timestamp.now()),
    reaction: [0, 0, 0],
    diaryId: 'diaryId',
  );

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? get userId => FirebaseAuth.instance.currentUser!.uid;

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
    if (diaryModel.emotion.length >= 2) {
      //키워드가 2개 이상 있을 경우
      //분류하기
      Emotion emotion = classifyEmotion(diaryModel.emotion);
      if (emotion != Emotion.unknown) {
        dev.log(emotion.toString());
        String emotionString = emotion.toString().split('.').last;
        String returnDiaryId = await scanAndCompareEmotionTimestamps(
            emotionString, diaryModel.diaryId);
        sendOtherDiary(returnDiaryId);
      }
    }
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

      diaryModel.userId = userId!;
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

  Emotion classifyEmotion(List<dynamic> emotion) {
    // 각 감정의 카운트를 저장할 Map
    Map<Emotion, int> sixEmotionsCounts = {
      Emotion.happiness: 0,
      Emotion.fear: 0,
      Emotion.discomfort: 0,
      Emotion.anger: 0,
      Emotion.sadness: 0,
      Emotion.unknown: 0,
    };

    // Keyword 클래스의 인스턴스 생성
    Keyword keyword = Keyword();

    // emotionMap을 순회
    for (var entry in keyword.emotionMap.entries) {
      Emotion emotionKey = entry.key; // 감정
      List<String> categories = entry.value; // 해당 감정에 해당하는 카테고리 리스트

      // emotion 리스트 내의 각 문자열을 순회
      for (String e in emotion) {
        // 카테고리 리스트와 일치하는지 확인
        if (categories.contains(e)) {
          // 일치하면 해당 감정의 카운트를 증가
          sixEmotionsCounts[emotionKey] =
              (sixEmotionsCounts[emotionKey] ?? 0) + 1;
        }
      }
    }
    Emotion maxKey = sixEmotionsCounts.keys.first;
    int maxValue = sixEmotionsCounts[maxKey]!;
    sixEmotionsCounts.forEach((key, value) {
      if (value > maxValue) {
        maxKey = key;
        maxValue = value;
      }
    });
    return maxKey;
  }

  Future<String> scanAndCompareEmotionTimestamps(
      String emotion, String diaryId) async {
    // Firestore 인스턴스 생성
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // 특정 emotion 값을 가진 문서를 가져옴
      DocumentSnapshot documentSnapshot = await firestore
          .collection('representativeDocument')
          .doc(emotion)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          dev.log('Document ID: ${documentSnapshot.id}');

          DateTime now = DateTime.now();
          bool updated = false;

          for (int i = 1; i <= 4; i++) {
            String timeFieldKey = '$emotion${i}_time';
            String idFieldKey = '$emotion${i}_id';

            if (data.containsKey(timeFieldKey) &&
                data[timeFieldKey] is Timestamp) {
              Timestamp timestamp = data[timeFieldKey];
              DateTime fieldTime = timestamp.toDate();

              // 현재 시간과 비교하여 24시간 이상 차이가 나는 경우 업데이트
              if (now.difference(fieldTime).inHours >= 24) {
                String id = data[idFieldKey];
                // 업데이트할 데이터
                Map<String, dynamic> updates = {
                  timeFieldKey: timestampToLocal(Timestamp.now()),
                  idFieldKey: diaryId,
                };

                // Firestore에 업데이트
                await firestore
                    .collection('representativeDocument')
                    .doc(emotion)
                    .update(updates);

                updated = true;
                return id;
              }
            }
          }

          if (!updated) {
            return data['$emotion${Random().nextInt(4) + 1}_id'];
          } else {
            return "null";
          }
        } else {
          dev.log('No data found for document with ID: ${documentSnapshot.id}');
          return "null";
        }
      } else {
        dev.log('No document found with ID: $emotion');
        return "null";
      }
    } catch (e) {
      dev.log('Error scanning and updating document: $e');
      return "null";
    }
  }

  Diary otherDiaryModel = Diary(
    userId: 'userId',
    title: 'title',
    content: 'content',
    emotion: ['emotion'],
    createdAt: timestampToLocal(Timestamp.now()),
    updatedAt: timestampToLocal(Timestamp.now()),
    reaction: [0, 0, 0],
    diaryId: 'diaryId',
    cheerText: 'cheerText',
  );
  bool otherDiaryOpen = false;

  Future<void> sendOtherDiary(String diaryId) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('allDiary')
        .doc(diaryId)
        .get();

    if (documentSnapshot.exists) {
      Diary diary = Diary.fromSnapshot(documentSnapshot);
      otherDiaryModel = diary;
      otherDiaryOpen = true;
      notifyListeners();
    } else {
      dev.log('Diary with ID $diaryId does not exist.');
    }
  }

  void offDiaryOpen() {
    otherDiaryOpen = false;
    otherDiaryModel = Diary(
      userId: 'userId',
      title: 'title',
      content: 'content',
      emotion: ['emotion'],
      createdAt: timestampToLocal(Timestamp.now()),
      updatedAt: timestampToLocal(Timestamp.now()),
      reaction: [0, 0, 0],
      diaryId: 'diaryId',
      cheerText: 'cheerText',
    );
    notifyListeners();
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
        updatedAt: timestampToLocal(Timestamp.now()));
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
