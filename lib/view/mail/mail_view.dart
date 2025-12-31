import 'dart:ui';

import 'package:bandi_official/components/appbar/new_custom_appbar.dart';
import 'package:bandi_official/components/bottom_sheet/calendar_bottom_sheet.dart';
import 'package:bandi_official/main.dart';
import 'package:bandi_official/view/alarm/controller/alarm_controller.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
// import 'package:bandi_official/view/mail/every_mail_view.dart';
import 'package:bandi_official/view/mail/letters_view.dart';
import 'package:bandi_official/view/mail/liked_diary_view.dart';
import 'package:bandi_official/view/mail/new_letter_popup.dart';
import 'package:bandi_official/view/mail/widget/liked_diary_action_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

class MailView extends StatefulWidget {
  const MailView({super.key});

  @override
  State<MailView> createState() => _MailViewState();
}

class _MailViewState extends State<MailView>
    with SingleTickerProviderStateMixin {
  MailController? mailController;

  @override
  void initState() {
    super.initState();
    mailController = Provider.of<MailController>(context, listen: false);

    // InitState of the ScrollControllers
    mailController!
        .initTabController(this, 2, mailController!.savedCurrentIndex);

    // InitState of the TabController
    mailController?.initScrollControllers();
  }

  @override
  void dispose() {
    // Dispose of the ScrollControllers
    // mailController!.everyMailScrollController.dispose();
    mailController!.letterScrollController.dispose();
    mailController!.likedDiaryScrollController.dispose();

    // Dispose of the TabController
    mailController!.tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MailController mailController = context.watch<MailController>();
    // AlarmController alarmController = context.watch<AlarmController>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: BandiColor.transparent(context),
        appBar: NewCustomAppBar(
          appBarType: AppBarType.subtitleNeutral,
          title: 'inbox_title'.tr(context),
          leftActionButtonIcon: (mailController.tabController.index == 1)
              ? PhosphorIcons.funnelSimple(PhosphorIconsStyle.thin)
              : null,
          leftActionButtonColor: (mailController.filteredchipLabels.length != 3)
              ? BandiColor.accentColorYellow(context)
              : null,
          rightActionButtonIcon:
              PhosphorIcons.calendarBlank(PhosphorIconsStyle.thin),
          onLeftActionButtonPressed: () async {
            await showLikedDiaryActionSheet(context, mailController);

            // For alarm test
            /*
            messageTestFunction(alarmController);
            For test delete finction
            mailController.deleteEveryMailDataFromLocal();
            For new Letter pop page test
            newLetterPopUpPageTestFunction(context);
            */
          },
          onRightActionButtonPressed: () {
            CalendarBottomSheet(
              initialDate: mailController.calenderSelectedDate,
              mode: (mailController.tabController.index == 1)
                  ? CalendarMode.date
                  : CalendarMode.month,
              eventDates: [
                DateTime(2025, 12, 31),
              ],
              onDateSelected: (date) {
                (mailController.tabController.index == 1)
                    ? dev
                        .log("선택된 월: ${date.year}년 ${date.month}월 ${date.day}일")
                    : dev.log("선택된 월: ${date.year}년 ${date.month}월");

                mailController.updateCalenderSelectedDate(date);
              },
            ).show(context);
          },
          disableLefttActionButton: false,
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 0, left: 24, right: 24),
          child: Stack(
            children: [
              TabBarView(
                controller: mailController.tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  // EveryMailPage(),
                  MyLettersPage(),
                  LikedDiaryPage(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 112),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildCustomToggle(
                    context,
                    mailController,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildCustomToggle(BuildContext context, MailController controller) {
  return ClipRRect(
    borderRadius: BandiEffects.radiusLarge,
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: BandiEffects.blurSmall,
        sigmaY: BandiEffects.blurSmall,
      ),
      child: Container(
        width: 239,
        height: 40,
        decoration: BoxDecoration(
          color: BandiColor.foundationColor40(context),
          borderRadius: BandiEffects.radiusLarge,
        ),
        child: Stack(
          children: [
            // 슬라이딩되는 선택 배경
            AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              alignment: Alignment(
                controller.tabController.index == 0 ? -1.0 : 1.0,
                0,
              ),
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: BandiColor.neutralColor10(context),
                    borderRadius: BandiEffects.radiusLarge,
                  ),
                ),
              ),
            ),
            // 탭 버튼들
            Row(
              children: List.generate(
                2,
                (index) {
                  bool isSelected = controller.tabController.index == index;
                  String label = index == 0 ? '편지' : '나눔 일기';

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        controller.tabController.animateTo(index);
                      },
                      child: Center(
                        child: Text(
                          label,
                          style: BandiFont.bodyMedium(context)?.copyWith(
                            color: isSelected
                                ? BandiColor.neutralColor70(context)
                                : BandiColor.neutralColor40(context),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void messageTestFunction(AlarmController alarmController) {
  // receiver fcm token
  String fcmToken = '';
  // receiver user Id
  String userId = '';
  // sender user Id
  String testLikedDiaryId = '21jPhIHrf7iBwVAh92ZW1';

  alarmController.sendLikedDiaryNotification(
      testLikedDiaryId, fcmToken, userId);
}

void newLetterPopUpPageTestFunction(BuildContext context) {
  Letter letter = Letter(
    title: 'title',
    content: 'content',
    date: Timestamp.now(),
    letterId: 'letterId',
  );
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          NewLetterPopuView(newLetter: letter),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    ),
  );
}
