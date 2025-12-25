import 'package:flutter/material.dart';
import 'package:wrapped_korean_text/wrapped_korean_text.dart';

import '../../../string_extention.dart';
import '../../../theme/custom_theme_data.dart';
import '../../../components/button/primary_button.dart';

Future<void> showAgreementDetailDialog(
    BuildContext context, {
      required List<List<String>> data,
      required String titleKey,
    }) {
  return showDialog(
    context: context,
    useSafeArea: false,
    builder: (ctx) {
      return Container(
        color: BandiColor.neutralColor80(ctx),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 24.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      titleKey.tr(ctx),
                      style: BandiFont.headlineMedium(ctx)?.copyWith(
                        color: BandiColor.foundationColor100(ctx),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: BandiColor.foundationColor04(context),thickness: 1, height: 33,),
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24, top: 6.5),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (int i = 0; i < data.length; i++)
                              Column(
                                children: [
                                  if (i != 0) const SizedBox(height: 80),
                                  SizedBox(
                                    width: MediaQuery.of(ctx).size.width,
                                    child: WrappedKoreanText(
                                      data[i][0],
                                      style: BandiFont.titleSmall(ctx)?.copyWith(
                                        color: BandiColor.foundationColor90(ctx),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: MediaQuery.of(ctx).size.width,
                                    child: WrappedKoreanText(
                                      data[i][1],
                                      style: BandiFont.bodyMedium(ctx)?.copyWith(
                                        color: BandiColor.foundationColor90(ctx),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 150),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32, left: 24, right: 24),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: CustomPrimaryButton(
                          title: 'onboarding_button'.tr(ctx),
                          onPrimaryButtonPressed: () => Navigator.pop(ctx),
                          disableButton: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
