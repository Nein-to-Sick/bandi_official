import 'package:bandi_official/analytics/log_other_journal_search.dart';
import 'package:bandi_official/components/loading/loading_page.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/mail/detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      mailController = Provider.of<MailController>(context, listen: false);

      mailController.loadDataAndSetting().then((value) {
        mailController.restoreLikedDiaryScrollPosition();

        if (!mailController.isLikedDiaryListenerAdded) {
          // when screen reached nearly bottom of the list load more past data
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            mailController.likedDiaryScrollController
                .addListener(_scrollListener);
            mailController.toggleIsLikedDiaryListenerAdded(true);
          });
        }
      });
    });

    super.initState();
  }

  void _scrollListener() async {
    final position = mailController.likedDiaryScrollController.position;
    if (mailController.loadMoreLikedDiaryData &&
        position.atEdge &&
        position.pixels != 0) {
      if (position.userScrollDirection == ScrollDirection.reverse &&
          position.maxScrollExtent - position.pixels <= 300) {
        mailController.toggleLoadMoreLikedDiaryData(
            await mailController.loadMoreLikedDiary());
      }
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

    return (mailController.isLoading)
        ? MyFireFlyProgressbar(
            loadingText: 'loading'.tr(context),
          )
        : (mailController.likedDiaryList.isEmpty)
            ? Center(
                child: Text(
                  'inbox_no_reacted_diaries'.tr(context),
                  style: BandiFont.headlineMedium(context)?.copyWith(
                    color: BandiColor.neutralColor80(context),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ListView.builder(
                  controller: mailController.likedDiaryScrollController,
                  itemCount: mailController.likedDiaryList.length,
                  itemBuilder: (context, index) {
                    Diary diary = mailController.likedDiaryList[
                        mailController.likedDiaryList.length - index - 1];
                    return likedDiaryWidget(diary, mailController, context);
                  },
                ),
              );
  }
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
                  Text(diary.title,
                      style: BandiFont.titleSmall(context)?.copyWith(
                          color: BandiColor.neutralColor90(context))),
                  Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BandiFont.labelSmall(context)
                        ?.copyWith(color: BandiColor.neutralColor60(context)),
                  ),
                ],
              ),
            ),
          ),
        )
      : const SizedBox.shrink();
}
