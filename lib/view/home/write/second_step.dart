import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../components/button/primary_button.dart';
import '../../../controller/home_to_write.dart';
import '../../../controller/navigation_toggle_provider.dart';

class SecondStep extends StatelessWidget {
  const SecondStep({super.key});

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      writeProvider.diaryModel.cheerText == ''
                          ? "제목 생성 중...."
                          : writeProvider.diaryModel.title,
                      style: BandiFont.displaySmall(context)?.copyWith(
                          color: BandiColor.neutralColor100(context)),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      DateFormat('yyyy년 M월 d일').format(DateTime.now()),
                      style: BandiFont.headlineSmall(context)?.copyWith(
                          color: BandiColor.neutralColor100(context)),
                    )
                  ],
                ),
                GestureDetector(
                  onTap: writeProvider.diaryModel.cheerText == '' ? null : () {
                    writeProvider.nextWrite(3);
                  },
                  child: PhosphorIcon(
                    PhosphorIcons.pencilSimple(),
                    color: writeProvider.diaryModel.cheerText == '' ? BandiColor.neutralColor10(context) : BandiColor.neutralColor40(context),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  writeProvider.diaryModel.content,
                  style: BandiFont.titleSmall(context)
                      ?.copyWith(color: BandiColor.neutralColor100(context)),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            containerBox(context, "반디가 분석한 감정"),
            const SizedBox(
              height: 8,
            ),
            writeProvider.diaryModel.cheerText == ''
                ? Text(
              "감정 파악 중...",
              style: BandiFont.titleSmall(context)
                  ?.copyWith(color: BandiColor.neutralColor100(context)),
            )
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (String emotion in writeProvider.diaryModel.emotion)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        "#$emotion",
                        style: BandiFont.titleSmall(context)?.copyWith(
                            color: BandiColor.neutralColor100(context)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            containerBox(context, "반디가 건네는 한마디"),
            const SizedBox(
              height: 8,
            ),
            Text(
              writeProvider.diaryModel.cheerText == ''
                  ? "할 말 생각중..."
                  : "\"${writeProvider.diaryModel.cheerText}\"",
              style: BandiFont.titleSmall(context)
                  ?.copyWith(color: BandiColor.neutralColor100(context)),
            ),
            const SizedBox(
              height: 24,
            ),
            Center(
              child: CustomPrimaryButton(
                title: '확인',
                onPrimaryButtonPressed: () {
                  if (writeProvider.gotoDirectListPage) {
                    navigationToggleProvider.selectIndex(1);
                  }
                  writeProvider.initialize();
                  writeProvider.toggleWrite();
                },
                disableButton: writeProvider.diaryModel.cheerText == '' ? true : false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget containerBox(context, String text) {
  return Container(
    decoration: BoxDecoration(
        color: BandiColor.neutralColor20(context),
        borderRadius: BandiEffects.radius()),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 12),
      child: Text(
        text,
        style: BandiFont.headlineSmall(context)
            ?.copyWith(color: BandiColor.neutralColor100(context)),
      ),
    ),
  );
}