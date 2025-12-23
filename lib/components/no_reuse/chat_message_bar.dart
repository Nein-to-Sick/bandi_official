import 'dart:ui';

import 'package:bandi_official/components/dialogue/dialogue.dart';
import 'package:bandi_official/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/controller/emotion_provider.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

class ChatMessageBar extends StatefulWidget {
  const ChatMessageBar({super.key});

  @override
  State<ChatMessageBar> createState() => _ChatMessageBarState();
}

class _ChatMessageBarState extends State<ChatMessageBar> {
  // button pressed state (just for design)
  bool isSendButtonPressed = false;
  late ScrollController listViewController;

  @override
  void initState() {
    super.initState();
    listViewController = ScrollController();
  }

  @override
  void dispose() {
    listViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DiaryAiChatController diaryAiChatController =
        context.watch<DiaryAiChatController>();

    bool sendButtonCondition() {
      if (diaryAiChatController.chatTextController.text.trim().isEmpty ||
          diaryAiChatController.isChatResponsLoading) {
        return true;
      } else {
        return false;
      }
    }

    final bottomHeight = MediaQuery.of(context).padding.bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (diaryAiChatController.sendFirstMessage)
          const SizedBox.shrink()
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'ai_chat_assistant_message_guide'.tr(context),
                      style: BandiFont.bodyMedium(context)?.copyWith(
                        color: BandiColor.neutralColor100(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 35,
                child: ListView.builder(
                  controller: listViewController,
                  physics: (listViewController.hasClients &&
                          (listViewController.position.maxScrollExtent +
                                  MediaQuery.of(context).size.width) <=
                              MediaQuery.of(context).size.width)
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics()
                          .applyTo(const BouncingScrollPhysics()),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      DiaryAiChatController.assistantMessage(context).length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: (index == 0) ? 24 : 12,
                        right: (index ==
                                DiaryAiChatController.assistantMessage(context)
                                        .length -
                                    1)
                            ? 24
                            : 0,
                      ),
                      child: CustomDialogue(
                        chatMessage: DiaryAiChatController.assistantMessage(
                            context)[index],
                        onDialoguePressed: () {
                          diaryAiChatController.onAssistantMessageSubmitted(
                              DiaryAiChatController.assistantMessage(
                                      context)[index]
                                  .message
                                  .trim(),
                              context);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          ),

        // chat message bar and send button
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: BandiEffects.backgroundBlur(),
              sigmaY: BandiEffects.backgroundBlur(),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutCirc,
              height: 78 + bottomHeight,
              decoration: BoxDecoration(
                color: BandiColor.foundationColor10(context),
                border: Border(
                  top: BorderSide(
                    width: 1,
                    color: BandiColor.foundationColor20(context),
                  ),
                ),
              ),
              child: Padding(
                padding:
                    EdgeInsets.only(left: 24, right: 24, bottom: bottomHeight),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: IgnorePointer(
                        ignoring: diaryAiChatController.isChatResponsLoading,
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: BandiColor.neutralColor20(context),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: TextField(
                            onChanged: (text) {
                              diaryAiChatController.updateTexfieldMessage();
                            },
                            controller:
                                diaryAiChatController.chatTextController,
                            focusNode: diaryAiChatController.chatFocusNode,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            cursorColor: BandiColor.neutralColor100(context),
                            style: BandiFont.labelMedium(context)?.copyWith(
                              color: BandiColor.neutralColor100(context),
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  (diaryAiChatController.isChatResponsLoading)
                                      ? 'ai_chat_textbar_message_1'.tr(context)
                                      : 'ai_chat_textbar_message_2'.tr(context),
                              hintStyle:
                                  BandiFont.labelMedium(context)?.copyWith(
                                color: BandiColor.neutralColor40(context),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTapDown: (sendButtonCondition())
                          ? null
                          : (_) {
                              dev.log('Pressed!');
                              setState(() {
                                isSendButtonPressed = true;
                              });
                            },
                      onTapUp: (sendButtonCondition())
                          ? null
                          : (_) {
                              dev.log('Run!');
                              setState(() {
                                isSendButtonPressed = false;
                              });
                              diaryAiChatController.onMessageSubmitted(context);
                            },
                      onTapCancel: (sendButtonCondition())
                          ? null
                          : () {
                              dev.log('Cancel!');
                              setState(() {
                                isSendButtonPressed = false;
                              });
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: (sendButtonCondition())
                              ? BandiColor.neutralColor20(context) // Disabled
                              : (isSendButtonPressed)
                                  ? BandiColor.neutralColor60(
                                      context) // Pressed
                                  : BandiColor.neutralColor20(
                                      context), // Default
                          borderRadius: BandiEffects.radius(),
                        ),
                        child: Center(
                          child: PhosphorIcon(
                            PhosphorIcons.paperPlaneRight(
                              PhosphorIconsStyle.fill,
                            ),
                            color: (sendButtonCondition())
                                ? BandiColor.neutralColor20(context) // Disabled
                                : BandiColor.neutralColor80(context), // Default
                            size: 26,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
