import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:bandi_official/components/dialogue/reset_dialogue.dart';
import 'package:bandi_official/view/alarm/controller/alarm_controller.dart';
import 'package:bandi_official/view/diary_ai_chat/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/controller/internet_connection_controller.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // ✅ BGM init (1회)
      context.read<BgmController>().init();

      // ✅ 자동 로그인 init (1회)
      if (!_loginInitDone) {
        _loginInitDone = true;
        context.read<LoginController>().init();
      }

      final internet = context.read<InternetConnectionController>();
      setState(() {
        _networkFuture = internet.checkNetworkConnectivity();
      });
    });
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

        final shouldExit = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => CustomResetDialogue(
            text: 'dialogue_message_exit_app'.tr(context),
            onYesText: 'dialogue_yes'.tr(context),
            onNoText: 'dialogue_no'.tr(context),
            onYesFunction: () => Navigator.pop(context, true),
            onNoFunction: () => Navigator.pop(context, false),
          ),
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
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image:
                    AssetImage('assets/images/backgrounds/background_dark.png'),
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
                            bottom: MediaQuery.of(context).padding.bottom,
                            child: FrostedNavBar(
                              width: 327,
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
                    body: Center(
                      child: CustomResetDialogue(
                        text: 'internet_connection_check'.tr(context),
                        onYesText: 'internet_connection_refresh'.tr(context),
                        onNoText: 'internet_connection_exit'.tr(context),
                        onYesFunction: () {
                          log('새로고침!');
                          setState(() {
                            _networkFuture =
                                internet.checkNetworkConnectivity();
                          });
                        },
                        onNoFunction: () => exit(0),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
