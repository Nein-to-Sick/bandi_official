import 'package:bandi_official/components/loading/loading_page.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/mail/detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

class LikedDiaryPage extends StatefulWidget {
  const LikedDiaryPage({super.key});

  @override
  State<LikedDiaryPage> createState() => _LikedDiaryPageState();
}

class _LikedDiaryPageState extends State<LikedDiaryPage> {
  bool loadMoreData = true;

  Widget filterChips(MailController mailController) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 10.0,
        runSpacing: 8.0,
        children: mailController.chipLabels.map((label) {
          return IntrinsicWidth(
            child: GestureDetector(
              onTap: () {
                mailController.updateFilter(label);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: (mailController
                              .chipLabels[mailController.filteredKeywordValue]
                              .compareTo(label) ==
                          0)
                      ? BandiColor.foundationColor40(context)
                      : BandiColor.neutralColor10(context),
                  borderRadius: BorderRadius.circular(100),
                ),
                constraints: const BoxConstraints(
                  minHeight: 29,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: BandiFont.labelLarge(context)?.copyWith(
                        color: (mailController.chipLabels[
                                        mailController.filteredKeywordValue]
                                    .compareTo(label) ==
                                0)
                            ? BandiColor.neutralColor100(context)
                            : BandiColor.neutralColor60(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      MailController mailController =
          Provider.of<MailController>(context, listen: false);

      mailController.loadDataAndSetting();
      mailController.restoreLikedDiaryScrollPosition();

      // when screen reached nearly top of the list load more past data
      mailController.likedDiaryScrollController.addListener(() async {
        final position = mailController.likedDiaryScrollController.position;
        if (loadMoreData && position.atEdge && position.pixels != 0) {
          if (position.userScrollDirection == ScrollDirection.reverse &&
              position.maxScrollExtent - position.pixels <= 300) {
            loadMoreData = await mailController.loadMoreLikedDiary();
          }
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MailController mailController = context.watch<MailController>();

    return (mailController.isLoading)
        ? const MyFireFlyProgressbar(
            loadingText: '로딩 중...',
          )
        : Column(
            children: [
              const SizedBox(height: 16),
              filterChips(mailController),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ListView.builder(
                    controller: mailController.likedDiaryScrollController,
                    itemCount: mailController.likedDiaryList.length,
                    itemBuilder: (context, index) {
                      Diary diary = mailController.likedDiaryList[
                          mailController.likedDiaryList.length - index - 1];
                      return likedDiaryWidget(diary, mailController, context);
                    },
                  ),
                ),
              ),
            ],
          );
  }
}

Widget likedDiaryWidget(
    Diary diary, MailController mailController, BuildContext context) {
  String combinedEmotions = (diary.emotion).join(', ');
  return (mailController.currentIndex == 0 ||
          mailController.filteredKeywordValue == 0 ||
          mailController.filteredKeywordValue == diary.otherUserReaction + 1)
      ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: GestureDetector(
            // 일기 열람 기능 추가
            onTap: () {
              mailController.toggleDetailView(true);
              showDialog(
                context: context,
                barrierDismissible: false,
                barrierColor: BandiColor.transparent(context),
                builder: (BuildContext context) {
                  return DetailView(
                    item: diary,
                    mailController: mailController,
                  );
                },
              );
            },
            child: Container(
              color: BandiColor.transparent(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(diary.title,
                      style: BandiFont.headlineMedium(context)?.copyWith(
                          color: BandiColor.neutralColor100(context))),
                  const SizedBox(height: 8),
                  Text(
                    diary.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: BandiFont.headlineSmall(context)
                        ?.copyWith(color: BandiColor.neutralColor60(context)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        diary.otherUserLikedAt,
                        style: BandiFont.headlineSmall(context)?.copyWith(
                            color: BandiColor.neutralColor60(context)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          combinedEmotions,
                          style: BandiFont.headlineSmall(context)?.copyWith(
                              color: BandiColor.neutralColor60(context)),
                          overflow: TextOverflow.ellipsis,
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
        )
      : const SizedBox.shrink();
}
