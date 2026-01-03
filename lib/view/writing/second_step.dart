import 'dart:ui';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/diary_ai_chat/controller/diary_ai_chat_controller.dart';
import 'package:bandi_official/view/diary_ai_chat/diary_ai_chat_view.dart';
import 'package:bandi_official/view/writing/widget/diary_action_sheet.dart';
import 'package:bandi_official/view/writing/widget/emotion_keyword_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../controller/home_to_write.dart';
import '../../../controller/navigation_toggle_provider.dart';
import '../../components/bottom_sheet/show_floating_confirm_sheet.dart';

class SecondStep extends StatelessWidget {
  const SecondStep({super.key});

  @override
  Widget build(BuildContext context) {
    final writeProvider = Provider.of<HomeToWrite>(context);
    final navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);
    final diaryAiChatController = context.watch<DiaryAiChatController>();

    final title = writeProvider.diaryModel.cheerText == ''
        ? 'write_title_generating'.tr(context)
        : writeProvider.diaryModel.title;

    final dateText = DateFormat('yyyy년 M월 d일')
        .format(writeProvider.diaryModel.createdAt.toDate());

    final reaction = writeProvider.diaryModel.reaction;

    final praiseCount = (reaction.isNotEmpty) ? reaction[0] : 0;
    final likeCount = (reaction.length > 1) ? reaction[1] : 0;
    final peopleCount = (reaction.length > 2) ? reaction[2] : 0;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- 상단 타이틀 + 더보기 ----
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BandiFont.headlineMedium(context)?.copyWith(
                        color: BandiColor.neutralColor100(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      final action = await showDiaryActionSheet(context);
                      if (action == DiarySheetAction.edit) {
                        writeProvider.nextWrite(3);
                      } else if (action == DiarySheetAction.delete) {
                        final confirmed = await showFloatingConfirmSheet(
                          context,
                          title: '일기를 정말로 삭제하시겠어요?',
                          description: '한 번 삭제한 기록은 복구할 수 없어요.',
                          cancelText: '취소',
                          confirmText: '삭제',
                        );

                        if (confirmed == true) {
                          await writeProvider.deleteDiaryById(
                            writeProvider.diaryModel.diaryId,
                          );

                          navigationToggleProvider.selectIndex(0);
                          writeProvider.toggleWrite();
                        }
                      }
                    },
                    child: PhosphorIcon(
                      PhosphorIcons.dotsThreeVertical(),
                      color: BandiColor.neutralColor40(context),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            // ---- 상단 divider ----
            Divider(
              color: BandiColor.neutralColor04(context),
              thickness: 1,
            ),

            // ---- 본문 ----
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  writeProvider.diaryModel.content,
                  style: BandiFont.bodyLarge(context)?.copyWith(
                    color: BandiColor.neutralColor90(context),
                  ),
                ),
              ),
            ),

            // ---- 하단 메타 (아이콘들 + 날짜) ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  _MetaIcon(
                    icon: PhosphorIcons.handsPraying(),
                    value: praiseCount.toString(),
                  ),
                  const SizedBox(width: 14),
                  _MetaIcon(
                    icon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
                    value: likeCount.toString(),
                  ),
                  const SizedBox(width: 14),
                  _MetaIcon(
                    icon:
                        PhosphorIcons.personArmsSpread(PhosphorIconsStyle.fill),
                    value: peopleCount.toString(),
                  ),
                  const Spacer(),
                  Text(
                    dateText,
                    style: BandiFont.labelSmall(context)?.copyWith(
                      color: BandiColor.neutralColor60(context),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(child: Container()),
            // ===== 하단 Frosted Bar =====
            _BottomFrostBar(
              leftTitle: '감정 키워드',
              onTapLeft: () async {
                await showEmotionKeywordSheet(
                  context,
                  writeProvider: writeProvider,
                );
              },
              onTapMiddle: () async {
                diaryAiChatController.toggleChatOpen(true);
                diaryAiChatController.onMyDiarytMessageSubmitted(
                    writeProvider.diaryModel.content, context);
                DiaryAIChatSheet().show(context).then((_) {
                  if (context.mounted) {
                    diaryAiChatController.toggleChatOpen(false);
                  }
                });
              },
              onTapHome: () {
                navigationToggleProvider.selectIndex(0);
                writeProvider.initialize();
                writeProvider.toggleWrite();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaIcon extends StatelessWidget {
  final IconData icon;
  final String value;

  const _MetaIcon({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PhosphorIcon(
          icon,
          size: 12,
          color: BandiColor.neutralColor60(context),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: BandiFont.labelSmall(context)?.copyWith(
            color: BandiColor.neutralColor60(context),
          ),
        ),
      ],
    );
  }
}

class _BottomFrostBar extends StatelessWidget {
  final String leftTitle;
  final VoidCallback onTapLeft;
  final VoidCallback onTapMiddle;
  final VoidCallback onTapHome;

  const _BottomFrostBar({
    required this.leftTitle,
    required this.onTapLeft,
    required this.onTapMiddle,
    required this.onTapHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: BandiColor.neutralColor10(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 왼쪽: 감정 키워드 + >
          Expanded(
            child: Row(
              children: [
                Text(
                  leftTitle,
                  style: BandiFont.labelMedium(context)?.copyWith(
                    color: BandiColor.neutralColor80(context),
                  ),
                ),
                const SizedBox(width: 8),
                _CircleNavButton(
                  icon: PhosphorIcons.caretRight(),
                  onTap: onTapLeft,
                ),
              ],
            ),
          ),

          // 가운데: 댓글 버튼(원형)
          _CircleNavButton(
            icon: PhosphorIcons.chat(),
            onTap: onTapMiddle,
          ),
          const SizedBox(width: 12),

          // 홈 버튼(원형)
          _CircleNavButton(
            icon: PhosphorIcons.house(),
            onTap: onTapHome,
          ),
        ],
      ),
    );
  }
}

class _CircleNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleNavButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: icon == PhosphorIcons.caretRight()
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
              : const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: PhosphorIcon(
            icon,
            size: 16,
            color: BandiColor.neutralColor90(context),
          ),
        ),
      ),
    );
  }
}
