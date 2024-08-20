import 'package:bandi_official/components/loading/loading_page.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/mail/detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

class MyLettersPage extends StatefulWidget {
  const MyLettersPage({super.key});

  @override
  State<MyLettersPage> createState() => _MyLettersPageState();
}

class _MyLettersPageState extends State<MyLettersPage> {
  bool loadMoreData = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      MailController mailController =
          Provider.of<MailController>(context, listen: false);

      mailController.loadDataAndSetting();

      // when screen reached nearly top of the list load more past data
      mailController.letterScrollController.addListener(() async {
        final position = mailController.letterScrollController.position;
        if (loadMoreData && position.atEdge && position.pixels != 0) {
          if (position.userScrollDirection == ScrollDirection.reverse &&
              position.maxScrollExtent - position.pixels <= 300) {
            loadMoreData = await mailController.loadMoreLetter();
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
        : Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ListView.builder(
              controller: mailController.letterScrollController,
              itemCount: mailController.letterList.length,
              itemBuilder: (context, index) {
                Letter letter = mailController.letterList[index];
                return lettersWidget(letter, context);
              },
            ),
          );
  }
}

Widget lettersWidget(Letter letter, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: GestureDetector(
      // 편지 열람 기능 추가
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          builder: (BuildContext context) {
            return DetailView(
              item: letter,
            );
          },
        );
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(letter.title,
                style: BandiFont.headlineMedium(context)
                    ?.copyWith(color: BandiColor.neutralColor100(context))),
            const SizedBox(height: 8),
            Text(
              letter.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: BandiFont.headlineSmall(context)
                  ?.copyWith(color: BandiColor.neutralColor60(context)),
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
