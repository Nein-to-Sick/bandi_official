import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/view/settings/widget/agreement_content.dart';
import 'package:bandi_official/view/settings/widget/frosted_settings_scaffold.dart';
import 'package:flutter/material.dart';
import '../../model/settingsInfos.dart';

class EulaAgreementScreen extends StatelessWidget {
  final VoidCallback onBack;

  const EulaAgreementScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    String langCode = Localizations.localeOf(context).languageCode;
    List<List<String>>? eulaContent = CompanyInfo().localizedEula[langCode] ??
        CompanyInfo().localizedEula['ko'];

    return FrostedSettingsScaffold(
      title: 'settings_eula'.tr(context),
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
                for (int i = 0; i < eulaContent!.length; i++) ...[
                  if (i != 0) const SizedBox(height: 26),
                  AgreementSection(
                    sectionTitle: eulaContent[i][0],
                    sectionBody: eulaContent[i][1],
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
