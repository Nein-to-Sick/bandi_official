import 'dart:async';
import 'dart:developer';
import 'package:bandi_official/view/login/controller/login_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/navigation_toggle_provider.dart';
import '../../controller/user_info_controller.dart';
import '../tutorial/controller/tutorial_controller.dart';
import '../tutorial/tutorial_flow_page.dart';
import 'sheets/agreement_sheet.dart';
import 'sheets/nickname_sheet.dart';

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

    final tutorial = context.read<TutorialController>();
    final nav = context.read<NavigationToggleProvider>();
    final userInfo = context.read<UserInfoValueModel>();
    final login = context.read<LoginController>();

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      userInfo.updateUserID(uid);
      await userInfo.loadProfileFromServer(uid);
    }

    await tutorial.loadFromStorage();

    log('[GATE] kick '
        'agreed=${userInfo.isAgreed} '
        'nick="${userInfo.getNickName()}" '
        'tutorialActive=${tutorial.active} '
        'finished=${tutorial.finished} '
        'phase=${tutorial.phase} '
        'step=${tutorial.step}');

    // =========================
    // 1️⃣ 약관 (미동의면 무조건 여기)
    // =========================
    if (!userInfo.isAgreed) {
      final accepted = await AgreementSheet().show(context);
      if (!mounted) { _opened = false; return; }

      if (accepted != true) {
        _opened = false;
        return;
      } else {
        await login.onAgreementAccepted();
      }
    }

    // =========================
    // 2️⃣ 닉네임 (동의는 했지만 닉네임 없으면 무조건 여기)
    // =========================
    if (userInfo.getNickName().trim().isEmpty) {
      final nickname = await NicknameSheet().show(context);
      if (!mounted) { _opened = false; return; }

      if (nickname == null || nickname.trim().isEmpty) {
        _opened = false;
        return;
      }

    }

    // =========================
    // 3️⃣ 튜토리얼 (동의+닉네임 완료면 여기서 시작/재개)
    // =========================
    if (!tutorial.finished) {
      if (tutorial.flowOpened || tutorial.hasPendingFlow) {
        _opened = false;
        return;
      }

      if (tutorial.active) {
        if (tutorial.phase != TutorialPhase.explain) {
          await tutorial.restartFromExplain();
        }
      } else {
        await tutorial.start();
      }

      final res = await tutorial.showExplainFlowNow(context);
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
    // 4️⃣ 모든 온보딩 완료 → 메인
    // =========================
    nav.selectIndex(0);
    _opened = false;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.transparent, body: SizedBox.expand());
  }
}
