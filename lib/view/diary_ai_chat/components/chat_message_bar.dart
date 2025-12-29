import 'dart:ui';

import 'package:bandi_official/view/diary_ai_chat/components/dialogue.dart';
import 'package:bandi_official/view/diary_ai_chat/controller/diary_ai_chat_controller.dart';
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
              /*
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
              */

              // assistant message
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
            ],
          ),

        // chat message bar and send button
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCirc,
          height: 94 + bottomHeight,
          decoration: BoxDecoration(
            color: BandiColor.transparent(context),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                left: 24, right: 24, top: 16, bottom: bottomHeight),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 3,
                  child: IgnorePointer(
                    ignoring: diaryAiChatController.isChatResponsLoading,
                    child: ClipRRect(
                      borderRadius: BandiEffects.radiusLarge,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: BandiEffects.blurLarge,
                          sigmaY: BandiEffects.blurLarge,
                        ),
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: BandiColor.neutralColor40(context),
                            borderRadius: BandiEffects.radiusLarge,
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
                            cursorColor: BandiColor.foundationColor90(context),
                            cursorWidth: 1.5,
                            cursorHeight: 18,
                            style: BandiFont.bodyLarge(context)?.copyWith(
                              color: BandiColor.foundationColor90(context),
                            ),
                            decoration: InputDecoration(
                              hintText: (diaryAiChatController
                                      .isChatResponsLoading)
                                  ? '  ${'ai_chat_textbar_message_1'.tr(context)}'
                                  : '  ${'ai_chat_textbar_message_2'.tr(context)}',
                              hintStyle: BandiFont.bodyLarge(context)?.copyWith(
                                color: BandiColor.foundationColor20(context),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
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
                        height: 46,
                        decoration: BoxDecoration(
                          color: (sendButtonCondition())
                              ? BandiColor.foundationColor10(
                                  context) // Disabled
                              : (isSendButtonPressed)
                                  ? BandiColor.foundationColor10(
                                      context) // Pressed
                                  : BandiColor.foundationColor90(
                                      context), // Default
                          borderRadius: BandiEffects.radiusLarge,
                        ),
                        child: Center(
                          child: PhosphorIcon(
                            PhosphorIcons.paperPlaneRight(
                              PhosphorIconsStyle.fill,
                            ),
                            color: (sendButtonCondition())
                                ? BandiColor.neutralColor40(context) // Disabled
                                : BandiColor.neutralColor90(context), // Default
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
