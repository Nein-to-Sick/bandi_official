import 'package:bandi_official/controller/alarm_controller.dart';
import 'package:bandi_official/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/alarm/alarm_view.dart';
import 'package:bandi_official/view/diary_ai_chat/diary_ai_chat_view.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../view/home/write_diary.dart';
import '../../view/navigation.dart';

class HomeTopBar extends StatefulWidget {
  const HomeTopBar({super.key});

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends State<HomeTopBar> {
  @override
  Widget build(BuildContext context) {
    final writeProvider = Provider.of<HomeToWrite>(context);
    final DiaryAiChatController diaryAiChatController =
        context.watch<DiaryAiChatController>();
    final MailController mailController = context.watch<MailController>();
    final AlarmController alarmController = context.watch<AlarmController>();

    return Stack(
      children: [
        // 일기 open
        AnimatedOpacity(
          opacity: writeProvider.write ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: writeProvider.write
              ? const WriteDiary()
              : const SizedBox.shrink(),
        ),
        // ai chat open
        AnimatedOpacity(
          opacity: (diaryAiChatController.isChatOpen) ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: diaryAiChatController.isChatOpen
              ? const DiaryAIChatPage()
              : const SizedBox.shrink(),
        ),
        // mail page detail view open
        AnimatedOpacity(
          opacity: (mailController.isDetailViewShowing) ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: const SizedBox.shrink(),
        ),
        // alarm page view open
        AnimatedOpacity(
            opacity: (alarmController.isAlarmOpen) ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: (alarmController.isAlarmOpen)
                ? const AlarmView()
                : const SizedBox.shrink()),
        // home
        (!writeProvider.write &&
                !diaryAiChatController.isChatOpen &&
                !mailController.isDetailViewShowing &&
                !alarmController.isAlarmOpen)
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // top icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: PhosphorIcon(
                              speakerOn
                                  ? PhosphorIcons.speakerSimpleHigh(
                                      PhosphorIconsStyle.fill)
                                  : PhosphorIcons.speakerSimpleSlash(
                                      PhosphorIconsStyle.fill),
                              color: BandiColor.neutralColor100(context),
                            ),
                            onPressed: () async {
                              setState(() {
                                speakerOn = !speakerOn;
                              });
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool('speakerOn', speakerOn);

                              // Adjust audio based on the new setting
                              if (speakerOn) {
                                assetsAudioPlayer.play();
                              } else {
                                assetsAudioPlayer.pause();
                              }
                            },
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: PhosphorIcon(
                                  PhosphorIcons.chat(PhosphorIconsStyle.fill),
                                  color: BandiColor.neutralColor100(context),
                                ),
                                onPressed: () {
                                  diaryAiChatController.toggleChatOpen(true);
                                },
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  IconButton(
                                    icon: PhosphorIcon(
                                      PhosphorIcons.bell(
                                          PhosphorIconsStyle.fill),
                                      color:
                                          BandiColor.neutralColor100(context),
                                    ),
                                    onPressed: () {
                                      alarmController.toggleAlarmOpen(true);
                                    },
                                  ),
                                  (mailController.isNewNotifications)
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 13, right: 13),
                                          child: ClipOval(
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              color:
                                                  BandiColor.accentColorYellow(
                                                      context),
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // write button
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 100.0, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                writeProvider.toggleWrite();
                              },
                              icon: CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    BandiColor.neutralColor60(context),
                                child: PhosphorIcon(
                                  PhosphorIcons.plus(PhosphorIconsStyle.bold),
                                  size: 21,
                                  color: BandiColor.foundationColor80(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Container()
      ],
    );
  }
}
