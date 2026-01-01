import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';

class CustomPrimaryButton extends StatefulWidget {
  const CustomPrimaryButton({
    super.key,
    this.icon,
    this.size = "large",
    required this.title,
    required this.onPrimaryButtonPressed,
    required this.disableButton,
  });

  final PhosphorIconData? icon;
  final String title;
  final VoidCallback onPrimaryButtonPressed;
  final bool disableButton;
  final String? size;

  @override
  State<CustomPrimaryButton> createState() => _CustomPrimaryButtonState();
}

class _CustomPrimaryButtonState extends State<CustomPrimaryButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.disableButton
          ? null
          : (_) {
              dev.log('Pressed!');
              setState(() => isPressed = true);
            },
      onTapUp: widget.disableButton
          ? null
          : (_) {
              dev.log('Run!');
              setState(() => isPressed = false);
              widget.onPrimaryButtonPressed();
            },
      onTapCancel: widget.disableButton
          ? null
          : () {
              dev.log('Cancel!');
              setState(() => isPressed = false);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.disableButton
              ? BandiColor.foundationColor40(context)
              : isPressed
                  ? BandiColor.foundationColor40(context)
                  : BandiColor.foundationColor90(context),
          borderRadius: BorderRadius.circular(100),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: widget.size == "small" ? 13 : 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              PhosphorIcon(
                widget.icon!,
                size: 16,
                color: widget.disableButton
                    ? BandiColor.neutralColor20(context)
                    : BandiColor.neutralColor90(context),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              widget.title,
              style: widget.size == "small"
                  ? BandiFont.labelMedium(context)?.copyWith(
                      color: widget.disableButton
                          ? BandiColor.neutralColor20(context)
                          : BandiColor.neutralColor90(context),
                    )
                  : BandiFont.labelLarge(context)?.copyWith(
                      color: widget.disableButton
                          ? BandiColor.neutralColor20(context)
                          : BandiColor.neutralColor90(context),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
