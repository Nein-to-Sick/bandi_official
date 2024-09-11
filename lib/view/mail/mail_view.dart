import 'package:bandi_official/components/appbar/appbar.dart';
import 'package:bandi_official/controller/alarm_controller.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/mail/every_mail_view.dart';
import 'package:bandi_official/view/mail/letters_view.dart';
import 'package:bandi_official/view/mail/liked_diary_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
        .initTabController(this, 3, mailController!.savedCurrentIndex);

    // InitState of the TabController
    mailController?.initScrollControllers();
  }

  @override
  void dispose() {
    // Dispose of the ScrollControllers
    mailController!.everyMailScrollController.dispose();
    mailController!.letterScrollController.dispose();
    mailController!.likedDiaryScrollController.dispose();

    // Dispose of the TabController
    mailController!.tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MailController mailController = context.watch<MailController>();
    AlarmController alarmController = context.watch<AlarmController>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: BandiColor.transparent(context),
        appBar: CustomAppBar(
          title: '보관함',
          trailingIcon: PhosphorIcons.flask(PhosphorIconsStyle.fill),
          onLeadingIconPressed: () {},
          onTrailingIconPressed: () async {
            // String fcmToken =
            //     'fQ_HW18-Spq8KPbBpgGkHP:APA91bHzJSVXFE0InFxgH60gIfgpxsVB5hFZasiVyW-mQA_ip7CkhJ4BZIlt2HrK0sHX_j24umUok1E3m08diwluFWGadxfY2eCMgNeM208L1mw1vcdq_SMj_kdTvqC-42HqO-rwbp3A';

            // alarmController.sendLikedDiaryNotification('21jPhIHrf7iBwVAh92ZW1',
            //     fcmToken, 'writeProvider.otherDiaryModel.userId');

            // For test delete finction
            // mailController.deleteEveryMailDataFromLocal();

            // For Firebase Function deploy test
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const TestViewPage()),
            // );
          },
          disableLeadingButton: false,
          disableTrailingButton: false,
          isVisibleLeadingButton: false,
          isVisibleTrailingButton: true,
        ),
        body: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.1, top: 10),
          child: DefaultTabController(
            length: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  TabBar(
                    controller: mailController.tabController,
                    labelColor: BandiColor.neutralColor100(context),
                    unselectedLabelColor: BandiColor.neutralColor40(context),
                    labelStyle: BandiFont.headlineMedium(context)?.copyWith(
                      color: BandiColor.neutralColor100(context),
                    ),
                    indicatorColor: BandiColor.neutralColor100(context),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: BandiColor.neutralColor40(context),
                    tabs: const [
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Tab(text: "전체"),
                      ),
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Tab(
                          text: "편지",
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Tab(
                          text: "공감한 일기",
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: mailController.tabController,
                      children: const [
                        EveryMailPage(),
                        MyLettersPage(),
                        LikedDiaryPage(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
