import 'package:bandi_official/components/appbar/appbar.dart';
import 'package:bandi_official/components/dialogue/dialogue.dart';
import 'package:bandi_official/components/no_reuse/chat_message_bar.dart';
import 'package:bandi_official/components/dialogue/reset_dialogue.dart';
import 'package:bandi_official/view/diary_ai_chat/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/model/diary_ai_chat.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:developer' as dev;

class DiaryAIChatPage extends StatefulWidget {
  const DiaryAIChatPage({super.key});

  @override
  State<DiaryAIChatPage> createState() => _DiaryAIChatPageState();
}

class _DiaryAIChatPageState extends State<DiaryAIChatPage> {
  late DiaryAiChatController diaryAiChatController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      diaryAiChatController =
          Provider.of<DiaryAiChatController>(context, listen: false);

      diaryAiChatController.loadDataAndSetting().then((value) {
        if (!diaryAiChatController.isListenerAdded) {
          // when screen reached nearly top of the list load more past data
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

    super.initState();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      diaryAiChatController.chatScrollController
          .removeListener(_scrollListener);
      diaryAiChatController.toggleIsListenerAdded(false);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DiaryAiChatController diaryAiChatController =
        context.watch<DiaryAiChatController>();

    return WillPopScope(
      onWillPop: () => Future(() => false),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: BandiColor.transparent(context),
        appBar: CustomAppBar(
          title: 'ai_chat_title'.tr(context),
          trailingIcon:
              PhosphorIcons.arrowCounterClockwise(PhosphorIconsStyle.regular),
          onLeadingIconPressed: () {
            diaryAiChatController.toggleChatOpen(false);
          },
          onTrailingIconPressed: () {
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
          disableLeadingButton: diaryAiChatController.isChatResponsLoading,
          disableTrailingButton: diaryAiChatController.isChatResponsLoading,
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (diaryAiChatController.chatFocusNode.hasFocus) {
              diaryAiChatController.chatFocusNode.unfocus();
            }
          },
          child: Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ListView.builder(
                    controller: diaryAiChatController.chatScrollController,
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: diaryAiChatController.chatlog.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: IgnorePointer(
                          ignoring: true,
                          child: CustomDialogue(
                            chatMessage: diaryAiChatController.chatlog[
                                diaryAiChatController.chatlog.length -
                                    index -
                                    1],
                            onDialoguePressed: () {},
                          ),
                        ),
                      );
                    },
                  ),
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
    );
  }
}
