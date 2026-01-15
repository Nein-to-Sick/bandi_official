import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomIconButton extends StatefulWidget {
  const CustomIconButton({
    super.key,
    required this.onIconButtonPressed,
    required this.disableButton,
    this.icon,
    this.iconColor,
    this.rightActionButtonKey
  });
  final IconData? icon;
  final Function onIconButtonPressed;
  final bool disableButton;
  final Color? iconColor;
  final GlobalKey? rightActionButtonKey;

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: widget.rightActionButtonKey,
      onPressed: widget.disableButton
          ? null
          : () => widget.onIconButtonPressed(),
      icon: PhosphorIcon(
        widget.icon ?? PhosphorIcons.caretLeft(PhosphorIconsStyle.regular),
        color: (widget.iconColor != null)
            ? widget.iconColor
            : widget.disableButton
                ? BandiColor.neutralColor20(context)
                : BandiColor.neutralColor80(context),
        size: 24,
      ),
    );
  }
}
