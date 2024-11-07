import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class CustomResetDialogue extends StatefulWidget {
  const CustomResetDialogue({
    super.key,
    required this.text,
    this.onYesText = '예',
    this.onNoText = '아니오',
    required this.onYesFunction,
    required this.onNoFunction,
  });
  final String text;
  final String onYesText;
  final String onNoText;
  final Function onYesFunction;
  final Function onNoFunction;

  @override
  State<CustomResetDialogue> createState() => _CustomResetDialogueState();
}

class _CustomResetDialogueState extends State<CustomResetDialogue> {
  bool isPressed = false;

  Widget responsButton(BuildContext context, String text,
      Decoration boxDecoration, TextStyle textStyle, Function onButtonPressed) {
    return Flexible(
      flex: 1,
      child: GestureDetector(
        onTapDown: (_) {
          dev.log('눌림!');
          setState(() {
            isPressed = true;
          });
        },
        onTapUp: (_) {
          dev.log('실행!');
          setState(() {
            isPressed = false;
          });
          onButtonPressed();
        },
        onTapCancel: () {
          dev.log('취소!');
          setState(() {
            isPressed = false;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: boxDecoration,
          child: Center(
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BandiEffects.radius(),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 27),
      backgroundColor: BandiColor.neutralColor100(context),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.text,
            style: BandiFont.headlineMedium(context)
                ?.copyWith(color: BandiColor.foundationColor60(context)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 24,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              responsButton(
                context,
                widget.onNoText,
                BoxDecoration(
                  color: BandiColor.foundationColor10(context),
                  borderRadius: BandiEffects.radius(),
                ),
                BandiFont.labelLarge(context)!.copyWith(
                  color: BandiColor.foundationColor100(
                    context,
                  ),
                ),
                () {
                  widget.onNoFunction();
                },
              ),
              const SizedBox(
                width: 12,
              ),
              responsButton(
                context,
                widget.onYesText,
                BoxDecoration(
                  color: BandiColor.foundationColor80(context),
                  borderRadius: BandiEffects.radius(),
                ),
                BandiFont.labelLarge(context)!.copyWith(
                  color: BandiColor.neutralColor100(
                    context,
                  ),
                ),
                () {
                  widget.onYesFunction();
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
