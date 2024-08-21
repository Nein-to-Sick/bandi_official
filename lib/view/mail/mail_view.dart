import 'package:bandi_official/components/appbar/appbar.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/test_view.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/mail/every_mail_view.dart';
import 'package:bandi_official/view/mail/letters_view.dart';
import 'package:bandi_official/view/mail/liked_diary_view.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class MailView extends StatefulWidget {
  const MailView({super.key});

  @override
  State<MailView> createState() => _MailViewState();
}

class _MailViewState extends State<MailView>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    MailController mailController =
        Provider.of<MailController>(context, listen: false);
    mailController.initController(this, 3); // 3은 탭의 개수입니다.
  }

  @override
  Widget build(BuildContext context) {
    MailController mailController = context.watch<MailController>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: '보관함',
          trailingIcon: PhosphorIcons.flask(PhosphorIconsStyle.fill),
          onLeadingIconPressed: () {},
          onTrailingIconPressed: () {
            // For test delete finction
            //mailController.deleteEveryMailDataFromLocal();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TestViewPage()),
            );
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
                      Tab(text: "전체"),
                      Tab(text: "편지"),
                      Tab(
                        text: "공감한 일기",
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: mailController.tabController,
                      children: [
                        const EveryMailPage(),
                        const MyLettersPage(),
                        const LikedDiaryPage(),
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
