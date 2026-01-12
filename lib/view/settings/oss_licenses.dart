// lib/views/user/oss_licenses.dart
import 'package:bandi_official/localization/string_extention.dart';
import 'package:bandi_official/view/settings/widget/frosted_settings_scaffold.dart';
import 'package:flutter/material.dart';

import '../../model/oss_licenses_model.dart';
import '../../theme/custom_theme_data.dart';

class OssLicensesScreen extends StatefulWidget {
  final VoidCallback onBack;

  // ✅ 더 이상 상세 페이지 이동이 필요 없으면 제거해도 됨
  // (남겨두고 싶으면 안 쓰더라도 파라미터만 유지 가능)
  final Function(Map<String, dynamic>)? onNavigateLicenseDetail;

  const OssLicensesScreen({
    super.key,
    required this.onBack,
    this.onNavigateLicenseDetail,
  });

  @override
  State<OssLicensesScreen> createState() => _OssLicensesScreenState();
}

class _OssLicensesScreenState extends State<OssLicensesScreen>
    with TickerProviderStateMixin {
  int? expandedIndex;

  String _licenseBodyText(String licenseText) {
    return licenseText
        .split('\n')
        .map((line) {
          if (line.startsWith('//')) line = line.substring(2);
          return line.trimRight();
        })
        .join('\n')
        .trim();
  }

  void _toggle(int index) {
    setState(() {
      if (expandedIndex == index) {
        expandedIndex = null;
      } else {
        expandedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FrostedSettingsScaffold(
      title: 'settings_open_license'.tr(context),
      onBack: widget.onBack,
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
            final isExpanded = expandedIndex == index;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _toggle(index),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== Header (기존: name + description) =====
                          Text(
                            package.name,
                            style: BandiFont.titleSmall(context)?.copyWith(
                              color: BandiColor.foundationColor90(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (isExpanded && package.version.isNotEmpty) ...[
                            Text('version : ${package.version}',
                                style: BandiFont.labelSmall(context)?.copyWith(
                                  color: BandiColor.foundationColor60(context),
                                )),
                            const SizedBox(
                              height: 4,
                            ),
                          ],
                          if (package.description.isNotEmpty)
                            Text(
                              package.description,
                              style: BandiFont.labelSmall(context)?.copyWith(
                                color: BandiColor.foundationColor60(context),
                              ),
                            ),

                          // ===== Expanded body =====
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            child: isExpanded
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // license text
                                        Text(
                                          _licenseBodyText(package.license!),
                                          style: BandiFont.labelSmall(context)
                                              ?.copyWith(
                                            color: BandiColor.foundationColor60(
                                                context),
                                          ),
                                        ),

                                        if (package.homepage != null) ...[
                                          const SizedBox(height: 14),
                                          Text(
                                            package.homepage!,
                                            style: BandiFont.labelSmall(context)
                                                ?.copyWith(
                                                    color: BandiColor
                                                        .foundationColor60(
                                                            context),
                                                    decoration: TextDecoration
                                                        .underline),
                                          ),
                                        ],
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
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
      ),
    );
  }
}
