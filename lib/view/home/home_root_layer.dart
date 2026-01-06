import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/alarm/controller/alarm_controller.dart';
import 'package:bandi_official/view/diary_ai_chat/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/view/alarm/alarm_view.dart';
import 'package:bandi_official/view/diary_ai_chat/diary_ai_chat_view.dart';
import 'package:bandi_official/view/home/widgets/home_action_card_button.dart';
import 'package:bandi_official/view/home/widgets/home_notification_stack.dart';
import 'package:bandi_official/view/home/widgets/speaker_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bandi_official/model/alarm.dart';

import '../../controller/user_info_controller.dart';
import '../../controller/navigation_toggle_provider.dart';
import '../../model/diary.dart';
import '../mail/controller/mail_controller.dart';
import '../mail/detail_view.dart';
import '../sharing_diary/other_diary.dart';
import '../writing/write_diary.dart';
import 'controller/bgm_controller.dart';
import 'package:bandi_official/model/letter.dart';

class HomeRootLayer extends StatefulWidget {
  const HomeRootLayer({super.key});

  @override
  State<HomeRootLayer> createState() => _HomeRootLayerState();
}

class _HomeRootLayerState extends State<HomeRootLayer> {
  bool _notiDropdownOpen = false;
  bool _hideChrome = false;

  void _toggleChrome() {
    final writeProvider = context.read<HomeToWrite>();
    writeProvider.toggleChrome();
    setState(() => _hideChrome = writeProvider.hideChrome);
  }

