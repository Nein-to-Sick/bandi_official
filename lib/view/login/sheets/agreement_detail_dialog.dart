import 'package:flutter/material.dart';

import '../../../string_extention.dart';
import '../../../theme/custom_theme_data.dart';
import '../../../components/button/primary_button.dart';
import '../../settings/widget/agreement_content.dart';

Future<void> showAgreementDetailDialog(
    BuildContext context, {
      required List<List<String>> data,
      required String titleKey,
    }) {
  return showDialog(
    context: context,
    useSafeArea: false,
    barrierDismissible: false,
    builder: (ctx) {
      return _AgreementDetailDialog(
        title: titleKey.tr(ctx),
        data: data,
      );
    },
  );
}

class _AgreementDetailDialog extends StatelessWidget {
  final String title;
  final List<List<String>> data;

  const _AgreementDetailDialog({
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
        color: BandiColor.neutralColor80(context),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Column(
            children: [
              // ===== Header =====
              Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: safeTop + 18,
                  bottom: 14,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: BandiFont.headlineMedium(context)?.copyWith(
                      color: BandiColor.foundationColor100(context),
                    ),
                  ),
                ),
              ),

              Divider(
                color: BandiColor.foundationColor04(context),
                thickness: 1,
                height: 1,
              ),

              // ===== Content + Bottom button overlay =====
              Expanded(
                child: Stack(
                  children: [
                    // Scroll content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          top: 18,
                          bottom: 140 + safeBottom, // 버튼 공간 확보
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < data.length; i++) ...[
                              if (i != 0) const SizedBox(height: 26),
                              AgreementSection(
                                sectionTitle: data[i][0],
                                sectionBody: data[i][1],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Bottom button
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 32,
                      child: CustomPrimaryButton(
                        title: 'onboarding_button'.tr(context), // "닫기" 등
                        onPrimaryButtonPressed: () => Navigator.pop(context),
                        disableButton: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}