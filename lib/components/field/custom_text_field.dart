import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({super.key});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final TextEditingController _controller = TextEditingController();
  int _charCount = 0;
  final int _maxLength = 20;

  void _clearText() {
    _controller.clear();
    setState(() {
      _charCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLength: _maxLength,
      onChanged: (text) {
        setState(() {
          _charCount = text.length;
        });
      },
      decoration: InputDecoration(
        counterText: '', // 기본 카운터 텍스트 숨기기
        suffixIcon: _charCount > 0
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _clearText,
                    child: Icon(
                      PhosphorIcons.xCircle(),
                      color: BandiColor.foundationColor20(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$_charCount/$_maxLength',
                    style: BandiFont.labelMedium(context)?.copyWith(
                      color: BandiColor.foundationColor20(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              )
            : null,
        hintText: '최대 $_maxLength글자',
        fillColor: BandiColor.neutralColor40(context),
        filled: true,
        hintStyle: BandiFont.labelMedium(context)?.copyWith(
          color: BandiColor.foundationColor40(context),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      style: TextStyle(color: BandiColor.foundationColor80(context)),
      cursorColor: BandiColor.neutralColor100(context),
    );
  }
}
