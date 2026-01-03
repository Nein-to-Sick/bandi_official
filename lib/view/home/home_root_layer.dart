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

import '../../controller/user_info_controller.dart';
import '../mail/controller/mail_controller.dart';
import '../mail/new_letter_popup.dart';
import '../sharing_diary/otherDiary.dart';
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

    final mailController = context.watch<MailController>();

    final isHomeVisible = !writeProvider.write &&
        !writeProvider.otherDiaryOpen &&
        !alarmController.isAlarmOpen;

    final canToggleChrome = isHomeVisible;

    final bool isOtherDiaryComing =
        writeProvider.otherDiaryCome == true && writeProvider.step == 1;

    // ===== 알림 아이템 구성 =====
    final List<HomeNotiItem> homeNotis = [];
    final hideTopControls = (!wroteToday && _notiDropdownOpen);

    // ✅ 디자인 확인용 더미 알림(디버그에서만)
    assert(() {
      final now = DateTime.now();
      homeNotis.insertAll(0, [
        HomeNotiItem(
          id: "dbg_1",
          text: "${userInfo.nickname}님과 비슷한 친구가 있어요!",
          type: HomeNotiType.otherDiary,
          createdAt: now.subtract(const Duration(minutes: 3)),
          onTap: () => debugPrint("DBG tap: otherDiary"),
        ),
        HomeNotiItem(
          id: "dbg_2",
          text: "누군가 나의 기록에 공감했어요!",
          type: HomeNotiType.likedDiary,
          createdAt: now.subtract(const Duration(minutes: 2)),
          onTap: () => debugPrint("DBG tap: likedDiary"),
        ),
        HomeNotiItem(
          id: "dbg_3",
          text: "2026년 1월 편지가 도착했습니다.",
          type: HomeNotiType.letter,
          createdAt: now.subtract(const Duration(minutes: 1)),
          onTap: () => debugPrint("DBG tap: letter"),
        ),
        HomeNotiItem(
          id: "dbg_3",
          text: "2026년 1월 편지가 도착했습니다.",
          type: HomeNotiType.letter,
          createdAt: now.subtract(const Duration(minutes: 1)),
          onTap: () => debugPrint("DBG tap: letter"),
        ),
        HomeNotiItem(
          id: "dbg_3",
          text: "2026년 1월 편지가 도착했습니다.",
          type: HomeNotiType.letter,
          createdAt: now.subtract(const Duration(minutes: 1)),
          onTap: () => debugPrint("DBG tap: letter"),
        ),
      ]);
      return true;
    }());

    final now = DateTime.now();

    // 1) 비슷한 친구
    if (isOtherDiaryComing) {
      homeNotis.add(
        HomeNotiItem(
          id: "otherDiary",
          text: "${userInfo.nickname}님과 비슷한 친구가 있어요!",
          type: HomeNotiType.otherDiary,
          createdAt: now,
          onTap: () => writeProvider.openDiary(),
        ),
      );
    }

    // 2) 공감(누군가 내 기록에 공감) - 예시로 newNotificationCount 사용
    final bool hasLikeNoti = (mailController.newNotificationCount > 0);
    if (hasLikeNoti) {
      homeNotis.add(
        HomeNotiItem(
          id: "liked",
          text: "누군가 나의 기록에 공감했어요!",
          type: HomeNotiType.likedDiary,
          createdAt: now,
          onTap: () => alarmController.toggleAlarmOpen(true),
        ),
      );
    }

    // 3) 편지
    final Letter? newLetter = mailController.newLetter;
    final bool hasLetterNoti = newLetter != null;
    if (hasLetterNoti) {
      homeNotis.add(
        HomeNotiItem(
          id: "letter_${newLetter!.title.hashCode}",
          text: _letterNotiTextFromLetter(newLetter),
          type: HomeNotiType.letter,
          createdAt: now,
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                barrierColor: Colors.transparent,
                pageBuilder: (_, __, ___) =>
                    NewLetterPopuView(newLetter: newLetter),
                transitionsBuilder: (_, anim, __, child) {
                  return FadeTransition(opacity: anim, child: child);
                },
                transitionDuration: const Duration(milliseconds: 220),
              ),
            );
          },
        ),
      );
    }

    // 4) 기본 리마인더
    homeNotis.add(
      HomeNotiItem(
        id: "daily",
        text: "오늘 하루는 어떠셨나요?",
        type: HomeNotiType.dailyReminder,
        createdAt: now,
        onTap: () => writeProvider.toggleWrite(),
      ),
    );

    return Stack(
      children: [
        // 일기 작성 화면
        AnimatedOpacity(
          opacity: writeProvider.write ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: writeProvider.write ? const WriteDiary() : const SizedBox.shrink(),
        ),

        // 공유 일기 화면
        AnimatedOpacity(
          opacity: writeProvider.otherDiaryOpen ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: writeProvider.otherDiaryOpen
              ? OtherDiary(writeProvider: writeProvider)
              : const SizedBox.shrink(),
        ),

        // 알림 화면(알림센터)
        AnimatedOpacity(
          opacity: alarmController.isAlarmOpen ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: alarmController.isAlarmOpen ? const AlarmView() : const SizedBox.shrink(),
        ),

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
            ignoring: _hideChrome, // 숨김 상태에서 UI 터치 막기
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
                      // ✅ 상단 영역(기존 그대로)
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
                                items: homeNotis,
                                onDropdownOpenChanged: (open) {
                                  setState(() => _notiDropdownOpen = open);
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
                                  speakerOn: context.watch<BgmController>().speakerOn,
                                  onPressed: () {
                                    final bgm = context.read<BgmController>();
                                    bgm.setSpeakerOn(!bgm.speakerOn);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ✅ 하단 버튼(기존 그대로)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 112),
                        child: Row(
                          children: [
                            Expanded(
                              child: HomeActionCardButton(
                                icon: PhosphorIcons.chat(PhosphorIconsStyle.light),
                                label: "ai_chat_title".tr(context),
                                onTap: () async {
                                  diaryAiChatController.toggleChatOpen(true);
                                  DiaryAIChatSheet().show(context).then((_) {
                                    if (context.mounted) {
                                      diaryAiChatController.toggleChatOpen(false);
                                    }
                                  });
                                },
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

// ====== helpers (파일 하단) ======

String _extractMonthFromLetterTitle(String title) {
  final reg = RegExp(r'(\d+)(?=월\s*편지$)');
  final m = reg.firstMatch(title);
  return m?.group(1) ?? '';
}

String _letterNotiTextFromLetter(Letter letter) {
  final month = _extractMonthFromLetterTitle(letter.title);
  if (month.isEmpty) return "편지가 도착했습니다.";
  return "2026년 ${month}월 편지가 도착했습니다.";
}
