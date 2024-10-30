import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bandi_official/model/diary_ai_chat.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';

class CustomDialogue extends StatefulWidget {
  const CustomDialogue(
      {super.key, required this.chatMessage, required this.onDialoguePressed});
  final ChatMessage chatMessage;
  final Function onDialoguePressed;

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
      case Messenger.special:
        boxColor = BandiColor.neutralColor90(context);
        textColor = BandiColor.foundationColor100(context);
        break;
    }
    return GestureDetector(
      onTap: () {
        widget.onDialoguePressed();
      },
      child: Row(
        mainAxisAlignment: (widget.chatMessage.messenger == Messenger.user)
            ? MainAxisAlignment.end
            : (widget.chatMessage.messenger == Messenger.ai ||
                    widget.chatMessage.messenger == Messenger.special)
                ? MainAxisAlignment.start
                : (widget.chatMessage.messenger == Messenger.system)
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: (widget.chatMessage.messenger == Messenger.user ||
                        widget.chatMessage.messenger == Messenger.ai ||
                        widget.chatMessage.messenger == Messenger.special)
                    ? 25
                    : 0),
            child: IntrinsicWidth(
              child: ClipRRect(
                borderRadius: BandiEffects.radius(),
                child: BackdropFilter(
                  filter: boxBlur,
                  child: Container(
                    constraints: BoxConstraints(
                        minHeight: 32,
                        maxWidth: MediaQuery.of(context).size.width * 0.55),
                    decoration: BoxDecoration(
                      color: boxColor,
                    ),
                    child:
                        // inner padding
                        Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Center(
                        child: (widget.chatMessage.messenger ==
                                Messenger.special)
                            ? AnimatedTextKit(
                                repeatForever: true,
                                animatedTexts: [
                                  TyperAnimatedText(
                                    '. . . . .',
                                    speed: const Duration(milliseconds: 150),
                                  ),
                                ],
                              )
                            : Text(
                                widget.chatMessage.message,
                                maxLines: 15,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: BandiFont.headlineSmall(context)
                                    ?.copyWith(color: textColor),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
