import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../components/button/primary_button.dart';
import '../../../controller/home_to_write.dart';
import '../../../theme/custom_theme_data.dart';

class FirstStep extends StatefulWidget {
  const FirstStep({Key? key}) : super(key: key);

  @override
  State<FirstStep> createState() => _State();
}

class _State extends State<FirstStep> {
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;

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

    print(writeProvider.diaryModel.content);
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                    setState(() => writeProvider.diaryModel.content =
                        _textEditingController.text);
                  },
                  maxLines: null,
                  expands: true,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              CustomPrimaryButton(
                title: '완료',
                onPrimaryButtonPressed: () {
                  writeProvider.aiAndSaveDiary(context);
                  writeProvider.nextWrite(2);
                },
                disableButton:
                    writeProvider.diaryModel.content.isNotEmpty ? false : true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
