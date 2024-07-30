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

    return Column(
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
                  writeProvider.title,
                  style: BandiFont.displaySmall(context)
                      ?.copyWith(color: BandiColor.neutralColor100(context)),
                ),
              ],
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
          child: Text(
            writeProvider.content,
            style: BandiFont.titleSmall(context)
                ?.copyWith(color: BandiColor.neutralColor100(context)),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            containerBox(context, "반디가 분석한 감정"),
            GestureDetector(
                onTap: () {
                  showMoreBottomSheet(context, writeProvider);
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
        Row(
          children: [
            for (String emotion in writeProvider.emotion)
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
        const SizedBox(
          height: 24,
        ),
        Center(
          child: CustomPrimaryButton(
            title: '완료',
            onPrimaryButtonPressed: () {
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

