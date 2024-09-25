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
  late MailController mailController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      mailController = Provider.of<MailController>(context, listen: false);

      mailController.loadDataAndSetting().then((value) {
        mailController.restoreLetterScrollPosition();

        if (!mailController.isLettersListenerAdded) {
          // when screen reached nearly bottom of the list load more past data
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            mailController.letterScrollController.addListener(_scrollListener);
            mailController.toggleIsLettersListenerAdded(true);
          });
        }
      });
    });

    super.initState();
  }

  void _scrollListener() async {
    final position = mailController.letterScrollController.position;
    if (mailController.loadMoreLetterData &&
        position.atEdge &&
        position.pixels != 0) {
      if (position.userScrollDirection == ScrollDirection.reverse &&
          position.maxScrollExtent - position.pixels <= 300) {
        mailController
            .toggleLoadMoreLetterData(await mailController.loadMoreLetter());
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mailController.letterScrollController.removeListener(_scrollListener);
      mailController.toggleIsLettersListenerAdded(false);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MailController mailController = context.watch<MailController>();
    return (mailController.isLoading)
        ? const MyFireFlyProgressbar(
            loadingText: '로딩 중...',
          )
        : (mailController.letterList.isEmpty)
            ? Center(
                child: Text(
                  '편지가 없습니다',
                  style: BandiFont.headlineMedium(context)?.copyWith(
                    color: BandiColor.neutralColor80(context),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ListView.builder(
                  controller: mailController.letterScrollController,
                  itemCount: mailController.letterList.length,
                  itemBuilder: (context, index) {
                    Letter letter = mailController.letterList[
                        mailController.letterList.length - index - 1];
                    return lettersWidget(letter, mailController, context);
                  },
                ),
              );
  }
}

Widget lettersWidget(
    Letter letter, MailController mailController, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: GestureDetector(
      onTap: () {
        mailController.toggleDetailView(true);
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: BandiColor.transparent(context),
          builder: (BuildContext context) {
            return DetailView(
              item: letter,
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
