import 'package:flutter/material.dart';

import '../../../theme/custom_theme_data.dart';
import '../../../string_extention.dart';

class OnboardingStepHeader extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;

  const OnboardingStepHeader({
    super.key,
    required this.step,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (step >= 4) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          title,
          style: BandiFont.headlineLarge(context)?.copyWith(
            color: BandiColor.neutralColor90(context),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: BandiFont.headlineMedium(context)?.copyWith(
            color: BandiColor.neutralColor60(context),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class OnboardingStepImage extends StatelessWidget {
  final int step;

  const OnboardingStepImage({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    if (step >= 4) return const SizedBox.shrink();

    final country = 'onboarding_step_image_country'.tr(context);
    final path = "assets/images/onboarding/onboarding_${step}_$country.png";

    return Image.asset(
      path,
      fit: BoxFit.contain,
    );
  }
}
