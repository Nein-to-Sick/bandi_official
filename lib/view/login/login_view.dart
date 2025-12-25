import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/navigation_toggle_provider.dart';
import 'login_page.dart';
import 'onboarding_page.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationToggleProvider>();

    // -4면 온보딩, 아니면 로그인
    return nav.getIndex() == -4 ? const OnboardingPage() : const LoginPage();
  }
}
