import 'package:bandi_official/string_extention.dart';
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
                    'write_query_feeling'.tr(context),
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
                    hintText: 'write_hint_text'.tr(context),
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
              // ✅ Toggle 추가
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'sharing_diary'.tr(context),
                      style: BandiFont.titleMedium(context)?.copyWith(
                        color: BandiColor.neutralColor100(context),
                      ),
                    ),
                    Switch(
                      value: writeProvider.isPublic,
                      onChanged: writeProvider.setIsPublic,
                      inactiveTrackColor: BandiColor.neutralColor40(context),
                      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                      inactiveThumbColor: BandiColor.foundationColor80(context),
                      activeColor: BandiColor.accentColorYellow(context),
                    ),
                  ],
                ),
              ),
              CustomPrimaryButton(
                title: 'done'.tr(context),
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
