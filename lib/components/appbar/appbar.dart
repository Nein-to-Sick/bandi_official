import 'package:bandi_official/components/icon_button/icon_button.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.titleColor,
    required this.trailingIcon,
    this.leadingIconColor,
    this.trailingIconColor,
    required this.onLeadingIconPressed,
    required this.onTrailingIconPressed,
    required this.disableLeadingButton,
    required this.disableTrailingButton,
    required this.isVisibleLeadingButton,
    required this.isVisibleTrailingButton,
  });

  final String title;
  final Color? titleColor;
  final PhosphorIconData trailingIcon;
  final Color? leadingIconColor;
  final Color? trailingIconColor;
  final Function onLeadingIconPressed;
  final Function onTrailingIconPressed;
  final bool disableLeadingButton;
  final bool disableTrailingButton;
  final bool isVisibleLeadingButton;
  final bool isVisibleTrailingButton;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: BandiColor.transparent(context),
      title: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Text(
          widget.title,
          style: BandiFont.displaySmall(context)?.copyWith(
            color: (widget.titleColor != null)
                ? widget.titleColor
                : BandiColor.neutralColor100(context),
          ),
        ),
      ),
      centerTitle: true,
      leading: (widget.isVisibleLeadingButton)
          ? Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              child: widget.title == "나의 일기"
                  ? IconButton(
                      icon: PhosphorIcon(
                        PhosphorIcons.arrowUDownLeft(),
                        color: (widget.disableLeadingButton
                            ? BandiColor.neutralColor20(context)
                            : BandiColor.neutralColor80(context)),
                        size: 24,
                      ),
                      onPressed: () {
                        (widget.disableLeadingButton)
                            ? null
                            : widget.onLeadingIconPressed();
                      },
                    )
                  : CustomIconButton(
                      onIconButtonPressed: widget.onLeadingIconPressed,
                      disableButton: widget.disableLeadingButton,
                      iconColor: widget.leadingIconColor,
                    ),
            )
          : const SizedBox.shrink(),
      actions: [
        if (widget.isVisibleTrailingButton)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            child: IconButton(
              icon: PhosphorIcon(
                widget.trailingIcon,
                color: (widget.trailingIconColor != null)
                    ? widget.trailingIconColor
                    : widget.disableTrailingButton
                        ? BandiColor.neutralColor20(context)
                        : BandiColor.neutralColor80(context),
                size: 24,
              ),
              onPressed: () {
                (widget.disableTrailingButton)
                    ? null
                    : widget.onTrailingIconPressed();
              },
            ),
          ),
      ],
    );
  }
}
