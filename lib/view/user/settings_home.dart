// lib/views/user/settings_home.dart
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../components/dialogue/reset_dialogue.dart';
import '../../controller/permission_controller.dart';
import '../../theme/custom_theme_data.dart';

class SettingsHome extends StatelessWidget {
  final Function(int) onNavigate;
  const SettingsHome({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final permissionController = Provider.of<PermissionController>(context);

    return Scaffold(
      backgroundColor: BandiColor.neutralColor80(context).withOpacity(0.8),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BandiColor.transparent(context),
        title: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Text(
            'settings_title'.tr(context),
            style: BandiFont.headlineMedium(context)?.copyWith(
              color: BandiColor.foundationColor80(context),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
        children: [
          _buildSettingOption(
            context: context,
            icon: PhosphorIcons.user(),
            text: 'settings_my_account'.tr(context),
            onTap: () => onNavigate(1),
            autotext: 0,
          ),
          const SizedBox(height: 8),
          _buildSettingOption(
            context: context,
            icon: PhosphorIcons.bell(),
            text: 'settings_notifications'.tr(context),
            onTap: () {},
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (permissionController.getNotificationPermissionState())
                      ? 'settings_notifications_on'.tr(context)
                      : 'settings_notifications_off'.tr(context),
                  style: BandiFont.bodyMedium(context)?.copyWith(
                    color: BandiColor.foundationColor10(context),
                  ),
                ),
                const SizedBox(width: 12.5),
                Switch(
                  value: permissionController.getNotificationPermissionState(),
                  onChanged: (bool value) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomResetDialogue(
                            text: 'settings_notifications_text'.tr(context),
                            onYesText: 'dialogue_yes'.tr(context),
                            onNoText: 'dialogue_no'.tr(context),
                            onYesFunction: () {
                              Navigator.pop(context);
                              openAppSettings();
                            },
                            onNoFunction: () {
                              Navigator.pop(context);
                            },
                          );
                        });
                  },
                  activeColor: BandiColor.accentColorYellow(context),
                  activeTrackColor: BandiColor.neutralColor100(context),
                  inactiveThumbColor: BandiColor.foundationColor80(context),
                  inactiveTrackColor: BandiColor.foundationColor40(context),
                ),
              ],
            ),
            autotext: 0,
          ),
          const SizedBox(height: 24),
          Divider(
            height: 1.0,
            color: BandiColor.foundationColor10(context),
          ),
          const SizedBox(height: 16),
          _buildSettingOption(
            context: context,
            text: 'settings_open_license'.tr(context),
            onTap: () => onNavigate(3),
            autotext: 0,
          ),
          const SizedBox(height: 8),
          _buildSettingOption(
            context: context,
            text: 'settings_terms_of_use'.tr(context),
            onTap: () => onNavigate(4),
            autotext: 0,
          ),
          const SizedBox(height: 8),
          _buildSettingOption(
            context: context,
            text: 'settings_privacy_policy'.tr(context),
            onTap: () => onNavigate(5),
            autotext: 0,
          ),
          const SizedBox(height: 8),
          _buildSettingOption(
            context: context,
            text: 'settings_eula'.tr(context),
            onTap: () => onNavigate(8),
            autotext: 0,
          ),
          const SizedBox(height: 8),
          _buildSettingOption(
            context: context,
            text: 'settings_business_information'.tr(context),
            onTap: () => onNavigate(6),
            autotext: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption({
    context,
    required String text,
    required VoidCallback onTap,
    IconData? icon,
    Widget? trailing,
    required int autotext,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onTap,
      child: Container(
        color: BandiColor.transparent(context),
        height: 42.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 24,
                color: BandiColor.foundationColor80(context),
              ),
            if (icon != null) const SizedBox(width: 8),
            (autotext == 1)
                ? Text(
                    text,
                    style: BandiFont.bodyMedium(context)?.copyWith(
                      color: BandiColor.foundationColor80(context),
                    ),
                  )
                : AutoSizeText(
                    text,
                    style: BandiFont.bodyMedium(context)?.copyWith(
                      color: BandiColor.foundationColor80(context),
                    ),
                    maxLines: 1,
                  ),
            if (trailing != null) ...[
              const Spacer(),
              trailing,
            ] else ...[
              const Spacer(),
              Icon(
                PhosphorIcons.caretRight(),
                size: 24,
                color: BandiColor.foundationColor20(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
