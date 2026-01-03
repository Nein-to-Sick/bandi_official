import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  // number of new notifications
  int newNotificationCount = 0;

  // Get current user from FirebaseAuth
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // maximum number of data to load at once
  int maxDataToLoad = 10;

  // liked diary and letter models
  List<Diary> likedDiaryList = Diary.defaultLikedDiaryList();
  List<String> likedDiaryListDates = [];

  List<Letter> letterList = Letter.defaultLetterList();
  List<String> letterListDates = [];

  // Manage the page scroll
  late ScrollController _letterScrollController;
  ScrollController get letterScrollController => _letterScrollController;
  double letterScrollPosition = 0.0;

  late ScrollController _likedDiaryScrollController;
  ScrollController get likedDiaryScrollController => _likedDiaryScrollController;
  double likedDiaryScrollPosition = 0.0;

  void initScrollControllers() {
    _letterScrollController = ScrollController();
    _likedDiaryScrollController = ScrollController();

    _letterScrollController.addListener(() {
      letterScrollPosition = _letterScrollController.position.pixels;
    });

    _likedDiaryScrollController.addListener(() {
      likedDiaryScrollPosition = _likedDiaryScrollController.position.pixels;
    });
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
  bool isLettersListenerAdded = false;
  bool isLikedDiaryListenerAdded = false;

  // ✅ NEW: new letter model (nullable, late 제거)
  Letter? _newLetter;
  Letter? get newLetter => _newLetter;
  bool get hasNewLetter => _newLetter != null;

  void setNewLetter(Letter? letter) {
    _newLetter = letter;
    notifyListeners();
  }

  void clearNewLetter() {
    _newLetter = null;
    notifyListeners();
  }

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
    loadMoreLetterData = value;
    notifyListeners();
  }

  // toggle the loadMoreLikedDiaryData value
  void toggleLoadMoreLikedDiaryData(value) {
    loadMoreLikedDiaryData = value;
    notifyListeners();
  }

  // toggle the isListenerAdded value
  void toggleIsLettersListenerAdded(value) {
    isLettersListenerAdded = value;
    notifyListeners();
  }

  // toggle the isListenerAdded value
  void toggleIsLikedDiaryListenerAdded(value) {
    isLikedDiaryListenerAdded = value;
    notifyListeners();
  }

  void updateSavedCurrentIndex(int value) {
    savedCurrentIndex = value;
    notifyListeners();
  }

  // read chat log from local storage at the first stage
  void getLikedDiaryFromLocal() async {
    final uid = userId;
    if (uid != null && uid.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keys = prefs
          .getKeys()
          .where((key) => key.startsWith('${uid}_likedDiaryList_'))
          .toList();

      if (keys.isNotEmpty) {
        keys.sort();

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
                return Diary.fromJsonLocal(jsonMap, jsonMap['otherUserReaction'],
                    jsonMap['otherUserLikedAt']);
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
    final uid = userId;
    if (uid != null && uid.isNotEmpty) {
      dev.log('trying to fetch liked Diary from DB');
      likedDiaryListDates.clear();
      likedDiaryList.clear();

      try {
        loadLikedDiaryDataOnce = true;
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        String todayKey =
            '${uid}_likedDiaryList_${DateTime.now().toIso8601String().substring(0, 10)}';

        DocumentSnapshot userDoc =
        await firestore.collection('users').doc(uid).get();

        List<String> likedDiaryIds = List<String>.from(userDoc['likedDiaryId']);

        if (likedDiaryIds.isEmpty) {
          dev.log('No liked diaries found for user.');
          return;
        }

        List<String> pureIds = likedDiaryIds.map((entry) {
          return entry.split('_')[2];
        }).toList();

        QuerySnapshot diarySnapshot = await firestore
            .collection('allDiary')
            .where(FieldPath.documentId, whereIn: pureIds)
            .get();

        Map<String, QueryDocumentSnapshot> docMap = {
          for (var doc in diarySnapshot.docs) doc.get('diaryId'): doc
        };

        List<QueryDocumentSnapshot<Object?>?> sortedSnapshot = pureIds
            .map((id) => docMap[id])
            .where((doc) => doc != null)
            .toList();

        likedDiaryList = sortedSnapshot.map((doc) {
          final diaryId = likedDiaryIds.firstWhere((id) {
            return id.split('_')[2] == doc!['diaryId'];
          });

          final otherUserReaction = int.tryParse(diaryId.substring(0, 1)) ?? 0;
          final otherUserLikedAt = diaryId.substring(2, 12);

          return Diary.fromJsonDB(doc?.data() as Map<String, dynamic>,
              otherUserReaction, otherUserLikedAt);
        }).toList();

        likedDiaryListDates.add(todayKey);

        List<String> jsonMessages =
        likedDiaryList.map((m) => jsonEncode(m.toJson())).toList();
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
    final uid = userId;
    if (uid != null && uid.isNotEmpty) {
      DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(uid);

      String dateString =
          "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

      String formattedId = "${prefixNumber}_${dateString}_${likedDiary.diaryId}";

      await userDocRef.update({
        'likedDiaryId': FieldValue.arrayUnion([formattedId])
      });

      dev.log('Added formatted likedDiary id $formattedId to Firestore');

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // ✅ FIX: 끝에 } 제거
      String todayKey = '${uid}_likedDiaryList_$dateString';

      List<String>? storedMessages = prefs.getStringList(todayKey);
      List<Diary> todayMessages = [];

      if (storedMessages != null) {
        todayMessages = storedMessages.map((jsonMessage) {
          final decodedJson = jsonDecode(jsonMessage);
          return Diary.fromJsonLocal(
            decodedJson,
            decodedJson['otherUserReaction'],
            formattedId.substring(2, 12),
          );
        }).toList();
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
    final uid = userId;
    if (uid != null && uid.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keys = prefs
          .getKeys()
          .where((key) => key.startsWith('${uid}_likedDiaryList_'))
          .toList();

      if (keys.isNotEmpty) {
        keys.sort();
        for (String key in keys.reversed) {
          if (!likedDiaryListDates.contains(key)) {
            List<String>? jsonMessages = prefs.getStringList(key);
            if (jsonMessages != null) {
              List<Diary> additionalMessages = jsonMessages.map((jsonMessage) {
                final jsonMap = jsonDecode(jsonMessage);
                return Diary.fromJsonLocal(jsonMap, jsonMap['otherUserReaction'],
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
        dev.log('there is no ${uid}_likedDiaryList_');
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
    final uid = userId;
    if (uid != null && uid.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keys = prefs
          .getKeys()
          .where((key) => key.startsWith('${uid}_letterList_'))
          .toList();

      if (keys.isNotEmpty) {
        keys.sort();
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
    final uid = userId;
    if (uid != null && uid.isNotEmpty) {
      dev.log('trying to fetch letter from DB');
      letterListDates.clear();
      letterList.clear();

      try {
        loadLetterDataOnce = true;
        final FirebaseFirestore firestore = FirebaseFirestore.instance;
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        String todayKey =
            '${uid}_letterList_${DateTime.now().toIso8601String().substring(0, 10)}';

        QuerySnapshot lettersSnapshot = await firestore
            .collection('users')
            .doc(uid)
            .collection('letters')
            .orderBy('date', descending: true)
            .get();

        if (lettersSnapshot.docs.isEmpty) {
          dev.log('No letters found for user.');
          return;
        }

        letterList =
            lettersSnapshot.docs.map((doc) => Letter.fromJsonDB(doc.data() as Map<String, dynamic>)).toList();

        letterListDates.add(todayKey);

        List<String> jsonMessages =
        letterList.map((m) => jsonEncode(m.toJson())).toList();
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

  /// ✅ FIXED:
  /// - late newLetter 제거
  /// - Letter? 안전 처리
  /// - setNewLetter(letter)로 저장
  Future<Tuple<bool, Letter?>> checkForNewLetterNewNotificationsAndSaveLetterToLocal() async {
    bool newLetterAvailable = false;
    final uid = userId;

    if (uid == null || uid.isEmpty) {
      dev.log('there is no firebase uid');
      return Tuple(false, null);
    }

    loadNewLetterAndNotificationsDataOnce = true;

    final userDoc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();

    dev.log('check for new letter and new notifications are arrived');

    if (userDoc.exists) {
      final data = userDoc.data()!;
      newLetterAvailable = data['newLetterAvailable'] == true;
      isNewNotifications = data['newNotificationsAvailable'] == true;
    }

    notifyListeners();

    if (!newLetterAvailable) {
      dev.log('there is no new letter');
      clearNewLetter();
      return Tuple(false, null);
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('letters')
        .orderBy('date', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      dev.log('there is new letter but cannot find new letter querySnapshot');
      clearNewLetter();
      return Tuple(false, null);
    }

    // ✅ 새 편지 로드
    final letter = Letter.fromSnapshot(querySnapshot.docs.first);
    setNewLetter(letter);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String todayKey =
        '${uid}_letterList_${DateTime.now().toIso8601String().substring(0, 10)}';

    List<String>? storedMessages = prefs.getStringList(todayKey);
    List<Letter> todayMessages = [];

    if (storedMessages != null) {
      todayMessages = storedMessages
          .map((jsonMessage) => Letter.fromJsonLocal(jsonDecode(jsonMessage)))
          .toList();
    }

    todayMessages.add(letter);
    letterList.add(letter);

    List<String> jsonMessages =
    todayMessages.map((message) => jsonEncode(message.toJson())).toList();
    await prefs.setStringList(todayKey, jsonMessages);

    dev.log(
        'save letter to local for date ${todayKey.split('_').skip(1).join('_')}');

    // ✅ 유저의 새 편지 변수 초기화
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'newLetterAvailable': false,
    });

    dev.log('update "newLetterAvailable" field from user document');

    notifyListeners();
    return Tuple(true, letter);
  }

  // load more letter from past
  Future<bool> loadMoreLetter() async {
    final uid = userId;
    if (uid != null && uid.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keys = prefs
          .getKeys()
          .where((key) => key.startsWith('${uid}_letterList_'))
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
        dev.log('there is no ${uid}_letterList_');
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
    final uid = userId;
    if (uid != null && uid.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> keys = prefs
          .getKeys()
          .where((key) => key.startsWith('${uid}_likedDiaryList_'))
          .toList();
      for (String key in keys) {
        await prefs.remove(key);
      }

      keys = prefs
          .getKeys()
          .where((key) => key.startsWith('${uid}_letterList_'))
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

      clearNewLetter();

      notifyListeners();

      dev.log('delete liked Diary and Letter from local');
    } else {
      dev.log('there is no firebase uid');
    }
  }

  void updateNotificationsDataToDB() async {
    final uid = userId;
    if (uid == null || uid.isEmpty) {
      dev.log('there is no firebase uid');
      return;
    }

    if (isNewNotifications) {
      isNewNotifications = false;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'newNotificationsAvailable': false,
      });

      var docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
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
    final yearRegExp = RegExp(r'^\d{4}[년\.\-\s]+');
    String titleWithoutYear = fullTitle.replaceFirst(yearRegExp, '').trim();

    final monthRegExp = RegExp(r'(\d+)월');
    final match = monthRegExp.firstMatch(titleWithoutYear);

    if (match == null) return titleWithoutYear;

    String monthNum = match.group(1)!;
    int monthInt = int.parse(monthNum);

    switch (localeCode) {
      case 'ko':
        return titleWithoutYear.replaceFirst('월', '월의');

      case 'enUs':
      case 'en':
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
        return 'Letter of $monthName';

      default:
        return titleWithoutYear;
    }
  }

  // for Calendar selection
  DateTime CalendarSelectedDate = DateTime.now();

  void updateCalendarSelectedDate(DateTime value) {
    CalendarSelectedDate = value;
    notifyListeners();
  }
}
