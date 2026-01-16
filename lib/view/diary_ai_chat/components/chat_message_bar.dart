import 'dart:ui';

import 'package:bandi_official/view/diary_ai_chat/components/dialogue.dart';
import 'package:bandi_official/view/diary_ai_chat/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/localization/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

import '../../tutorial/controller/tutorial_controller.dart';
import '../../tutorial/controller/tutorial_target_registry.dart';

class ChatMessageBar extends StatefulWidget {
  const ChatMessageBar({super.key});

  @override
  State<ChatMessageBar> createState() => _ChatMessageBarState();
}

class _ChatMessageBarState extends State<ChatMessageBar> {
  bool isSendButtonPressed = false;
  late ScrollController listViewController;

  // ✅ assistant message 2번째 요소 타겟
  final GlobalKey _tutorialAssistantSecondKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    listViewController = ScrollController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TutorialTargetRegistry>().unregister('aichat.assistantMessage.second');
    });

    listViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diaryAiChatController = context.watch<DiaryAiChatController>();
    final tc = context.watch<TutorialController>();

    bool sendButtonCondition() {
      return diaryAiChatController.chatTextController.text.trim().isEmpty ||
          diaryAiChatController.isChatResponsLoading;
    }

    // ✅ 튜토리얼 중 + 아직 메시지 전송 전이면 assistant second만 클릭 가능하게
    final focusingAssistantSecond =
        tc.isRetrospectFlow &&
            tc.retrospectPhase == RetrospectTutorialPhase.focusMessageBar &&
            !tc.retrospectAssistantPicked;

    final assistantList = DiaryAiChatController.assistantMessage(context);

    // ✅ 타겟 등록은 "두 번째가 존재할 때만"
    if (focusingAssistantSecond && assistantList.length >= 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final reg = context.read<TutorialTargetRegistry>();
        reg.register('aichat.assistantMessage.second', _tutorialAssistantSecondKey);
        reg.refreshAll();
      });
    } else {
      // 두번째가 없거나 튜토리얼이 아니면 등록 제거
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<TutorialTargetRegistry>().unregister('aichat.assistantMessage.second');
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (diaryAiChatController.sendFirstMessage)
          const SizedBox.shrink()
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  itemCount: assistantList.length,
                  itemBuilder: (context, index) {
                    final isSecond = (index == 1);
                    final msg = assistantList[index];

                    // ✅ 튜토리얼 중엔 두번째만 클릭 가능
                    final allowTap = focusingAssistantSecond ? isSecond : true;

                    return Padding(
                      key: isSecond ? _tutorialAssistantSecondKey : null,
                      padding: EdgeInsets.only(
                        left: (index == 0) ? 24 : 12,
                        right: (index == assistantList.length - 1) ? 24 : 0,
                      ),
                      child: IgnorePointer(
                        ignoring: !allowTap,
                        child: CustomDialogue(
                          chatMessage: msg,
                          onDialoguePressed: () {
                            diaryAiChatController.onAssistantMessageSubmitted(
                              msg.message.trim(),
                              context,
                            );

                            if (focusingAssistantSecond && isSecond) {
                              context.read<TutorialController>().markRetrospectAssistantPicked();
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

        // chat message bar and send button (기존 유지)
        ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: BandiEffects.blurLarge,
              sigmaY: BandiEffects.blurLarge,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOutCirc,
              constraints: const BoxConstraints(minHeight: 94, maxHeight: 144),
              decoration: BoxDecoration(
                color: BandiColor.neutralColor30(context),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      flex: 3,
                      child: IgnorePointer(
                        ignoring: diaryAiChatController.isChatResponsLoading,
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          constraints: const BoxConstraints(minHeight: 48, maxHeight: 96),
                          decoration: BoxDecoration(
                            color: BandiColor.neutralColor80(context),
                            borderRadius: BandiEffects.radiusSmall,
                          ),
                          child: TextField(
                            onChanged: (text) {
                              diaryAiChatController.updateTexfieldMessage();
                            },
                            controller: diaryAiChatController.chatTextController,
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
                              hintText: (diaryAiChatController.isChatResponsLoading)
                                  ? '  ${'ai_chat_textbar_message_1'.tr(context)}'
                                  : '  ${'ai_chat_textbar_message_2'.tr(context)}',
                              hintStyle: BandiFont.bodyLarge(context)?.copyWith(
                                color: BandiColor.foundationColor20(context),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.only(left: 6),
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
                          onTapDown: sendButtonCondition() ? null : (_) {
                            setState(() => isSendButtonPressed = true);
                          },
                          onTapUp: sendButtonCondition() ? null : (_) {
                            setState(() => isSendButtonPressed = false);

                            // ✅ 실제 전송
                            diaryAiChatController.onMessageSubmitted(context);

                            // ✅ 전송 1회 이상이면 X 활성/overlay 해제
                            if (tc.isRetrospectFlow &&
                                tc.retrospectPhase == RetrospectTutorialPhase.focusMessageBar) {
                              context.read<TutorialController>().markRetrospectMessageSent();
                            }
                          },
                          onTapCancel: sendButtonCondition() ? null : () {
                            setState(() => isSendButtonPressed = false);
                          },
                          child: AnimatedContainer(
                            height: 48,
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: (sendButtonCondition())
                                  ? BandiColor.foundationColor10(context)
                                  : (isSendButtonPressed)
                                  ? BandiColor.foundationColor10(context)
                                  : BandiColor.foundationColor90(context),
                              borderRadius: BandiEffects.radiusSmall,
                            ),
                            child: Center(
                              child: PhosphorIcon(
                                PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill),
                                color: (sendButtonCondition())
                                    ? BandiColor.neutralColor40(context)
                                    : BandiColor.neutralColor90(context),
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
