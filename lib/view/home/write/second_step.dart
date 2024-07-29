import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../components/button/primary_button.dart';
import '../../../controller/home_to_write.dart';

class SecondStep extends StatelessWidget {
  const SecondStep({super.key});

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
                const SizedBox(
                  height: 4,
                ),
                Text(
                  DateFormat('yyyy년 M월 d일').format(DateTime.now()),
                  style: BandiFont.headlineSmall(context)
                      ?.copyWith(color: BandiColor.neutralColor100(context)),
                )
              ],
            ),
            PhosphorIcon(
              PhosphorIcons.pencilSimple(),
              color: BandiColor.neutralColor40(context),
            )
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        Expanded(
          child: Text(
            writeProvider.content,
            style: BandiFont.titleSmall(context)
                ?.copyWith(color: BandiColor.neutralColor100(context)),
          ),
        ),
        containerBox(context, "반디가 분석한 감정"),
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
          height: 16,
        ),
        containerBox(context, "반디가 건네는 한마디"),
        const SizedBox(
          height: 8,
        ),
        Text(
          "\"${writeProvider.cheerText}\"",
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
              writeProvider.nextWrite(3);
            },
            disableButton: false,
          ),
        ),
      ],
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
