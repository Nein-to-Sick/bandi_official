import 'dart:async';

import 'package:bandi_official/localization/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/alarm/controller/alarm_controller.dart';
import 'package:bandi_official/view/diary_ai_chat/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/controller/home_to_write.dart';
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
import '../diary_ai_chat/diary_ai_chat_view.dart';
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

class _HomeRootLayerState extends State<HomeRootLayer>
    with WidgetsBindingObserver {
  bool _notiDropdownOpen = false;
  bool _hideChrome = false;
  Timer? _midnightTimer;

  DateTime? _latestRealAlarmAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final write = context.read<HomeToWrite>();
      write.loadLastDiaryDate();
      write.loadHomeNotiLastSeen();
      _scheduleMidnightRefresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      final t = _latestRealAlarmAt;
      if (t != null) {
        // ignore: unawaited_futures
        context.read<HomeToWrite>().setHomeNotiLastSeenAt(t);
      }
    }
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final dur = nextMidnight.difference(now);

    _midnightTimer = Timer(dur, () {
      if (!mounted) return;
      setState(() {});
      _scheduleMidnightRefresh();
    });
  }

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

    if (alarm.type == AlarmType.likedDiary) {
      final Diary diary =
          await alarmController.readDiaryDataFromDB(alarm.dataId);

      writeProvider.readMyDiary(diary);
      navigationToggleProvider.selectIndex(0);
      writeProvider.toggleWrite();
      return;
    }

    if (alarm.type == AlarmType.letter) {
      final Letter letter =
          await alarmController.readLetterDataFromDB(alarm.dataId);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        DetailViewSheet(item: letter, mailController: mailController)
            .show(context)
            .then((_) {
          if (context.mounted) {
            mailController.toggleDetailView(false);
          }
        });
      });

      // if (!mounted) return;
      // Navigator.of(context).push(
      //   PageRouteBuilder(
      //     opaque: false,
      //     barrierColor: Colors.transparent,
      //     pageBuilder: (_, __, ___) => DetailView(
      //       item: letter,
      //       mailController: mailController,
      //     ),
      //     transitionsBuilder: (_, anim, __, child) {
      //       return FadeTransition(opacity: anim, child: child);
      //     },
      //     transitionDuration: const Duration(milliseconds: 220),
      //   ),
      // );
      return;
    }

    if (alarm.type == AlarmType.dailyReminder) {
      writeProvider.toggleWrite();
      return;
    }

    if (alarm.type == AlarmType.otherDiary) {
      final Diary otherDiary =
          await alarmController.readDiaryDataFromDB(alarm.dataId);
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
        reactionPayload: alarm.reaction,
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

  DateTime _dailyReminderCreatedAt() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 9, 0, 0);
  }

  String _dailyReminderId() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return "daily_reminder_$y-$m-$d";
  }

  @override
  Widget build(BuildContext context) {
    final writeProvider = context.watch<HomeToWrite>();
    final diaryAiChatController = context.watch<DiaryAiChatController>();
    final alarmController = context.watch<AlarmController>();
    final navigationToggleProvider = context.watch<NavigationToggleProvider>();
    final userInfo = Provider.of<UserInfoValueModel>(context);
    final mailController = context.watch<MailController>();

    final isHomeVisible = !writeProvider.write &&
        !writeProvider.otherDiaryOpen &&
        !alarmController.isAlarmOpen;

    final canToggleChrome = isHomeVisible;

    return Stack(
      children: [
        AnimatedOpacity(
          opacity: writeProvider.write ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: writeProvider.write
              ? const WriteDiary()
              : const SizedBox.shrink(),
        ),
        AnimatedOpacity(
          opacity: writeProvider.otherDiaryOpen ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: writeProvider.otherDiaryOpen
              ? OtherDiary(writeProvider: writeProvider)
              : const SizedBox.shrink(),
        ),
        if (canToggleChrome && !_hideChrome)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _toggleChrome,
            ),
          ),
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

                          // DB 알림
                          List<Alarm> dbAlarms = [];
                          if (snapshot.hasData &&
                              snapshot.data!.docs.isNotEmpty) {
                            dbAlarms = snapshot.data!.docs
                                .map((doc) => Alarm.fromFirestore(doc))
                                .toList();

                            items = _mapAlarmsToHomeNotiItems(
                              alarms: dbAlarms,
                              alarmController: alarmController,
                              mailController: mailController,
                              writeProvider: writeProvider,
                              navigationToggleProvider:
                                  navigationToggleProvider,
                            );
                          }

                          // DB 알림 기준 최신 시간 (NEW dot 계산용)
                          DateTime? latestRealAlarmAt;
                          for (final a in dbAlarms) {
                            final t = a.alarmTime.toDate();
                            if (latestRealAlarmAt == null ||
                                t.isAfter(latestRealAlarmAt)) {
                              latestRealAlarmAt = t;
                            }
                          }
                          _latestRealAlarmAt = latestRealAlarmAt;

                          // dailyReminder(상태 기반, DB에 쌓이지 않음)
                          if (!writeProvider.wroteDiaryToday) {
                            items.add(
                              HomeNotiItem(
                                id: _dailyReminderId(),
                                text: "오늘 하루는 어떠셨나요?",
                                type: HomeNotiType.dailyReminder,
                                createdAt: _dailyReminderCreatedAt(),
                                onTap: () => writeProvider.toggleWrite(),
                              ),
                            );
                          }

                          // 정렬
                          items.sort(
                              (a, b) => b.createdAt.compareTo(a.createdAt));

                          // ✅ NEW dot 여부: DB 알림만 기준(리마인더 제외)
                          final lastSeen = writeProvider.homeNotiLastSeenAt;
                          final showNewDot = (latestRealAlarmAt != null) &&
                              (lastSeen == null ||
                                  latestRealAlarmAt.isAfter(lastSeen));

                          final hideTopControls =
                              items.isNotEmpty && _notiDropdownOpen;

                          return Padding(
                            padding: const EdgeInsets.only(top: 17.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: items.isEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${userInfo.nickname}님,",
                                              style:
                                                  BandiFont.titleSmall(context)!
                                                      .copyWith(
                                                color:
                                                    BandiColor.neutralColor60(
                                                        context),
                                              ),
                                            ),
                                            Text(
                                              "오늘도 수고 많았어요.",
                                              style: BandiFont.headlineMedium(
                                                      context)!
                                                  .copyWith(
                                                color:
                                                    BandiColor.neutralColor100(
                                                        context),
                                              ),
                                            ),
                                          ],
                                        )
                                      : HomeNotificationStack(
                                          key: const ValueKey(
                                              "home_notification_stack"),
                                          items: items,
                                          showNewDot: showNewDot,
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
