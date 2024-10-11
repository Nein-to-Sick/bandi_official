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
              dev.log('눌림!');
              setState(() {
                isPressed = true;
              });
            },
      onTapUp: (widget.disableButton)
          ? null
          : (_) {
              dev.log('실행!');
              setState(() {
                isPressed = false;
              });
              widget.onSecondaryButtonPressed();
            },
      onTapCancel: widget.disableButton
          ? null
          : () {
              dev.log('취소!');
              setState(() {
                isPressed = false;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 327,
        height: 46,
        decoration: BoxDecoration(
          color: (widget.disableButton)
              ? BandiColor.neutralColor20(context) // Disabled
              : (isPressed)
                  ? BandiColor.neutralColor60(context) // Pressed
                  : BandiColor.neutralColor20(context), // Default
          borderRadius: BandiEffects.radius(),
        ),
        child: Center(
          child: Text(
            widget.title,
            style: BandiFont.bodyMedium(context)?.copyWith(
              color: (widget.disableButton)
                  ? BandiColor.neutralColor20(context) // Disabled
                  : BandiColor.neutralColor100(context), // Default
            ),
          ),
        ),
      ),
    );
  }
}
