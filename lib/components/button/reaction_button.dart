import 'package:bandi_official/string_extention.dart';
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
    String langCode = Localizations.localeOf(context).languageCode;

    return Container(
      width: 327,
      height: 83,
      decoration: BoxDecoration(
        color: BandiColor.foundationColor80(context),
        borderRadius: BandiEffects.radiusSmall,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: langCode == 'en' ? 40 : 61.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            iconAndButtonSet(context, 'reaction_support'.tr(context),
                PhosphorIcons.gift, isFirstButtonPressed, () {
              widget.onFirstButtonPressed();
              setState(() {
                isFirstButtonPressed = true;
                if (isFirstButtonPressed) {
                  isSecondButtonPressed = isThirdButtonPressed = false;
                }
              });
            }),
            iconAndButtonSet(context, 'reaction_relate'.tr(context),
                PhosphorIcons.heart, isSecondButtonPressed, () {
              widget.onSecondButtonPressed();
              setState(() {
                isSecondButtonPressed = true;
                if (isSecondButtonPressed) {
                  isFirstButtonPressed = isThirdButtonPressed = false;
                }
              });
            }),
            iconAndButtonSet(context, 'reaction_with'.tr(context),
                PhosphorIcons.personArmsSpread, isThirdButtonPressed, () {
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
