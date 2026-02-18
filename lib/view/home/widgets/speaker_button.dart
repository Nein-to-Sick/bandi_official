import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SpeakerButton extends StatelessWidget {
  final bool speakerOn;
  final VoidCallback onPressed;

  const SpeakerButton({
    super.key,
    required this.speakerOn,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: PhosphorIcon(
        speakerOn
            ? PhosphorIcons.speakerSimpleHigh(PhosphorIconsStyle.light)
            : PhosphorIcons.speakerSimpleSlash(PhosphorIconsStyle.light),
        size: 24,
        color: BandiColor.neutralColor90(context),
      ),
    );
  }
}