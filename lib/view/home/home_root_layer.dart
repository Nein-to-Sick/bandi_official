import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/alarm/controller/alarm_controller.dart';
import 'package:bandi_official/view/diary_ai_chat/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/view/alarm/alarm_view.dart';
import 'package:bandi_official/view/diary_ai_chat/diary_ai_chat_view.dart';
import 'package:bandi_official/view/home/widgets/home_action_card_button.dart';
import 'package:bandi_official/view/home/widgets/home_notification_pill.dart';
import 'package:bandi_official/view/home/widgets/speaker_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../controller/user_info_controller.dart';
import '../sharing_diary/otherDiary.dart';
import '../writing/write_diary.dart';
import 'controller/bgm_controller.dart';

class HomeRootLayer extends StatefulWidget {
  const HomeRootLayer({super.key});

  @override
  State<HomeRootLayer> createState() => _HomeRootLayerState();
}

class _HomeRootLayerState extends State<HomeRootLayer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeToWrite>().loadLastDiaryDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final writeProvider = context.watch<HomeToWrite>();
    final diaryAiChatController = context.watch<DiaryAiChatController>();
    final alarmController = context.watch<AlarmController>();
    final userInfo = Provider.of<UserInfoValueModel>(context);
    final wroteToday = writeProvider.wroteDiaryToday;

    final bgm = context.watch<BgmController>();

    final isHomeVisible = !writeProvider.write &&
        !writeProvider.otherDiaryOpen &&
        !alarmController.isAlarmOpen;
    bool isOtherDiaryComing =
        writeProvider.otherDiaryCome == true && writeProvider.step == 1;

    return Stack(
      children: [
        // 일기 작성 화면
        AnimatedOpacity(
          opacity: writeProvider.write ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: writeProvider.write
              ? const WriteDiary()
              : const SizedBox.shrink(),
        ),

        /*
        // AI Chat 화면
        AnimatedOpacity(
          opacity: diaryAiChatController.isChatOpen ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: diaryAiChatController.isChatOpen
              ? const DiaryAIChatPage()
              : const SizedBox.shrink(),
        ),
        */

        AnimatedOpacity(
          opacity: writeProvider.otherDiaryOpen ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: writeProvider.otherDiaryOpen
              ? OtherDiary(writeProvider: writeProvider)
              : const SizedBox.shrink(),
        ),

        // 알림 화면
        AnimatedOpacity(
          opacity: alarmController.isAlarmOpen ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: alarmController.isAlarmOpen
              ? const AlarmView()
              : const SizedBox.shrink(),
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
                          child: wroteToday
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${userInfo.nickname}님,",
                                      style: BandiFont.titleSmall(context)!
                                          .copyWith(
                                              color: BandiColor.neutralColor60(
                                                  context)),
                                    ),
                                    Text(
                                      "오늘도 수고 많았어요.",
                                      style: BandiFont.headlineMedium(context)!
                                          .copyWith(
                                              color: BandiColor.neutralColor100(
                                                  context)),
                                    ),
                                  ],
                                )
                              : HomeNotificationPill(
                                  text: isOtherDiaryComing
                                      ? "${userInfo.nickname}님과 비슷한 친구가 있어요!"
                                      : "오늘 하루는 어떠셨나요?",
                                  onTap: () {
                                    if (isOtherDiaryComing) {
                                      writeProvider.openDiary();
                                    } else {
                                      alarmController.toggleAlarmOpen(true);
                                    }
                                  },
                                ),
                        ),
                        const SizedBox(width: 12),
                        SpeakerButton(
                          speakerOn: context.watch<BgmController>().speakerOn,
                          onPressed: () {
                            final bgm = context.read<BgmController>();
                            bgm.setSpeakerOn(!bgm.speakerOn);
                          },
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
                              icon:
                                  PhosphorIcons.chat(PhosphorIconsStyle.light),
                              label: "ai_chat_title".tr(context),
                              onTap: () async {
                                diaryAiChatController.toggleChatOpen(true);
                                DiaryAIChatSheet().show(context).then((_) {
                                  if (context.mounted) {
                                    diaryAiChatController.toggleChatOpen(false);
                                  }
                                });
                              }),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: HomeActionCardButton(
                            icon: PhosphorIcons.pencilSimple(
                                PhosphorIconsStyle.light),
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
