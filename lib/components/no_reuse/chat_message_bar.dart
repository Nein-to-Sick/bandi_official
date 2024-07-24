import 'dart:ui';

import 'package:bandi_official/components/dialogue/dialogue.dart';
import 'package:bandi_official/controller/diary_ai_chat_controller.dart';
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
  final ScrollController listViewController = ScrollController();

  @override
  void initState() {
    super.initState();
    listViewController.addListener(() {
      setState(() {});
    });
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '이렇게 대화를 시작해 보세요!',
                      // TODO: 폰트 설정이 없음
                      style: BandiFont.headlineSmall(context)?.copyWith(
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
                          (listViewController.position.maxScrollExtent) <
                              MediaQuery.of(context).size.width)
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics()
                          .applyTo(const BouncingScrollPhysics()),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: diaryAiChatController.assistantMessage.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                          left: 13,
                          right: (index ==
                                  diaryAiChatController
                                          .assistantMessage.length -
                                      1)
                              ? 13
                              : 0),
                      child: CustomDialogue(
                        chatMessage:
                            diaryAiChatController.assistantMessage[index],
                        onDialoguePressed: () {
                          diaryAiChatController.onAssistantMessageSubmitted(
                            diaryAiChatController
                                .assistantMessage[index].message
                                .trim(),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        const SizedBox(
          height: 15,
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
              height: 56,
              decoration: BoxDecoration(
                color: BandiColor.foundationColor10(context),
                border: Border(
                  top: BorderSide(
                    width: 1,
                    color: BandiColor.foundationColor20(context),
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: IgnorePointer(
                      ignoring: diaryAiChatController.isChatResponsLoading,
                      child: TextField(
                        onChanged: (text) {
                          diaryAiChatController.updateTexfieldMessage();
                        },
                        controller: diaryAiChatController.chatTextController,
                        focusNode: diaryAiChatController.chatFocusNode,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        cursorColor: BandiColor.neutralColor100(context),
                        style: BandiFont.headlineLarge(context)?.copyWith(
                          color: BandiColor.neutralColor100(context),
                        ),
                        decoration: InputDecoration(
                          hintText: (diaryAiChatController.isChatResponsLoading)
                              ? '답변 중이에요'
                              : '대화를 시작해보세요',
                          hintStyle: BandiFont.headlineLarge(context)?.copyWith(
                            color: BandiColor.neutralColor100(context),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(left: 5.5),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 5.5),
                    child: GestureDetector(
                      onTapDown: (diaryAiChatController.chatTextController.text
                                  .trim()
                                  .isEmpty ||
                              diaryAiChatController.isChatResponsLoading)
                          ? null
                          : (_) {
                              dev.log('눌림!');
                              setState(() {
                                isSendButtonPressed = true;
                              });
                            },
                      onTapUp: (diaryAiChatController.chatTextController.text
                                  .trim()
                                  .isEmpty ||
                              diaryAiChatController.isChatResponsLoading)
                          ? null
                          : (_) {
                              dev.log('실행!');
                              setState(() {
                                isSendButtonPressed = false;
                              });
                              if (diaryAiChatController.chatTextController.text
                                  .trim()
                                  .isNotEmpty) {
                                diaryAiChatController.onMessageSubmitted();
                              }
                            },
                      onTapCancel: (diaryAiChatController
                                  .chatTextController.text
                                  .trim()
                                  .isEmpty ||
                              diaryAiChatController.isChatResponsLoading)
                          ? null
                          : () {
                              dev.log('취소!');
                              setState(() {
                                isSendButtonPressed = false;
                              });
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (diaryAiChatController.chatTextController.text
                                      .trim()
                                      .isEmpty ||
                                  diaryAiChatController.isChatResponsLoading)
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
                            color: (diaryAiChatController
                                        .chatTextController.text
                                        .trim()
                                        .isEmpty ||
                                    diaryAiChatController.isChatResponsLoading)
                                ? BandiColor.neutralColor20(context) // Disabled
                                : BandiColor.neutralColor80(context), // Default
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
