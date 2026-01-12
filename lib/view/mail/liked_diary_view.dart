import 'package:bandi_official/analytics/log_other_journal_search.dart';
import 'package:bandi_official/components/loading/loading_page.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/localization/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/mail/detail_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

class LikedDiaryPage extends StatefulWidget {
  const LikedDiaryPage({super.key});

  @override
  State<LikedDiaryPage> createState() => _LikedDiaryPageState();
}

class _LikedDiaryPageState extends State<LikedDiaryPage> {
  late MailController mailController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      mailController = Provider.of<MailController>(context, listen: false);

      mailController.loadDataAndSetting().then((_) {
        if (mailController.likedDiaryScrollController.hasClients) {
          mailController.restoreLikedDiaryScrollPosition();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mailController.likedDiaryScrollController.hasClients) {
              mailController.restoreLikedDiaryScrollPosition();
            }
          });
        }

        if (!mailController.isLikedDiaryListenerAdded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mailController.likedDiaryScrollController.hasClients) {
              mailController.likedDiaryScrollController
                  .addListener(_scrollListener);
              mailController.toggleIsLikedDiaryListenerAdded(true);
            }
          });
        }
      });
    });
  }

  void _scrollListener() async {
    if (!mailController.loadMoreLikedDiaryData ||
        mailController.isLoadingLikedDiary) {
      return;
    }

    final position = mailController.likedDiaryScrollController.position;

    if (position.maxScrollExtent - position.pixels <= 200) {
      bool hasMore = await mailController.loadMoreLikedDiary();
      mailController.toggleLoadMoreLikedDiaryData(hasMore);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mailController.likedDiaryScrollController.removeListener(_scrollListener);
      mailController.toggleIsLikedDiaryListenerAdded(false);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MailController mailController = context.watch<MailController>();

    final allDiaries = mailController.likedDiaryList;
    final DateTime? filterDate = mailController.likedDiaryFilteredDate;

    // 선택된 날짜가 있으면 해당 날짜만, 없으면 전체 리스트
    final displayList = filterDate == null
        ? allDiaries
        : allDiaries.where((diary) {
            // diary.otherUserLikedAt 형식: "2024-07-25"
            String targetDateString =
                filterDate.toIso8601String().substring(0, 10);
            return diary.otherUserLikedAt.startsWith(targetDateString);
          }).toList();

    return (mailController.isLoading)
        ? MyFireFlyProgressbar(
            loadingText: 'loading'.tr(context),
          )
        : (displayList.isEmpty)
            ? _buildEmptyState(filterDate != null, mailController, context)
            : Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ListView.builder(
                  controller: mailController.likedDiaryScrollController,
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        likedDiaryWidget(
                            displayList[index], mailController, context),
                        if (index == displayList.length - 1)
                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 188,
                          )
                      ],
                    );
                  },
                ),
              );
  }
}

// 데이터가 없을 때 표시할 위젯
Widget _buildEmptyState(
    bool isFiltered, MailController mailController, BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'inbox_no_shared_journals'.tr(context),
          textAlign: TextAlign.center,
          style: BandiFont.headlineMedium(context)?.copyWith(
            color: BandiColor.neutralColor80(context),
          ),
        ),
        // const SizedBox(height: 24),
        // if (isFiltered)
        //   TextButton(
        //     onPressed: () => mailController.updateCalendarSelectedDate(null),
        //     child: Text(
        //       'calendar_selection_reset'.tr(context),
        //       style: BandiFont.labelMedium(context)
        //           ?.copyWith(color: BandiColor.neutralColor80(context)),
        //     ),
        //   ),
      ],
    ),
  );
}

Widget likedDiaryWidget(
    Diary diary, MailController mailController, BuildContext context) {
  DateTime parsedDate = DateTime.parse(diary.otherUserLikedAt);

  String date = DateFormat('detail_view_diary_date_form'.tr(context),
          'detail_view_date_form_country'.tr(context))
      .format(parsedDate);

  return (mailController.filteredchipLabels
          .contains(diary.otherUserReaction + 1))
      ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: GestureDetector(
            onTap: () {
              logOtherJournalSearch(journalType: 'others');
              mailController.toggleDetailView(true);
              DetailViewSheet(item: diary, mailController: mailController)
                  .show(context)
                  .then((_) {
                if (context.mounted) {
                  mailController.toggleDetailView(false);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: BandiColor.transparent(context),
                border: Border(
                  bottom: BorderSide(
                      color: BandiColor.neutralColor20(context), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(
                      diary.title,
                      style: BandiFont.titleSmall(context)
                          ?.copyWith(color: BandiColor.neutralColor90(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Text(
                      date,
                      style: BandiFont.labelSmall(context)
                          ?.copyWith(color: BandiColor.neutralColor60(context)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      : const SizedBox.shrink();
}
