import 'dart:async';
import 'dart:convert';

import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

import 'package:shared_preferences/shared_preferences.dart';

class Tuple<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple(this.item1, this.item2);
}

class MailController with ChangeNotifier {
  // load data one when navigate to the view at the first time
  bool loadLikedDiaryDataOnce = false;
  bool loadLetterDataOnce = false;
  bool loadNewLetterAndNotificationsDataOnce = false;

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
  late ScrollController _everyMailScrollController;
  ScrollController get everyMailScrollController => _everyMailScrollController;
  double everyMailScrollPosition = 0.0;

  late ScrollController _letterScrollController;
  ScrollController get letterScrollController => _letterScrollController;
  double letterScrollPosition = 0.0;

  late ScrollController _likedDiaryScrollController;
  ScrollController get likedDiaryScrollController =>
      _likedDiaryScrollController;
  double likedDiaryScrollPosition = 0.0;

  void initScrollControllers() {
    _everyMailScrollController = ScrollController();
    _letterScrollController = ScrollController();
    _likedDiaryScrollController = ScrollController();

    // Add listener to save scroll position for everyMail
    _everyMailScrollController.addListener(() {
      everyMailScrollPosition = _everyMailScrollController.position.pixels;
    });

    // Add listener to save scroll position for letter
    _letterScrollController.addListener(() {
      letterScrollPosition = _letterScrollController.position.pixels;
    });

    // Add listener to save scroll position for likedDiary
    _likedDiaryScrollController.addListener(() {
      likedDiaryScrollPosition = _likedDiaryScrollController.position.pixels;
    });
  }

  void restoreEveryMailScrollPosition() {
    if (_everyMailScrollController.hasClients) {
      _everyMailScrollController.jumpTo(everyMailScrollPosition);
    } else {
      dev.log('_everyMailScrollController has no clients');
    }
  }

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
  final List<String> chipLabels = ['전체', '응원해요', '공감해요', '함께해요'];
  int filteredKeywordValue = 0;

  // while loading
  bool isLoading = false;

  // while detail view is shown
  bool isDetailViewShowing = false;

  // Flag variable indicating whether more data needs to be loaded
  bool loadMoreLetterData = true;
  bool loadMoreLikedDiaryData = true;

  // Flag variable to track whether the scroll listener has already been added
  bool isEveryMailListenerAdded = false;
  bool isLettersListenerAdded = false;
  bool isLikedDiaryListenerAdded = false;

  // // for new letter model
  late Letter newLetter;

  // // for new letter model
  // late Letter newLetter = Letter(
  //   title: 'yyyy년 m월 편지',
  //   content: 'test' * 100,
  //   date: timestampToLocal(Timestamp.now()),
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

  // Filter for liked Diary
  void updateFilter(String value) {
    filteredKeywordValue = chipLabels.indexOf(value);
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
    dev.log('dhkdhdkdh');
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
  void toggleIsEveryMailListenerAdded(value) {
    // dev.log('모든 메일 리스너 토글: $value');
    isEveryMailListenerAdded = value;
    notifyListeners();
  }

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

  // read chat log from local storage at the first stage
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
    if (userId!.isNotEmpty) {
      dev.log('trying to fetch liked Diary from DB');
      likedDiaryListDates.clear();
      likedDiaryList.clear();

      try {
        loadLikedDiaryDataOnce = true;
        // Firestore 인스턴스 가져오기
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        // 현재 날짜를 키로 사용하기 위해 ISO 형식의 날짜 문자열 생성
        String todayKey =
            '${userId}_likedDiaryList_${DateTime.now().toIso8601String().substring(0, 10)}';

        // 특정 사용자의 likedDiaryIds 가져오기
        DocumentSnapshot userDoc =
            await firestore.collection('users').doc(userId).get();

        List<String> likedDiaryIds = List<String>.from(userDoc['likedDiaryId']);

        // 데이터가 없을 경우 종료
        if (likedDiaryIds.isEmpty) {
          dev.log('No liked diaries found for user.');
          return;
        }

        // 순수 id 값을 추출한 리스트 생성
        List<String> pureIds = likedDiaryIds.map((entry) {
          return entry.split('_')[2];
        }).toList();

        // likedDiaryIds에 해당하는 다이어리들 조회
        QuerySnapshot diarySnapshot = await firestore
            .collection('allDiary')
            .where(FieldPath.documentId, whereIn: pureIds)
            .get();

        // Create a map for quick lookups of documents by their 'diaryId'
        Map<String, QueryDocumentSnapshot> docMap = {
          for (var doc in diarySnapshot.docs) doc.get('diaryId'): doc
        };

        // 'idsFromLikedDiaryIds' 리스트의 순서에 맞춰 'diarySnapshot.docs' 리스트를 정렬
        List<QueryDocumentSnapshot<Object?>?> sortedSnapshot = pureIds
            .map((id) => docMap[id]) // Look up the document in the map
            .where((doc) => doc != null) // Filter out null values
            .toList();

        // 조회된 다이어리들을 likedDiaryList에 추가
        likedDiaryList = sortedSnapshot.map((doc) {
          // Extract `diaryId` from the document data
          final diaryId = likedDiaryIds.firstWhere((id) {
            if (id.split('_')[2] == doc!['diaryId']) {
              // dev.log(id);
              // dev.log(doc['diaryId']);
            }
            return id.split('_')[2] == doc['diaryId'];
          });

          // Extract and convert the first character of `diaryId` to an integer
          final otherUserReaction = int.tryParse(diaryId.substring(0, 1)) ?? 0;
          final otherUserLikedAt = diaryId.substring(2, 12);

          return Diary.fromJsonDB(doc?.data() as Map<String, dynamic>,
              otherUserReaction, otherUserLikedAt);
        }).toList();

        likedDiaryListDates.add(todayKey);

        // 병합된 리스트를 로컬 저장소에 저장
        List<String> jsonMessages = likedDiaryList
            .map((message) => jsonEncode(message.toJson()))
            .toList();
        await prefs.setStringList(todayKey, jsonMessages);

        dev.log(
            'Fetched and saved ${likedDiaryList.length} liked diaries for date ${todayKey.split('_').skip(1).join('_')}.');
      } catch (e) {
        dev.log('Error fetching liked diaries: $e');
      }
    } else {
      dev.log('there is no firebase uid');
    }
  }

