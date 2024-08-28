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
  bool _isObscured = true;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _currentLength = widget.initialValue.characters.length;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (value) {
        // 최대 10글자까지만 입력받도록 제한
        if (value.characters.length <= 10) {
          setState(() {
            _currentLength = value.characters.length;
          });
          widget.onChanged(value);
        } else {
          String newValue = value.characters.take(10).toString();
          _controller.text = newValue;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
          setState(() {
            _currentLength = newValue.characters.length;
          });
        }
      },
      obscureText: widget.isPassword ? _isObscured : false,
      enabled: widget.isEnabled,
      maxLength: 10, // 최대 10글자로 제한
      decoration: InputDecoration(
        hintText: '최대 10글자',
        hintStyle: BandiFont.labelMedium(context)?.copyWith(
          color: BandiColor.foundationColor40(context),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, // Border 색 없음
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, // 포커스 시에도 Border 색 없음
        ),
        filled: true,
        fillColor: BandiColor.neutralColor40(context), // 배경 색상
        suffixIcon: GestureDetector(
          onTap: () {
            // 텍스트 필드의 내용을 모두 삭제
            _controller.clear();
            setState(() {
              _currentLength = 0;
            });
            widget.onChanged(''); // 빈 값으로 콜백 호출
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIcons.xCircle(),
                size: 24,
                color: BandiColor.foundationColor20(context),
              ),
              const SizedBox(width: 7),
              Text(
                '$_currentLength/10',
                style: BandiFont.labelMedium(context)?.copyWith(
                  color: BandiColor.foundationColor20(context),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
        counterText: '', // 글자 수 표시를 제거
      ),
      cursorColor: BandiColor.neutralColor100(context), // 포커스 시 깜박이는 커서 색상
      style: BandiFont.labelMedium(context)?.copyWith(
        color: BandiColor.foundationColor100(context), // 텍스트 필드 안의 글자 색상
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
