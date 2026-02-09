import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../model/settingsInfos.dart';
import '../../../localization/string_extention.dart';
import '../../../theme/custom_theme_data.dart';
import '../../../components/button/primary_button.dart';
import 'agreement_detail_dialog.dart';

class AgreementSheet {
  Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AgreementStateful(),
    );
  }
}

class _AgreementStateful extends StatefulWidget {
  const _AgreementStateful();

  @override
  State<_AgreementStateful> createState() => _AgreementStatefulState();
}

class _AgreementStatefulState extends State<_AgreementStateful> {
  bool _hideSheet = false;

  bool allSelected = false;
  bool option1Selected = false;
  bool option2Selected = false;
  bool option3Selected = false;
  bool option4Selected = false;

  Future<void> _openDetail({
    required BuildContext context,
    required List<List<String>> data,
    required String titleKey,
  }) async {
    setState(() => _hideSheet = true);
    await showAgreementDetailDialog(context, data: data, titleKey: titleKey);
    if (!mounted) return;
    setState(() => _hideSheet = false);
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;

    final terms = CompanyInfo().localizedTermsOfUse[langCode] ??
        CompanyInfo().localizedTermsOfUse['ko']!;
    final privacy = CompanyInfo().localizedPrivacyPolicy[langCode] ??
        CompanyInfo().localizedPrivacyPolicy['ko']!;
    final eula = CompanyInfo().localizedEula[langCode] ??
        CompanyInfo().localizedEula['ko']!;

    final sysBottom = MediaQuery.of(context).viewPadding.bottom;
    final extraBottom = Platform.isAndroid ? math.min(sysBottom, 48.0) : 0.0;

    return PopScope(
      canPop: false,
      child: IgnorePointer(
        ignoring: _hideSheet,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: _hideSheet ? 0.0 : 1.0,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 8, // ✅ 16 / 2
              sigmaY: 8,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: BandiColor.neutralColor80(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Text(
                            "onboarding_agreement_condition_title".tr(context),
                            style: BandiFont.headlineMedium(context)?.copyWith(
                              color: BandiColor.foundationColor100(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 21),
                        _tile(
                          context,
                          title: 'onboarding_agreement_condition_header'
                              .tr(context),
                          checked: allSelected,
                          onTap: () {
                            setState(() {
                              allSelected = !allSelected;
                              option1Selected = allSelected;
                              option2Selected = allSelected;
                              option3Selected = allSelected;
                              option4Selected = allSelected;
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Container(
                            width: double.maxFinite,
                            height: 1,
                            decoration: BoxDecoration(
                              color: BandiColor.foundationColor04(context),
                            ),
                          ),
                        ),
                        _tile(
                          context,
                          title: 'onboarding_agreement_condition_1'.tr(context),
                          checked: option1Selected,
                          onTap: () {
                            setState(() {
                              option1Selected = !option1Selected;
                              allSelected = option1Selected &&
                                  option2Selected &&
                                  option3Selected &&
                                  option4Selected;
                            });
                          },
                        ),
                        _tileRich(
                          context,
                          langCode: langCode,
                          titleKey: "onboarding_agreement_condition_2",
                          checked: option2Selected,
                          onOpenDetail: () => _openDetail(
                            context: context,
                            data: privacy,
                            titleKey: "onboarding_agreement_condition_2",
                          ),
                          onTapCheck: () {
                            setState(() {
                              option2Selected = !option2Selected;
                              allSelected = option1Selected &&
                                  option2Selected &&
                                  option3Selected &&
                                  option4Selected;
                            });
                          },
                        ),
                        _tileRich(
                          context,
                          langCode: langCode,
                          titleKey: "onboarding_agreement_condition_3",
                          checked: option3Selected,
                          onOpenDetail: () => _openDetail(
                            context: context,
                            data: terms,
                            titleKey: "onboarding_agreement_condition_3",
                          ),
                          onTapCheck: () {
                            setState(() {
                              option3Selected = !option3Selected;
                              allSelected = option1Selected &&
                                  option2Selected &&
                                  option3Selected &&
                                  option4Selected;
                            });
                          },
                        ),
                        _tileRich(
                          context,
                          langCode: langCode,
                          titleKey: "onboarding_agreement_condition_4",
                          checked: option4Selected,
                          onOpenDetail: () => _openDetail(
                            context: context,
                            data: eula,
                            titleKey: "onboarding_agreement_condition_4",
                          ),
                          onTapCheck: () {
                            setState(() {
                              option4Selected = !option4Selected;
                              allSelected = option1Selected &&
                                  option2Selected &&
                                  option3Selected &&
                                  option4Selected;
                            });
                          },
                        ),
                        const SizedBox(height: 28),
                        CustomPrimaryButton(
                          title: 'onboarding_button_confirm'.tr(context),
                          onPrimaryButtonPressed: () {
                            if (allSelected) Navigator.pop(context, true);
                          },
                          disableButton: !allSelected,
                        ),
                        SizedBox(height: 32 + extraBottom),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required String title,
    required bool checked,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -3),
      minVerticalPadding: 0,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: BandiFont.bodyLarge(context)?.copyWith(
          color: BandiColor.foundationColor90(context),
        ),
      ),
      trailing: GestureDetector(
        onTap: onTap,
        child: checked
            ? PhosphorIcon(
                size: 26,
                PhosphorIconsFill.checkCircle,
                color: BandiColor.foundationColor80(context),
              )
            : PhosphorIcon(
                size: 26,
                PhosphorIcons.checkCircle(),
                color: BandiColor.foundationColor20(context),
              ),
      ),
    );
  }

  Widget _tileRich(
    BuildContext context, {
    required String langCode,
    required String titleKey,
    required bool checked,
    required VoidCallback onOpenDetail,
    required VoidCallback onTapCheck,
  }) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -3),
      minVerticalPadding: 0,
      contentPadding: EdgeInsets.zero,
      title: GestureDetector(
        onTap: onOpenDetail,
        child: RichText(
          text: TextSpan(
            style: BandiFont.bodyLarge(context)?.copyWith(
              color: BandiColor.foundationColor90(context),
            ),
            children: (langCode == 'ko')
                ? [
                    const TextSpan(text: '(필수) '),
                    TextSpan(
                      text: titleKey.tr(context).replaceAll('(필수) ', ''),
                      style:
                          const TextStyle(decoration: TextDecoration.underline),
                    ),
                    const TextSpan(text: '에 동의하시나요?'),
                  ]
                : [
                    const TextSpan(text: '(Required) '),
                    TextSpan(
                      text: titleKey.tr(context),
                      style:
                          const TextStyle(decoration: TextDecoration.underline),
                    ),
                  ],
          ),
        ),
      ),
      trailing: GestureDetector(
        onTap: onTapCheck,
        child: checked
            ? PhosphorIcon(
                size: 26,
                PhosphorIconsFill.checkCircle,
                color: BandiColor.foundationColor80(context),
              )
            : PhosphorIcon(
                size: 26,
                PhosphorIcons.checkCircle(),
                color: BandiColor.foundationColor20(context),
              ),
      ),
    );
  }
}
