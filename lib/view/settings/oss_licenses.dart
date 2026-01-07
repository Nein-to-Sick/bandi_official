// lib/views/user/oss_licenses.dart
import 'package:bandi_official/components/appbar/appbar.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/view/settings/widget/frosted_settings_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../model/oss_licenses_model.dart';
import '../../theme/custom_theme_data.dart';

class OssLicensesScreen extends StatelessWidget {
  final VoidCallback onBack;

  // 새로 추가: 라이센스 상세 페이지로 이동하기 위한 콜백
  final Function(Map<String, dynamic>) onNavigateLicenseDetail;

  const OssLicensesScreen({
    super.key,
    required this.onBack,
    required this.onNavigateLicenseDetail,
  });

  @override
  Widget build(BuildContext context) {
    return FrostedSettingsScaffold(
        title: 'settings_open_license'.tr(context),
        onBack: onBack,
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
          child: ListView.builder(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.1,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: ossLicenses.length,
            itemBuilder: (context, index) {
              final package = ossLicenses[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      onNavigateLicenseDetail({
                        'name': package.name,
                        'version': package.version,
                        'description': package.description,
                        'license': package.license,
                        'homepage': package.homepage,
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                package.name,
                                style: BandiFont.titleSmall(context)?.copyWith(
                                  color: BandiColor.foundationColor90(context),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(package.description,
                                  style:
                                      BandiFont.labelSmall(context)?.copyWith(
                                    color:
                                        BandiColor.foundationColor60(context),
                                  ))
                            ]),
                      ),
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    color: BandiColor.foundationColor10(context),
                  ),
                ],
              );
            },
          ),
        ));
  }
}

class MiscOssLicenseSingle extends StatelessWidget {
  final VoidCallback onBack;
  final String name;
  final String version;
  final String description;
  final String licenseText;
  final String homepage;

  const MiscOssLicenseSingle({
    super.key,
    required this.onBack,
    required this.name,
    required this.version,
    required this.description,
    required this.licenseText,
    required this.homepage,
  });

  String _bodyText() {
    return licenseText.split('\n').map((line) {
      if (line.startsWith('//')) line = line.substring(2);
      return line.trim();
    }).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return FrostedSettingsScaffold(
        title: 'settings_open_license'.tr(context),
        onBack: onBack,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: BandiFont.bodySmall(context)?.copyWith(
                  color: BandiColor.foundationColor100(context),
                ),
              ),
              Text(
                'version : $version',
                style: BandiFont.bodySmall(context)?.copyWith(
                  color: BandiColor.foundationColor100(context),
                ),
              ),
              if (description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    description,
                    style: BandiFont.bodySmall(context)?.copyWith(
                      color: BandiColor.foundationColor80(context),
                    ),
                  ),
                ),
              Divider(color: BandiColor.foundationColor20(context)),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  _bodyText(),
                  style: BandiFont.bodySmall(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
