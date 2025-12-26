import 'package:flutter/material.dart';

import 'package:bandi_official/view/home/home_view.dart';
import 'package:bandi_official/view/list/list_view.dart';
import 'package:bandi_official/view/login/login_view.dart';
import 'package:bandi_official/view/mail/mail_view.dart';
import 'package:bandi_official/view/sharing_diary/otherDiary.dart';
import 'package:bandi_official/view/user/user_view.dart';
import 'package:bandi_official/components/loading/loading_page.dart';

import '../../controller/home_to_write.dart';
import '../../controller/navigation_toggle_provider.dart';
import '../../controller/diary_ai_chat_controller.dart';
import '../../controller/mail_controller.dart';
import '../../controller/alarm_controller.dart';
import '../login/onboarding_gate.dart';
import '../../string_extention.dart';

class AppRouter {
  static Widget buildMain({
    required BuildContext context,
    required NavigationToggleProvider nav,
    required HomeToWrite writeProvider,
    required DiaryAiChatController diaryAiChatController,
    required MailController mailController,
    required AlarmController alarmController,
  }) {
    // 오버레이 우선
    if (writeProvider.otherDiaryOpen == true && writeProvider.step == 1) {
      return OtherDiary(writeProvider: writeProvider);
    }

    // 회원가입/온보딩
    if (nav.selectedIndex == -3) return const OnboardingGate();

    // 로그인
    if (nav.selectedIndex <= -1 && nav.selectedIndex != -2) {
      return const LoginView();
    }

    // 로딩
    if (nav.selectedIndex == 100) {
      return Center(
        child: MyFireFlyProgressbar(loadingText: 'loading'.tr(context)),
      );
    }

    // 메인 탭
    switch (nav.selectedIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const ListPage();
      case 2:
        return AnimatedOpacity(
          opacity: (!mailController.isDetailViewShowing) ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: const MailView(),
        );
      default:
        return const UserView();
    }
  }

  static bool shouldShowNavBar({
    required NavigationToggleProvider nav,
    required HomeToWrite writeProvider,
    required DiaryAiChatController diaryAiChatController,
    required MailController mailController,
    required AlarmController alarmController,
  }) {
    if (nav.selectedIndex < 0 || nav.selectedIndex == 100) return false;

    final isOverlayOpen = writeProvider.write ||
        diaryAiChatController.isChatOpen ||
        mailController.isDetailViewShowing ||
        alarmController.isAlarmOpen ||
        (writeProvider.otherDiaryOpen == true && writeProvider.step == 1);

    return !isOverlayOpen;
  }
}