  Future<void> _handleHomeNotiTap({
    required Alarm alarm,
    required AlarmController alarmController,
    required MailController mailController,
    required HomeToWrite writeProvider,
    required NavigationToggleProvider navigationToggleProvider,
  }) async {
    await alarmController.dismissAlarm(alarm.notificationId);

    /// 공감 받은 일기 열람 (TODO:공감 구분 필요)
    if (alarm.type == AlarmType.likedDiary) {
      final Diary diary =
      await alarmController.readLikedDiaryDataFromDB(alarm.dataId);

      writeProvider.readMyDiary(diary);
      navigationToggleProvider.selectIndex(0);
      writeProvider.toggleWrite();
      return;
    }

    // 일기 쓰기 이동
    if (alarm.type == AlarmType.dailyReminder) {
      writeProvider.toggleWrite();
      return;
    }

    // 편지 열기
    if (alarm.type == AlarmType.letter) {
      final Letter letter =
      await alarmController.readLetterDataFromDB(alarm.dataId);

      if (!mounted) return;
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          barrierColor: Colors.transparent,
          pageBuilder: (_, __, ___) => DetailView(
            item: letter,
            mailController: mailController,
          ),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
          transitionDuration: const Duration(milliseconds: 220),
        ),
      );
      return;
    }

    // 다른 유저의 일기 도착
    if (alarm.type == AlarmType.otherDiary) {
      final Diary otherDiary =
          await alarmController.readOtherDiaryDataFromDB(alarm.dataId);
      writeProvider.setOtherDiary(otherDiary);
      return;
    }
  }

  List<HomeNotiItem> _mapAlarmsToHomeNotiItems({
    required List<Alarm> alarms,
    required AlarmController alarmController,
    required MailController mailController,
    required HomeToWrite writeProvider,
    required NavigationToggleProvider navigationToggleProvider,
  }) {
    return alarms.map((alarm) {
      return HomeNotiItem(
        id: alarm.notificationId,
        text: alarm.title,
        type: _mapAlarmTypeToHomeType(alarm.type),
        createdAt: alarm.alarmTime.toDate(),
        onTap: () {
          _handleHomeNotiTap(
            alarm: alarm,
            alarmController: alarmController,
            mailController: mailController,
            writeProvider: writeProvider,
            navigationToggleProvider: navigationToggleProvider,
          );
        },
      );
    }).toList();
  }

  HomeNotiType _mapAlarmTypeToHomeType(AlarmType t) {
    switch (t) {
      case AlarmType.likedDiary:
        return HomeNotiType.likedDiary;
      case AlarmType.letter:
        return HomeNotiType.letter;
      case AlarmType.dailyReminder:
        return HomeNotiType.dailyReminder;
      case AlarmType.otherDiary:
        return HomeNotiType.otherDiary;
      default:
        return HomeNotiType.likedDiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final writeProvider = context.watch<HomeToWrite>();
    final diaryAiChatController = context.watch<DiaryAiChatController>();
    final alarmController = context.watch<AlarmController>();
    final navigationToggleProvider =
    context.watch<NavigationToggleProvider>();
    final userInfo = Provider.of<UserInfoValueModel>(context);
    final mailController = context.watch<MailController>();

    final isHomeVisible = !writeProvider.write &&
        !writeProvider.otherDiaryOpen &&
        !alarmController.isAlarmOpen;

    final canToggleChrome = isHomeVisible;

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

        // 공유 일기 화면
        AnimatedOpacity(
          opacity: writeProvider.otherDiaryOpen ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: writeProvider.otherDiaryOpen
              ? OtherDiary(writeProvider: writeProvider)
              : const SizedBox.shrink(),
        ),

        // 컴포넌트 숨기기, 빈화면
        if (canToggleChrome && !_hideChrome)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _toggleChrome,
            ),
          ),

        // HOME UI
        if (isHomeVisible)
          IgnorePointer(
            ignoring: _hideChrome,
            child: AnimatedOpacity(
              opacity: _hideChrome ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 180),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: alarmController.alarmStreamQuery(),
                        builder: (context, snapshot) {
                          List<HomeNotiItem> items = [];
                          if (snapshot.hasData &&
                              snapshot.data!.docs.isNotEmpty) {
                            final alarms = snapshot.data!.docs
                                .map((doc) => Alarm.fromFirestore(doc))
                                .toList();

                            items = _mapAlarmsToHomeNotiItems(
                              alarms: alarms,
                              alarmController: alarmController,
                              mailController: mailController,
                              writeProvider: writeProvider,
                              navigationToggleProvider:
                              navigationToggleProvider,
                            );
                          }

                          final hideTopControls =
                              items.isNotEmpty && _notiDropdownOpen;

                          return Padding(
                            padding: const EdgeInsets.only(top: 17.0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: items.isEmpty
                                      ? Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${userInfo.nickname}님,",
                                        style: BandiFont.titleSmall(
                                            context)!
                                            .copyWith(
                                          color: BandiColor
                                              .neutralColor60(context),
                                        ),
                                      ),
                                      Text(
                                        "오늘도 수고 많았어요.",
                                        style: BandiFont
                                            .headlineMedium(context)!
                                            .copyWith(
                                          color: BandiColor
                                              .neutralColor100(context),
                                        ),
                                      ),
                                    ],
                                  )
                                      : HomeNotificationStack(
                                    key: const ValueKey(
                                        "home_notification_stack"),
                                    items: items,
                                    onDropdownOpenChanged: (open) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (!mounted) return;
                                        setState(() =>
                                        _notiDropdownOpen = open);
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 80),
                                  opacity: hideTopControls ? 0.0 : 1.0,
                                  child: IgnorePointer(
                                    ignoring: hideTopControls,
                                    child: SpeakerButton(
                                      speakerOn: context
                                          .watch<BgmController>()
                                          .speakerOn,
                                      onPressed: () {
                                        final bgm =
                                        context.read<BgmController>();
                                        bgm.setSpeakerOn(!bgm.speakerOn);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // 하단 버튼
                      Padding(
                        padding: const EdgeInsets.only(bottom: 112),
                        child: Row(
                          children: [
                            Expanded(
                              child: HomeActionCardButton(
                                icon: PhosphorIcons.chat(
                                    PhosphorIconsStyle.light),
                                label: "ai_chat_title".tr(context),
                                onTap: () async {
                                  diaryAiChatController.toggleChatOpen(true);
                                  DiaryAIChatSheet().show(context).then((_) {
                                    if (context.mounted) {
                                      diaryAiChatController
                                          .toggleChatOpen(false);
                                    }
                                  });
                                },
                              ),
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
            ),
          ),

        if (canToggleChrome && _hideChrome)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleChrome,
            ),
          ),
      ],
    );
  }
}
