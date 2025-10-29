import 'package:bandi_official/string_extention.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../analytics/logJournalCreate.dart';
import '../../../components/button/primary_button.dart';
import '../../../controller/home_to_write.dart';
import '../../../theme/custom_theme_data.dart';

import 'dart:developer' as dev;

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
              const SizedBox(height: 26),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    writeProvider.isPublic ? "sharing_diary_on".tr(context) : 'sharing_diary_off'.tr(context),
                    style: BandiFont.titleSmall(context)?.copyWith(
                      color: BandiColor.neutralColor100(context),
                    ),
                  ),
                  FlutterSwitch(
                    value: writeProvider.isPublic,
                    onToggle: writeProvider.setIsPublic,
                    inactiveColor: BandiColor.foundationColor40(context),
                    activeColor: BandiColor.accentColorYellow(context),
                    inactiveToggleColor: BandiColor.foundationColor40(context),
                    width: 42.0,
                    height: 21.0,
                    padding: 2,
                    toggleSize: 18.0,
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomPrimaryButton(
                      title: 'done'.tr(context),
                      onPrimaryButtonPressed: () async {
                        writeProvider.aiAndSaveDiary(context);
                        writeProvider.nextWrite(2);
                        await logJournalCreate(usedAI: writeProvider.isPublic);
                      },
                      disableButton:
                          writeProvider.diaryModel.content.isNotEmpty ? false : true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
