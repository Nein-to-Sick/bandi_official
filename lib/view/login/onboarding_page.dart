import 'dart:async';

import 'package:bandi_official/view/login/sheets/nickname_sheet.dart';
import 'package:flutter/material.dart';

import '../../theme/custom_theme_data.dart';
import '../../localization/string_extention.dart';
import '../../components/button/primary_button.dart';
import '../../components/button/secondary_button.dart';

import 'controller/onboarding_controller.dart';
import 'widgets/onboarding_step.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final OnboardingController controller;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    controller = OnboardingController();

    _sub = controller.events.listen((event) async {
      if (!mounted) return;

      switch (event) {
        case ShowNicknameSheet():
          await NicknameSheet().show(context);
          break;
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BandiColor.transparent(context),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final step = controller.step;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (step < 4) const SizedBox(height: 116),
                  if (step < 4)
                    OnboardingStepHeader(
                      step: step,
                      title: (step == 1)
                          ? "onboarding_step_title_1".tr(context)
                          : (step == 2)
                              ? "onboarding_step_title_2".tr(context)
                              : "onboarding_step_title_3".tr(context),
                      subtitle: (step == 1)
                          ? "onboarding_step_subtitle_1".tr(context)
                          : (step == 2)
                              ? "onboarding_step_subtitle_2".tr(context)
                              : "onboarding_step_subtitle_3".tr(context),
                    ),
                  if (step < 4)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.5),
                        child: OnboardingStepImage(step: step),
                      ),
                    ),
                  if (step < 3)
                    CustomSecondaryButton(
                      title: 'onboarding_step_button_1'.tr(context),
                      onSecondaryButtonPressed: controller.skipToNickname,
                      disableButton: false,
                    ),
                  const SizedBox(height: 12),
                  if (step < 4)
                    CustomPrimaryButton(
                      title: step < 3
                          ? 'onboarding_step_button_2'.tr(context)
                          : 'onboarding_step_button_3'.tr(context),
                      onPrimaryButtonPressed: controller.next,
                      disableButton: false,
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
