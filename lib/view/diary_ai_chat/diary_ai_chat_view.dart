import 'package:bandi_official/components/appbar/appbar.dart';
import 'package:bandi_official/components/dialogue/dialogue.dart';
import 'package:bandi_official/components/no_reuse/chat_message_bar.dart';
import 'package:bandi_official/controller/diary_ai_chat_controller.dart';
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
  bool disableLeadingButton = false;

  @override
  void initState() {
    // TODO: implement initState
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
        trailingIcon: PhosphorIcons.x,
        onLeadingIconPressed: () {
          diaryAiChatController.toggleChatOpen();
        },
        onTrailingIconPressed: () {},
        disableLeadingButton: disableLeadingButton,
        disableTrailingButton: false,
        isVisibleLeadingButton: true,
        isVisibleTrailingButton: false,
      ),
      body: Column(
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
                              diaryAiChatController.chatlog.length - index - 1],
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
    );
  }
}
