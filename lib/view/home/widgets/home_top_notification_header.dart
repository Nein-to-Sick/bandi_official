import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/home/widgets/home_notification_stack.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controller/home_to_write.dart';
import '../../../controller/navigation_toggle_provider.dart';
import '../../../model/alarm.dart';
import '../../alarm/controller/alarm_controller.dart';
import '../../mail/controller/mail_controller.dart';
import '../../tutorial/controller/tutorial_controller.dart';
import '../../../controller/user_info_controller.dart';

typedef MapAlarmsToItems = List<HomeNotiItem> Function({
required List<Alarm> alarms,
required AlarmController alarmController,
required MailController mailController,
required HomeToWrite writeProvider,
required NavigationToggleProvider navigationToggleProvider,
});

class HomeTopNotificationHeader extends StatelessWidget {
  final GlobalKey tutorialNotiStackKey;

  /// HomeRootLayer에서 상태 유지하려고 콜백으로 올려줌
  final void Function(bool open) onDropdownOpenChanged;
  final void Function(DateTime? latest) onLatestRealAlarmAtChanged;

  /// 기존에 HomeRootLayer에 있던 매핑 함수 그대로 주입 (파일 쪼개도 로직 재사용)
  final MapAlarmsToItems mapAlarmsToHomeNotiItems;

  /// dailyReminder id/time 계산을 외부에서 주입 (HomeRootLayer 메서드 재사용)
  final String Function() dailyReminderId;
  final DateTime Function() dailyReminderCreatedAt;

  const HomeTopNotificationHeader({
    super.key,
    required this.tutorialNotiStackKey,
    required this.onDropdownOpenChanged,
    required this.onLatestRealAlarmAtChanged,
    required this.mapAlarmsToHomeNotiItems,
    required this.dailyReminderId,
    required this.dailyReminderCreatedAt,
  });

  @override
  Widget build(BuildContext context) {
    final alarmController = context.watch<AlarmController>();
    final writeProvider = context.watch<HomeToWrite>();
    final navigationToggleProvider = context.watch<NavigationToggleProvider>();
    final mailController = context.watch<MailController>();
    final userInfo = context.watch<UserInfoValueModel>();
    final tutorial = context.watch<TutorialController>();

    final wrapForTutorial = tutorial.active &&
        tutorial.phase == TutorialPhase.practice &&
        (tutorial.step == TutorialStep.connectionAndEmpathy || tutorial.step == TutorialStep.growth);

    return StreamBuilder<QuerySnapshot>(
      stream: alarmController.alarmStreamQuery(),
      builder: (context, snapshot) {
        List<HomeNotiItem> items = [];

        // DB 알림
        List<Alarm> dbAlarms = [];
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          dbAlarms = snapshot.data!.docs
              .map((doc) => Alarm.fromFirestore(doc))
              .toList();

          items = mapAlarmsToHomeNotiItems(
            alarms: dbAlarms,
            alarmController: alarmController,
            mailController: mailController,
            writeProvider: writeProvider,
            navigationToggleProvider: navigationToggleProvider,
          );
        }

        // DB 알림 기준 최신 시간 (NEW dot 계산용)
        DateTime? latestRealAlarmAt;
        for (final a in dbAlarms) {
          final t = a.alarmTime.toDate();
          if (latestRealAlarmAt == null || t.isAfter(latestRealAlarmAt)) {
            latestRealAlarmAt = t;
          }
        }

        // ✅ 부모(HomeRootLayer) 상태 업데이트
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onLatestRealAlarmAtChanged(latestRealAlarmAt);
        });

        // dailyReminder(상태 기반, DB에 쌓이지 않음)
        if (!writeProvider.wroteDiaryToday) {
          items.add(
            HomeNotiItem(
              id: dailyReminderId(),
              text: "오늘 하루는 어떠셨나요?",
              type: HomeNotiType.dailyReminder,
              createdAt: dailyReminderCreatedAt(),
              onTap: () => writeProvider.toggleWrite(),
            ),
          );
        }

        // 정렬
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // NEW dot 여부: DB 알림만 기준(리마인더 제외)
        final lastSeen = writeProvider.homeNotiLastSeenAt;
        final showNewDot = (latestRealAlarmAt != null) &&
            (lastSeen == null || latestRealAlarmAt.isAfter(lastSeen));

        return Padding(
          padding: const EdgeInsets.only(top: 17.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: items.isEmpty
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${userInfo.nickname}님,",
                      style: BandiFont.titleSmall(context)!.copyWith(
                        color: BandiColor.neutralColor60(context),
                      ),
                    ),
                    Text(
                      "오늘도 수고 많았어요.",
                      style: BandiFont.headlineMedium(context)!.copyWith(
                        color: BandiColor.neutralColor100(context),
                      ),
                    ),
                  ],
                )
                    : HomeNotificationStack(
                  key: tutorialNotiStackKey,
                  items: items,
                  showNewDot: showNewDot,
                  onDropdownOpenChanged: (open) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      onDropdownOpenChanged(open);
                    });
                  },
                  onStackTap: wrapForTutorial
                      ? () async {
                    final t = context.read<TutorialController>();
                    if (t.step == TutorialStep.connectionAndEmpathy) {
                      await t.advanceConnectionPhase(); // => focusReactionSelector
                    }
                    else if (t.connectionPhase == ConnectionTutorialPhase.focusHomeNotification) {
                      t.setGrowthPhase(GrowthTutorialPhase.focusLetterCloseX);
                    }
                  }
                      : null,

                )
              ),
              const SizedBox(width: 12),
            ],
          ),
        );
      },
    );
  }
}
