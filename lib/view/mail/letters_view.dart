import 'package:bandi_official/analytics/log_other_journal_search.dart';
import 'package:bandi_official/components/loading/loading_page.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/mail/detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
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
        ? MyFireFlyProgressbar(
            loadingText: 'loading'.tr(context),
          )
        : (mailController.letterList.isEmpty)
            ? Center(
                child: Text(
                  'inbox_no_letters'.tr(context),
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
                    return lettersWidget(
                        index, letter, mailController, context);
                  },
                ),
              );
  }
}

Widget lettersWidget(int num, Letter letter, MailController mailController,
    BuildContext context) {
  String title = mailController.formatMailTitle(
      letter.title, 'detail_view_date_form_country'.tr(context));
  String date = DateFormat('detail_view_letter_date_form'.tr(context),
          'detail_view_date_form_country'.tr(context))
      .format(letter.date.toDate());
  String numbering = (num + 1).toString().padLeft(3, '0');

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: GestureDetector(
      onTap: () {
        logOtherJournalSearch(journalType: 'letters');
        mailController.toggleDetailView(true);
        DetailViewSheet(item: letter, mailController: mailController)
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
            bottom:
                BorderSide(color: BandiColor.neutralColor20(context), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$numbering. $title',
                style: BandiFont.titleSmall(context)
                    ?.copyWith(color: BandiColor.neutralColor90(context))),
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
  );
}
