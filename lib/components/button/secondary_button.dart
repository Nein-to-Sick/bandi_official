import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class CustomSecondaryButton extends StatefulWidget {
  const CustomSecondaryButton({
    super.key,
    required this.title,
    required this.onSecondaryButtonPressed,
    required this.disableButton,
  });
  final String title;
  final Function onSecondaryButtonPressed;
  final bool disableButton;

  @override
  State<CustomSecondaryButton> createState() => _CustomSecondaryButtonState();
}

class _CustomSecondaryButtonState extends State<CustomSecondaryButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.disableButton
          ? null
          : (_) {
              dev.log('Pressed!');
              setState(() {
                isPressed = true;
              });
            },
      onTapUp: (widget.disableButton)
          ? null
          : (_) {
              dev.log('Run!');
              setState(() {
                isPressed = false;
              });
              widget.onSecondaryButtonPressed();
            },
      onTapCancel: widget.disableButton
          ? null
          : () {
              dev.log('Cancel!');
              setState(() {
                isPressed = false;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: (widget.disableButton)
              ? BandiColor.neutralColor20(context) // Disabled
              : (isPressed)
                  ? BandiColor.foundationColor80(context) // Pressed
                  : BandiColor.foundationColor10(context), // Default
          borderRadius: BandiEffects.radiusSmall,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Center(
            child: Text(
              widget.title,
              style: BandiFont.bodyMedium(context)?.copyWith(
                color: (widget.disableButton)
                    ? BandiColor.neutralColor20(context) // Disabled
                    : (isPressed)
                    ? BandiColor.neutralColor80(context) // Pressed
                    : BandiColor.foundationColor80(context), // Default
              ),
            ),
          ),
        ),
      ),
    );
  }
}
