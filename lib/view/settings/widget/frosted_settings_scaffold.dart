import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../theme/custom_theme_data.dart';

class FrostedSettingsScaffold extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final Widget child;

  final bool bottomSafeArea;
  final double blurSigma;
  final Color Function(BuildContext) backgroundColorBuilder;

  const FrostedSettingsScaffold({
    super.key,
    required this.title,
    required this.onBack,
    required this.child,
    this.bottomSafeArea = false,
    this.blurSigma = BandiEffects.blurLarge,
    this.backgroundColorBuilder = BandiColor.neutralColor80,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: backgroundColorBuilder(context)),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: const SizedBox.expand(),
          ),
        ),
        SafeArea(
          bottom: bottomSafeArea,
          child: Column(
            children: [
              _settingsAppBar(context, title, onBack),
              Expanded(child: child),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _settingsAppBar(context, String title, VoidCallback onBack) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: BandiFont.headlineMedium(context)!
                  .copyWith(color: BandiColor.foundationColor100(context)),
            ),
            GestureDetector(
              onTap: onBack,
              child: PhosphorIcon(
                PhosphorIcons.x(),
                size: 24,
                color: BandiColor.foundationColor30(context),
              ),
            )
          ],
        ),
      ),
      Divider(
        height: 0,
        color: BandiColor.foundationColor04(context),
        thickness: 1,
      ),
    ],
  );
}
