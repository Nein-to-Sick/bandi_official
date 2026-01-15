import 'package:bandi_official/components/icon_button/icon_button.dart';
import 'package:bandi_official/localization/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleColor,
    this.trailingIcon,
    this.leadingIconColor,
    this.trailingIconColor,
    this.onLeadingIconPressed,
    this.onTrailingIconPressed,
    this.disableLeadingButton,
    this.disableTrailingButton,
    this.isVisibleLeadingButton,
    this.isVisibleTrailingButton,
  });

  final String? title;
  final Color? titleColor;
  final PhosphorIconData? trailingIcon;
  final Color? leadingIconColor;
  final Color? trailingIconColor;
  final Function? onLeadingIconPressed;
  final Function? onTrailingIconPressed;
  final bool? disableLeadingButton;
  final bool? disableTrailingButton;
  final bool? isVisibleLeadingButton;
  final bool? isVisibleTrailingButton;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BandiColor.transparent(context),
        title: Text(
          widget.title ?? '',
          style: BandiFont.headlineMedium(context)?.copyWith(
            color: (widget.titleColor != null)
                ? widget.titleColor
                : BandiColor.neutralColor100(context),
          ),
        ),
        centerTitle: true,
        leading: (widget.isVisibleLeadingButton ?? true)
            ? Container(
                child: widget.title == 'journal_title'.tr(context)
                    ? CustomIconButton(
                        icon: PhosphorIcons.arrowUDownLeft(),
                        onIconButtonPressed:
                            widget.onLeadingIconPressed ?? () {},
                        disableButton: widget.disableLeadingButton ?? false,
                        iconColor: widget.leadingIconColor,
                      )
                    : CustomIconButton(
                        onIconButtonPressed:
                            widget.onLeadingIconPressed ?? () {},
                        disableButton: widget.disableLeadingButton ?? false,
                        iconColor: widget.leadingIconColor,
                      ),
              )
            : const SizedBox.shrink(),
        actions: [
          if (widget.isVisibleTrailingButton ?? true)
            CustomIconButton(
              icon: widget.trailingIcon ??
                  PhosphorIcons.x(PhosphorIconsStyle.fill),
              onIconButtonPressed: widget.onTrailingIconPressed ?? () {},
              disableButton: widget.disableTrailingButton ?? false,
              iconColor: widget.trailingIconColor,
            ),
        ],
      ),
    );
  }
}
