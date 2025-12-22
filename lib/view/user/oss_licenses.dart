// lib/views/user/oss_licenses.dart
import 'package:bandi_official/components/appbar/appbar.dart';
import 'package:bandi_official/string_extention.dart';
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
          'settings_open_license'.tr(context),
          style: BandiFont.headlineMedium(context)?.copyWith(
            color: BandiColor.foundationColor80(context),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
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
                ListTile(
                  title: Text(
                    package.name,
                    style: BandiFont.bodyMedium(context)?.copyWith(
                      color: BandiColor.foundationColor80(context),
                    ),
                  ),
                  subtitle: Text(
                    package.description,
                    style: BandiFont.bodySmall(context)?.copyWith(
                      color: BandiColor.foundationColor20(context),
                    ),
                  ),
                  onTap: () {
                    // 기존 Navigator.push 대신 콜백으로 라이센스 정보 전달
                    onNavigateLicenseDetail({
                      'name': package.name,
                      'version': package.version,
                      'description': package.description,
                      'license': package.license,
                      'homepage': package.homepage,
                    });
                  },
                ),
                Divider(
                  height: 1.0,
                  color: BandiColor.foundationColor10(context),
                ),
              ],
            );
          },
        ),
      ),
    );
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
    return Scaffold(
      // iOS에서 흰 배경이 잠깐 보이지 않도록 투명/어두운 배경 사용
      backgroundColor: BandiColor.neutralColor80(context).withOpacity(0.8),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BandiColor.transparent(context),
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft()),
          onPressed: onBack, // Navigator.pop() 대신 settings=3으로 돌아가도록
        ),
        title: Text(
          "오픈 라이센스",
          style: BandiFont.headlineMedium(context)?.copyWith(
            color: BandiColor.foundationColor80(context),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 23.0),
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
        ),
      ),
    );
  }
}
