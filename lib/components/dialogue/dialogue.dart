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
    }
    return IntrinsicWidth(
      child: Container(
        constraints: BoxConstraints(
            minHeight: 31, maxWidth: MediaQuery.of(context).size.width * 0.55),
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BandiEffects.radius(),
        ),
        child: Padding(
          // inner padding
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Center(
            child: Text(
              widget.chatMessage.message,
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
              style:
                  BandiFont.headlineSmall(context)?.copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
