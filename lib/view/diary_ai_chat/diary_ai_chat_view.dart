import 'dart:ui'; // Blur 처리를 위해 필요
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

class DiaryAIChatSheet {
  Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
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
    DiaryAiChatController diaryAiChatController =
        context.watch<DiaryAiChatController>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: BandiColor.neutralColor80(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(BandiEffects.radiusValueSmall),
        ),
      ),
      child: Scaffold(
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
              title: '대화창을 정말로 나가시겠어요?',
              description: '지금까지 나눈 이야기는 모두 사라져요.',
              cancelText: '취소',
              confirmText: '나가기',
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
            if (diaryAiChatController.chatFocusNode.hasFocus) {
              diaryAiChatController.chatFocusNode.unfocus();
            }
          },
          child: Stack(
            children: [
              // chat content
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
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
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

              // chat bar
              const Align(
                alignment: Alignment.bottomCenter,
                child: ChatMessageBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
