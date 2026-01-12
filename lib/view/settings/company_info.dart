import 'package:bandi_official/localization/string_extention.dart';
import 'package:bandi_official/view/settings/widget/frosted_settings_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../model/settingsInfos.dart';
import '../../theme/custom_theme_data.dart';

class CompanyInfoScreen extends StatelessWidget {
  final VoidCallback onBack;

  const CompanyInfoScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    String langCode = Localizations.localeOf(context).languageCode;
    Map<String, String>? companyInfo =
        CompanyInfo().localizedCompanyInfo[langCode] ??
            CompanyInfo().localizedCompanyInfo['ko'];

    return FrostedSettingsScaffold(
        title: 'settings_business_information'.tr(context),
        onBack: onBack,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSettingOption(
                    context: context,
                    text: 'settings_business_information_company_name'
                        .tr(context),
                    value: companyInfo!['companyName']!),
                _buildSettingOption(
                    context: context,
                    text: 'settings_business_information_ceo'.tr(context),
                    value: companyInfo!['ceo']!),
                _buildSettingOption(
                    context: context,
                    text: 'settings_business_information_address'.tr(context),
                    value: companyInfo!['address']!),
                _buildSettingOption(
                    context: context,
                    text: 'settings_business_information_email'.tr(context),
                    value: companyInfo!['email']!),
              ],
            ),
          ),
        ));
  }

  Widget _buildSettingOption({
    context,
    required String text,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: BandiFont.titleSmall(context)?.copyWith(
                  color: BandiColor.foundationColor90(context),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                value,
                style: BandiFont.labelSmall(context)?.copyWith(
                  color: BandiColor.foundationColor60(context),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 0,
          color: BandiColor.foundationColor04(context),
          thickness: 1,
        ),
      ],
    );
  }
}
