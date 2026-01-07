// lib/views/user/settings_home.dart
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
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

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 21),
            child: Text(
              "설정",
              style: BandiFont.titleMedium(context)!
                  .copyWith(color: BandiColor.neutralColor90(context)),
            ),
          ),
          Divider(
            height: 0,
            color: BandiColor.neutralColor04(context),
            thickness: 1,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 23.0, right: 25.0),
              children: [
                _buildSettingFunction(
                  context: context,
                  text: 'settings_my_account'.tr(context),
                  onTap: () => onNavigate(1),
                  trailing: PhosphorIcon(
                    PhosphorIcons.caretRight(),
                    size: 16,
                    color: BandiColor.neutralColor40(context),
                  ),
                ),
                _buildSettingFunction(
                  context: context,
                  text: 'settings_notifications'.tr(context),
                  onTap: () {},
                  trailing: FlutterSwitch(
                    value: permissionController
                        .getNotificationPermissionState(),
                    onToggle: (bool value) {
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
                        },
                      );
                    },
                    width: 32.0,
                    height: 16.0,
                    padding: 2,
                    toggleSize: 12.0,
                    activeColor: BandiColor.accentColorYellow(context),
                    inactiveColor: BandiColor.foundationColor40(context),
                    toggleColor: BandiColor.neutralColor100(context),
                    inactiveToggleColor: BandiColor.foundationColor40(context),
                  ),
                ),
                const SizedBox(height: 24),
                _buildSettingDocument(
                  context: context,
                  text: 'settings_open_license'.tr(context),
                  onTap: () => onNavigate(3),
                  autotext: 0,
                ),
                _buildSettingDocument(
                  context: context,
                  text: 'settings_terms_of_use'.tr(context),
                  onTap: () => onNavigate(4),
                  autotext: 0,
                ),
                _buildSettingDocument(
                  context: context,
                  text: 'settings_privacy_policy'.tr(context),
                  onTap: () => onNavigate(5),
                  autotext: 0,
                ),
                _buildSettingDocument(
                  context: context,
                  text: 'settings_eula'.tr(context),
                  onTap: () => onNavigate(8),
                  autotext: 0,
                ),
                _buildSettingDocument(
                  context: context,
                  text: 'settings_business_information'.tr(context),
                  onTap: () => onNavigate(6),
                  autotext: 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingFunction({
    context,
    required String text,
    required VoidCallback onTap,
    required Widget trailing,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Container(
              color: BandiColor.transparent(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    text,
                    style: BandiFont.titleSmall(context)?.copyWith(
                      color: BandiColor.neutralColor90(context),
                    ),
                  ),
                  trailing
                ],
              ),
            ),
          ),
        ),
        Divider(height: 0, color: BandiColor.neutralColor04(context), thickness: 1,),
      ],
    );
  }

  Widget _buildSettingDocument({
    context,
    required String text,
    required VoidCallback onTap,
    required int autotext,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: BandiColor.transparent(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            text,
            style: BandiFont.labelSmall(context)?.copyWith(
              color: BandiColor.neutralColor40(context),
            ),
          ),
        ),
      ),
    );
  }
}
