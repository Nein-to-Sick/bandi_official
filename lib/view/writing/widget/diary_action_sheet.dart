import 'package:bandi_official/localization/string_extention.dart';
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
          title: "v2_diary_action_sheet_button_edit".tr(context),
          onPrimaryButtonPressed: () =>
              Navigator.pop(context, DiarySheetAction.edit),
          disableButton: false,
        ),
        const SizedBox(height: 8),
        CustomPrimaryButton(
          title: "v2_diary_action_sheet_button_delete".tr(context),
          onPrimaryButtonPressed: () =>
              Navigator.pop(context, DiarySheetAction.delete),
          disableButton: false,
        ),
      ],
    ),
  );
}
