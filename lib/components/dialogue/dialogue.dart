import 'dart:ui';

import 'package:bandi_official/model/diary_ai_chat.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';

class CustomDialogue extends StatefulWidget {
  const CustomDialogue({super.key, required this.chatMessage});
  final ChatMessage chatMessage;

  @override
  State<CustomDialogue> createState() => _CustomDialogueState();
}

class _CustomDialogueState extends State<CustomDialogue> {
  Color? boxColor;
  Color? textColor;
  ImageFilter boxBlur = ImageFilter.blur(sigmaX: 0, sigmaY: 0);

  @override
  Widget build(BuildContext context) {
    switch (widget.chatMessage.messenger) {
      case Messenger.user:
        boxColor = BandiColor.foundationColor80(context);
        textColor = BandiColor.neutralColor100(context);
        break;
      case Messenger.ai:
        boxColor = BandiColor.neutralColor90(context);
        textColor = BandiColor.foundationColor100(context);
        break;
      case Messenger.system:
        boxColor = BandiColor.foundationColor10(context);
        textColor = BandiColor.neutralColor100(context);
        break;
      case Messenger.assistant:
        boxColor = BandiColor.neutralColor20(context);
        textColor = BandiColor.neutralColor100(context);
        boxBlur = ImageFilter.blur(
            sigmaX: BandiEffects.backgroundBlur(),
            sigmaY: BandiEffects.backgroundBlur());
        break;
    }
    return IntrinsicWidth(
      child: ClipRRect(
        borderRadius: BandiEffects.radius(),
        child: BackdropFilter(
          filter: boxBlur,
          child: Container(
            constraints: BoxConstraints(
                minHeight: 31,
                maxWidth: MediaQuery.of(context).size.width * 0.55),
            decoration: BoxDecoration(
              color: boxColor,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Center(
                child: Text(
                  widget.chatMessage.message,
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                  style: BandiFont.headlineSmall(context)
                      ?.copyWith(color: textColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
