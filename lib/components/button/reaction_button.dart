import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:developer' as dev;

class CustomReactionButton extends StatefulWidget {
  const CustomReactionButton({
    super.key,
    required this.onFirstButtonPressed,
    required this.onSecondButtonPressed,
    required this.onThirdButtonPressed,
  });
  final Function onFirstButtonPressed;
  final Function onSecondButtonPressed;
  final Function onThirdButtonPressed;

  @override
  State<CustomReactionButton> createState() => _CustomReactionButtonState();
}

class _CustomReactionButtonState extends State<CustomReactionButton> {
  bool isFirstButtonPressed = false;
  bool isSecondButtonPressed = false;
  bool isThirdButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 327,
      height: 83,
      decoration: BoxDecoration(
        color: BandiColor.foundationColor80(context),
        borderRadius: BandiEffects.radius(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 61.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            iconAndButtonSet(
                context, '응원해요', PhosphorIcons.gift, isFirstButtonPressed, () {
              widget.onFirstButtonPressed();
              setState(() {
                isFirstButtonPressed = true;
                if (isFirstButtonPressed) {
                  isSecondButtonPressed = isThirdButtonPressed = false;
                }
              });
            }),
            iconAndButtonSet(
                context, '공감해요', PhosphorIcons.heart, isSecondButtonPressed,
                () {
              widget.onSecondButtonPressed();
              setState(() {
                isSecondButtonPressed = true;
                if (isSecondButtonPressed) {
                  isFirstButtonPressed = isThirdButtonPressed = false;
                }
              });
            }),
            iconAndButtonSet(context, '함께해요', PhosphorIcons.personArmsSpread,
                isThirdButtonPressed, () {
              widget.onThirdButtonPressed();
              setState(() {
                isThirdButtonPressed = true;
                if (isThirdButtonPressed) {
                  isSecondButtonPressed = isFirstButtonPressed = false;
                }
              });
            }),
          ],
        ),
      ),
    );
  }
}

Widget iconAndButtonSet(
  BuildContext context,
  String title,
  PhosphorIconData Function([PhosphorIconsStyle]) icon,
  bool isButtonPressed,
  Function onButtonPressed,
) {
  return GestureDetector(
    onTap: () {
      onButtonPressed();
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PhosphorIcon(
          (isButtonPressed)
              ? icon(PhosphorIconsStyle.fill)
              : icon(PhosphorIconsStyle.regular),
          color: (isButtonPressed)
              ? BandiColor.neutralColor100(context)
              : BandiColor.neutralColor40(context),
          size: 32,
        ),
        Text(
          title,
          style: BandiFont.labelLarge(context)?.copyWith(
            color: (isButtonPressed)
                ? BandiColor.neutralColor100(context)
                : BandiColor.neutralColor40(context),
          ),
        ),
      ],
    ),
  );
}
