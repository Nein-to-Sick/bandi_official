import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../components/button/primary_button.dart';
import '../../../controller/home_to_write.dart';
import '../../../theme/custom_theme_data.dart';

class FirstStep extends StatefulWidget {
  const FirstStep ({Key? key}) : super(key: key);

  @override
  State<FirstStep> createState() => _State();
}

class _State extends State<FirstStep> {
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;
  // 사용자가 입력한 값을 저장하는 변수
  String textContent = "";

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();

    // Automatically focus the text field when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final writeProvider = Provider.of<HomeToWrite>(context);

    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "기분이 어떠신가요?",
                style: BandiFont.displaySmall(context)
                    ?.copyWith(color: BandiColor.neutralColor100(context)),
              ),
              GestureDetector(
                onTap: () {
                  writeProvider.toggleWrite();
                  writeProvider.initialize();
                },
                child: PhosphorIcon(
                  PhosphorIcons.x(),
                  color: BandiColor.neutralColor40(context),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: TextField(
              controller: _textEditingController,
              focusNode: _focusNode,
              cursorColor: BandiColor.neutralColor100(context),
              style: BandiFont.titleSmall(context)
                  ?.copyWith(color: BandiColor.neutralColor100(context)),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '겪었던 일과 느꼈던 감정에 대해 써주세요.',
                hintStyle: BandiFont.titleSmall(context)?.copyWith(
                  color: BandiColor.neutralColor40(context),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  // _textEditingController.text = value;
                  /* 변경 : 값을 문자열 변수에 업데이트 */
                  setState(() => textContent = _textEditingController.text);
                });
              },
              maxLines: null,
              expands: true,
            ),
          ),
          CustomPrimaryButton(
            title: '완료',
            onPrimaryButtonPressed: () {
              writeProvider.aiAndSaveDairy(textContent);
              writeProvider.nextWrite(2);
            },
            disableButton: textContent.isNotEmpty ? false : true,
          ),
          const SizedBox(height: 16,),
        ],
      ),
    );
  }
}
