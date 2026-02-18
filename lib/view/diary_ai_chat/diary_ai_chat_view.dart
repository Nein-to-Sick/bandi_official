import 'dart:io';
import 'dart:ui'; // Blur 처리를 위해 필요
import 'dart:math' as math;

import 'package:bandi_official/components/appbar/new_custom_appbar.dart';
import 'package:bandi_official/components/bottom_sheet/show_floating_confirm_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/localization/string_extention.dart';
import 'package:bandi_official/view/diary_ai_chat/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/view/diary_ai_chat/components/dialogue.dart';
import 'package:bandi_official/view/diary_ai_chat/components/chat_message_bar.dart';

import '../tutorial/controller/tutorial_controller.dart';
import '../tutorial/controller/tutorial_target_registry.dart';
import '../tutorial/tutorial_overlay.dart';

class DiaryAIChatSheet {
  Future<void> show(BuildContext context, {bool lockDismiss = false}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: !lockDismiss,
      isDismissible: !lockDismiss,
      barrierColor: BandiColor.transparent(context),
      backgroundColor: BandiColor.neutralColor60(context),
      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: BandiEffects.blurSmall,
            sigmaY: BandiEffects.blurSmall,
          ),
          child: const _DiaryAIChatStateful(),
        );
      },
    );
  }
}

class _DiaryAIChatStateful extends StatefulWidget {
  const _DiaryAIChatStateful();

  @override
  State<_DiaryAIChatStateful> createState() => _DiaryAIChatStatefulState();
}

class _DiaryAIChatStatefulState extends State<_DiaryAIChatStateful> {
  late DiaryAiChatController diaryAiChatController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      diaryAiChatController =
          Provider.of<DiaryAiChatController>(context, listen: false);

      diaryAiChatController.loadDataAndSetting().then((value) {
        if (!diaryAiChatController.isListenerAdded) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            diaryAiChatController.chatScrollController
                .addListener(_scrollListener);
            diaryAiChatController.toggleIsListenerAdded(true);
            if (!diaryAiChatController.sendFirstMessage) {
              diaryAiChatController.chatLogInitialization(context);
            }
          });
        }
      });
    });
  }

  void _scrollListener() async {
    if (!diaryAiChatController.loadMoreData ||
        diaryAiChatController.isLoadingOlderChat) {
      return;
    }

    final position = diaryAiChatController.chatScrollController.position;

    if (position.maxScrollExtent - position.pixels <= 200) {
      bool hasMore = await diaryAiChatController.loadOlderChatLogs();
      diaryAiChatController.toggleLoadMoreData(hasMore);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (diaryAiChatController.isListenerAdded) {
        diaryAiChatController.chatScrollController
            .removeListener(_scrollListener);
        diaryAiChatController.toggleIsListenerAdded(false);
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diaryAiChatController = context.watch<DiaryAiChatController>();
    final tc = context.watch<TutorialController>();
    final reg = context.watch<TutorialTargetRegistry>();

    final lockExit = tc.isRetrospectFlow && !tc.retrospectMessageSent;

    // ✅ 이제 "assistant message의 2번째 요소"를 포커싱 타겟으로 사용
    final focusingAssistantSecond =
        tc.isRetrospectFlow &&
            tc.retrospectPhase == RetrospectTutorialPhase.focusMessageBar &&
            !tc.retrospectAssistantPicked;

    final rawRect =
    focusingAssistantSecond ? reg.rectOf('aichat.assistantMessage.second') : null;

    // ✅ global rect -> sheet(local) rect 변환
    Rect? localRect;
    if (rawRect != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        reg.refreshAll();
      });

      final overlayBox = context.findRenderObject() as RenderBox;
      final tl = overlayBox.globalToLocal(rawRect.topLeft);
      final br = overlayBox.globalToLocal(rawRect.bottomRight);
      localRect = Rect.fromPoints(tl, br).shift(const Offset(-20, -4));
    }

    if (focusingAssistantSecond) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        FocusManager.instance.primaryFocus?.unfocus();
        reg.refreshAll();
      });
    }
    final sysBottom = MediaQuery.of(context).viewPadding.bottom;
    final extraBottom = Platform.isAndroid ? math.min(sysBottom, 48.0) : 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: extraBottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9 - extraBottom,
        decoration: BoxDecoration(
          color: BandiColor.neutralColor80(context),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(BandiEffects.radiusValueSmall),
          ),
        ),
        child: Stack(
          children: [
            Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: BandiColor.transparent(context),
              appBar: NewCustomAppBar(
                appBarType: AppBarType.headLineFoundation,
                title: 'ai_chat_title'.tr(context),
                leftActionButtonIcon: PhosphorIcons.signOut(PhosphorIconsStyle.thin),
                rightActionButtonIcon: PhosphorIcons.x(PhosphorIconsStyle.thin),
                onLeftActionButtonPressed: () async {
                  final ok = await showFloatingConfirmSheet(
                    context,
                    title: 'v2_ai_chat_confirm_title'.tr(context),
                    description: 'v2_ai_chat_confirm_content'.tr(context),
                    cancelText: 'v2_ai_chat_confirm_button_1'.tr(context),
                    confirmText: 'v2_ai_chat_confirm_button_2'.tr(context),
                  );

                  if (ok == true) {
                    diaryAiChatController.resetTheChat(context);
                  }
                },
                onRightActionButtonPressed: () {
                  Navigator.pop(context);
                },
                disableLefttActionButton: diaryAiChatController.isChatResponsLoading,
              ),
              body: GestureDetector(
                onTap: () {
                  // ✅ 포커스 강제 X. (원하면 unfocus만 유지)
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                        controller: diaryAiChatController.chatScrollController,
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: diaryAiChatController.chatlog.length,
                        itemBuilder: (context, index) {
                          final chatMsg = diaryAiChatController.chatlog[
                          diaryAiChatController.chatlog.length - index - 1];
                          return Column(
                            children: [
                              (chatMsg.isVisible)
                                  ? Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                child: IgnorePointer(
                                  ignoring: true,
                                  child: CustomDialogue(
                                    chatMessage: chatMsg,
                                    onDialoguePressed: () {},
                                  ),
                                ),
                              )
                                  : const SizedBox.shrink(),
                              if (index == 0)
                                SizedBox(
                                  height: MediaQuery.of(context).padding.bottom + 94,
                                )
                            ],
                          );
                        },
                      ),
                    ),
                    const Align(
                      alignment: Alignment.bottomCenter,
                      child: ChatMessageBar(),
                    ),
                  ],
                ),
              ),
            ),

            if (localRect != null)
              TutorialOverlay(
                targetRect: localRect!,
                radius: 14,
                guide: const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }

}
