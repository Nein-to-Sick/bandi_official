import 'dart:developer';
import 'dart:io';

import 'package:bandi_official/localization/string_extention.dart';
import 'package:bandi_official/view/settings/controller/user_view_controller.dart';
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
import '../home/controller/bgm_controller.dart';
import '../login/controller/login_controller.dart';
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<BgmController>().init();

      if (!_loginInitDone) {
        _loginInitDone = true;
        context.read<LoginController>().init();
      }

      _ensureNetworkOrExit();
    });
  }

  Future<void> _ensureNetworkOrExit() async {
    if (_offlineLoopRunning) return;
    _offlineLoopRunning = true;

    try {
      final internet = context.read<InternetConnectionController>();

      while (mounted) {
        final ok = await internet.checkNetworkConnectivity();

        // ✅ 연결되면 끝
        if (ok == true) {
          setState(() {
            _networkFuture = Future.value(true);
          });
          return;
        }

        if (!mounted) return;

        // ✅ 연결 안됨 → 시트 띄우고 선택 기다림
        final res = await showFloatingConfirmSheet(
          context,
          title: 'internet_connection_check_title'.tr(context),
          description: 'internet_connection_check_content'.tr(context),
          cancelText: 'internet_connection_check_button_1'.tr(context),
          confirmText: 'internet_connection_check_button_2'.tr(context),
          barrierDismissible: false,
        );

        if (!mounted) return;

        // 나가기(또는 null 포함)면 종료
        if (res != true) {
          exit(0); // 또는 SystemNavigator.pop();
        }

        // ✅ 새로고침(true) → 루프 계속(다시 체크)
        // 여기서 잠깐 딜레이 주고 싶으면:
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } finally {
      _offlineLoopRunning = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ locale 바뀔 때만 date formatting
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
    final userViewController = context.watch<UserViewController>();

    // alarm detail에서 context 필요하다면 유지
    alarmController.updateContext(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

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
          // 일기 작성시
          if (writeProvider.step == 1) {
            nav.selectIndex(0);
          }
          // 일기 열람시
          else if (writeProvider.step == 2) {
            nav.selectIndex(1);
          }
          // 일기 수정시
          else {
            return;
          }
          writeProvider.initialize();
          writeProvider.toggleWrite();
          return;
        }

        // 설정 화면시
        if (nav.selectedIndex == -2) {
          if (userViewController.settings == 2) {
            userViewController.updateSettingValue(1);
          } else {
            userViewController.updateSettingValue(0);
          }
          nav.selectIndex(3);
          return;
        }

        final shouldExit = await showFloatingConfirmSheet(
          context,
          title: 'dialogue_message_exit_app_title'.tr(context),
          description: 'dialogue_message_exit_app_content'.tr(context),
          cancelText: 'dialogue_message_exit_app_button_1'.tr(context),
          confirmText: 'dialogue_message_exit_app_button_2'.tr(context),
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
                          'assets/images/backgrounds/background_blur.png')),
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
                              onTap: (i) => nav.selectIndex(i),
                              items: [
                                NavItem(
                                    icon: PhosphorIcons.house(
                                        PhosphorIconsStyle.fill)),
                                NavItem(
                                    icon: PhosphorIcons.book(
                                        PhosphorIconsStyle.fill)),
                                NavItem(
                                    icon: PhosphorIcons.tray(
                                        PhosphorIconsStyle.fill)),
                                NavItem(
                                    icon: PhosphorIcons.gearSix(
                                        PhosphorIconsStyle.fill)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                : Scaffold(
                    backgroundColor: BandiColor.transparent(context),
                    body: const SizedBox.shrink(),
                  ),
          );
        },
      ),
    );
  }
}
