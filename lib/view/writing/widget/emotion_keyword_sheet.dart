import 'package:bandi_official/components/button/primary_button.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/localization/string_extention.dart';
import 'package:bandi_official/view/my_diary_list/controller/my_diary_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../components/bottom_sheet/app_bottom_sheet.dart';
import '../controller/emotion_provider.dart';
import '../../../controller/home_to_write.dart';
import '../../../theme/custom_theme_data.dart';

Future<void> showEmotionKeywordSheet(
  BuildContext context, {
  required HomeToWrite writeProvider,
}) async {
  final emotionProvider = EmotionProvider();

  await showAppBottomSheet<void>(
    context: context,
    contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
    child: ChangeNotifierProvider.value(
      value: emotionProvider,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.90,
        child: EmotionKeywordSheet(
          writeProvider: writeProvider,
          initialSelected: writeProvider.diaryModel.emotion,
        ),
      ),
    ),
  );
}

/// ✅ 실제 시트 UI (섹션별 나열)
class EmotionKeywordSheet extends StatefulWidget {
  const EmotionKeywordSheet({
    super.key,
    required this.writeProvider,
    required this.initialSelected,
  });

  final HomeToWrite writeProvider;
  final List<dynamic> initialSelected;

  @override
  State<EmotionKeywordSheet> createState() => _EmotionKeywordSheetState();
}

class _EmotionKeywordSheetState extends State<EmotionKeywordSheet> {
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;

    // ✅ Provider 초기화 + 초기 선택 반영 (하드코딩 X)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<EmotionProvider>();
      await provider.initialize(context);
      provider.setInitialSelected(widget.initialSelected);
    });
  }

  @override
  Widget build(BuildContext context) {
    MyDiaryListController myDiaryListController =
        Provider.of<MyDiaryListController>(context);
    return Consumer<EmotionProvider>(
      builder: (context, provider, _) {
        if (!provider.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        final sections = provider.optionsByEmotion; // ✅ Map<섹션, 키워드리스트>

        return IgnorePointer(
          ignoring: provider.isLoading,
          child: Stack(
            children: [
              Column(
                children: [
                  // ===== Header =====
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "v2_emotion_keyword_sheet_title".tr(context),
                            style: BandiFont.titleSmall(context)?.copyWith(
                              color: BandiColor.foundationColor80(context),
                            ),
                          ),
                        ),
                        GestureDetector(
                            onTap: () => provider.resetSelected(context),
                            child: PhosphorIcon(
                              size: 24,
                              PhosphorIcons.arrowClockwise(
                                  PhosphorIconsStyle.regular),
                              color: BandiColor.foundationColor20(context),
                            )),
                        const SizedBox(
                          width: 12,
                        ),
                        GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: PhosphorIcon(
                              size: 24,
                              PhosphorIcons.x(PhosphorIconsStyle.regular),
                              color: BandiColor.foundationColor20(context),
                            )),
                      ],
                    ),
                  ),
                  Divider(
                      height: 1, color: BandiColor.foundationColor04(context)),

                  // ===== Body (scroll) =====
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final entry in sections.entries) ...[
                            _SectionTitle(entry.key),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 4,
                              runSpacing: 8,
                              children: entry.value.map((keyword) {
                                final selected =
                                    provider.selectedEmotions.contains(keyword);

                                return _KeywordChip(
                                  text: "emotion_keyword_$keyword".tr(context),
                                  selected: selected,
                                  onTap: () =>
                                      provider.toggleEmotion(keyword, context),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 40),
                          ],

                          const SizedBox(height: 70), // 하단 고정 버튼 공간
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // ===== Bottom fixed button =====
              Positioned(
                left: 24,
                right: 24,
                bottom: 32,
                child: CustomPrimaryButton(
                    title: "v2_emotion_keyword_sheet_button".tr(context),
                    onPrimaryButtonPressed: () async {
                      provider.toggleIsLoading(true);
                      await widget.writeProvider
                          .changeDiaryValue(provider.selectedEmotions);

                      Diary modifiedDiary = Diary(
                        userId: widget.writeProvider.diaryModel.userId,
                        title: widget.writeProvider.diaryModel.title,
                        content: widget.writeProvider.diaryModel.content,
                        emotion: provider.selectedEmotions,
                        createdAt: widget.writeProvider.diaryModel.createdAt,
                        updatedAt: widget.writeProvider.diaryModel.updatedAt,
                        reaction: widget.writeProvider.diaryModel.reaction,
                        diaryId: widget.writeProvider.diaryModel.diaryId,
                        cheerText: widget.writeProvider.diaryModel.cheerText,
                        otherUserReaction: -1,
                        otherUserLikedAt: '',
                      );

                      await myDiaryListController
                          .updateMyDiaryLocal(modifiedDiary);

                      if (mounted) {
                        provider.toggleIsLoading(false);
                        Navigator.pop(context);
                      }
                    },
                    disableButton: (provider.listEquals(
                            widget.writeProvider.diaryModel.emotion,
                            provider.selectedEmotions)) ||
                        provider.isLoading),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: BandiFont.labelSmall(context)?.copyWith(
          color: BandiColor.foundationColor60(context),
        ),
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _KeywordChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? BandiColor.foundationColor90(context)
        : BandiColor.transparent(context);

    final fg = selected
        ? BandiColor.neutralColor90(context)
        : BandiColor.foundationColor40(context);

    final borderColor =
        selected ? Colors.transparent : BandiColor.foundationColor10(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: BandiFont.labelMedium(context)?.copyWith(
            color: fg,
          ),
        ),
      ),
    );
  }
}
