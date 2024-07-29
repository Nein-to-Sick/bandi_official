import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../components/button/primary_button.dart';
import '../../controller/home_to_write.dart';
import '../../theme/custom_theme_data.dart';

class WriteDiary extends StatefulWidget {
  const WriteDiary({super.key});

  @override
  _WriteDiaryState createState() => _WriteDiaryState();
}

class _WriteDiaryState extends State<WriteDiary> {
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
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: BandiEffects.backgroundBlur(), sigmaY: BandiEffects.backgroundBlur()),
        child: Container(
          color: BandiColor.neutralColor10(context),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 32.0, left: 24, right: 24),
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
                          _textEditingController.text = value;
                        });
                      },
                      maxLines: null,
                      expands: true,
                    ),
                  ),
                  CustomPrimaryButton(
                    title: '완료',
                    onPrimaryButtonPressed: () {
                      writeProvider.saveDiary("title", _textEditingController.text, ["기쁨"]);
                    },
                    disableButton: _textEditingController.text.isNotEmpty ? false : true,
                  ),
                  const SizedBox(height: 16,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
