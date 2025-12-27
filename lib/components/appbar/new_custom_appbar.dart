import 'package:bandi_official/components/icon_button/icon_button.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum AppBarType {
  oneButtonFoundation,
  oneButtonNeutral,
  twoButtonFoundation,
  twoButtonNeutral,
}

extension AppBarTypeExtension on AppBarType {
  // 타이틀 스타일 결정
  TextStyle? getTitleStyle(BuildContext context) {
    switch (this) {
      case AppBarType.oneButtonFoundation:
        return BandiFont.headlineMedium(context)
            ?.copyWith(color: BandiColor.foundationColor100(context));
      case AppBarType.oneButtonNeutral:
        return BandiFont.headlineMedium(context)
            ?.copyWith(color: BandiColor.neutralColor100(context));
      case AppBarType.twoButtonFoundation:
        return BandiFont.titleSmall(context)
            ?.copyWith(color: BandiColor.foundationColor100(context));
      case AppBarType.twoButtonNeutral:
        return BandiFont.titleSmall(context)
            ?.copyWith(color: BandiColor.neutralColor100(context));
    }
  }

  // 아이콘 색상 결정
  Color getIconColor(BuildContext context) {
    switch (this) {
      case AppBarType.oneButtonFoundation:
      case AppBarType.twoButtonFoundation:
        return BandiColor.foundationColor20(context);
      case AppBarType.oneButtonNeutral:
      case AppBarType.twoButtonNeutral:
      default:
        return BandiColor.neutralColor20(context);
    }
  }
}

class NewCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NewCustomAppBar({
    super.key,
    this.title,
    required this.appBarType,
    this.leftActionButtonIcon,
    this.rightActionButtonIcon,
    this.onLeftActionButtonPressed,
    this.onRightActionButtonPressed,
    this.disableLefttActionButton = false,
    this.disableRightActionButton = false,
  });

  final String? title;
  final AppBarType appBarType;
  final IconData? leftActionButtonIcon;
  final IconData? rightActionButtonIcon;
  final VoidCallback? onLeftActionButtonPressed;
  final VoidCallback? onRightActionButtonPressed;
  final bool disableLefttActionButton;
  final bool disableRightActionButton;

  // 피그마의 전체 높이 64px 반영
  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  @override
  Widget build(BuildContext context) {
    final iconColor = appBarType.getIconColor(context);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: BandiColor.transparent(context),
        border: Border(
          bottom: BorderSide(
              color: BandiColor.foundationColor10(context), width: 1),
        ),
      ),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title ?? "",
              style: appBarType.getTitleStyle(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _buildActionButtons(context, iconColor),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context, Color iconColor) {
    switch (appBarType) {
      case AppBarType.oneButtonFoundation:
      case AppBarType.oneButtonNeutral:
        return [
          CustomIconButton(
            icon: rightActionButtonIcon ??
                PhosphorIcons.x(PhosphorIconsStyle.thin),
            iconColor: iconColor,
            onIconButtonPressed: onRightActionButtonPressed ?? () {},
            disableButton: disableRightActionButton,
          ),
        ];
      case AppBarType.twoButtonFoundation:
      case AppBarType.twoButtonNeutral:
        return [
          CustomIconButton(
            icon: leftActionButtonIcon ??
                PhosphorIcons.funnelSimple(PhosphorIconsStyle.thin),
            iconColor: iconColor,
            onIconButtonPressed: onLeftActionButtonPressed ?? () {},
            disableButton: disableLefttActionButton,
          ),
          const SizedBox(width: 0),
          CustomIconButton(
            icon: rightActionButtonIcon ??
                PhosphorIcons.calendarBlank(PhosphorIconsStyle.thin),
            iconColor: iconColor,
            onIconButtonPressed: onRightActionButtonPressed ?? () {},
            disableButton: disableRightActionButton,
          ),
        ];
    }
  }
}