  // update liked diary to local storage
  void saveLikedDiaryToLocal(Diary likedDiary, int prefixNumber) async {
    if (userId!.isNotEmpty) {
      // Firestore 업데이트 로직 추가
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // 날짜 형식 생성
      String dateString =
          "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

      // id 앞에 번호(prefixNumber)를 붙이고 뒤에 날짜를 추가
      String formattedId =
          "${prefixNumber}_${dateString}_${likedDiary.diaryId}";

      // Firestore likedDiaryId 배열에 formattedId 추가
      await userDocRef.update({
        'likedDiaryId': FieldValue.arrayUnion([formattedId])
      });

      dev.log('Added formatted likedDiary id $formattedId to Firestore');

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String todayKey = '${userId}_likedDiaryList_$dateString}';

      // 로컬 저장소에서 오늘의 메시지들을 불러오기
      List<String>? storedMessages = prefs.getStringList(todayKey);
      List<Diary> todayMessages = [];

      if (storedMessages != null) {
        todayMessages = storedMessages.map(
          (jsonMessage) {
            // JSON 문자열을 한 번만 디코드하여 Map<String, dynamic> 객체로 변환
            final decodedJson = jsonDecode(jsonMessage);

            // 디코드된 객체를 재사용하여 Diary 객체 생성
            return Diary.fromJsonLocal(
              decodedJson,
              decodedJson['otherUserReaction'],
              formattedId.substring(2, 12),
            );
          },
        ).toList();
      }

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

      // 인수로 받은 likedDiary 추가
      todayMessages.add(updatedDiary);

      List<String> jsonMessages =
          todayMessages.map((message) => jsonEncode(message.toJson())).toList();
      await prefs.setStringList(todayKey, jsonMessages);
      dev.log(
          'save liked Diary to local for date ${todayKey.split('_').skip(1).join('_')}');
      loadLikedDiaryDataOnce = false;
    } else {
      dev.log('there is no firebase uid');
    }
  }

