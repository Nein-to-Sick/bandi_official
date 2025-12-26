import 'dart:ui'; // Blur 처리를 위해 필요
import 'package:bandi_official/components/appbar/appbar.dart';
import 'package:bandi_official/components/appbar/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/view/diary_ai_chat/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/view/diary_ai_chat/components/dialogue.dart';
import 'package:bandi_official/view/diary_ai_chat/components/chat_message_bar.dart';
import 'package:bandi_official/components/dialogue/reset_dialogue.dart'; // 리셋 다이얼로그 import

class DiaryAIChatSheet {
  Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // 드래그로 닫기 가능 여부
      enableDrag: true,
      barrierColor: BandiColor.transparent(context),
      backgroundColor: BandiColor.neutralColor80(context),
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
    final position = diaryAiChatController.chatScrollController.position;
    if (diaryAiChatController.loadMoreData &&
        position.atEdge &&
        position.pixels != 0) {
      if (position.userScrollDirection == ScrollDirection.reverse &&
          position.maxScrollExtent - position.pixels <= 500) {
        diaryAiChatController
            .toggleLoadMoreData(await diaryAiChatController.loadMoreChatLogs());
      }
    }
  }

  @override
  void dispose() {
    // 리스너 제거 로직
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
        resizeToAvoidBottomInset: false,
        backgroundColor: BandiColor.transparent(context),
        appBar: CustomAppBar2(
          appBarType: AppBarType.twoButtonFoundation,
          title: 'ai_chat_title'.tr(context),
          leftActionButtonIcon: PhosphorIcons.signOut(PhosphorIconsStyle.thin),
          rightActionButtonIcon: PhosphorIcons.x(PhosphorIconsStyle.thin),
          onLeftActionButtonPressed: () {
            showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return CustomResetDialogue(
                  text: 'dialogue_message_ai_chat_reset'.tr(context),
                  onYesText: 'dialogue_yes'.tr(context),
                  onNoText: 'dialogue_no'.tr(context),
                  onYesFunction: () {
                    diaryAiChatController.resetTheChat(context);
                    Navigator.pop(context);
                  },
                  onNoFunction: () {
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
          onRightActionButtonPressed: () {
            Navigator.pop(context);
          },
          disableLefttActionButton: diaryAiChatController.isChatResponsLoading,
          disableRightActionButton: diaryAiChatController.isChatResponsLoading,
        ),
        body: GestureDetector(
          onTap: () {
            if (diaryAiChatController.chatFocusNode.hasFocus) {
              diaryAiChatController.chatFocusNode.unfocus();
            }
          },
          child: Column(
            children: [
              // chat content
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ListView.builder(
                    controller: diaryAiChatController.chatScrollController,
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: diaryAiChatController.chatlog.length,
                    itemBuilder: (context, index) {
                      final chatMsg = diaryAiChatController.chatlog[
                          diaryAiChatController.chatlog.length - index - 1];

                      return Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: IgnorePointer(
                          ignoring: true,
                          child: CustomDialogue(
                            chatMessage: chatMsg,
                            onDialoguePressed: () {},
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // chat bar
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: const ChatMessageBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
