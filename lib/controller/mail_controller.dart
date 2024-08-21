import 'dart:convert';

import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

import 'package:shared_preferences/shared_preferences.dart';

class MailController with ChangeNotifier {
  // Get current user from FirebaseAuth
  User? get currentUser => FirebaseAuth.instance.currentUser;
  bool loadLikedDiaryDataOnce = false;
  bool loadLetterDataOnce = false;

  // maximum number of data to load at once
  int maxDataToLoad = 10;

  // liked diary and letter models
  List<Diary> likedDiaryList = Diary.defaultLikedDiaryList();
  List<String> likedDiaryListDates = [];

  List<Letter> letterList = Letter.defaultLetterList();
  List<String> letterListDates = [];

  // manage the page scroll
  final everyMailScrollController = ScrollController();
  final letterScrollController = ScrollController();
  final likedDiaryScrollController = ScrollController();

  // keyword filter variable
  final List<String> chipLabels = ['전체', '응원해요', '공감해요', '함께해요'];
  int filteredKeywordValue = 0;

  // while loading
  bool isLoading = false;

  // while detail view is shown
  bool isDetailViewShowing = false;

  // mail view tab controller
  late TabController _tabController;

  TabController get tabController => _tabController;

  void initController(TickerProvider vsync, int length) {
    _tabController = TabController(length: length, vsync: vsync);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        notifyListeners();
      }
    });
  }

  int get currentIndex => _tabController.index;

  // called on initState
  void loadDataAndSetting() {
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
    notifyListeners();
  }

  // toggle the loading value
  void toggleLoading(value) {
    isLoading = value;
    notifyListeners();
  }

  // toggle the detail view value
  void toggleDetailView(value) {
    isDetailViewShowing = value;
    notifyListeners();
  }

  // read chat log from local storage at the first stage
  void getLikedDiaryFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keys = prefs
        .getKeys()
        .where((key) => key.startsWith('likedDiaryList_'))
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
          dev.log('read liked Diary log from local for date $key');
          loadLikedDiaryDataOnce = true;
          likedDiaryListDates.add(key);
          likedDiaryList.addAll(
            jsonMessages.map((jsonMessage) {
              final jsonMap = jsonDecode(jsonMessage);
              // Create and return the Diary instance
              return Diary.fromJsonLocal(jsonMap, jsonMap['otherUserReaction'],
                  jsonMap['otherUserLikedAt']);
            }).toList(),
          );
        } else {
          dev.log('there is no liked Diary data for date $key');
        }
      }
    } else {
      dev.log('there is no liked Diary data');
      await fetchLikedDiariesAndSaveFromDB();
    }

    toggleLoading(false);
    notifyListeners();
  }

  Future<void> fetchLikedDiariesAndSaveFromDB() async {
    dev.log('trying to fetch liked Diary from DB');
    likedDiaryListDates.clear();
    likedDiaryList.clear();

    try {
      // Firestore 인스턴스 가져오기
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // 현재 날짜를 키로 사용하기 위해 ISO 형식의 날짜 문자열 생성
      String todayKey =
          'likedDiaryList_${DateTime.now().toIso8601String().substring(0, 10)}';

      // 특정 사용자의 likedDiaryIds 가져오기
      DocumentSnapshot userDoc = await firestore
          .collection('users')
          //.doc(currentUser!.uid)
          .doc('21jPhIHrf7iBwVAh92ZW')
          .get();

      List<String> likedDiaryIds = List<String>.from(userDoc['likedDiaryId']);
      // 순수 id 값을 추출한 리스트 생성
      List<String> pureIds = likedDiaryIds.map((entry) {
        return entry.split('_')[2];
      }).toList();

      // likedDiaryIds에 해당하는 다이어리들 조회
      QuerySnapshot diarySnapshot = await firestore
          .collection('allDiary')
          .where(FieldPath.documentId, whereIn: pureIds)
          .get();

      loadLikedDiaryDataOnce = true;

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
          'Fetched and saved ${likedDiaryList.length} liked diaries for date $todayKey.');
    } catch (e) {
      dev.log('Error fetching liked diaries: $e');
    }
  }

  // update liked diary to local storage
  void saveLikedDiaryToLocal(Diary likedDiary, int prefixNumber) async {
    // Firestore 업데이트 로직 추가
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('users')
        //.doc(currentUser!.uid)
        .doc('21jPhIHrf7iBwVAh92ZW');

    // 날짜 형식 생성
    String dateString =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    // id 앞에 번호(prefixNumber)를 붙이고 뒤에 날짜를 추가
    String formattedId = "${prefixNumber}_${dateString}_${likedDiary.diaryId}";

    // Firestore likedDiaryId 배열에 formattedId 추가
    await userDocRef.update({
      'likedDiaryId': FieldValue.arrayUnion([formattedId])
    });

    dev.log('Added formatted likedDiary id $formattedId to Firestore');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String todayKey = 'likedDiaryList_$dateString}';

    // 로컬 저장소에서 오늘의 메시지들을 불러오기
    List<String>? storedMessages = prefs.getStringList(todayKey);
    List<Diary> todayMessages = [];

    if (storedMessages != null) {
      todayMessages = storedMessages
          .map(
            (jsonMessage) => Diary.fromJsonLocal(
              jsonDecode(jsonMessage),
              (int.tryParse(formattedId.substring(0, 1)) ?? 0),
              formattedId.substring(2, 12),
            ),
          )
          .toList();
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
    dev.log('save liked Diary to local for date $todayKey');
    loadLikedDiaryDataOnce = false;
  }

  // load more liked diary from past
  Future<bool> loadMoreLikedDiary() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keys = prefs
        .getKeys()
        .where((key) => key.startsWith('likedDiaryList_'))
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
              return Diary.fromJsonLocal(jsonMap, jsonMap['otherUserReaction'],
                  jsonMap['otherUserLikedAt']);
            }).toList();

            likedDiaryList.insertAll(0, additionalMessages);
            likedDiaryListDates.add(key);
            notifyListeners();
            dev.log('read older liked Diary from local for date $key');

            if (keys.indexOf(key) == 0) {
              dev.log('there is no more older liked Diary data');
              return false;
            }
            break;
          }
        } else {
          if (keys.indexOf(key) == 0) {
            dev.log('there is no more older liked Diary data');
            return false;
          }
          break;
        }
      }
    } else {
      dev.log('there is no likedDiaryList_');
      return false;
    }
    notifyListeners();
    return true;
  }

  // read letter from local storage at the first stage
  void getLetterFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keys =
        prefs.getKeys().where((key) => key.startsWith('letterList_')).toList();

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
          dev.log('read letter log from local for date $key');
          loadLetterDataOnce = true;
          letterListDates.add(key);
          letterList.addAll(
            jsonMessages
                .map((jsonMessage) =>
                    Letter.fromJsonLocal(jsonDecode(jsonMessage)))
                .toList(),
          );
        } else {
          dev.log('there is no letter data for date $key');
        }
      }
    } else {
      dev.log('there is no letter data');
      await fetchLettersAndSaveFromDB();
    }

    toggleLoading(false);
    notifyListeners();
  }

  Future<void> fetchLettersAndSaveFromDB() async {
    dev.log('trying to fetch letter from DB');
    letterListDates.clear();
    letterList.clear();

    try {
      // Firestore 인스턴스 가져오기
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // 현재 날짜를 키로 사용하기 위해 ISO 형식의 날짜 문자열 생성
      String todayKey =
          'letterList_${DateTime.now().toIso8601String().substring(0, 10)}';

      // Firestore에서 특정 사용자의 letters 컬렉션의 문서들을 가져오기
      QuerySnapshot lettersSnapshot = await firestore
          .collection('users')
          //.doc(currentUser!.uid)
          .doc('21jPhIHrf7iBwVAh92ZW')
          .collection('letters')
          .orderBy('date', descending: true)
          .get();

      loadLetterDataOnce = true;
      // 조회된 다이어리들을 letterList에 추가
      letterList = lettersSnapshot.docs.map((doc) {
        return Letter.fromJsonDB(doc.data() as Map<String, dynamic>);
      }).toList();

      letterListDates.add(todayKey);
      List<Letter> todayMessages = [];

      // Firestore에서 가져온 letterList와 로컬에 저장된 todayMessages를 병합
      todayMessages = letterList;

      // 병합된 리스트를 로컬 저장소에 저장
      List<String> jsonMessages =
          todayMessages.map((message) => jsonEncode(message.toJson())).toList();
      await prefs.setStringList(todayKey, jsonMessages);

      dev.log(
          'Fetched and saved ${letterList.length} letters for date $todayKey.');
    } catch (e) {
      dev.log('Error fetching letters: $e');
    }
  }

  // update liked diary to local storage
  // TODO: function 함수에 해당함
  void saveLetterToLocal(Letter letter) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String todayKey =
        'letterList_${DateTime.now().toIso8601String().substring(0, 10)}';

    // 로컬 저장소에서 오늘의 메시지들을 불러오기
    List<String>? storedMessages = prefs.getStringList(todayKey);
    List<Letter> todayMessages = [];

    if (storedMessages != null) {
      todayMessages = storedMessages
          .map((jsonMessage) => Letter.fromJsonLocal(jsonDecode(jsonMessage)))
          .toList();
    }

    // 인수로 받은 letter 추가
    todayMessages.add(letter);

    List<String> jsonMessages =
        todayMessages.map((message) => jsonEncode(message.toJson())).toList();
    await prefs.setStringList(todayKey, jsonMessages);
    dev.log('save letter to local for date $todayKey');
    loadLetterDataOnce = false;
  }

  // load more liked diary from past
  Future<bool> loadMoreLetter() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keys =
        prefs.getKeys().where((key) => key.startsWith('letterList_')).toList();

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
            dev.log('read older letter from local for date $key');

            if (keys.indexOf(key) == 0) {
              dev.log('there is no more older letter data');
              return false;
            }
            break;
          }
        } else {
          if (keys.indexOf(key) == 0) {
            dev.log('there is no more older letter data');
            return false;
          }
          break;
        }
      }
    } else {
      dev.log('there is no letterList_');
      return false;
    }
    notifyListeners();
    return true;
  }

  // delete all data from local storage
  void deleteEveryMailDataFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> keys = prefs
        .getKeys()
        .where((key) => key.startsWith('likedDiaryList_'))
        .toList();
    for (String key in keys) {
      await prefs.remove(key);
    }

    keys =
        prefs.getKeys().where((key) => key.startsWith('letterList_')).toList();
    for (String key in keys) {
      await prefs.remove(key);
    }

    loadLetterDataOnce = false;
    loadLikedDiaryDataOnce = false;
    likedDiaryList.clear();
    likedDiaryListDates.clear();
    letterList.clear();
    letterListDates.clear();

    dev.log('delete liked Diary and Letter from local');
  }
}
