import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../model/settingsInfos.dart';
import '../../theme/custom_theme_data.dart';

class CompanyInfoScreen extends StatelessWidget {
  final VoidCallback onBack;

  const CompanyInfoScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
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
            "사업자 정보",
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CompanyInfo().companyName,
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
                  "대표",
                  style: BandiFont.headlineMedium(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
                Text(
                  CompanyInfo().ceo,
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
                  "주소",
                  style: BandiFont.headlineMedium(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
                Text(
                  CompanyInfo().address,
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
                  "이메일",
                  style: BandiFont.headlineMedium(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
                Text(
                  CompanyInfo().email,
                  style: BandiFont.bodySmall(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        )
    );
  }
}
