import 'package:bandi_official/view/writing/controller/emotion_provider.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomField extends StatefulWidget {
  const CustomField({
    super.key,
    required this.onChanged,
    this.initialValue = '',
    this.isPassword = false,
    this.isEnabled = true,
  });

  final Function(String) onChanged;
  final String initialValue;
  final bool isPassword;
  final bool isEnabled;

  @override
  _CustomFieldState createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  final bool _isObscured = true;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _currentLength = widget.initialValue.characters.length;

    _focusNode.addListener(() {
      setState(() {}); // 포커스 변경 시 suffixIcon 다시 그림
    });
  }

  @override
  Widget build(BuildContext context) {
    String langCode = Localizations.localeOf(context).languageCode;
    int maxLength = (langCode == 'ko') ? 10 : 20;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: (value) {
        if (value.characters.length <= maxLength) {
          setState(() {
            _currentLength = value.characters.length;
          });
          widget.onChanged(value);
        } else {
          final newValue = value.characters.take(maxLength).toString();
          _controller.text = newValue;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: newValue.length),
          );
          setState(() {
            _currentLength = newValue.characters.length;
          });
        }
      },
      obscureText: widget.isPassword ? _isObscured : false,
      enabled: widget.isEnabled,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: 'onboarding_nickname_textbar_message'.tr(context),
        hintStyle: BandiFont.bodyLarge(context)?.copyWith(
          color: BandiColor.foundationColor20(context),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: BandiColor.neutralColor40(context),

        suffixIcon: _focusNode.hasFocus
            ? GestureDetector(
          onTap: () {
            _controller.clear();
            setState(() {
              _currentLength = 0;
            });
            widget.onChanged('');
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
                size: 20,
                color: BandiColor.foundationColor20(context),
              ),
              const SizedBox(width: 10),
              Text(
                '$_currentLength/$maxLength',
                style: BandiFont.labelSmall(context)?.copyWith(
                  color: BandiColor.foundationColor40(context),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        )
            : null,

        counterText: '',
      ),
      cursorHeight: 20,
      cursorColor: BandiColor.foundationColor100(context),
      style: BandiFont.bodyLarge(context)?.copyWith(
        color: BandiColor.foundationColor90(context),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
