import 'package:bandi_official/string_extention.dart';
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
            'settings_business_information'.tr(context),
            style: BandiFont.headlineMedium(context)?.copyWith(
              color: BandiColor.foundationColor80(context),
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyInfo!['companyName']!,
                  style: BandiFont.headlineLarge(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Divider(
                  height: 1.0,
                  color: BandiColor.foundationColor10(context),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'settings_business_information_ceo'.tr(context),
                  style: BandiFont.headlineMedium(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
                Text(
                  companyInfo!['ceo']!,
                  style: BandiFont.bodySmall(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Divider(
                  height: 1.0,
                  color: BandiColor.foundationColor10(context),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'settings_business_information_address'.tr(context),
                  style: BandiFont.headlineMedium(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
                Text(
                  companyInfo!['address']!,
                  style: BandiFont.bodySmall(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Divider(
                  height: 1.0,
                  color: BandiColor.foundationColor10(context),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  'settings_business_information_email'.tr(context),
                  style: BandiFont.headlineMedium(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
                Text(
                  companyInfo!['email']!,
                  style: BandiFont.bodySmall(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ));
  }
}
