import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  StreamSubscription<LoginUiEvent>? _sub;
  bool _opened = false; // ✅ 중복 오픈 방지

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<LoginController>();

      _sub = controller.events.listen((event) async {
        if (!mounted) return;
        if (_opened) return;

        switch (event) {
          case ShowAgreementSheet():
            _opened = true;
            final accepted = await AgreementSheet().show(context);
            _opened = false;
            if (accepted == true) {
              await controller.onAgreementAccepted();
            }
            break;

          case ShowNicknameSheet():
            _opened = true;
            final nickname = await NicknameSheet().show(context);
            _opened = false;
            if (nickname != null && nickname.trim().isNotEmpty) {
              await controller.onNicknameCompleted(nickname.trim());
            }
            break;

          case LoginErrorToast(:final message):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
            break;
        }
      });

      // ✅ -3로 들어오면, controller가 이미 emit 했던 pending 이벤트를 여기서 받게 됨
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BandiColor.transparent(context),
      body: const SizedBox.expand(),
    );
  }
}
