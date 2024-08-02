import 'package:bandi_official/components/appbar/appbar.dart';
import 'package:bandi_official/components/dialogue/dialogue.dart';
import 'package:bandi_official/components/no_reuse/chat_message_bar.dart';
import 'package:bandi_official/components/no_reuse/reset_dialogue.dart';
import 'package:bandi_official/controller/diary_ai_chat_controller.dart';
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
  bool loadMoreData = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      DiaryAiChatController diaryAiChatController =
          Provider.of<DiaryAiChatController>(context, listen: false);

      diaryAiChatController.loadDataAndSetting();

      // when screen reached nearly top of the list load more past data
      diaryAiChatController.chatScrollController.addListener(() async {
        final position = diaryAiChatController.chatScrollController.position;
        if (loadMoreData && position.atEdge && position.pixels != 0) {
          if (diaryAiChatController
                      .chatScrollController.position.userScrollDirection ==
                  ScrollDirection.reverse &&
              diaryAiChatController
                          .chatScrollController.position.maxScrollExtent -
                      diaryAiChatController
                          .chatScrollController.position.pixels <=
                  500) {
            loadMoreData = await diaryAiChatController.loadMoreChatLogs();
          }
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DiaryAiChatController diaryAiChatController =
        context.watch<DiaryAiChatController>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(
        title: '반디와 대화하기',
        trailingIcon: PhosphorIcons.arrowCounterClockwise,
        onLeadingIconPressed: () {
          diaryAiChatController.toggleChatOpen();
        },
        onTrailingIconPressed: () {
          showResetDialog(context, diaryAiChatController);
        },
        disableLeadingButton: diaryAiChatController.isChatResponsLoading,
        disableTrailingButton: diaryAiChatController.isChatResponsLoading,
        isVisibleLeadingButton: true,
        isVisibleTrailingButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () {
                    if (diaryAiChatController.chatFocusNode.hasFocus) {
                      diaryAiChatController.chatFocusNode.unfocus();
                    }
                  },
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
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: ChatMessageBar(),
            ),
          ],
        ),
      ),
    );
  }
}
