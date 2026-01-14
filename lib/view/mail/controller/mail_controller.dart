import 'dart:async';
import 'dart:convert';

import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

import 'package:shared_preferences/shared_preferences.dart';

enum MailDataType {
  all, // 모두
  diary, // 일기만
  letter, // 편지만
}

class MailController with ChangeNotifier {
  // load data one when navigate to the view at the first time
  bool loadLikedDiaryDataOnce = false;
  bool loadLetterDataOnce = false;
  bool loadNewLetterAndNotificationsDataOnce = false;

  // prevent duplication loading
  bool _isLoadingLikedDiary = false;
  bool get isLoadingLikedDiary => _isLoadingLikedDiary;
  bool _isLoadingLetter = false;
  bool get isLoadingLetter => _isLoadingLetter;

  // whether the new notifications are available
  bool isNewNotifications = false;
  // number of nre notifications
  int newNotificationCount = 0;

  // Get current user from FirebaseAuth
  String? get userId => FirebaseAuth.instance.currentUser!.uid;

  // maximum number of data to load at once
  int maxDataToLoad = 10;

  // liked diary and letter models
  List<Diary> likedDiaryList = Diary.defaultLikedDiaryList();
  List<String> likedDiaryListDates = [];

  List<Letter> letterList = Letter.defaultLetterList();
  List<String> letterListDates = [];

  // Manage the page scroll
  // ScrollController _everyMailScrollController;
  // ScrollController get everyMailScrollController => _everyMailScrollController;
  // double everyMailScrollPosition = 0.0;

  late ScrollController _letterScrollController;
  ScrollController get letterScrollController => _letterScrollController;
  double letterScrollPosition = 0.0;

  late ScrollController _likedDiaryScrollController;
  ScrollController get likedDiaryScrollController =>
      _likedDiaryScrollController;
  double likedDiaryScrollPosition = 0.0;

  void initScrollControllers() {
    // _everyMailScrollController = ScrollController();
    _letterScrollController = ScrollController();
    _likedDiaryScrollController = ScrollController();

    // Add listener to save scroll position for everyMail
    // _everyMailScrollController.addListener(() {
    //   everyMailScrollPosition = _everyMailScrollController.position.pixels;
    // });

    // Add listener to save scroll position for letter
    _letterScrollController.addListener(() {
      letterScrollPosition = _letterScrollController.position.pixels;
    });

    // Add listener to save scroll position for likedDiary
    _likedDiaryScrollController.addListener(() {
      likedDiaryScrollPosition = _likedDiaryScrollController.position.pixels;
    });
  }

  // void restoreEveryMailScrollPosition() {
  //   if (_everyMailScrollController.hasClients) {
  //     _everyMailScrollController.jumpTo(everyMailScrollPosition);
  //   } else {
  //     dev.log('_everyMailScrollController has no clients');
  //   }
  // }

  void restoreLetterScrollPosition() {
    if (_letterScrollController.hasClients) {
      _letterScrollController.jumpTo(letterScrollPosition);
    } else {
      dev.log('_letterScrollController has no clients');
    }
  }

  void restoreLikedDiaryScrollPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_likedDiaryScrollController.hasClients) {
        _likedDiaryScrollController.jumpTo(likedDiaryScrollPosition);
      } else {
        dev.log('_likedDiaryScrollController has no clients');
      }
    });
  }

  // keyword filter variable
  final List<String> chipLabels = [
    'reaction_all',
    'reaction_support',
    'reaction_relate',
    'reaction_with'
  ];
  List<int> filteredchipLabels = [1, 2, 3];

  // while loading
  bool isLoading = false;

  // while detail view is shown
  bool isDetailViewShowing = false;

  // Flag variable indicating whether more data needs to be loaded
  bool loadMoreLetterData = true;
  bool loadMoreLikedDiaryData = true;

  // Flag variable to track whether the scroll listener has already been added
  // bool isEveryMailListenerAdded = false;
  bool isLettersListenerAdded = false;
  bool isLikedDiaryListenerAdded = false;

  // // for new letter model
  late Letter newLetter;

  // // for new letter model
  // late Letter newLetter = Letter(
  //   title: 'yyyy년 m월 편지',
  //   content: 'test' * 100,
  //   date: timestampToLocalTimestamp.now(),
  //   letterId: 'letterId',
  // );

  // mail view tab controller
  late TabController _tabController;

  // to save current index page
  int savedCurrentIndex = 0;

  TabController get tabController => _tabController;

  void initTabController(TickerProvider vsync, int length, int initialIndex) {
    _tabController =
        TabController(length: length, vsync: vsync, initialIndex: initialIndex);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        savedCurrentIndex = tabController.index;
        notifyListeners();
      }
    });
  }

  int get currentIndex => _tabController.index;

  // called on initState
  Future<void> loadDataAndSetting() async {
    if (!loadLikedDiaryDataOnce || !loadLetterDataOnce) {
      toggleLoading(true);
      if (!loadLikedDiaryDataOnce) {
        getLikedDiaryFromLocal();
      }
      if (!loadLetterDataOnce) {
        getLetterFromLocal();
      }
    } else {
      dev.log('did not read data');
    }
  }

  void initializeFilter() {
    filteredchipLabels.clear();
    filteredchipLabels.addAll([1, 2, 3]);
    notifyListeners();
  }

  // Filter for liked Diary
  void updateFilter(String value) {
    int index = chipLabels.indexOf(value);
    if (filteredchipLabels.contains(index)) {
      filteredchipLabels.remove(index);
    } else {
      filteredchipLabels.add(index);
    }
    if (filteredchipLabels.isEmpty) {
      filteredchipLabels.addAll([1, 2, 3]);
    }
    // Scroll to the top of the list
    likedDiaryScrollController.jumpTo(0);
    notifyListeners();
  }

  // toggle the loading value
  void toggleLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // toggle the detail view value
  void toggleDetailView(bool value) {
    isDetailViewShowing = value;
    notifyListeners();
  }

  // toggle the loadMoreLetterData value
  void toggleLoadMoreLetterData(value) {
    // dev.log('편지 데이터 로드 토글: $value');
    loadMoreLetterData = value;
    notifyListeners();
  }

  // toggle the loadMoreLikedDiaryData value
  void toggleLoadMoreLikedDiaryData(value) {
    // dev.log('공감 일기 데이터 로드 토글: $value');
    loadMoreLikedDiaryData = value;
    notifyListeners();
  }

  // toggle the isListenerAdded value
  // void toggleIsEveryMailListenerAdded(value) {
  //   // dev.log('모든 메일 리스너 토글: $value');
  //   isEveryMailListenerAdded = value;
  //   notifyListeners();
  // }

  // toggle the isListenerAdded value
  void toggleIsLettersListenerAdded(value) {
    // dev.log('편지 리스너 토글: $value');
    isLettersListenerAdded = value;
    notifyListeners();
  }

  // toggle the isListenerAdded value
  void toggleIsLikedDiaryListenerAdded(value) {
    // dev.log('공감 일기 메일리스너 토글: $value');
    isLikedDiaryListenerAdded = value;
    notifyListeners();
  }

  void updateSavedCurrentIndex(int value) {
    savedCurrentIndex = value;
    notifyListeners();
  }

  // read liked diary from local storage at the first stage
  void getLikedDiaryFromLocal() async {
    if (userId!.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keys = prefs
          .getKeys()
          .where((key) => key.startsWith('${userId}_likedDiaryList_'))
          .toList();

      if (keys.isNotEmpty) {
        // sorting by time
        keys.sort();
        // latest maxDataToLoad message List's keys
        List<String> latestKeys = keys
            .skip((keys.length - maxDataToLoad) > 0
                ? keys.length - maxDataToLoad
                : 0)
            .toList()
            .toList();
        likedDiaryListDates.clear();
        likedDiaryList.clear();

        for (String key in latestKeys) {
          List<String>? jsonMessages = prefs.getStringList(key);

          if (jsonMessages != null) {
            dev.log(
                'read liked Diary log from local for date ${key.split('_').skip(1).join('_')}');
            loadLikedDiaryDataOnce = true;
            likedDiaryListDates.add(key);
            likedDiaryList.addAll(
              jsonMessages.map((jsonMessage) {
                final jsonMap = jsonDecode(jsonMessage);
                // Create and return the Diary instance
                return Diary.fromJsonLocal(jsonMap,
                    jsonMap['otherUserReaction'], jsonMap['otherUserLikedAt']);
              }).toList(),
            );
          } else {
            dev.log(
                'there is no liked Diary data for date ${key.split('_').skip(1).join('_')}');
          }
        }
      } else {
        dev.log('there is no liked Diary data');
        await fetchLikedDiariesAndSaveFromDB();
      }
    } else {
      dev.log('there is no firebase uid');
    }

    toggleLoading(false);
    notifyListeners();
  }

  Future<void> fetchLikedDiariesAndSaveFromDB() async {
    // 유저 ID 체크
    if (userId == null || userId!.isEmpty) {
      dev.log('there is no firebase uid');
      return;
    }

    dev.log('trying to fetch liked Diary from DB with Chunking');
    likedDiaryListDates.clear();
    likedDiaryList.clear();

    try {
      loadLikedDiaryDataOnce = true;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // 유저 문서에서 likedDiaryId 배열 가져오기
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists || userDoc.data() == null) return;

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      if (!userData.containsKey('likedDiaryId')) return;

      List<String> likedDiaryIds = List<String>.from(userData['likedDiaryId']);

      if (likedDiaryIds.isEmpty) {
        dev.log('No liked diaries found for user.');
        notifyListeners();
        return;
      }

      // 순수 ID 추출 (1_2025-01-01_diaryId -> diaryId)
      List<String> pureIds = likedDiaryIds.map((entry) {
        return entry.split('_')[2];
      }).toList();

      List<QueryDocumentSnapshot> allFetchedDocs = [];
      int chunkSize = 10;

      for (int i = 0; i < pureIds.length; i += chunkSize) {
        // 10개씩 자르기 (마지막 남은 개수 처리 포함)
        int end =
            (i + chunkSize < pureIds.length) ? i + chunkSize : pureIds.length;
        List<String> chunk = pureIds.sublist(i, end);

        // Firestore 조회
        QuerySnapshot chunkSnapshot = await firestore
            .collection('allDiary')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        allFetchedDocs.addAll(chunkSnapshot.docs);
      }

      // 조회된 문서를 ID 기준으로 빠르게 찾기 위해 맵으로 변환
      Map<String, QueryDocumentSnapshot> docMap = {
        for (var doc in allFetchedDocs) doc.get('diaryId'): doc
      };

      // Diary 객체 생성 (메타데이터 주입)
      List<Diary> fetchedDiaries = [];

      for (String fullId in likedDiaryIds) {
        List<String> parts = fullId.split('_');
        if (parts.length < 3) continue;

        String prefix = parts[0]; // reaction
        String dateStr = parts[1]; // likedAt date
        String realId = parts[2]; // diaryId

        var doc = docMap[realId];
        // 삭제된 일기가 아닐 경우에만 리스트에 추가
        if (doc != null) {
          int otherUserReaction = int.tryParse(prefix) ?? 0;
          String otherUserLikedAt = dateStr; // "2025-01-01"

          // DB 데이터에 파싱한 정보를 주입하여 객체 생성
          fetchedDiaries.add(Diary.fromJsonDB(
            doc.data() as Map<String, dynamic>,
            otherUserReaction,
            otherUserLikedAt,
          ));
        }
      }

      // 메모리 리스트 업데이트
      likedDiaryList = fetchedDiaries;

      Map<String, List<Diary>> groupedDiaries = {};

      for (var diary in likedDiaryList) {
        // ID 문자열에서 파싱해온 실제 날짜(otherUserLikedAt) 사용
        String dateStr = diary.otherUserLikedAt;

        // 날짜 유효성 방어 코드 (yyyy-MM-dd 형태가 아니면 오늘 날짜로)
        if (dateStr.length < 10) {
          dateStr = DateTime.now().toIso8601String().substring(0, 10);
        } else {
          dateStr = dateStr.substring(0, 10);
        }

        if (!groupedDiaries.containsKey(dateStr)) {
          groupedDiaries[dateStr] = [];
        }
        groupedDiaries[dateStr]!.add(diary);
      }

      // 그룹화된 데이터를 날짜별 키로 저장
      for (var entry in groupedDiaries.entries) {
        String dateStr = entry.key;
        List<Diary> diaries = entry.value;

        // 로컬 키 생성 (userId_likedDiaryList_yyyy-MM-dd)
        String key = '${userId}_likedDiaryList_$dateStr';

        List<String> jsonMessages =
            diaries.map((msg) => jsonEncode(msg.toJson())).toList();

        await prefs.setStringList(key, jsonMessages);

        if (!likedDiaryListDates.contains(key)) {
          likedDiaryListDates.add(key);
        }
      }

      // 날짜 최신순 정렬 (화면 표시용)
      likedDiaryListDates.sort((a, b) => b.compareTo(a));

      dev.log(
          'Fetched ${likedDiaryList.length} liked diaries using chunking and saved locally.');
      notifyListeners();
    } catch (e) {
      dev.log('Error fetching liked diaries: $e');
    }
  }

  // 알림 등을 통해 새 공감 일기를 전달받았을 때 처리하는 함수
  void saveLikedDiaryToLocal(Diary likedDiary, int prefixNumber) async {
    // 유저 ID가 없으면 로직 수행 불가
    if (userId == null || userId!.isEmpty) {
      dev.log('there is no firebase uid');
      return;
    }

    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      DocumentReference userDocRef = firestore.collection('users').doc(userId);

      // 날짜 형식 생성 (서버 저장용 ID는 '받은 시점'인 현재 시간 기준)
      // 이 시점이 곧 'otherUserLikedAt'이 됩니다.
      String dateString =
          "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

      // ID 생성 (prefix_date_id)
      String formattedId =
          "${prefixNumber}_${dateString}_${likedDiary.diaryId}";

      // Firestore 배열에 추가
      await userDocRef.update({
        'likedDiaryId': FieldValue.arrayUnion([formattedId])
      });

      dev.log('Added formatted likedDiary id $formattedId to Firestore');

      // 로컬 저장소 키 생성 (문법 오류 수정됨: } 제거)
      String targetKey = '${userId}_likedDiaryList_$dateString';

      // 해당 날짜의 기존 메시지 불러오기
      List<String>? storedMessages = prefs.getStringList(targetKey);
      List<Diary> messages = [];

      if (storedMessages != null) {
        messages = storedMessages.map((jsonMessage) {
          final decodedJson = jsonDecode(jsonMessage);

          // [수정 핵심] 기존 데이터 파싱 시, 기존 데이터의 값을 그대로 유지해야 함
          // formattedId(새 데이터 정보)를 넣으면 안 됨!
          return Diary.fromJsonLocal(
            decodedJson,
            decodedJson['otherUserReaction'] ?? -1,
            decodedJson['otherUserLikedAt'] ?? '',
          );
        }).toList();
      }

      // 저장할 새 Diary 객체 생성 (메타데이터 주입)
      Diary updatedDiary = Diary(
        userId: likedDiary.userId,
        title: likedDiary.title,
        content: likedDiary.content,
        emotion: likedDiary.emotion,
        createdAt: likedDiary.createdAt,
        updatedAt: likedDiary.updatedAt,
        reaction: likedDiary.reaction,
        diaryId: likedDiary.diaryId,
        otherUserReaction: prefixNumber,
        otherUserLikedAt: dateString,
      );

      // 리스트에 추가 (로컬 저장용)
      messages.add(updatedDiary);

      // 메모리 리스트(화면 표시용)에도 추가 (최신순 유지를 위해 맨 앞 삽입)
      // 이렇게 하면 loadLikedDiaryDataOnce = false를 할 필요 없이 즉시 반영됨
      likedDiaryList.insert(0, updatedDiary);

      // 로컬 저장소에 저장
      List<String> jsonMessages =
          messages.map((message) => jsonEncode(message.toJson())).toList();
      await prefs.setStringList(targetKey, jsonMessages);

      // 날짜 키 리스트 업데이트 (화면 섹션 갱신용)
      if (!likedDiaryListDates.contains(targetKey)) {
        likedDiaryListDates.add(targetKey);
        // 날짜 내림차순 정렬
        likedDiaryListDates.sort((a, b) => b.compareTo(a));
      }

      dev.log('Saved liked Diary to local for date $dateString');

      // UI 갱신 알림
      notifyListeners();
    } catch (e) {
      dev.log('Error saving liked diary locally: $e');
    }
  }

  // load more liked diary from past
  Future<bool> loadMoreLikedDiary() async {
    if (_isLoadingLikedDiary) {
      dev.log('LikedDiary 로딩 중입니다. 중복 요청을 무시합니다.');
      return false;
    }

    _isLoadingLikedDiary = true;

    try {
      if (userId!.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> keys = prefs
            .getKeys()
            .where((key) => key.startsWith('${userId}_likedDiaryList_'))
            .toList();

        if (keys.isNotEmpty) {
          keys.sort();
          // load older messages
          for (String key in keys.reversed) {
            if (!likedDiaryListDates.contains(key)) {
              List<String>? jsonMessages = prefs.getStringList(key);
              if (jsonMessages != null) {
                List<Diary> additionalMessages =
                    jsonMessages.map((jsonMessage) {
                  final jsonMap = jsonDecode(jsonMessage);
                  // Create and return the Diary instance
                  return Diary.fromJsonLocal(
                      jsonMap,
                      jsonMap['otherUserReaction'],
                      jsonMap['otherUserLikedAt']);
                }).toList();

                likedDiaryList.insertAll(0, additionalMessages);
                likedDiaryListDates.add(key);

                notifyListeners();

                dev.log(
                    'read older liked Diary from local for date ${key.split('_').skip(1).join('_')}');

                if (keys.indexOf(key) == 0) {
                  dev.log('[2] there is no more older liked Diary data');
                  return false;
                }
                break;
              }
            } else {
              if (keys.indexOf(key) == 0) {
                dev.log('[1] there is no more older liked Diary data');
                return false;
              }
            }
          }
        } else {
          dev.log('there is no ${userId}_likedDiaryList_');
          return false;
        }
      } else {
        dev.log('there is no firebase uid');
      }
      return true;
    } catch (e) {
      dev.log('Error loading more liked diaries: $e');
      return false;
    } finally {
      _isLoadingLikedDiary = false;
      notifyListeners();
    }
  }

  // read letter from local storage at the first stage
  void getLetterFromLocal() async {
    if (userId!.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keys = prefs
          .getKeys()
          .where((key) => key.startsWith('${userId}_letterList_'))
          .toList();

      if (keys.isNotEmpty) {
        // sorting by time
        keys.sort();
        // latest maxDataToLoad message List's keys
        List<String> latestKeys = keys
            .skip((keys.length - maxDataToLoad) > 0
                ? keys.length - maxDataToLoad
                : 0)
            .toList()
            .toList();

        letterListDates.clear();
        letterList.clear();

        for (String key in latestKeys) {
          List<String>? jsonMessages = prefs.getStringList(key);

          if (jsonMessages != null) {
            dev.log(
                'read letter log from local for date ${key.split('_').skip(1).join('_')}');
            loadLetterDataOnce = true;
            letterListDates.add(key);
            letterList.addAll(
              jsonMessages
                  .map((jsonMessage) =>
                      Letter.fromJsonLocal(jsonDecode(jsonMessage)))
                  .toList(),
            );
          } else {
            dev.log(
                'there is no letter data for date ${key.split('_').skip(1).join('_')}');
          }
        }
      } else {
        dev.log('there is no letter data');
        await fetchLettersAndSaveFromDB();
      }
    } else {
      dev.log('there is no firebase uid');
    }

    toggleLoading(false);
    notifyListeners();
  }

  Future<void> fetchLettersAndSaveFromDB() async {
    // 유저 ID 체크
    if (userId == null || userId!.isEmpty) {
      dev.log('there is no firebase uid');
      return;
    }

    dev.log('trying to fetch letter from DB');

    // 리스트 초기화
    letterListDates.clear();
    letterList.clear();

    try {
      loadLetterDataOnce = true;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      QuerySnapshot lettersSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('letters')
          .orderBy('date', descending: true)
          .get();

      // 데이터가 없으면 종료
      if (lettersSnapshot.docs.isEmpty) {
        dev.log('No letters found for user.');
        notifyListeners(); // 빈 리스트라도 화면 갱신 필요
        return;
      }

      // Snapshot -> Letter 모델 리스트로 변환
      letterList = lettersSnapshot.docs.map((doc) {
        return Letter.fromSnapshot(doc);
      }).toList();

      Map<String, List<Letter>> groupedLetters = {};

      for (var letter in letterList) {
        // 편지의 실제 날짜(date)를 가져옴
        DateTime date = letter.date.toDate();

        // 키 생성용 날짜 문자열 추출 (yyyy-MM-dd)
        String dateKey = date.toIso8601String().substring(0, 10);

        if (!groupedLetters.containsKey(dateKey)) {
          groupedLetters[dateKey] = [];
        }
        groupedLetters[dateKey]!.add(letter);
      }

      // 그룹화된 데이터를 날짜별 키(Key)로 로컬에 저장
      for (var entry in groupedLetters.entries) {
        String dateStr = entry.key; // 예: "2025-05-05"
        List<Letter> lettersOfDay = entry.value;

        // 로컬 저장소 키 생성 (예: userId_letterList_2025-05-05)
        String key = '${userId}_letterList_$dateStr';

        // List<Letter> -> List<String(JSON)> 변환
        List<String> jsonMessages =
            lettersOfDay.map((msg) => jsonEncode(msg.toJson())).toList();

        // SharedPreferences에 저장
        await prefs.setStringList(key, jsonMessages);

        // 화면 표시용 날짜 키 리스트에도 추가
        if (!letterListDates.contains(key)) {
          letterListDates.add(key);
        }
      }

      // 날짜 내림차순 정렬 (최신 날짜가 위로 오도록)
      letterListDates.sort((a, b) => b.compareTo(a));

      dev.log('Fetched and grouped ${letterList.length} letters.');

      // UI 갱신 알림
      notifyListeners();
    } catch (e) {
      dev.log('Error fetching letters: $e');
    }
  }

  Future<(bool, dynamic)>
      checkForNewLetterNewNotificationsAndSaveLetterToLocal() async {
    bool newLetterAvailable = false;
    // 유저 ID 체크
    if (userId == null || userId!.isEmpty) {
      dev.log('there is no firebase uid');
      return (newLetterAvailable, null);
    }

    try {
      loadNewLetterAndNotificationsDataOnce = true;

      // 사용자의 문서를 가져와 플래그 확인
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      dev.log('check for new letter and new notifications are arrived');

      if (userDoc.exists && userDoc.data() != null) {
        newLetterAvailable = userDoc.data()!['newLetterAvailable'] ?? false;
        isNewNotifications =
            userDoc.data()!['newNotificationsAvailable'] ?? false;
        notifyListeners();
      }

      // 새 편지가 없으면 종료
      if (!newLetterAvailable) {
        dev.log('there is no new letter');
        return (newLetterAvailable, null);
      }

      // 가장 최신 편지 1개 가져오기
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('letters')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        dev.log(
            'there is new letter available flag but cannot find actual document');
        // 플래그는 true인데 데이터가 없는 예외 상황 처리
        return (!newLetterAvailable, null);
      }

      // 4. 편지 객체 생성
      newLetter = Letter.fromSnapshot(querySnapshot.docs.first);

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      DateTime letterDate = newLetter.date.toDate().toLocal();
      String dateKey = letterDate.toIso8601String().substring(0, 10);

      // 로컬 저장소 키 생성 (예: userId_letterList_2025-07-12)
      String targetKey = '${userId}_letterList_$dateKey';

      // 해당 날짜의 기존 로컬 메시지 불러오기
      List<String>? storedMessages = prefs.getStringList(targetKey);
      List<Letter> targetMessages = [];

      if (storedMessages != null) {
        targetMessages = storedMessages
            .map((jsonMessage) => Letter.fromJsonLocal(jsonDecode(jsonMessage)))
            .toList();
      }

      // 중복 방지 및 데이터 추가
      // (이미 저장된 편지인지 확인)
      bool isDuplicate =
          targetMessages.any((l) => l.letterId == newLetter.letterId);

      if (!isDuplicate) {
        // 로컬 리스트에 추가
        targetMessages.add(newLetter);

        // 메모리 리스트(UI 표시용) 최상단에 추가
        letterList.insert(0, newLetter);

        // 로컬 저장소에 저장
        List<String> jsonMessages = targetMessages
            .map((message) => jsonEncode(message.toJson()))
            .toList();
        await prefs.setStringList(targetKey, jsonMessages);

        if (!letterListDates.contains(targetKey)) {
          letterListDates.add(targetKey);
          // 날짜 내림차순 정렬
          letterListDates.sort((a, b) => b.compareTo(a));
        }

        dev.log('save letter to local for date $dateKey');
      }

      // 7. Firestore 플래그 초기화 (newLetterAvailable -> false)
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'newLetterAvailable': false,
      });

      dev.log('update "newLetterAvailable" field from user document');
    } catch (e) {
      dev.log('Error checking for new letter: $e');
    }

    notifyListeners();
    return (newLetterAvailable, newLetter);
  }

  // load more letter from past
  Future<bool> loadMoreLetter() async {
    if (_isLoadingLetter) {
      dev.log('Letter 로딩 중입니다. 중복 요청을 무시합니다.');
      return false;
    }

    _isLoadingLetter = true;

    try {
      if (userId!.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        List<String> keys = prefs
            .getKeys()
            .where((key) => key.startsWith('${userId}_letterList_'))
            .toList();

        if (keys.isNotEmpty) {
          keys.sort();
          for (String key in keys.reversed) {
            if (!letterListDates.contains(key)) {
              List<String>? jsonMessages = prefs.getStringList(key);
              if (jsonMessages != null) {
                List<Letter> additionalMessages = jsonMessages
                    .map((jsonMessage) =>
                        Letter.fromJsonLocal(jsonDecode(jsonMessage)))
                    .toList();

                // 메모리 리스트 병합
                letterList.insertAll(0, additionalMessages);
                letterListDates.add(key);

                notifyListeners();
                dev.log(
                    'read older letter from local for date ${key.split('_').skip(1).join('_')}');

                // 더 이상 불러올 과거 데이터가 없는 경우 (첫 번째 키인 경우)
                if (keys.indexOf(key) == 0) {
                  dev.log('[2] there is no more older letter data');
                  return false;
                }
                break;
              }
            } else {
              if (keys.indexOf(key) == 0) {
                dev.log('[1] there is no more older letter data');
                return false;
              }
            }
          }
        } else {
          dev.log('there is no ${userId}_letterList_');
          return false;
        }
      } else {
        dev.log('there is no firebase uid');
      }

      return true;
    } catch (e) {
      dev.log('Error loading more letters: $e');
      return false;
    } finally {
      _isLoadingLetter = false;
      notifyListeners();
    }
  }

  // delete all data from local storage
  Future<void> deleteEveryMailDataFromLocal() async {
    if (userId!.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keys = prefs
          .getKeys()
          .where((key) => key.startsWith('${userId}_likedDiaryList_'))
          .toList();
      for (String key in keys) {
        await prefs.remove(key);
      }

      keys = prefs
          .getKeys()
          .where((key) => key.startsWith('${userId}_letterList_'))
          .toList();
      for (String key in keys) {
        await prefs.remove(key);
      }

      loadLetterDataOnce = false;
      loadLikedDiaryDataOnce = false;
      likedDiaryList.clear();
      likedDiaryListDates.clear();
      letterList.clear();
      letterListDates.clear();

      notifyListeners();

      dev.log('delete liked Diary and Letter from local');
    } else {
      dev.log('there is no firebase uid');
    }
  }

  void updateNotificationsDataToDB() async {
    if (isNewNotifications) {
      isNewNotifications = false;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'newNotificationsAvailable': false,
      });

      var docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc('0000_docSummary');

      var docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;
        newNotificationCount = data['isNew'] ?? 0;
        await docRef.update({'isNew': 0});
        notifyListeners();
      }

      dev.log('update "newNotificationsAvailable" field from user document');
    } else {
      isNewNotifications = false;
      dev.log('there is no need to update notification data');
    }
  }

  void updateIsNewNotifications(bool value) {
    isNewNotifications = value;
    notifyListeners();
  }

  void initializeNewNotificaitonCount() {
    newNotificationCount = 0;
    notifyListeners();
  }

  String formatMailTitle(String fullTitle, String localeCode) {
    // 1. 연도(2025년 등) 제거
    final yearRegExp = RegExp(r'^\d{4}[년\.\-\s]+');
    String titleWithoutYear = fullTitle.replaceFirst(yearRegExp, '').trim();

    // 2. 월 숫자 추출 (예: "7월 편지"에서 "7" 추출)
    final monthRegExp = RegExp(r'(\d+)월');
    final match = monthRegExp.firstMatch(titleWithoutYear);

    if (match == null) return titleWithoutYear; // 월 숫자가 없으면 그대로 반환

    String monthNum = match.group(1)!;
    int monthInt = int.parse(monthNum);

    // 3. 지역 코드에 따른 결과 생성
    switch (localeCode) {
      case 'ko':
        // "7월 편지" -> "7월의 편지"
        return titleWithoutYear.replaceFirst('월', '월의');

      case 'enUs':
      case 'en':
        // 월 숫자를 영문 월 이름으로 변환
        const englishMonths = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        String monthName = englishMonths[monthInt - 1];

        // "7월 편지" -> "Letter of July"
        return 'Letter of $monthName';

      default:
        return titleWithoutYear;
    }
  }

  // for Calendar selection
  DateTime? _likedDiaryFilteredDate;
  DateTime? _letterFilteredDate;

  // Getter
  DateTime? get likedDiaryFilteredDate => _likedDiaryFilteredDate;
  DateTime? get letterFilteredDate => _letterFilteredDate;

  void updateLikedDiaryCalendarSelectedDate(DateTime? date) {
    _likedDiaryFilteredDate = date;
    notifyListeners();
  }

  void updateLetterCalendarSelectedDate(DateTime? date) {
    _letterFilteredDate = date;
    notifyListeners();
  }

  /// 로컬 저장소의 데이터를 파싱하여 캘린더 점 표시를 위한 날짜 리스트를 반환
  /// [type] : all(전체), diary(일기만), letter(편지만)
  Future<List<DateTime>> getAllEventDatesFromLocal(
      {MailDataType type = MailDataType.all}) async {
    if (userId == null || userId!.isEmpty) return [];

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Set<String> keys = prefs.getKeys();

    // 중복 날짜 제거를 위해 Set 사용 (yyyy-MM-dd 문자열로 관리)
    final Set<String> uniqueDateStrings = {};

    final String diaryPrefix = '${userId}_likedDiaryList_';
    final String letterPrefix = '${userId}_letterList_';

    for (String key in keys) {
      // 1. 타입에 따른 키 필터링
      bool isDiaryKey = key.startsWith(diaryPrefix);
      bool isLetterKey = key.startsWith(letterPrefix);

      if (type == MailDataType.diary && !isDiaryKey) continue;
      if (type == MailDataType.letter && !isLetterKey) continue;
      if (type == MailDataType.all && (!isDiaryKey && !isLetterKey)) continue;

      // 2. 데이터 파싱
      List<String>? jsonList = prefs.getStringList(key);
      if (jsonList == null) continue;

      for (String jsonStr in jsonList) {
        try {
          final Map<String, dynamic> data = jsonDecode(jsonStr);
          DateTime? extractedDate;

          // [Letter 파싱]
          if (isLetterKey) {
            // letter.dart의 toJson: 'date'는 int (milliseconds)
            var dateVal = data['date'];
            if (dateVal is int) {
              extractedDate = DateTime.fromMillisecondsSinceEpoch(dateVal);
            }
          }
          // [Diary 파싱]
          else if (isDiaryKey) {
            // diary.dart의 toJson: 'otherUserLikedAt' (String)
            String? likedAt = data['otherUserLikedAt'];
            if (likedAt != null && likedAt.length >= 10) {
              extractedDate = DateTime.tryParse(likedAt.substring(0, 10));
            }
          }

          if (extractedDate != null) {
            // 시간 정보 제거하고 날짜만 저장 (yyyy-MM-dd)
            String yyyyMMdd = extractedDate.toIso8601String().substring(0, 10);
            uniqueDateStrings.add(yyyyMMdd);
          }
        } catch (e) {
          // 개별 파싱 에러는 무시
        }
      }
    }

    return uniqueDateStrings.map((d) => DateTime.parse(d)).toList();
  }
}
