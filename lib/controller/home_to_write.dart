import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:bandi_official/analytics/log_other_diary_received.dart';
import 'package:bandi_official/view/my_diary_list/controller/my_diary_list_controller.dart';
import 'package:bandi_official/view/writing/controller/diary_ai_analysis_controller.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/model/keyword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

class HomeToWrite with ChangeNotifier {
  Diary diaryModel = Diary(
    userId: 'userId',
    title: 'title',
    content: '',
    emotion: ['emotion'],
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
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

  bool _isPublic = false;
  bool get isPublic => _isPublic;

  void setIsPublic(bool value) {
    _isPublic = value;
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

  Future<void> aiAndSaveDiary(BuildContext context) async {
    String langCode = Localizations.localeOf(context).languageCode;
    MyDiaryListController myDiaryListController =
        context.watch<MyDiaryListController>();
    await aiDiary(context, langCode);
    await saveDiary();
    myDiaryListController.saveMyDiaryToLocal(diaryModel);
    if (diaryModel.emotion.length >= 2) {
      Emotion emotion = classifyEmotion(diaryModel.emotion);
      if (emotion != Emotion.unknown) {
        dev.log(emotion.toString());
        String emotionString = emotion.toString().split('.').last;
        String returnDiaryId = await scanAndCompareEmotionTimestamps(
            emotionString, diaryModel.diaryId);
        if (_isPublic) {
          sendOtherDiary(returnDiaryId);
          await logOtherDiaryReceived();
        }
      }
    }
  }

  Future<void> aiDiary(BuildContext context, String langCode) async {
    DiaryAIAnalysisController diaryAIAnalysisController =
        context.read<DiaryAIAnalysisController>();
    await diaryAIAnalysisController.analyzeAll(diaryModel, langCode);
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

      // Add the new diary to the allDiary collection
      await firestore.collection('allDiary').doc(newDiaryId).set(diaryData);

      final todayKey = _todayKey();

      await firestore.collection('users').doc(userId).update({
        'myDiaryId': FieldValue.arrayUnion([newDiaryId]),
        'lastDiaryDateKey': todayKey, // ✅ 추가
      });

      _lastDiaryDateKey = todayKey;
      notifyListeners();
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
          int representativeDocumentLength = 4;
          List<int> usableDiaryList =
              List.generate(representativeDocumentLength, (index) => index + 1);

          String userId = FirebaseAuth.instance.currentUser!.uid;
          var userData = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();

          List<String> blockedUsersList = [];
          if (userData.exists &&
              userData.data()!.containsKey('blockedUsersList')) {
            blockedUsersList =
                List<String>.from(userData.get('blockedUsersList'));
            dev.log('blocked user list exist');
            for (int i = 0; i < blockedUsersList.length; i++) {
              dev.log('${blockedUsersList[i]} \n');
            }
          } else {
            dev.log('blocked user list never exist');
          }

          for (int i = 1; i <= representativeDocumentLength; i++) {
            String timeFieldKey = '$emotion${i}_time';
            String idFieldKey = '$emotion${i}_id';

            dev.log('try to confirm ${data[idFieldKey]} value');

            bool isBlockedUser = blockedUsersList
                .any((blockedId) => data[idFieldKey].startsWith(blockedId));

            if (isBlockedUser) {
              dev.log('blocked User diary found no.$i');
              usableDiaryList.remove(i);
              continue;
            }

            if (data.containsKey(timeFieldKey) &&
                data[timeFieldKey] is Timestamp) {
              Timestamp timestamp = data[timeFieldKey];
              DateTime fieldTime = timestamp.toDate();

              // 현재 시간과 비교하여 24시간 이상 차이가 나는 경우 업데이트
              if (now.difference(fieldTime).inHours >= 24) {
                String id = data[idFieldKey];
                // 업데이트할 데이터
                Map<String, dynamic> updates = {
                  timeFieldKey: Timestamp.now(),
                  idFieldKey: diaryId,
                };

                // Firestore에 업데이트
                await firestore
                    .collection('representativeDocument')
                    .doc(emotion)
                    .update(updates);

                updated = true;
                dev.log('new representativeDocument Diary updated!');
                return id;
              }
            }
          }

          if (!updated && usableDiaryList.isNotEmpty) {
            // 조건에 맞지 않을 경우, 차단되지 않은 사용자 일기 목록 중에서 무작위로 선택해 보여줌
            int randomNum =
                usableDiaryList[Random().nextInt(usableDiaryList.length)];
            dev.log(
                'There is no porper diary to replace but show random result');
            return data['$emotion${randomNum}_id'];
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

  //========================= 일기 공유 ============================

  Diary otherDiaryModel = Diary(
    userId: 'userId',
    title: '행복한 날입니다.',
    content: '죄송해요 저는 여기까지입니다.',
    emotion: ['emotion'],
    createdAt: Timestamp.now(),
    updatedAt: Timestamp.now(),
    reaction: [0, 0, 0],
    diaryId: 'diaryId',
    cheerText: 'cheerText',
  );
  bool otherDiaryCome = false;
  bool otherDiaryOpen = false;
  late DateTime otherDiaryComeTime;

  Future<void> sendOtherDiary(String diaryId) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('allDiary')
        .doc(diaryId)
        .get();

    if (documentSnapshot.exists) {
      Diary diary = Diary.fromSnapshot(documentSnapshot);
      otherDiaryModel = diary;
      otherDiaryCome = true;
      otherDiaryComeTime = DateTime.now();
      notifyListeners();
    } else {
      dev.log('Diary with ID $diaryId does not exist.');
    }
  }

  void offDiaryOpen() {
    otherDiaryCome = false;
    otherDiaryOpen = false;
    otherDiaryModel = Diary(
      userId: 'userId',
      title: 'title',
      content: 'content',
      emotion: ['emotion'],
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      reaction: [0, 0, 0],
      diaryId: 'diaryId',
      cheerText: 'cheerText',
    );
    notifyListeners();
  }

  void openDiary() {
    otherDiaryOpen = true;
    notifyListeners();
  }

  //--------------나의 일기--------------------------------------------------------

  bool gotoDirectListPage = false;

  Future<void> readMyDiary(Diary diary) async {
    step = 2;
    diaryModel = diary;
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
        title: titleText, content: contentText, updatedAt: Timestamp.now());
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

  bool _deleting = false;
  bool get deleting => _deleting;

  Future<void> deleteDiaryById(String diaryId) async {
    if (diaryId.isEmpty) return;
    if (_deleting) return;

    _deleting = true;
    notifyListeners();

    try {
      final uid = userId;
      final diaryRef = firestore.collection('allDiary').doc(diaryId);
      final userRef = firestore.collection('users').doc(uid);

      final snap = await diaryRef.get();
      if (!snap.exists) {
        developer.log("Diary not found: $diaryId");
        return;
      }
      final data = snap.data() as Map<String, dynamic>;
      if (data['userId'] != uid) {
        developer.log("Permission denied: not owner");
        return;
      }

      final batch = firestore.batch();
      batch.delete(diaryRef);
      batch.update(userRef, {
        'myDiaryId': FieldValue.arrayRemove([diaryId]),
      });

      await batch.commit();

      // 로컬 상태 초기화(지금 보고 있는 일기를 삭제한 경우)
      if (diaryModel.diaryId == diaryId) {
        initialize(); // step=1, diaryModel reset 등
      }

      developer.log("Diary deleted: $diaryId");
    } catch (e) {
      developer.log("Error deleting diary: $e");
      rethrow;
    } finally {
      _deleting = false;
      notifyListeners();
    }
  }

  String? _lastDiaryDateKey; // "2026-01-01" 같은 형태
  String? get lastDiaryDateKey => _lastDiaryDateKey;

  String _todayKey() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}"
        "-${now.month.toString().padLeft(2, '0')}"
        "-${now.day.toString().padLeft(2, '0')}";
  }

  bool get wroteDiaryToday => _lastDiaryDateKey == _todayKey();

  Future<void> loadLastDiaryDate() async {
    final uid = userId;
    if (uid == null) return;

    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    _lastDiaryDateKey = data['lastDiaryDateKey'] as String?;
    notifyListeners();
  }

  bool hideChrome = false;
  void setHideChrome(bool v) {
    hideChrome = v;
    notifyListeners();
  }

  void toggleChrome() => setHideChrome(!hideChrome);
}
