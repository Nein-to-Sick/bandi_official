import 'package:bandi_official/components/button/primary_button.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailView extends StatelessWidget {
  final Object item;
  final MailController mailController;
  const DetailView(
      {super.key, required this.item, required this.mailController});

  @override
  Widget build(BuildContext context) {
    String title = '';
    String date = '';
    String content = '';

    if (item is Letter) {
      Letter letter = item as Letter;
      title = 'detail_view_letter_title'.tr(context);
      date = DateFormat('detail_view_letter_date_form'.tr(context),
              'detail_view_date_form_country'.tr(context))
          .format(letter.date.toDate());
      content = letter.content;
    } else if (item is Diary) {
      Diary diary = item as Diary;
      title = diary.title;
      DateTime dateTime =
          DateFormat('yyyy-MM-dd').parse(diary.otherUserLikedAt);
      date =
          '${'detail_view_header_1'.tr(context)}: ${DateFormat('detail_view_diary_date_form'.tr(context), 'detail_view_date_form_country'.tr(context)).format(dateTime)}';
      content = diary.content;
    } else {
      title = 'title';
      date = '0000-00-00';
      content = 'test content';
    }

    return PopScope(
      canPop: true,
      onPopInvoked: (value) {
        mailController.toggleDetailView(false);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: BandiColor.neutralColor100(context),
                    borderRadius: BandiEffects.radiusSmall,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 16.0, right: 16.0),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                                onTap: () {
                                  //Navigator.pop(context);
                                },
                                child: const SizedBox.shrink()
                                // PhosphorIcon(
                                //   PhosphorIcons.x(),
                                //   color: BandiColor.foundationColor40(context),
                                // ),
                                ),
                          ),
                        ),
                        Text(
                          title,
                          style: BandiFont.headlineMedium(context)?.copyWith(
                            color: BandiColor.foundationColor100(context),
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          date,
                          style: BandiFont.bodyMedium(context)?.copyWith(
                            color: BandiColor.foundationColor100(context),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Text(
                              content,
                              style: BandiFont.titleSmall(context)?.copyWith(
                                color: BandiColor.foundationColor100(context),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              CustomPrimaryButton(
                title: 'detail_view_button'.tr(context),
                onPrimaryButtonPressed: () {
                  mailController.toggleDetailView(false);
                  Navigator.pop(context);
                },
                disableButton: false,
              )
            ],
          ),
        ),
      ),
    );
  }
}
