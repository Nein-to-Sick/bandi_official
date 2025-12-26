import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class CustomPrimaryButton extends StatefulWidget {
  const CustomPrimaryButton({
    super.key,
    required this.title,
    required this.onPrimaryButtonPressed,
    required this.disableButton,
  });
  final String title;
  final Function onPrimaryButtonPressed;
  final bool disableButton;

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
              widget.onPrimaryButtonPressed();
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
        height: 46,
        decoration: BoxDecoration(
          color: (widget.disableButton)
              ? BandiColor.foundationColor40(context) // Disabled
              : (isPressed)
                  ? BandiColor.foundationColor40(context) // Pressed
                  : BandiColor.foundationColor90(context), // Default
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Text(
            widget.title,
            style: BandiFont.labelLarge(context)?.copyWith(
              color: (widget.disableButton)
                  ? BandiColor.neutralColor20(context) // Disabled
                  : BandiColor.neutralColor90(context), // Default
            ),
          ),
        ),
      ),
    );
  }
}
