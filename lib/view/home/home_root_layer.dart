import 'dart:async';

import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/view/alarm/controller/alarm_controller.dart';
import 'package:bandi_official/view/diary_ai_chat/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/view/home/widgets/home_action_card_button.dart';
import 'package:bandi_official/view/home/widgets/home_notification_stack.dart';
import 'package:bandi_official/view/home/widgets/home_top_notification_header.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'package:bandi_official/model/alarm.dart';

import '../../controller/user_info_controller.dart';
import '../../controller/navigation_toggle_provider.dart';
import '../../main.dart';
import '../../model/diary.dart';
import '../diary_ai_chat/diary_ai_chat_view.dart';
import '../mail/controller/mail_controller.dart';
import '../mail/detail_view.dart';
import '../sharing_diary/other_diary.dart';
import '../tutorial/controller/tutorial_controller.dart';
import '../tutorial/controller/tutorial_target_registry.dart';
import '../tutorial/tutorial_flow_page.dart';
import '../writing/write_diary.dart';
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

  TutorialTargetRegistry? _tutorialReg;
  HomeToWrite? _writeProvider;

  final GlobalKey _tutorialWriteBtnKey = GlobalKey();
  final GlobalKey _tutorialNotiStackKey = GlobalKey();
  final GlobalKey _tutorialAiChatBtnKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _tutorialReg ??= context.read<TutorialTargetRegistry>();
    _writeProvider ??= context.read<HomeToWrite>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final write = _writeProvider;
      write?.loadLastDiaryDate();
      write?.loadHomeNotiLastSeen();
      _scheduleMidnightRefresh();

      _tutorialReg?.register('home.writeButton', _tutorialWriteBtnKey);
      _tutorialReg?.register('home.notificationButton', _tutorialNotiStackKey);
      _tutorialReg?.register('home.aiChatButton', _tutorialAiChatBtnKey);
    });
  }

  @override
  void dispose() {
    _tutorialReg?.unregister('home.writeButton');
    _tutorialReg?.unregister('home.notificationButton');
    _tutorialReg?.unregister('home.aiChatButton');

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
        _writeProvider?.setHomeNotiLastSeenAt(t);
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
    final alarmController = context.watch<AlarmController>();

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
                      HomeTopNotificationHeader(
                        tutorialNotiStackKey: _tutorialNotiStackKey,
                        mapAlarmsToHomeNotiItems: _mapAlarmsToHomeNotiItems,
                        dailyReminderId: _dailyReminderId,
                        dailyReminderCreatedAt: _dailyReminderCreatedAt,
                        onLatestRealAlarmAtChanged: (latest) {
                          _latestRealAlarmAt = latest;
                        },
                        onDropdownOpenChanged: (open) {
                          if (!mounted) return;
                          setState(() => _notiDropdownOpen = open);

                          if (!open) return;

                          final tc = context.read<TutorialController>();
                          if (tc.isGrowthFlow && tc.growthPhase == GrowthTutorialPhase.focusHomeNotification) {
                            tc.setGrowthPhase(GrowthTutorialPhase.focusLetterCloseX);
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 112),
                        child: Row(
                          children: [
                            Expanded(
                              child: HomeActionCardButton(
                                key: _tutorialAiChatBtnKey,
                                icon: PhosphorIcons.chat(
                                    PhosphorIconsStyle.light),
                                label: "ai_chat_title".tr(context),
                                onTap: () async {
                                  final tc = context.read<TutorialController>();
                                  final diaryAiChatController =
                                  context.read<DiaryAiChatController>();

                                  if (tc.isRetrospectFlow &&
                                      tc.retrospectPhase ==
                                          RetrospectTutorialPhase.focusAiChatButton) {
                                    tc.setRetrospectPhase(
                                        RetrospectTutorialPhase.focusMessageBar);
                                  }

                                  diaryAiChatController.toggleChatOpen(true);

                                  final f = DiaryAIChatSheet().show(
                                    context,
                                    lockDismiss: tc.active,
                                  );

                                  f.whenComplete(() async {
                                    final rootCtx = navigatorKey.currentContext;
                                    if (rootCtx == null) return;

                                    Provider.of<DiaryAiChatController>(
                                      rootCtx,
                                      listen: false,
                                    ).toggleChatOpen(false);

                                    final tc2 =
                                    Provider.of<TutorialController>(rootCtx, listen: false);

                                    if (!tc2.isRetrospectFlow) return;

                                    // ✅ practice 완료 → 다음 step으로
                                    await tc2.advanceAfterPractice();

                                    tc2.scheduleExplainFlow(rootCtx);
                                  });

                                  await f;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: HomeActionCardButton(
                                key: _tutorialWriteBtnKey,
                                icon: PhosphorIcons.pencilSimple(
                                    PhosphorIconsStyle.light),
                                label: "일기 쓰기",
                                onTap: () async {
                                  writeProvider.toggleWrite();
                                },
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
