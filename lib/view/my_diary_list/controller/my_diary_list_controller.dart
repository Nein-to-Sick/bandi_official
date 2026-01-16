import 'dart:convert';

import 'package:bandi_official/model/diary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

import 'package:shared_preferences/shared_preferences.dart';

class MyDiaryListController with ChangeNotifier {
  // load data one when navigate to the view at the first time
  bool loadMyDiaryDataOnce = false;

  // prevent duplication loading
  bool _isLoadingMyDiary = false;
  bool get isLoadingMyDiary => _isLoadingMyDiary;

  // Get current user from FirebaseAuth
  String? get userId => FirebaseAuth.instance.currentUser!.uid;

  // maximum number of data to load at once
  int maxDataToLoad = 10;

  // My diary models
  List<Diary> myDiaryList = Diary.defaultMyDiaryList();
  List<String> myDiaryListDates = [];

  // Manage the page scroll
  final ScrollController _myDiaryScrollController = ScrollController();
  ScrollController get myDiaryScrollController => _myDiaryScrollController;
  double myDiaryScrollPosition = 0.0;

  initScrollControllers() {
    // Add listener to save scroll position for MyDiary
    _myDiaryScrollController.addListener(() {
      if (!_myDiaryScrollController.hasClients) return;
      myDiaryScrollPosition = _myDiaryScrollController.position.pixels;
    });
  }

  void restoreMyDiaryScrollPosition() {
    if (_myDiaryScrollController.hasClients) {
      _myDiaryScrollController.jumpTo(myDiaryScrollPosition);
    } else {
      dev.log('_myDiaryScrollController has no clients');
    }
  }

  // while loading
  bool isLoading = false;

  // Flag variable indicating whether more data needs to be loaded
  bool loadMoreMyDiaryData = true;

  // Flag variable to track whether the scroll listener has already been added
  bool isMyDiaryListenerAdded = false;

  // called on initState
  Future<void> loadDataAndSetting() async {
    if (!loadMyDiaryDataOnce) {
      toggleLoading(true);
      getMyDiaryFromLocal();
    } else {
      dev.log('did not read data');
    }
  }

  void initializeLoadValue() {
    loadMyDiaryDataOnce = false;
  }

  // toggle the loading value
  void toggleLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // toggle the loadMoreMyDiaryData value
  void toggleLoadMoreMyDiaryData(value) {
    // dev.log('공감 일기 데이터 로드 토글: $value');
    loadMoreMyDiaryData = value;
    notifyListeners();
  }

  // toggle the isListenerAdded value
  void toggleIsMyDiaryListenerAdded(value) {
    // dev.log('공감 일기 메일리스너 토글: $value');
    isMyDiaryListenerAdded = value;
    notifyListeners();
  }

  // 로컬 저장소에서 내 일기 목록을 읽어오는 함수 (앱 초기 진입 시 사용)
  void getMyDiaryFromLocal() async {
    // 1. 유저 ID 확인
    if (userId == null || userId!.isEmpty) {
      dev.log('There is no firebase uid');
      toggleLoading(false);
      notifyListeners();
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // 2. 내 일기 키(Key) 검색
      // 키 패턴: {userId}_myDiaryList_{yyyy-MM-dd}
      List<String> keys = prefs
          .getKeys()
          .where((key) => key.startsWith('${userId}_myDiaryList_'))
          .toList();

      // 3. 데이터가 존재할 경우
      if (keys.isNotEmpty) {
        // 날짜순 정렬 (키에 날짜가 포함되어 있으므로 문자열 정렬 시 날짜순이 됨)
        keys.sort();

        List<String> reversedKeys = keys.reversed.toList();

        // 4. 앞에서부터 N개 가져오기 (가장 최신 데이터들)
        List<String> targetKeys = reversedKeys.take(maxDataToLoad).toList();

        // 메모리 리스트 초기화
        myDiaryListDates.clear();
        myDiaryList.clear();

        // 5. 각 키에 저장된 JSON 리스트 파싱
        for (String key in targetKeys) {
          List<String>? jsonMessages = prefs.getStringList(key);

          if (jsonMessages != null) {
            String datePart = key.split('_').last; // yyyy-MM-dd 추출
            dev.log('Read my diary log from local for date $datePart');
            myDiaryListDates.add(key);

            List<Diary> diaries = [];
            for (String jsonMessage in jsonMessages) {
              try {
                final jsonMap = jsonDecode(jsonMessage);
                // ID 유효성 검사
                if (jsonMap['diaryId'] == null ||
                    jsonMap['diaryId'].toString().isEmpty) {
                  continue;
                }

                diaries.add(Diary.fromJsonLocal(
                  jsonMap,
                  jsonMap['otherUserReaction'] ?? -1,
                  jsonMap['otherUserLikedAt'] ?? '',
                ));
              } catch (e) {
                dev.log("JSON parsing error: $e");
              }
            }

            // [중요] 해당 날짜 내의 일기들도 최신순 정렬 (하루에 여러 개 썼을 경우 대비)
            diaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            // 리스트에 추가 (최신 날짜부터 순서대로 addAll 하므로 결과적으로 최신순 유지됨)
            myDiaryList.addAll(diaries);
          }
        }
        loadMyDiaryDataOnce = true;
      } else {
        // 6. 로컬 데이터가 없을 경우 -> DB에서 가져오기
        dev.log('There is no my diary data in local storage.');
        await fetchMyDiariesAndSaveFromDB();
      }
    } catch (e) {
      dev.log('Error getting my diary from local: $e');
    } finally {
      // 7. 로딩 상태 해제 및 UI 갱신
      toggleLoading(false);
      notifyListeners();
    }
  }