  // load more liked diary from past
  Future<bool> loadMoreLikedDiary() async {
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
              List<Diary> additionalMessages = jsonMessages.map((jsonMessage) {
                final jsonMap = jsonDecode(jsonMessage);
                // Create and return the Diary instance
                return Diary.fromJsonLocal(jsonMap,
                    jsonMap['otherUserReaction'], jsonMap['otherUserLikedAt']);
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
    notifyListeners();
    return true;
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
    if (userId!.isNotEmpty) {
      dev.log('trying to fetch letter from DB');
      letterListDates.clear();
      letterList.clear();

      try {
        loadLetterDataOnce = true;
        // Firestore 인스턴스 가져오기
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        // 현재 날짜를 키로 사용하기 위해 ISO 형식의 날짜 문자열 생성
        String todayKey =
            '${userId}_letterList_${DateTime.now().toIso8601String().substring(0, 10)}';

        // Firestore에서 특정 사용자의 letters 컬렉션의 문서들을 가져오기
        QuerySnapshot lettersSnapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('letters')
            .orderBy('date', descending: true)
            .get();

        // 쿼리 결과가 비어 있는 경우 종료
        if (lettersSnapshot.docs.isEmpty) {
          dev.log('No letters found for user.');
          return;
        }

        // 조회된 다이어리들을 letterList에 추가
        letterList = lettersSnapshot.docs.map((doc) {
          return Letter.fromJsonDB(doc.data() as Map<String, dynamic>);
        }).toList();

        letterListDates.add(todayKey);
        List<Letter> todayMessages = [];

        // Firestore에서 가져온 letterList와 로컬에 저장된 todayMessages를 병합
        todayMessages = letterList;

        // 병합된 리스트를 로컬 저장소에 저장
        List<String> jsonMessages = todayMessages
            .map((message) => jsonEncode(message.toJson()))
            .toList();
        await prefs.setStringList(todayKey, jsonMessages);

        dev.log(
            'Fetched and saved ${letterList.length} letters for date ${todayKey.split('_').skip(1).join('_')}.');
      } catch (e) {
        dev.log('Error fetching letters: $e');
      }
    } else {
      dev.log('there is no firebase uid');
    }
  }

  // update liked diary to local storage
  Future<Tuple> checkForNewLetterNewNotificationsAndSaveLetterToLocal() async {
    bool newLetterAvailable = false;
    if (userId!.isNotEmpty) {
      loadNewLetterAndNotificationsDataOnce = true;

      // 사용자의 문서를 가져옴
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      dev.log('check for new letter and new notifications are arrived');

      // 새로운 편지와 알림이 도착했는지 확인
      if (userDoc.exists) {
        newLetterAvailable = userDoc.data()!['newLetterAvailable'];
        isNewNotifications = userDoc.data()!['newNotificationsAvailable'];
        notifyListeners();
      }

      if (!newLetterAvailable) {
        dev.log('there is no new letter');
        return Tuple(newLetterAvailable, null);
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('letters')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        dev.log('there is new letter but cannot find new letter querySnapshot');
        return Tuple(!newLetterAvailable, null);
      }

      newLetter = Letter.fromSnapshot(querySnapshot.docs.first);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String todayKey =
          '${userId}_letterList_${DateTime.now().toIso8601String().substring(0, 10)}';

      // 로컬 저장소에서 오늘의 메시지들을 불러오기
      List<String>? storedMessages = prefs.getStringList(todayKey);
      List<Letter> todayMessages = [];

      if (storedMessages != null) {
        todayMessages = storedMessages
            .map((jsonMessage) => Letter.fromJsonLocal(jsonDecode(jsonMessage)))
            .toList();
      }

      // 인수로 받은 letter 추가
      todayMessages.add(newLetter);
      letterList.add(newLetter);

      List<String> jsonMessages =
          todayMessages.map((message) => jsonEncode(message.toJson())).toList();
      await prefs.setStringList(todayKey, jsonMessages);

      dev.log(
          'save letter to local for date ${todayKey.split('_').skip(1).join('_')}');

      // 유저의 새 편지 변수 초기화
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'newLetterAvailable': false,
      });

      dev.log('update "newLetterAvailable" field from user document');
    } else {
      dev.log('there is no firebase uid');
      return Tuple(newLetterAvailable, null);
    }

    notifyListeners();
    return Tuple(newLetterAvailable, newLetter);
  }

  // load more liked diary from past
  Future<bool> loadMoreLetter() async {
    if (userId!.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keys = prefs
          .getKeys()
          .where((key) => key.startsWith('${userId}_letterList_'))
          .toList();

      if (keys.isNotEmpty) {
        keys.sort();
        // load older messages
        for (String key in keys.reversed) {
          if (!letterListDates.contains(key)) {
            List<String>? jsonMessages = prefs.getStringList(key);
            if (jsonMessages != null) {
              List<Letter> additionalMessages = jsonMessages
                  .map((jsonMessage) =>
                      Letter.fromJsonLocal(jsonDecode(jsonMessage)))
                  .toList();
              letterList.insertAll(0, additionalMessages);
              letterListDates.add(key);
              notifyListeners();
              dev.log(
                  'read older letter from local for date ${key.split('_').skip(1).join('_')}');

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

    notifyListeners();
    return true;
  }

  // delete all data from local storage
  void deleteEveryMailDataFromLocal() async {
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
}
