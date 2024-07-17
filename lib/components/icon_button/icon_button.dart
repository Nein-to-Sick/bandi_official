import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomIconButton extends StatefulWidget {
  const CustomIconButton(
      {super.key, required this.function, required this.isDisabled});
  final Function function;
  final bool isDisabled;

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        (widget.isDisabled) ? null : widget.function();
      },
      icon: PhosphorIcon(
        PhosphorIcons.caretLeft(PhosphorIconsStyle.regular),
        color: widget.isDisabled
            ? BandiColor.neutralColor20(context)
            : BandiColor.neutralColor80(context),
        size: 24,
      ),
    );
  }
}
