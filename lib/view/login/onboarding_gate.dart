import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/navigation_toggle_provider.dart';
import '../../controller/user_info_controller.dart';
import '../tutorial/controller/tutorial_controller.dart';
import '../tutorial/tutorial_flow_page.dart';
import 'controller/login_controller.dart';
import 'sheets/agreement_sheet.dart';
import 'sheets/nickname_sheet.dart';
import '../../theme/custom_theme_data.dart';

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key});

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _kick());
  }

  Future<void> _kick() async {
    if (!mounted || _opened) return;
    _opened = true;

    final login = context.read<LoginController>();
    final tutorial = context.read<TutorialController>();
    final nav = context.read<NavigationToggleProvider>();
    final userInfo = context.read<UserInfoValueModel>();

    log('[GATE] kick '
        'agreed=${userInfo.isAgreed} '
        'nick="${userInfo.getNickName()}" '
        'tutorialActive=${tutorial.active} '
        'phase=${tutorial.phase} '
        'step=${tutorial.step}');

    // =====================================================
    // 1️⃣ 튜토리얼을 이미 시작한 적이 있다면 → 무조건 재개
    // =====================================================
    if (tutorial.active && !tutorial.finished) {
      // 항상 explain부터 다시
      if (tutorial.phase != TutorialPhase.explain) {
        await tutorial.restartFromExplain();
      }

      while (mounted &&
          tutorial.active &&
          tutorial.phase == TutorialPhase.explain) {
        final idx = tutorial.explainIndex;

        final res = await TutorialFlowPage.show(
          context,
          startIndex: idx,
        );

        if (!mounted || res == null) break;

        nav.selectIndex(0);
        await Future.delayed(const Duration(milliseconds: 16));
        await tutorial.beginPracticeForStep(res.step);

        _opened = false;
        return;
      }
    }

    // =========================
    // 2️⃣ 신규 유저 → 약관
    // =========================
    if (!userInfo.isAgreed) {
      final accepted = await AgreementSheet().show(context);
      if (!mounted) { _opened = false; return; }

      if (accepted == true) {
        await login.onAgreementAccepted();
      } else {
        _opened = false;
        return;
      }
    }

    // =========================
    // 3️⃣ 신규 튜토리얼 시작
    // =========================
    if (!tutorial.finished) {
      await tutorial.start(); // explain부터 시작

      final idx = tutorial.explainIndex;
      final res = await TutorialFlowPage.show(context, startIndex: idx);
      if (!mounted || res == null) {
        _opened = false;
        return;
      }

      nav.selectIndex(0);
      await Future.delayed(const Duration(milliseconds: 16));
      await tutorial.beginPracticeForStep(res.step);

      _opened = false;
      return;
    }

    // =========================
    // 4️⃣ 닉네임
    // =========================
    if (userInfo.getNickName().trim().isEmpty) {
      final nickname = await NicknameSheet().show(context);
      if (!mounted) { _opened = false; return; }

      if (nickname != null && nickname.trim().isNotEmpty) {
        await login.onNicknameCompleted(nickname.trim());
      }
    }

    _opened = false;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.transparent, body: SizedBox.expand());
  }
}
