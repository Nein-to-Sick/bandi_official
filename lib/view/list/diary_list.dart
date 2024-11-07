import 'package:bandi_official/components/loading/loading_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../controller/home_to_write.dart';
import '../../controller/navigation_toggle_provider.dart';
import '../../model/diary.dart';
import '../../theme/custom_theme_data.dart';

class DiaryList extends StatefulWidget {
  final DateTime? selectedDate;

  const DiaryList({super.key, this.selectedDate});

  @override
  State<DiaryList> createState() => _DiaryListState();
}

class _DiaryListState extends State<DiaryList> {
  final int _limit = 4;
  final List<Map<String, dynamic>> _groupedDiaries = [];
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  DocumentSnapshot? _lastDocument;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initialLoadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant DiaryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      // 날짜가 변경될 때 데이터를 다시 로드합니다.
      _resetAndLoadData();
    }
  }

  void _resetAndLoadData() {
    setState(() {
      _groupedDiaries.clear();
      _lastDocument = null;
      _hasMore = true;
      _isInitialLoading = true;
    });
    _initialLoadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _loadMoreData(false);
    }
  }

  Future<void> _initialLoadData() async {
    await _loadMoreData(true);
    setState(() {
      _isInitialLoading = false;
    });
  }

  Future<void> _loadMoreData(bool first) async {
    if (!_hasMore || _isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final userId = FirebaseAuth.instance.currentUser!.uid;
    Query query = FirebaseFirestore.instance
        .collection('allDiary')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: userId)
        .where(FieldPath.documentId, isLessThan: '$userId\uf8ff')
        .orderBy('createdAt', descending: true)
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    if (widget.selectedDate != null) {
      final startOfDay = DateTime(widget.selectedDate!.year,
          widget.selectedDate!.month, widget.selectedDate!.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay));
    }

    final QuerySnapshot querySnapshot = await query.get();
    if (querySnapshot.docs.isNotEmpty) {
      _processNewDiaries(querySnapshot.docs, first);
      setState(() {
        _lastDocument = querySnapshot.docs.last;
        _hasMore = querySnapshot.docs.length == _limit;
        _isLoading = false;
      });
    } else {
      setState(() {
        _hasMore = false;
        _isLoading = false;
      });
    }
  }

  void _processNewDiaries(List<QueryDocumentSnapshot> newDocs, bool first) {
    String lastDisplayedMonth =
        _groupedDiaries.isNotEmpty && _groupedDiaries.last['isHeader'] == false
            ? DateFormat('yyyy년 M월')
                .format((_groupedDiaries.last['createdAt'] as DateTime))
            : '';

    for (var doc in newDocs) {
      final diaryData = doc.data() as Map<String, dynamic>;
      DateTime createdAt = (diaryData['createdAt'] as Timestamp).toDate();
      String currentMonth;
      if (widget.selectedDate != null) {
        currentMonth = DateFormat('yyyy년 M월 d일').format(widget.selectedDate!);
      } else {
        currentMonth = DateFormat('yyyy년 M월').format(createdAt);
      }

      if (currentMonth != lastDisplayedMonth && first) {
        _groupedDiaries.add({'isHeader': true, 'header': currentMonth});
        lastDisplayedMonth = currentMonth;
      }
      _groupedDiaries
          .add({'isHeader': false, 'data': diaryData, 'createdAt': createdAt});
    }
  }

  @override
  Widget build(BuildContext context) {
    final writeProvider = Provider.of<HomeToWrite>(context);
    final navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);

    if (_isInitialLoading) {
      return const Center(
        child: MyFireFlyProgressbar(loadingText: '로딩 중...'),
      );
    }

    return _groupedDiaries.isEmpty
        ? noDiary(context, widget.selectedDate ?? DateTime(1999,1,1))
        : ListView.builder(
            controller: _scrollController,
            itemCount: _groupedDiaries.length + 1,
            itemBuilder: (context, index) {
              if (index < _groupedDiaries.length) {
                final item = _groupedDiaries[index];

                if (item['isHeader']) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18, top: 10),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: BandiColor.foundationColor40(context),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 31),
                          child: Text(
                            item['header'],
                            style: BandiFont.headlineSmall(context)?.copyWith(
                              color: BandiColor.neutralColor100(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  final diaryData = item['data'] as Map<String, dynamic>;
                  DateTime createdAt = item['createdAt'] as DateTime;
                  String combinedEmotions =
                      (diaryData['emotion'] as List<dynamic>).join(', ');

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 24.0),
                    child: GestureDetector(
                      onTap: () {
                        Diary diary = Diary(
                          userId: diaryData['userId'],
                          title: diaryData['title'],
                          content: diaryData['content'],
                          emotion: diaryData['emotion'],
                          createdAt: diaryData['createdAt'],
                          updatedAt: diaryData['updatedAt'],
                          reaction: diaryData['reaction'],
                          diaryId: diaryData['diaryId'],
                          cheerText: diaryData['cheerText'],
                        );
                        writeProvider.readMyDiary(diary);
                        navigationToggleProvider.selectIndex(0);
                        writeProvider.toggleWrite();
                      },
                      child: Container(
                        color: BandiColor.transparent(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              diaryData['title'] ?? '제목 없음',
                              style:
                                  BandiFont.headlineMedium(context)?.copyWith(
                                color: BandiColor.neutralColor100(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              diaryData['content'] ?? '내용 없음',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: BandiFont.headlineSmall(context)?.copyWith(
                                color: BandiColor.neutralColor60(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  DateFormat('yyyy.M.d').format(createdAt),
                                  style: BandiFont.headlineSmall(context)
                                      ?.copyWith(
                                    color: BandiColor.neutralColor60(context),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    combinedEmotions,
                                    style: BandiFont.headlineSmall(context)
                                        ?.copyWith(
                                      color: BandiColor.neutralColor60(context),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                PhosphorIcon(
                                  PhosphorIcons.gift(),
                                  size: 12,
                                  color: BandiColor.neutralColor60(context),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  diaryData['reaction'][0].toString(),
                                  style:
                                      BandiFont.labelSmall(context)?.copyWith(
                                    color: BandiColor.neutralColor60(context),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                PhosphorIcon(
                                  PhosphorIcons.heart(),
                                  size: 12,
                                  color: BandiColor.neutralColor60(context),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  diaryData['reaction'][1].toString(),
                                  style:
                                      BandiFont.labelSmall(context)?.copyWith(
                                    color: BandiColor.neutralColor60(context),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                PhosphorIcon(
                                  PhosphorIcons.personArmsSpread(
                                      PhosphorIconsStyle.fill),
                                  color: BandiColor.neutralColor60(context),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  diaryData['reaction'][2].toString(),
                                  style:
                                      BandiFont.labelSmall(context)?.copyWith(
                                    color: BandiColor.neutralColor60(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(
                              color: BandiColor.neutralColor20(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              } else if (_hasMore) {
                return const Padding(
                  padding: EdgeInsets.all(0),
                  child: Center(
                    child: SizedBox(
                        width: 40,
                        child: MyFireFlyProgressbar(loadingText: '')),
                  ),
                );
              } else {
                return Center(
                    child: Text('끝',
                        style: BandiFont.headlineMedium(context)?.copyWith(
                          color: BandiColor.neutralColor60(context),
                        )));
              }
            },
          );
  }
}

Widget noDiary(context, DateTime date) {
  return Stack(
    children: [
      date == DateTime(1999, 1, 1) ? Container() : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 18, top: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: BandiColor.foundationColor40(context),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 5, horizontal: 31),
                child: Text(
                  DateFormat('yyyy년 M월 d일').format(date),
                  style: BandiFont.headlineSmall(context)?.copyWith(
                    color: BandiColor.neutralColor100(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      Center(
          child: Text('일기가 없습니다',
              style: BandiFont.headlineMedium(context)?.copyWith(
                color: BandiColor.neutralColor60(context),
              ))),
    ],
  );
}