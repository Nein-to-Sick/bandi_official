import 'package:bandi_official/components/loading/loading_page.dart';
import 'package:bandi_official/view/home/write_diary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../controller/home_to_write.dart';
import '../../controller/navigation_toggle_provider.dart';
import '../../model/diary.dart';
import '../../theme/custom_theme_data.dart';

class DiaryList extends StatelessWidget {
  final DateTime? selectedDate;

  const DiaryList({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final userId = '21jPhIHrf7iBwVAh92ZW'; // 예시 사용자 ID, 실제로는 사용자 인증을 통해 가져와야 함
    final writeProvider = Provider.of<HomeToWrite>(context);
    final navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);

    Query diaryQuery = FirebaseFirestore.instance
        .collection('allDiary')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: userId)
        .where(FieldPath.documentId, isLessThan: '$userId\uf8ff')
        .orderBy('createdAt', descending: true);

    // 필터링된 날짜가 있다면 해당 날짜의 일기만 필터링
    if (selectedDate != null) {
      final startOfDay =
          DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      diaryQuery = diaryQuery
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: diaryQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: MyFireFlyProgressbar(loadingText: '로딩 중...'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('일기가 없습니다.'));
        }

        final diaryDocs = snapshot.data!.docs;
        List<Map<String, dynamic>> groupedDiaries = [];
        String lastDisplayedMonth = '';

        for (var doc in diaryDocs) {
          final diaryData = doc.data() as Map<String, dynamic>;
          DateTime createdAt = (diaryData['createdAt'] as Timestamp).toDate();
          String currentMonth;
          if (selectedDate != null) {
            currentMonth = DateFormat('yyyy년 M월 d일').format(selectedDate!);
          } else {
            currentMonth = DateFormat('yyyy년 M월').format(createdAt);
          }
          if (currentMonth != lastDisplayedMonth) {
            groupedDiaries.add({'isHeader': true, 'header': currentMonth});
            lastDisplayedMonth = currentMonth;
          }
          groupedDiaries.add(
              {'isHeader': false, 'data': diaryData, 'createdAt': createdAt});
        }

        return ListView.builder(
          itemCount: groupedDiaries.length,
          itemBuilder: (context, index) {
            final item = groupedDiaries[index];

            if (item['isHeader']) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 18, top: 10),
                child: Center(
                    child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: BandiColor.foundationColor40(context)),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 31),
                    child: Text(item['header'],
                        style: BandiFont.headlineSmall(context)?.copyWith(
                            color: BandiColor.neutralColor100(context))),
                  ),
                )),
              );
            } else {
              final diaryData = item['data'] as Map<String, dynamic>;
              DateTime createdAt = item['createdAt'] as DateTime;

              // Combine the emotions with a space in between
              String combinedEmotions =
                  (diaryData['emotion'] as List<dynamic>).join(', ');

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
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
                        cheerText: diaryData['cheerText']);
                    writeProvider.readMyDiary(diary);
                    navigationToggleProvider.selectIndex(0);
                    writeProvider.toggleWrite();
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(diaryData['title'] ?? '제목 없음',
                            style: BandiFont.headlineMedium(context)?.copyWith(
                                color: BandiColor.neutralColor100(context))),
                        const SizedBox(height: 8),
                        Text(
                          diaryData['content'] ?? '내용 없음',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: BandiFont.headlineSmall(context)?.copyWith(
                              color: BandiColor.neutralColor60(context)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              DateFormat('yyyy.M.d').format(createdAt),
                              style: BandiFont.headlineSmall(context)?.copyWith(
                                  color: BandiColor.neutralColor60(context)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                combinedEmotions,
                                style: BandiFont.headlineSmall(context)
                                    ?.copyWith(
                                        color:
                                            BandiColor.neutralColor60(context)),
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
                              style: BandiFont.labelSmall(context)?.copyWith(
                                  color: BandiColor.neutralColor60(context)),
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
                              style: BandiFont.labelSmall(context)?.copyWith(
                                  color: BandiColor.neutralColor60(context)),
                            ),
                            const SizedBox(width: 7),
                            PhosphorIcon(
                                PhosphorIcons.personArmsSpread(
                                    PhosphorIconsStyle.fill),
                                color: BandiColor.neutralColor60(context),
                                size: 12),
                            const SizedBox(width: 4),
                            Text(
                              diaryData['reaction'][2].toString(),
                              style: BandiFont.labelSmall(context)?.copyWith(
                                  color: BandiColor.neutralColor60(context)),
                            )
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
          },
        );
      },
    );
  }
}