  // DB에 저장된 나의 일기 목록을 가져와 로컬에 저장하는 함수
  Future<void> fetchMyDiariesAndSaveFromDB() async {
    // 1. 유저 ID 유효성 체크
    if (userId == null || userId!.isEmpty) {
      dev.log('There is no firebase uid');
      return;
    }

    dev.log('Trying to fetch my diary from DB with Chunking');
    myDiaryListDates.clear();
    myDiaryList.clear();

    try {
      loadMyDiaryDataOnce = true;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // 2. 유저 문서에서 myDiaryId 배열 가져오기
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists || userDoc.data() == null) return;

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // 'myDiaryId' 필드 확인
      if (!userData.containsKey('myDiaryId')) {
        dev.log('No myDiaryId field in user doc.');
        notifyListeners();
        return;
      }

      // DB에 저장된 내 일기 ID 리스트 추출
      List<String> myDiaryIds = List<String>.from(userData['myDiaryId']);

      if (myDiaryIds.isEmpty) {
        dev.log('No diaries found for this user.');
        notifyListeners();
        return;
      }

      // 3. Chunking을 통한 일기 데이터 일괄 조회 (Firestore 10개 제한 대응)
      List<QueryDocumentSnapshot> allFetchedDocs = [];
      int chunkSize = maxDataToLoad;

      for (int i = 0; i < myDiaryIds.length; i += chunkSize) {
        int end = (i + chunkSize < myDiaryIds.length)
            ? i + chunkSize
            : myDiaryIds.length;
        List<String> chunk = myDiaryIds.sublist(i, end);

        if (chunk.isEmpty) continue;

        // Firestore 조회 (문서 ID로 조회)
        QuerySnapshot chunkSnapshot = await firestore
            .collection('allDiary')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        allFetchedDocs.addAll(chunkSnapshot.docs);
      }

      // 4. 조회된 문서를 ID 기준으로 빠르게 매핑하기 위해 Map으로 변환
      Map<String, QueryDocumentSnapshot> docMap = {
        for (var doc in allFetchedDocs) doc.id: doc
      };

      // 5. Diary 객체 생성 및 리스트 구성
      List<Diary> fetchedDiaries = [];

      for (String diaryId in myDiaryIds) {
        var doc = docMap[diaryId];

        // 삭제되지 않고 실제로 존재하는 일기만 처리
        if (doc != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          try {
            // [중요] Diary.fromJsonDB 생성자 시그니처에 맞게 호출
            // 내 일기이므로 '타인의 반응' 관련 필드는 기본값(-1, 빈 문자열) 처리
            fetchedDiaries.add(Diary.fromJsonDB(
              data,
              -1, // otherUserReaction
              "", // otherUserLikedAt
            ));
          } catch (e) {
            dev.log('Error parsing diary $diaryId: $e');
          }
        }
      }

      // 5.5. [핵심 추가] 전체 일기 목록을 최신순으로 정렬 (가장 최근 작성일 기준)
      fetchedDiaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 메모리 리스트 업데이트
      myDiaryList = fetchedDiaries;

      // 6. 날짜별 그룹화 (yyyy-MM-dd 기준)
      Map<String, List<Diary>> groupedDiaries = {};

      for (var diary in myDiaryList) {
        // createdAt은 Timestamp 타입이므로 DateTime 변환 후 문자열 추출
        DateTime date = diary.createdAt.toDate();
        DateTime localDate = date.toLocal();
        String dateStr =
            localDate.toIso8601String().substring(0, 10); // yyyy-MM-dd

        if (!groupedDiaries.containsKey(dateStr)) {
          groupedDiaries[dateStr] = [];
        }
        groupedDiaries[dateStr]!.add(diary);
      }

      // 7. 로컬 저장소(SharedPreferences)에 저장
      // 키 형식: {userId}_myDiaryList_{yyyy-MM-dd}
      for (var entry in groupedDiaries.entries) {
        String dateStr = entry.key;
        List<Diary> diaries = entry.value;

        String key = '${userId}_myDiaryList_$dateStr';

        List<String> jsonMessages =
            diaries.map((msg) => jsonEncode(msg.toJson())).toList();

        await prefs.setStringList(key, jsonMessages);

        // 날짜 리스트 업데이트 (중복 방지)
        if (!myDiaryListDates.contains(key)) {
          myDiaryListDates.add(key);
        }
      }

      // 날짜 최신순 정렬 (내림차순)
      myDiaryListDates.sort((a, b) => b.compareTo(a));

      dev.log(
          'Fetched ${myDiaryList.length} my diaries using chunking and saved locally.');

      notifyListeners();
    } catch (e) {
      dev.log('Error fetching my diaries: $e');
    }
  }

  //  일기 작성 후 로컬 저장소 및 메모리에 즉시 반영하는 함수
  Future<void> saveMyDiaryToLocal(Diary myDiary) async {
    // 1. 유저 ID 유효성 체크
    if (userId == null || userId!.isEmpty) {
      dev.log('There is no firebase uid');
      return;
    }

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // 2. 로컬 저장소 키 생성
      // 내 일기는 '작성일(createdAt)'을 기준으로 날짜 키를 생성합니다.
      DateTime createdDate = myDiary.createdAt.toDate().toLocal();
      String dateString =
          createdDate.toIso8601String().substring(0, 10); // yyyy-MM-dd

      // 키 형식: {userId}_myDiaryList_{yyyy-MM-dd}
      String targetKey = '${userId}_myDiaryList_$dateString';

      // 3. 해당 날짜의 기존 로컬 데이터 불러오기
      List<String>? storedMessages = prefs.getStringList(targetKey);
      List<Diary> messages = [];

      if (storedMessages != null) {
        messages = storedMessages
            .map((e) => Diary.fromJsonLocal(jsonDecode(e), -1, ''))
            .toList();
      }

      // [핵심 수정] 참조 끊기! 새로운 객체를 생성하여 값을 복사합니다.
      // 이렇게 해야 나중에 diaryModel이 초기화되어도 리스트의 데이터는 살아있습니다.
      Diary newDiaryEntry = Diary(
        userId: myDiary.userId,
        title: myDiary.title,
        content: myDiary.content,
        emotion: List.from(myDiary.emotion), // 리스트도 복사
        createdAt: myDiary.createdAt,
        updatedAt: myDiary.updatedAt,
        reaction: List.from(myDiary.reaction), // 리스트도 복사
        diaryId: myDiary.diaryId,
        cheerText: myDiary.cheerText,
        otherUserReaction: -1,
        otherUserLikedAt: '',
      );

      // 4. 리스트에 '복사된 객체' 추가
      messages.insert(0, newDiaryEntry);

      // 5. 메모리 리스트에도 '복사된 객체' 추가
      myDiaryList.insert(0, newDiaryEntry);

      // 6. 저장
      List<String> jsonMessages =
          messages.map((message) => jsonEncode(message.toJson())).toList();

      await prefs.setStringList(targetKey, jsonMessages);

      if (!myDiaryListDates.contains(targetKey)) {
        myDiaryListDates.add(targetKey);
        // 날짜 내림차순 정렬
        myDiaryListDates.sort((a, b) => b.compareTo(a));
      }

      dev.log('Saved my diary to local for date $dateString');
      notifyListeners();
    } catch (e) {
      dev.log('Error saving my diary locally: $e');
    }
  }

  // 과거의 내 일기 데이터를 추가로 로드하는 함수 (Pagination)
  Future<bool> loadMoreMyDiary() async {
    if (_isLoadingMyDiary) return false;
    _isLoadingMyDiary = true;
    notifyListeners();

    try {
      if (userId == null || userId!.isEmpty) return false;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keys = prefs
          .getKeys()
          .where((key) => key.startsWith('${userId}_myDiaryList_'))
          .toList();

      if (keys.isNotEmpty) {
        keys.sort(); // 오름차순 (옛날 -> 최신)
        List<String> reversedKeys = keys.reversed.toList(); // 최신 -> 옛날

        int loadedCount = 0;
        bool hasMoreData = false;

        for (String key in reversedKeys) {
          // 이미 로드된 날짜는 건너뜀
          if (myDiaryListDates.contains(key)) continue;

          // 새로운 과거 데이터 발견
          List<String>? jsonMessages = prefs.getStringList(key);
          if (jsonMessages != null) {
            List<Diary> oldDiaries = [];
            for (String jsonStr in jsonMessages) {
              try {
                final jsonMap = jsonDecode(jsonStr);
                if (jsonMap['diaryId'] == null) continue;
                oldDiaries.add(Diary.fromJsonLocal(
                    jsonMap,
                    jsonMap['otherUserReaction'] ?? -1,
                    jsonMap['otherUserLikedAt'] ?? ''));
              } catch (_) {}
            }

            // 날짜 내 정렬 (최신순)
            oldDiaries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            // [핵심] 과거 데이터이므로 리스트의 '맨 뒤'에 추가
            myDiaryList.addAll(oldDiaries);
            myDiaryListDates.add(key);

            loadedCount++;
            hasMoreData = true;

            dev.log(
                'read older My Diary from local for date ${key.split('_').skip(1).join('_')}');

            if (loadedCount >= maxDataToLoad) {
              break;
            }
          }
        }

        if (!hasMoreData) {
          dev.log('No more older my diary data.');
          return false;
        }

        return true;
      }
      return false;
    } catch (e) {
      dev.log('Error loading more My diaries: $e');
      return false;
    } finally {
      _isLoadingMyDiary = false;
      notifyListeners();
    }
  }

  // 일기 수정 시 로컬 데이터도 함께 갱신하는 함수
  Future<void> updateMyDiaryLocal(Diary updatedDiary) async {
    if (userId == null || userId!.isEmpty) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // 1. 키 생성 (작성일 기준)
      // 내 일기는 작성일(createdAt)을 기준으로 키가 생성되어 있음
      DateTime createdDate = updatedDiary.createdAt.toDate();
      String dateString = createdDate.toIso8601String().substring(0, 10);
      String key = '${userId}_myDiaryList_$dateString';

      // 2. 해당 날짜의 리스트 불러오기
      List<String>? storedMessages = prefs.getStringList(key);

      if (storedMessages != null) {
        // 3. 리스트에서 수정할 일기 찾아서 교체
        List<Diary> messages = storedMessages.map((jsonMessage) {
          final decodedJson = jsonDecode(jsonMessage);
          return Diary.fromJsonLocal(
            decodedJson,
            decodedJson['otherUserReaction'] ?? -1,
            decodedJson['otherUserLikedAt'] ?? '',
          );
        }).toList();

        // diaryId가 일치하는 항목 찾기
        int index =
            messages.indexWhere((d) => d.diaryId == updatedDiary.diaryId);

        if (index != -1) {
          // 데이터 교체
          messages[index] = updatedDiary;

          // 4. 로컬 저장소에 다시 저장
          List<String> jsonMessages =
              messages.map((m) => jsonEncode(m.toJson())).toList();
          await prefs.setStringList(key, jsonMessages);

          dev.log('Updated local diary for ID: ${updatedDiary.diaryId}');
        }
      }

      // 5. 메모리 리스트(화면 표시용) 갱신
      // 현재 보고 있는 리스트에서도 값을 바꿔줘야 화면이 즉시 갱신됨
      int memoryIndex =
          myDiaryList.indexWhere((d) => d.diaryId == updatedDiary.diaryId);
      if (memoryIndex != -1) {
        myDiaryList[memoryIndex] = updatedDiary;
      }

      notifyListeners();
    } catch (e) {
      dev.log('Error updating local diary: $e');
    }
  }

  // 일기 삭제 시 로컬 데이터도 함께 삭제하는 함수
  Future<void> deleteMyDiaryLocal(String diaryId, DateTime createdAt) async {
    if (userId == null || userId!.isEmpty) return;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // 전달받은 createdAt을 Local Time으로 변환 후 문자열 생성
      DateTime localDate = createdAt.toLocal();
      String dateString =
          localDate.toIso8601String().substring(0, 10); // yyyy-MM-dd

      String key = '${userId}_myDiaryList_$dateString';

      // 2. 해당 날짜의 리스트 불러오기
      List<String>? storedMessages = prefs.getStringList(key);

      if (storedMessages != null) {
        List<Diary> messages = storedMessages.map((jsonMessage) {
          final decodedJson = jsonDecode(jsonMessage);
          return Diary.fromJsonLocal(
            decodedJson,
            decodedJson['otherUserReaction'] ?? -1,
            decodedJson['otherUserLikedAt'] ?? '',
          );
        }).toList();

        // 3. 삭제할 일기 찾아서 제거
        int initialLength = messages.length;
        messages.removeWhere((d) => d.diaryId == diaryId);

        if (messages.length != initialLength) {
          // 4. 로컬 저장소 업데이트
          if (messages.isEmpty) {
            // 해당 날짜에 일기가 하나도 안 남았으면 키 자체를 삭제
            await prefs.remove(key);
            myDiaryListDates.remove(key); // 날짜 리스트에서도 제거
          } else {
            // 아직 다른 일기가 남아있으면 리스트 업데이트
            List<String> jsonMessages =
                messages.map((m) => jsonEncode(m.toJson())).toList();
            await prefs.setStringList(key, jsonMessages);
          }
          dev.log('Deleted local diary for ID: $diaryId');
        }
      }

      // 5. 메모리 리스트(화면 표시용) 갱신
      myDiaryList.removeWhere((d) => d.diaryId == diaryId);

      notifyListeners();
    } catch (e) {
      dev.log('Error deleting local diary: $e');
    }
  }

  // 로컬 저장소에 있는 '나의 일기' 데이터를 모두 삭제하는 함수
  Future<void> deleteEveryMyDiaryDataFromLocal() async {
    // 1. 유저 ID 확인
    if (userId != null && userId!.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // 2. 삭제할 키 검색
      // 키 패턴: {userId}_myDiaryList_
      List<String> keys = prefs
          .getKeys()
          .where((key) => key.startsWith('${userId}_myDiaryList_'))
          .toList();

      // 3. 로컬 저장소에서 제거
      for (String key in keys) {
        await prefs.remove(key);
      }

      // 4. 메모리 리스트 초기화
      myDiaryList.clear();
      myDiaryListDates.clear();

      loadMyDiaryDataOnce = false;

      // 5. UI 갱신
      notifyListeners();

      dev.log('Deleted all my diary data from local storage.');
    } else {
      dev.log('There is no firebase uid');
    }
  }

  // 특정 내 일기의 Reaction 정보를 DB에서 최신화하는 함수
  Future<List<dynamic>> fetchMyDiariesReactionAndSaveFromDB(
      String myDiaryId) async {
    List<dynamic> currentReaction = [0, 0, 0];

    if (myDiaryId.isEmpty) {
      dev.log('Skipping reaction fetch: myDiaryId is empty.');
      return currentReaction;
    }

    if (userId == null || userId!.isEmpty) return currentReaction;

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // 1. DB에서 해당 일기 문서 가져오기
      DocumentSnapshot diaryDoc =
          await firestore.collection('allDiary').doc(myDiaryId).get();

      if (!diaryDoc.exists || diaryDoc.data() == null) {
        dev.log('Diary document not found: $myDiaryId');
        return currentReaction;
      }

      Map<String, dynamic> data = diaryDoc.data() as Map<String, dynamic>;

      // DB의 최신 Reaction 값
      List<dynamic> serverReaction = data['reaction'] ?? [0, 0, 0];
      currentReaction = serverReaction; // 반환값 업데이트

      // 2. 로컬 데이터와 비교 및 갱신을 위해 로컬 데이터 로드
      // 내 일기는 작성일(createdAt) 기준으로 키가 생성되므로, DB 데이터에서 날짜 추출 필요
      Timestamp createdAtTimestamp = data['createdAt'];
      DateTime createdDate = createdAtTimestamp.toDate().toLocal(); // 타임존 고려
      String dateString =
          createdDate.toIso8601String().substring(0, 10); // yyyy-MM-dd

      String targetKey = '${userId}_myDiaryList_$dateString';

      List<String>? storedMessages = prefs.getStringList(targetKey);

      if (storedMessages != null) {
        bool needUpdate = false;

        List<Diary> messages = storedMessages.map((jsonMessage) {
          final decodedJson = jsonDecode(jsonMessage);

          // 해당 일기 찾기
          if (decodedJson['diaryId'] == myDiaryId) {
            List<dynamic> localReaction = decodedJson['reaction'] ?? [0, 0, 0];

            // 3. 값 비교 (다르면 업데이트)
            if (localReaction.toString() != serverReaction.toString()) {
              dev.log(
                  'Reaction updated for diary $myDiaryId: $localReaction -> $serverReaction');
              decodedJson['reaction'] = serverReaction; // JSON 값 갱신
              needUpdate = true;

              // (선택사항) 메모리 리스트(myDiaryList)도 갱신
              int memoryIndex =
                  myDiaryList.indexWhere((d) => d.diaryId == myDiaryId);
              if (memoryIndex != -1) {
                myDiaryList[memoryIndex].reaction = serverReaction;
              }
            }
          }

          // 다시 Diary 객체로 변환 (갱신된 JSON 반영)
          return Diary.fromJsonLocal(
            decodedJson,
            decodedJson['otherUserReaction'] ?? -1,
            decodedJson['otherUserLikedAt'] ?? '',
          );
        }).toList();

        // 4. 변경사항이 있으면 로컬 저장소에 덮어쓰기
        if (needUpdate) {
          List<String> updatedJsonMessages =
              messages.map((m) => jsonEncode(m.toJson())).toList();
          await prefs.setStringList(targetKey, updatedJsonMessages);
          notifyListeners(); // UI 갱신
        }
      }
    } catch (e) {
      dev.log('Error fetching reaction for diary $myDiaryId: $e');
    }

    return currentReaction;
  }

  // for Calendar selection
  DateTime? _myDiaryFilteredDate;

  // Getter
  DateTime? get myDiaryFilteredDate => _myDiaryFilteredDate;

  void updateMyDiaryCalendarSelectedDate(DateTime? date) {
    _myDiaryFilteredDate = date;
    notifyListeners();
  }

  //로컬 저장소에서 '내 일기'가 작성된 날짜들만 가져오는 함수
  Future<List<DateTime>> getAllMyDiaryDatesFromLocal() async {
    // 1. 유저 ID 확인
    if (userId == null || userId!.isEmpty) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 저장된 모든 키 가져오기
    final Set<String> keys = prefs.getKeys();

    // 날짜 문자열(yyyy-MM-dd)을 담을 Set (중복 방지용)
    final Set<String> uniqueDateStrings = {};

    // 내 일기 키 접두사 정의
    final String myDiaryPrefix = '${userId}_myDiaryList_';

    for (String key in keys) {
      // 2. '내 일기' 키인지 확인
      if (key.startsWith(myDiaryPrefix)) {
        try {
          // 3. 키에서 날짜 부분 추출
          final dateString = key.substring(myDiaryPrefix.length);

          // yyyy-MM-dd 형식인지 간단히 길이 체크
          if (dateString.length == 10 && dateString.contains('-')) {
            uniqueDateStrings.add(dateString);
          }
        } catch (_) {
          // 키 형식이 예상과 다를 경우 무시
          continue;
        }
      }
    }

    final List<DateTime> dates = [];
    for (String dateStr in uniqueDateStrings) {
      try {
        final date = DateTime.parse(dateStr);
        dates.add(date);
      } catch (_) {
        dev.log('Invalid date format in key: $dateStr');
      }
    }

    // 5. 날짜를 오름차순으로 정렬 (달력 표시를 위해)
    dates.sort((a, b) => a.compareTo(b));

    return dates;
  }
}
