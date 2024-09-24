import 'package:bandi_official/components/loading/loading_page.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/mail/letters_view.dart';
import 'package:bandi_official/view/mail/liked_diary_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

class EveryMailPage extends StatefulWidget {
  const EveryMailPage({super.key});

  @override
  State<EveryMailPage> createState() => _EveryMailPageState();
}

class _EveryMailPageState extends State<EveryMailPage> {
  late MailController mailController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      mailController = Provider.of<MailController>(context, listen: false);

      mailController.loadDataAndSetting().then((value) {
        mailController.restoreEveryMailScrollPosition();

        if (!mailController.isEveryMailListenerAdded) {
          // when screen reached nearly bottom of the list load more past data
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            mailController.everyMailScrollController
                .addListener(_scrollListener);
            mailController.toggleIsEveryMailListenerAdded(true);
          });
        }
      });
    });

    super.initState();
  }

  void _scrollListener() async {
    final position = mailController.everyMailScrollController.position;
    if ((mailController.loadMoreLetterData ||
            mailController.loadMoreLikedDiaryData) &&
        position.atEdge &&
        position.pixels != 0) {
      if (position.userScrollDirection == ScrollDirection.reverse &&
          position.maxScrollExtent - position.pixels <= 300) {
        if (mailController.loadMoreLetterData) {
          mailController
              .toggleLoadMoreLetterData(await mailController.loadMoreLetter());
        }
        if (mailController.loadMoreLikedDiaryData) {
          mailController.toggleLoadMoreLikedDiaryData(
              await mailController.loadMoreLikedDiary());
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mailController.toggleIsEveryMailListenerAdded(false);
      mailController.everyMailScrollController.removeListener(_scrollListener);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MailController mailController = context.watch<MailController>();

    // 병합된 리스트 생성 및 정렬
    final combinedList = <Map<String, dynamic>>[];

    for (var letter in mailController.letterList) {
      combinedList
          .add({'type': 'letter', 'data': letter, 'timestamp': letter.date});
    }

    for (var diary in mailController.likedDiaryList) {
      combinedList.add({
        'type': 'diary',
        'data': diary,
        'timestamp': Timestamp.fromDate(DateTime.parse(diary.otherUserLikedAt))
      });
    }

    // 최신순으로 정렬
    combinedList.sort((a, b) {
      Timestamp timestampA = a['timestamp'];
      Timestamp timestampB = b['timestamp'];

      return timestampB.compareTo(timestampA);
    });

    return (mailController.isLoading)
        ? const MyFireFlyProgressbar(
            loadingText: '로딩 중...',
          )
        : (mailController.letterList.isEmpty &&
                mailController.likedDiaryList.isEmpty)
            ? Center(
                child: Text(
                  '보관함이 비었습니다',
                  style: BandiFont.headlineMedium(context)?.copyWith(
                    color: BandiColor.neutralColor80(context),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ListView.builder(
                  controller: mailController.everyMailScrollController,
                  itemCount: combinedList.length,
                  itemBuilder: (context, index) {
                    final item = combinedList[index];
                    if (item['type'] == 'letter') {
                      final Letter letter = item['data'];
                      return lettersWidget(letter, mailController, context);
                    } else if (item['type'] == 'diary') {
                      final Diary diary = item['data'];
                      return likedDiaryWidget(diary, mailController, context);
                    }
                    return const SizedBox
                        .shrink(); // This should never be reached
                  },
                ),
              );
  }
}
