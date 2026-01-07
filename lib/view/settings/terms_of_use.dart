import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/view/settings/widget/agreement_content.dart';
import 'package:bandi_official/view/settings/widget/frosted_settings_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:wrapped_korean_text/wrapped_korean_text.dart';
import '../../model/settingsInfos.dart';
import '../../theme/custom_theme_data.dart';

class TermsOfUseScreen extends StatelessWidget {
  final VoidCallback onBack;

  const TermsOfUseScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    String langCode = Localizations.localeOf(context).languageCode;
    List<List<String>>? terms = CompanyInfo().localizedTermsOfUse[langCode] ??
        CompanyInfo().localizedTermsOfUse['ko'];

    return FrostedSettingsScaffold(
      title: 'settings_terms_of_use'.tr(context),
      onBack: onBack,
      child: Builder(
        builder: (context) {
          final safeBottom = MediaQuery.of(context).padding.bottom;

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: 32 + safeBottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < terms!.length; i++) ...[
                  if (i != 0) const SizedBox(height: 26),
                  AgreementSection(
                    sectionTitle: terms[i][0],
                    sectionBody: terms[i][1],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
