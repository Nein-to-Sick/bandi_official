import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:bandi_official/view/alarm/controller/alarm_controller.dart';
import 'package:bandi_official/view/diary_ai_chat/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/controller/internet_connection_controller.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';

import '../../components/bottom_sheet/show_floating_confirm_sheet.dart';
import '../../components/no_reuse/firefly.dart';
import '../../controller/home_to_write.dart';
import '../../controller/navigation_toggle_provider.dart';
import '../../controller/user_info_controller.dart';
import '../../main.dart';
import '../home/controller/bgm_controller.dart';
import '../login/controller/login_controller.dart';
import '../tutorial/controller/tutorial_controller.dart';
import '../tutorial/controller/tutorial_target_registry.dart';
import '../tutorial/tutorial_flow_page.dart';
import '../tutorial/tutorial_overlay.dart';
import '../tutorial/tutorial_speech_bubble.dart';
import 'app_router.dart';
import 'components/frosted_nav_bar.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({super.key});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  Future<bool>? _networkFuture;
  String? _lastLangCode;

  bool _loginInitDone = false;
  bool _offlineLoopRunning = false;

  bool _tutorialBootstrapped = false;

  final GlobalKey _tutorialTrayKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
      context
          .read<TutorialTargetRegistry>()
          .register('nav.tray', _tutorialTrayKey);
    });
  }

  Future<void> _bootstrap() async {
    final current = FirebaseAuth.instance.currentUser;
    if (current != null) {
      context.read<UserInfoValueModel>().updateUserID(current.uid);
    }
    if (!mounted) return;

    context.read<BgmController>().init();

    if (!_tutorialBootstrapped) {
      _tutorialBootstrapped = true;

      final t = context.read<TutorialController>();
      final nav = context.read<NavigationToggleProvider>();

      await t.loadFromStorage();
      if (!mounted) return;

      final userInfo = context.read<UserInfoValueModel>();

      final needAgreement = !userInfo.isAgreed;
      final needNickname = userInfo.getNickName().trim().isEmpty;
      final needTutorial = !t.finished;

      if (needAgreement || needNickname || needTutorial) {
        nav.selectIndex(-3);
      }

    }

    if (!_loginInitDone) {
      _loginInitDone = true;
      context.read<LoginController>().init();
    }

    await _ensureNetworkOrExit();
  }

  Future<void> _ensureNetworkOrExit() async {
    if (_offlineLoopRunning) return;
    _offlineLoopRunning = true;

    try {
      final internet = context.read<InternetConnectionController>();

      while (mounted) {
        final ok = await internet.checkNetworkConnectivity();

        if (ok == true) {
          if (!mounted) return;
          setState(() {
            _networkFuture = Future.value(true);
          });
          return;
        }

        final res = await showFloatingConfirmSheet(
          context,
          title: '인터넷 연결이 잠시 끊겼나요?',
          description: '네트워크 상태를 확인 후 다시 시도해 주세요.',
          cancelText: '나가기',
          confirmText: '새로고침',
          barrierDismissible: false,
        );

        if (!mounted) return;

        if (res != true) {
          exit(0);
        }

        await Future.delayed(const Duration(milliseconds: 200));
      }
    } finally {
      _offlineLoopRunning = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final langCode = Localizations.localeOf(context).languageCode;
    if (_lastLangCode != langCode) {
      _lastLangCode = langCode;
      initializeDateFormatting(langCode, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationToggleProvider>();
    final writeProvider = context.watch<HomeToWrite>();
    final diaryAiChatController = context.watch<DiaryAiChatController>();
    final mailController = context.watch<MailController>();
    final alarmController = context.watch<AlarmController>();
    final internet = context.watch<InternetConnectionController>();

    final tutorial = context.watch<TutorialController>();
    final registry = context.watch<TutorialTargetRegistry>();

    // 튜토리얼 진행 중이면 타겟 rect 갱신
    if (tutorial.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<TutorialTargetRegistry>().refreshAll();
      });
    }

    final targetId = tutorial.targetId;
    final rawRect = (targetId == null) ? null : registry.rectOf(targetId);

    final pointRect = (targetId == null || rawRect == null)
        ? null
        : _makePointRect(
            rawRect,
            size: 28,
            offset: _offsetForTarget(targetId),
          );

    final showTrayBubble = tutorial.active &&
        tutorial.phase == TutorialPhase.practice &&
        tutorial.step == TutorialStep.growth &&
        tutorial.growthPhase == GrowthTutorialPhase.focusTrayNav;

    final guideWidget = showTrayBubble
        ? TutorialSpeechBubble(
            targetRect: rawRect!,
            title: '반디가 보낸 편지와 공감한 일기는 \n여기에 보관됩니다.',
            subtitle: '따뜻한 위로가 필요할 때 언제든 다시 \n꺼내보세요.',
            gap: 23,
          )
        : const SizedBox.shrink();

    final isWritingOpen = writeProvider.write; // 글쓰기 화면(FirstStep) 열렸는지
    final isOtherDiaryOpen =
        writeProvider.otherDiaryOpen; // 글쓰기 화면(FirstStep) 열렸는지
    final shouldShowTutorialOverlay = tutorial.active &&
        !isWritingOpen &&
        !isOtherDiaryOpen &&
        pointRect != null;

    // alarm detail에서 context 필요하다면 유지
    alarmController.updateContext(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // ✅ 튜토리얼 중이면 뒤로가기 막고 현재 step 다시 시작(이탈 시 해당 단계 처음으로)
        if (tutorial.active) {
          await context.read<TutorialController>().restartFromExplain();
          // 설명 페이지가 떠야 하니 온보딩 게이트로 보내고 싶으면:
          context.read<NavigationToggleProvider>().selectIndex(-3);
          return;
        }

        if (diaryAiChatController.isChatOpen) {
          diaryAiChatController.toggleChatOpen(false);
          return;
        }

        if (alarmController.isAlarmOpen) {
          alarmController.toggleAlarmOpen(false);
          mailController.initializeNewNotificaitonCount();
          return;
        }

        if (writeProvider.write) {
          if (writeProvider.step == 1) {
            nav.selectIndex(0);
          } else if (writeProvider.step == 2) {
            nav.selectIndex(1);
          } else {
            return;
          }
          writeProvider.initialize();
          writeProvider.toggleWrite();
          return;
        }

        final shouldExit = await showFloatingConfirmSheet(
          context,
          title: '온기를 정말로 종료하시겠어요?',
          description: '언제든 위로가 필요하면 다시 찾아와 주세요.',
          cancelText: '취소',
          confirmText: '종료하기',
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: FutureBuilder<bool>(
        future: _networkFuture ?? internet.checkNetworkConnectivity(),
        builder: (context, snapshot) {
          final isOk = snapshot.connectionState == ConnectionState.waiting ||
              (snapshot.hasData && snapshot.data == true);

          return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: nav.selectedIndex != 3
                      ? const AssetImage(
                          'assets/images/backgrounds/background_dark.png')
                      : const AssetImage(
                          'assets/images/backgrounds/background_blur.png'),
                ),
              ),
              child: isOk
                  ? Scaffold(
                      backgroundColor: BandiColor.transparent(context),
                      body: Stack(
                        children: [
                          const FireFly(),

                          AppRouter.buildMain(
                            context: context,
                            nav: nav,
                            writeProvider: writeProvider,
                            diaryAiChatController: diaryAiChatController,
                            mailController: mailController,
                            alarmController: alarmController,
                          ),

                          // NavBar도 튜토리얼 중엔 막기
                          if (AppRouter.shouldShowNavBar(
                            nav: nav,
                            writeProvider: writeProvider,
                            diaryAiChatController: diaryAiChatController,
                            mailController: mailController,
                            alarmController: alarmController,
                          ))
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 32,
                              child: FrostedNavBar(
                                selectedIndex: nav.selectedIndex,
                                onTap: (i) async {
                                  final t = context.read<TutorialController>();

                                  final onlyTray = t.active &&
                                      t.phase == TutorialPhase.practice &&
                                      t.step == TutorialStep.growth &&
                                      t.growthPhase == GrowthTutorialPhase.focusTrayNav;

                                  if (onlyTray && i != 2) return;

                                  nav.selectIndex(i);

                                  if (onlyTray && i == 2) {
                                    t.setGrowthPhase(GrowthTutorialPhase.done);

                                    // ✅ practice 종료 → 다음 step
                                    await t.advanceAfterPractice();

                                    // ✅ 설명 페이지 예약 (done)
                                    t.scheduleExplainFlow(context);
                                  }
                                },
                                items: [
                                  NavItem(
                                      icon: PhosphorIcons.house(
                                          PhosphorIconsStyle.fill)),
                                  NavItem(
                                      icon: PhosphorIcons.book(
                                          PhosphorIconsStyle.fill)),
                                  NavItem(
                                      icon: PhosphorIcons.tray(
                                          PhosphorIconsStyle.fill),
                                      tutorialKey: _tutorialTrayKey),
                                  NavItem(
                                      icon: PhosphorIcons.gearSix(
                                          PhosphorIconsStyle.fill)),
                                ],
                              ),
                            ),

                          // ✅ 튜토리얼 오버레이
                          if (shouldShowTutorialOverlay)
                            TutorialOverlay(
                                targetRect: pointRect!,
                                radius: 14, // 28 / 2
                                guide: guideWidget),
                        ],
                      ),
                    )
                  : Scaffold(
                      backgroundColor: BandiColor.transparent(context),
                      body: const SizedBox.shrink(),
                    ));
        },
      ),
    );
  }
}

Rect _makePointRect(Rect base,
    {double size = 28, Offset offset = Offset.zero}) {
  final c = base.center + offset;
  return Rect.fromCenter(center: c, width: size, height: size);
}

Offset _offsetForTarget(String targetId) {
  switch (targetId) {
    case 'home.writeButton':
      return const Offset(-28, -6);
    case 'home.notificationButton':
      return const Offset(28, -6);
    case 'nav.tray':
      return const Offset(8, -8);
    default:
      return Offset.zero;
  }
}
