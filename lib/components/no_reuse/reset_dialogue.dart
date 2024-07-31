import 'package:bandi_official/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

import 'package:provider/provider.dart';

class CustomResetDialogue extends StatefulWidget {
  const CustomResetDialogue({super.key, required this.diaryAiChatController});
  final DiaryAiChatController diaryAiChatController;

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
      backgroundColor: BandiColor.neutralColor10(context),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '대화 내용을 리셋하실건가요? 리셋한 대화내용은 다시 볼 수 없어요.',
            style: BandiFont.headlineMedium(context)
                ?.copyWith(color: BandiColor.foundationColor80(context)),
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
                '아니요',
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
                  Navigator.pop(context);
                },
              ),
              const SizedBox(
                width: 12,
              ),
              responsButton(
                context,
                '네',
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
                  widget.diaryAiChatController.resetTheChat(context);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

Future<bool?> showResetDialog(
    BuildContext context, DiaryAiChatController diaryAiChatController) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CustomResetDialogue(
        diaryAiChatController: diaryAiChatController,
      );
    },
  );
}
