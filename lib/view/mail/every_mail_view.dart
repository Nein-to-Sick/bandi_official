import 'package:bandi_official/components/loading/loading_page.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/model/letter.dart';
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
  bool loadMoreLetter = true;
  bool loadMoreLikedDiary = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      MailController mailController =
          Provider.of<MailController>(context, listen: false);

      mailController.loadDataAndSetting();
      mailController.restoreEveryMailScrollPosition();

      // when screen reached nearly top of the list load more past data
      mailController.everyMailScrollController.addListener(() async {
        final position = mailController.everyMailScrollController.position;
        if ((loadMoreLetter || loadMoreLikedDiary) &&
            position.atEdge &&
            position.pixels != 0) {
          if (position.userScrollDirection == ScrollDirection.reverse &&
              position.maxScrollExtent - position.pixels <= 300) {
            if (loadMoreLetter) {
              loadMoreLetter = await mailController.loadMoreLetter();
            }
            if (loadMoreLikedDiary) {
              loadMoreLikedDiary = await mailController.loadMoreLikedDiary();
            }
          }
        }
      });
    });

    super.initState();
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
                return const SizedBox.shrink(); // This should never be reached
              },
            ),
          );
  }
}
