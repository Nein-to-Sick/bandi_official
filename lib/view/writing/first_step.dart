import 'package:bandi_official/analytics/log_journal_share.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/view/writing/widget/ai_saving_loading_dialog.dart';
import 'package:bandi_official/view/writing/widget/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../analytics/log_journal_create.dart';
import '../../../controller/home_to_write.dart';
import '../../../theme/custom_theme_data.dart';
import '../../components/bottom_sheet/show_floating_confirm_sheet.dart';

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
      onTap: () => _focusNode.unfocus(),
      child: SafeArea(
        child: Column(
          children: [
            // ====== Body (TextField) ======
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: TextField(
                  controller: _textEditingController,
                  focusNode: _focusNode,
                  cursorColor: BandiColor.neutralColor90(context),
                  style: BandiFont.titleSmall(context)?.copyWith(
                    color: BandiColor.neutralColor90(context),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'write_hint_text'.tr(context),
                    hintStyle: BandiFont.titleSmall(context)?.copyWith(
                      color: BandiColor.neutralColor40(context),
                    ),
                  ),
                  onChanged: (_) {
                    setState(() {
                      writeProvider.diaryModel.content =
                          _textEditingController.text;
                    });
                  },
                  maxLines: null,
                  expands: true,
                ),
              ),
            ),


            // ====== Bottom Bar (divider segmented) ======
            BottomBar(
              isPublic: writeProvider.isPublic,
              onTogglePublic: writeProvider.setIsPublic,
              publicLabel: writeProvider.isPublic
                  ? "sharing_diary_on".tr(context)
                  : "sharing_diary_off".tr(context),
              onExit: () async {
                _focusNode.unfocus();
                final hasText = _textEditingController.text.trim().isNotEmpty;

                if (!hasText) {
                  writeProvider.toggleWrite();
                  writeProvider.initialize();
                  return;
                }

                final ok = await showFloatingConfirmSheet(
                  context,
                  title: '작성을 중단하고 나가시겠어요?',
                  description: '작성 중인 내용은 저장되지 않고 모두 사라져요.',
                  cancelText: '취소',
                  confirmText: '나가기',
                );

                if (ok == true) {
                  writeProvider.toggleWrite();
                  writeProvider.initialize();
                }
              },
              onDone: () async {
                if (writeProvider.diaryModel.content.isEmpty) return;

                // 로딩 화면 띄우기
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const AiSavingLoadingDialog(),
                );

                try {
                  await writeProvider.aiAndSaveDiary(context);
                } finally {
                  // 로딩 닫기
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                }

                // 저장 완료 후 다음 단계로 이동
                writeProvider.nextWrite(2);

                await logJournalCreate(usedAI: writeProvider.isPublic);
                if (writeProvider.isPublic) {
                  await logJournalShare();
                }
              },

              doneEnabled: writeProvider.diaryModel.content.isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }

}



