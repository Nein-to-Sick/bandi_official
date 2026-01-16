import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/localization/string_extention.dart';
import 'package:bandi_official/view/my_diary_list/controller/my_diary_list_controller.dart';
import 'package:bandi_official/view/writing/widget/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controller/home_to_write.dart';
import '../../../controller/navigation_toggle_provider.dart';
import '../../../theme/custom_theme_data.dart';

class ThirdStep extends StatefulWidget {
  const ThirdStep({super.key});

  @override
  State<ThirdStep> createState() => _ThirdStepState();
}

class _ThirdStepState extends State<ThirdStep> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  String titleText = "";
  String contentText = "";
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    final writeProvider = Provider.of<HomeToWrite>(context, listen: false);

    titleController =
        TextEditingController(text: writeProvider.diaryModel.title);
    contentController =
        TextEditingController(text: writeProvider.diaryModel.content);
    titleText = writeProvider.diaryModel.title;
    contentText = writeProvider.diaryModel.content;
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final writeProvider = Provider.of<HomeToWrite>(context);
    final navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);
    MyDiaryListController myDiaryListController =
        context.watch<MyDiaryListController>();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: TextField(
              controller: titleController,
              decoration: const InputDecoration(border: InputBorder.none),
              cursorColor: BandiColor.neutralColor100(context),
              style: BandiFont.headlineMedium(context)
                  ?.copyWith(color: BandiColor.neutralColor100(context)),
              onChanged: (value) {
                setState(() => titleText = value);
              },
            ),
          ),
          Divider(
            color: BandiColor.neutralColor04(context),
            thickness: 1,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: TextField(
                controller: contentController,
                focusNode: _focusNode,
                cursorColor: BandiColor.neutralColor90(context),
                style: BandiFont.titleSmall(context)?.copyWith(
                  color: BandiColor.neutralColor90(context),
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'write_hint_text'.tr(context),
                  hintStyle: BandiFont.titleSmall(context)?.copyWith(
                    color: BandiColor.neutralColor40(context),
                  ),
                ),
                onChanged: (value) {
                  setState(() => contentText = value);
                },
                maxLines: null,
                expands: true,
              ),
            ),
          ),
          BottomBar(
            isPublic: writeProvider.isPublic,
            onTogglePublic: writeProvider.setIsPublic,
            publicLabel: writeProvider.isPublic
                ? "sharing_diary_on".tr(context)
                : "sharing_diary_off".tr(context),
            onExit: () async {
              navigationToggleProvider.selectIndex(1);
              writeProvider.toggleWrite();
              writeProvider.initialize();
            },
            onDone: () async {
              // 저장
              writeProvider.modifyDatabaseDiaryStringValue(
                  titleText, contentText);

              Diary modifiedDiary = Diary(
                userId: writeProvider.diaryModel.userId,
                title: titleText,
                content: contentText,
                emotion: writeProvider.diaryModel.emotion,
                createdAt: writeProvider.diaryModel.createdAt,
                updatedAt: writeProvider.diaryModel.updatedAt,
                reaction: writeProvider.diaryModel.reaction,
                diaryId: writeProvider.diaryModel.diaryId,
                cheerText: writeProvider.diaryModel.cheerText,
                otherUserReaction: -1,
                otherUserLikedAt: '',
              );

              myDiaryListController.updateMyDiaryLocal(modifiedDiary);
              if (writeProvider.gotoDirectListPage) {
                navigationToggleProvider.selectIndex(1);
              }
              writeProvider.toggleWrite();
              writeProvider.initialize();
            },
            doneEnabled: writeProvider.diaryModel.content.isNotEmpty,
          )
        ],
      ),
    );
  }
}
