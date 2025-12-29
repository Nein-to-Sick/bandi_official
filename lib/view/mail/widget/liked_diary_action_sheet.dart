import 'package:bandi_official/components/appbar/new_custom_appbar.dart';
import 'package:bandi_official/components/bottom_sheet/app_bottom_sheet.dart';
import 'package:bandi_official/components/button/primary_button.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:bandi_official/view/mail/widget/liked_diary_filter_chips.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

Future<void> showLikedDiaryActionSheet(
    BuildContext context, MailController mailController) {
  return showAppBottomSheet(
    context: context,
    contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NewCustomAppBar(
          appBarType: AppBarType.subtitleFoundation,
          title: '공감 키워드'.tr(context),
          leftActionButtonIcon:
              PhosphorIcons.arrowClockwise(PhosphorIconsStyle.thin),
          rightActionButtonIcon: PhosphorIcons.x(PhosphorIconsStyle.thin),
          onLeftActionButtonPressed: () async {
            mailController.initializeFilter();
            // For alarm test
            /*
            messageTestFunction(alarmController);
            For test delete finction
            mailController.deleteEveryMailDataFromLocal();
            For new Letter pop page test
            newLetterPopUpPageTestFunction(context);
            */
          },
          onRightActionButtonPressed: () {
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: LikedDiaryFilterChips(),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: CustomPrimaryButton(
            title: "dialogue_close".tr(context),
            onPrimaryButtonPressed: () => Navigator.pop(context),
            disableButton: false,
          ),
        ),
      ],
    ),
  );
}
