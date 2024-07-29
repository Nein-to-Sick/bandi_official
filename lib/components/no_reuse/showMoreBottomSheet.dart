import 'package:flutter/material.dart';

import '../../theme/custom_theme_data.dart';
import '../button/primary_button.dart';

void showMoreBottomSheet(BuildContext context, writeProvider) {
  //TODO: 수정필요
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "추가 감정 선택",
              style: BandiFont.displaySmall(context)
                  ?.copyWith(color: BandiColor.neutralColor100(context)),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: writeProvider.emotionOptions.map<Widget>((emotion) {
                return ChoiceChip(
                  label: Text(emotion),
                  selected: writeProvider.selectedEmotions.contains(emotion),
                  onSelected: (selected) {
                    if (selected) {
                      writeProvider.addEmotion(emotion);
                    } else {
                      writeProvider.removeEmotion(emotion);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            CustomPrimaryButton(
              title: '확인',
              onPrimaryButtonPressed: () {
                Navigator.pop(context);
              },
              disableButton: false,
            ),
          ],
        ),
      );
    },
  );
}
