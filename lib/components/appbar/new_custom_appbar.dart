import 'package:bandi_official/components/icon_button/icon_button.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';

enum AppBarType {
  titleFoundation,
  titleNeutral,
  dateFoundation,
  dateNeutral,
}

extension AppBarTypeExtension on AppBarType {
  // 타이틀 스타일 결정
  TextStyle? getTitleStyle(BuildContext context) {
    switch (this) {
      case AppBarType.titleFoundation:
        return BandiFont.headlineMedium(context)
            ?.copyWith(color: BandiColor.foundationColor100(context));
      case AppBarType.titleNeutral:
        return BandiFont.headlineMedium(context)
            ?.copyWith(color: BandiColor.neutralColor100(context));
      case AppBarType.dateFoundation:
        return BandiFont.titleSmall(context)
            ?.copyWith(color: BandiColor.foundationColor100(context));
      case AppBarType.dateNeutral:
        return BandiFont.titleSmall(context)
            ?.copyWith(color: BandiColor.neutralColor100(context));
    }
  }

  // 아이콘 색상 결정
  Color getIconColor(BuildContext context) {
    switch (this) {
      case AppBarType.titleFoundation:
      case AppBarType.dateFoundation:
        return BandiColor.foundationColor20(context);
      case AppBarType.titleNeutral:
      case AppBarType.dateNeutral:
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

  @override
  Size get preferredSize => const Size.fromHeight(72.0);

  @override
  Widget build(BuildContext context) {
    final iconColor = appBarType.getIconColor(context);

    return Container(
      decoration: BoxDecoration(
        color: BandiColor.transparent(context),
        border: Border(
          bottom: BorderSide(color: iconColor, width: 1),
        ),
      ),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
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
    return [
      if (leftActionButtonIcon != null)
        CustomIconButton(
          icon: leftActionButtonIcon!,
          iconColor: iconColor,
          onIconButtonPressed: onLeftActionButtonPressed ?? () {},
          disableButton: disableLefttActionButton,
        ),
      if (rightActionButtonIcon != null)
        CustomIconButton(
          icon: rightActionButtonIcon!,
          iconColor: iconColor,
          onIconButtonPressed: onRightActionButtonPressed ?? () {},
          disableButton: disableRightActionButton,
        ),
    ];
  }
}
