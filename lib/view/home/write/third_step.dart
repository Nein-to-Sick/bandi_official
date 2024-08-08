import 'package:bandi_official/view/home/write/second_step.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../components/button/primary_button.dart';
import '../../../components/no_reuse/showMoreBottomSheet.dart';
import '../../../controller/home_to_write.dart';
import '../../../theme/custom_theme_data.dart';

class ThirdStep extends StatelessWidget {
  const ThirdStep({super.key});

  @override
  Widget build(BuildContext context) {
    final writeProvider = Provider.of<HomeToWrite>(context);
    TextEditingController titleController =
        TextEditingController(text: writeProvider.diaryModel.title);
    TextEditingController contentController =
    TextEditingController(text: writeProvider.diaryModel.content);

    return Column(
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
          height: 32,
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
          ),
        ),
        const SizedBox(height: 15,),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            containerBox(context, "반디가 분석한 감정"),
            GestureDetector(
                onTap: () {
                  showMoreBottomSheet(context);
                },
                child: Text(
                  "더보기",
                  style: BandiFont.labelLarge(context)
                      ?.copyWith(color: BandiColor.neutralColor100(context)),
                ))
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (String emotion in writeProvider.diaryModel.emotion)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    "#$emotion",
                    style: BandiFont.titleSmall(context)
                        ?.copyWith(color: BandiColor.neutralColor100(context)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Center(
          child: CustomPrimaryButton(
            title: '완료',
            onPrimaryButtonPressed: () {
              // 저장

              writeProvider.toggleWrite();
              writeProvider.initialize();
            },
            disableButton: false,
          ),
        )
      ],
    );
  }
}
