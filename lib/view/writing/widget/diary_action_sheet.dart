import 'package:flutter/material.dart';

import '../../../components/bottom_sheet/app_bottom_sheet.dart';
import '../../../components/button/primary_button.dart';

enum DiarySheetAction { edit, delete }

Future<DiarySheetAction?> showDiaryActionSheet(BuildContext context) {
  return showAppBottomSheet<DiarySheetAction>(
    context: context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPrimaryButton(
          title: "수정",
          onPrimaryButtonPressed: () => Navigator.pop(context, DiarySheetAction.edit),
          disableButton: false,
        ),
        const SizedBox(height: 8),
        CustomPrimaryButton(
          title: "삭제",
          onPrimaryButtonPressed: () => Navigator.pop(context, DiarySheetAction.delete),
          disableButton: false,
        ),
      ],
    ),
  );
}