// lib/views/user/settings_home.dart
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../components/no_reuse/reset_dialogue.dart';
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
            "설정",
            style: BandiFont.displaySmall(context)?.copyWith(
              color: BandiColor.foundationColor80(context),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
        children: [
          _buildSettingOption(
            context: context,
            icon: PhosphorIcons.user(),
            text: "계정 관리",
            onTap: () => onNavigate(1),
            autotext: 0,
          ),
          const SizedBox(height: 8),
          _buildSettingOption(
            context: context,
            icon: PhosphorIcons.bell(),
            text: "알림 설정",
            onTap: () {},
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  (permissionController.getNotificationPermissionState())
                      ? "설정됨"
                      : "해제됨",
                  style: BandiFont.bodyMedium(context)?.copyWith(
                    color: BandiColor.foundationColor10(context),
                  ),
                ),
                const SizedBox(width: 12.5),
                Switch(
                  value:
                  permissionController.getNotificationPermissionState(),
                  onChanged: (bool value) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomResetDialogue(
                            text: '알림 설정은 시스템 설정에서 진행됩니다.\n시스템 설정으로 이동하시겠나요?',
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
            text: "오픈 라이센스",
            onTap: () => onNavigate(3),
            autotext: 0,
          ),
          const SizedBox(height: 8),
          _buildSettingOption(
            context: context,
            text: "이용 약관",
            onTap: () => onNavigate(4),
            autotext: 0,
          ),
          const SizedBox(height: 8),
          _buildSettingOption(
            context: context,
            text: "개인정보 처리방침",
            onTap: () => onNavigate(5),
            autotext: 0,
          ),
          const SizedBox(height: 8),
          _buildSettingOption(
            context: context,
            text: "사업자 정보",
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
        color: Colors.transparent,
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
