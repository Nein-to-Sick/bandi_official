import 'package:bandi_official/string_extention.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:wrapped_korean_text/wrapped_korean_text.dart';

import '../../model/settingsInfos.dart';
import '../../theme/custom_theme_data.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final VoidCallback onBack;

  const PrivacyPolicyScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    String langCode = Localizations.localeOf(context).languageCode;
    List<List<String>>? privacy =
        CompanyInfo().localizedPrivacyPolicy[langCode] ??
            CompanyInfo().localizedPrivacyPolicy['ko'];

    return Scaffold(
      backgroundColor: BandiColor.neutralColor80(context).withOpacity(0.8),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BandiColor.transparent(context),
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft()),
          onPressed: onBack,
        ),
        title: Text(
          'settings_privacy_policy'.tr(context),
          style: BandiFont.displaySmall(context)?.copyWith(
            color: BandiColor.foundationColor80(context),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23.0),
          child: Column(
            children: [
              for (int i = 0; i < privacy!.length; i++)
                Column(
                  children: [
                    if (i != 0) const SizedBox(height: 44),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: WrappedKoreanText(
                        privacy[i][0],
                        style: BandiFont.headlineMedium(context)?.copyWith(
                          color: BandiColor.foundationColor80(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 11),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: WrappedKoreanText(
                        privacy[i][1],
                        style: BandiFont.bodySmall(context)?.copyWith(
                          color: BandiColor.foundationColor80(context),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
