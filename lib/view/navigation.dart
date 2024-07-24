import 'package:bandi_official/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/view/home/home_view.dart';
import 'package:bandi_official/view/list/list_view.dart';
import 'package:bandi_official/view/mail/mail_view.dart';
import 'package:bandi_official/view/user/user_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/no_reuse/firefly.dart';
import '../components/no_reuse/navigation_bar.dart';
import '../controller/home_to_write.dart';
import '../controller/navigation_toggle_provider.dart';

class Navigation extends StatelessWidget {
  const Navigation({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);
    final writeProvider = Provider.of<HomeToWrite>(context);
    final DiaryAiChatController diaryAiChatController =
        context.watch<DiaryAiChatController>();

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image:
              AssetImage('assets/images/backgrounds/background.png'), // 배경 이미지
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const FireFly(),
            navigationToggleProvider.selectedIndex == 0
                ? const HomePage()
                : navigationToggleProvider.selectedIndex == 1
                    ? const ListPage()
                    : navigationToggleProvider.selectedIndex == 2
                        ? const MailView()
                        : const UserView(),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                (!writeProvider.write && !diaryAiChatController.isChatOpen)
                    ? navigationBar(context)
                    : Container()
              ],
            ),
          ],
        ),
      ),
    );
  }
}
