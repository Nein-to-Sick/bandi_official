import 'package:bandi_official/controller/alarm_controller.dart';
import 'package:bandi_official/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/view/alarm/alarm_view.dart';
import 'package:bandi_official/view/diary_ai_chat/diary_ai_chat_view.dart';
import 'package:bandi_official/view/home/widgets/home_action_card_button.dart';
import 'package:bandi_official/view/home/widgets/home_notification_pill.dart';
import 'package:bandi_official/view/home/widgets/speaker_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../writing/write_diary.dart';
import 'controller/bgm_controller.dart';

class HomeRootLayer extends StatefulWidget {
  const HomeRootLayer({super.key});

  @override
  State<HomeRootLayer> createState() => _HomeRootLayerState();
}

class _HomeRootLayerState extends State<HomeRootLayer> {
  @override
  Widget build(BuildContext context) {
    final writeProvider = context.watch<HomeToWrite>();
    final diaryAiChatController = context.watch<DiaryAiChatController>();
    final mailController = context.watch<MailController>();
    final alarmController = context.watch<AlarmController>();

    final bgm = context.watch<BgmController>();

    final isHomeVisible = !writeProvider.write &&
        !diaryAiChatController.isChatOpen &&
        !mailController.isDetailViewShowing &&
        !alarmController.isAlarmOpen;

    return Stack(
      children: [
        // 일기 작성 화면
        AnimatedOpacity(
          opacity: writeProvider.write ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: writeProvider.write ? const WriteDiary() : const SizedBox.shrink(),
        ),

        // AI Chat 화면
        AnimatedOpacity(
          opacity: diaryAiChatController.isChatOpen ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: diaryAiChatController.isChatOpen
              ? const DiaryAIChatPage()
              : const SizedBox.shrink(),
        ),

        // (메일 디테일 뷰는 기존 로직 유지. 실제 화면 있으면 여기 연결)
        AnimatedOpacity(
          opacity: mailController.isDetailViewShowing ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: const SizedBox.shrink(),
        ),

        // 알림 화면
        AnimatedOpacity(
          opacity: alarmController.isAlarmOpen ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: alarmController.isAlarmOpen ? const AlarmView() : const SizedBox.shrink(),
        ),

        // HOME UI
        if (isHomeVisible)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: HomeNotificationPill(
                            text: "오늘 하루는 어떠셨나요?",
                            showDot: mailController.isNewNotifications,
                            onTap: () => alarmController.toggleAlarmOpen(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SpeakerButton(
                          speakerOn: bgm.speakerOn,
                          onPressed: () => bgm.setSpeakerOn(!bgm.speakerOn),
                        ),
                      ],
                    ),
                  ),

                  // Bottom: 2개의 버튼 (반디와 대화 / 일기 쓰기)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 112),
                    child: Row(
                      children: [
                        Expanded(
                          child: HomeActionCardButton(
                            icon: PhosphorIcons.chat(PhosphorIconsStyle.light),
                            label: "반디와 대화하기",
                            onTap: () => diaryAiChatController.toggleChatOpen(true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: HomeActionCardButton(
                            icon: PhosphorIcons.pencilSimple(PhosphorIconsStyle.light),
                            label: "일기 쓰기",
                            onTap: () => writeProvider.toggleWrite(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}