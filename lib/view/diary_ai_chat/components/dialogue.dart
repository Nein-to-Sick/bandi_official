import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bandi_official/model/diary_ai_chat.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDialogue extends StatefulWidget {
  const CustomDialogue(
      {super.key, required this.chatMessage, required this.onDialoguePressed});
  final ChatMessage chatMessage;
  final Function onDialoguePressed;

  @override
  State<CustomDialogue> createState() => _CustomDialogueState();
}

class _CustomDialogueState extends State<CustomDialogue> {
  bool _isMessageToday(String message, BuildContext context) {
    DateTime now = DateTime.now();
    String todayFormatted = DateFormat(
      'ai_chat_date_form'.tr(context),
      'ai_chat_date_form_country'.tr(context),
    ).format(now);

    return message == todayFormatted;
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration? boxDeco;
    Color? textColor;
    EdgeInsets padding =
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12);

    String textData = widget.chatMessage.message;
    bool isMessageTypeSysOrAssist =
        widget.chatMessage.messenger == Messenger.system ||
            widget.chatMessage.messenger == Messenger.assistant;

    switch (widget.chatMessage.messenger) {
      case Messenger.user:
        boxDeco = BoxDecoration(color: BandiColor.foundationColor80(context));
        textColor = BandiColor.neutralColor100(context);
        break;
      case Messenger.special:
      case Messenger.ai:
        boxDeco = BoxDecoration(color: BandiColor.neutralColor90(context));
        textColor = BandiColor.foundationColor100(context);
        break;
      case Messenger.system:
        bool isToday = _isMessageToday(widget.chatMessage.message, context);
        textData = isToday ? 'ai_chat_today'.tr(context) : textData;
        boxDeco = BoxDecoration(color: BandiColor.transparent(context));
        textColor = BandiColor.foundationColor40(context);
        padding = const EdgeInsets.symmetric(horizontal: 12);
        break;
      case Messenger.assistant:
        boxDeco = BoxDecoration(
          border: Border.all(
            color: BandiColor.foundationColor10(context),
            width: 1,
          ),
          borderRadius: BandiEffects.radiusSmall,
          color: BandiColor.transparent(context),
        );
        textColor = BandiColor.foundationColor30(context);
        padding = const EdgeInsets.symmetric(horizontal: 12);
        break;
    }
    return GestureDetector(
      onTap: () {
        widget.onDialoguePressed();
      },
      child: Row(
        mainAxisAlignment: (widget.chatMessage.messenger == Messenger.user)
            ? MainAxisAlignment.end
            : (widget.chatMessage.messenger == Messenger.system)
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
        children: [
          if (widget.chatMessage.messenger == Messenger.system)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Container(
                  height: 1,
                  color: BandiColor.foundationColor10(context),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: (isMessageTypeSysOrAssist) ? 0 : 24),
            child: IntrinsicWidth(
              child: ClipRRect(
                borderRadius: BandiEffects.radiusSmall,
                child: Container(
                  padding: padding,
                  constraints: BoxConstraints(
                    minHeight: 49,
                    maxWidth: (isMessageTypeSysOrAssist)
                        ? double.infinity
                        : MediaQuery.of(context).size.width * 0.66,
                  ),
                  decoration: boxDeco,
                  child: Center(
                    child: (widget.chatMessage.messenger == Messenger.special)
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
                            textData,
                            maxLines: 15,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: BandiFont.bodyMedium(context)?.copyWith(
                              color: textColor,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          if (widget.chatMessage.messenger == Messenger.system)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Container(
                  height: 1,
                  color: BandiColor.foundationColor10(context),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
