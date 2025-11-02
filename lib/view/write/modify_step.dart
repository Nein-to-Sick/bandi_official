import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/view/write/second_step.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../components/button/primary_button.dart';
import '../../../components/no_reuse/showMoreBottomSheet.dart';
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
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final writeProvider = Provider.of<HomeToWrite>(context);
    final navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: titleController,
                    decoration: const InputDecoration(border: InputBorder.none),
                    cursorColor: BandiColor.neutralColor100(context),
                    style: BandiFont.displaySmall(context)
                        ?.copyWith(color: BandiColor.neutralColor100(context)),
                    onChanged: (value) {
                      setState(() => titleText = value);
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    writeProvider.toggleWrite();
                    writeProvider.initialize();
                  },
                  child: PhosphorIcon(
                    PhosphorIcons.x(),
                    color: BandiColor.neutralColor40(context),
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 26,
            ),
            Expanded(
              child: TextField(
                controller: contentController,
                cursorColor: BandiColor.neutralColor100(context),
                decoration: const InputDecoration(border: InputBorder.none),
                maxLines: null,
                expands: true,
                style: BandiFont.titleSmall(context)
                    ?.copyWith(color: BandiColor.neutralColor100(context)),
                onChanged: (value) {
                  setState(() => contentText = value);
                },
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                containerBox(context, 'write_emotion_title'.tr(context)),
                GestureDetector(
                    onTap: () {
                      showMoreBottomSheet(context, writeProvider);
                    },
                    child: Text(
                      'write_see_more'.tr(context),
                      style: BandiFont.labelLarge(context)?.copyWith(
                          color: BandiColor.neutralColor100(context)),
                    ))
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            writeProvider.diaryModel.emotion.isEmpty ? Text(
              'done'.tr(context),
              style: BandiFont.titleSmall(context)?.copyWith(
                  color: BandiColor.neutralColor100(context)),
            ) : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (String emotion in writeProvider.diaryModel.emotion)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        children: [
                          Text("#", style: BandiFont.titleSmall(context)?.copyWith(
                              color: BandiColor.neutralColor100(context))),
                          Text(
                            "emotion_keyword_$emotion".tr(context),
                            style: BandiFont.titleSmall(context)?.copyWith(
                                color: BandiColor.neutralColor100(context)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              children: [
                Expanded(
                  child: CustomPrimaryButton(
                    title: 'done'.tr(context),
                    onPrimaryButtonPressed: () async {
                      // 저장
                      writeProvider.modifyDatabaseDiaryValue(
                          titleText, contentText, writeProvider.diaryModel.diaryId);
                      if (writeProvider.gotoDirectListPage) {
                        navigationToggleProvider.selectIndex(1);
                      }
                      writeProvider.toggleWrite();
                      writeProvider.initialize();
                    },
                    disableButton: (writeProvider.diaryModel.title == titleText &&
                            writeProvider.diaryModel.content == contentText &&
                            writeProvider.flag == 0)
                        ? true
                        : false,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
