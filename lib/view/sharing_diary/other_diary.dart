// other_diary.dart
import 'dart:developer' as develop;

import 'package:bandi_official/components/button/primary_button.dart';
import 'package:bandi_official/components/dialogue/reset_dialogue.dart';
import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/alarm/controller/alarm_controller.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../components/bottom_sheet/show_floating_toast_sheet.dart';
import '../../components/bottom_sheet/app_bottom_sheet.dart';
import 'controller/deepl_service.dart';
import 'controller/other_diary_controller.dart';

// =====================
// Reaction enum & helpers
// =====================
enum DiaryReaction { cheer, empathize, together }

String reactionLabel(BuildContext context, DiaryReaction r) {
  switch (r) {
    case DiaryReaction.cheer:
      return "응원해요";
    case DiaryReaction.empathize:
      return "공감해요";
    case DiaryReaction.together:
      return "함께해요";
  }
}

PhosphorIconData reactionIcon(DiaryReaction r) {
  switch (r) {
    case DiaryReaction.cheer:
      return PhosphorIcons.handsPraying(PhosphorIconsStyle.fill);
    case DiaryReaction.empathize:
      return PhosphorIcons.heart(PhosphorIconsStyle.fill);
    case DiaryReaction.together:
      return PhosphorIcons.personArmsSpread(PhosphorIconsStyle.fill);
  }
}

class OtherDiary extends StatefulWidget {
  const OtherDiary({super.key, required this.writeProvider});

  final HomeToWrite writeProvider;

  @override
  State<OtherDiary> createState() => _OtherDiaryState();
}

class _OtherDiaryState extends State<OtherDiary> {
  // =====================
  // UI / state
  // =====================
  bool showFirstPage = true;

  DiaryReaction? selectedReaction;

  // =====================
  // Language / translation state
  // =====================
  late final DeepLService _deepLService;

  String originalLang = 'KO'; // 'KO' or 'EN' (원문 언어)
  String currentLang = 'KO'; // 현재 화면 표시 언어

  String translatedTitle = '';
  String translatedContent = '';

  bool _initTranslated = false;
  bool _isTranslating = false;

  // ✅ 로컬 캐시 (DeepL 재호출 방지)
  String? _cachedKoTitle;
  String? _cachedKoContent;
  String? _cachedEnTitle;
  String? _cachedEnContent;

  late OtherDiaryController _controller;

  // =====================
  // utils
  // =====================
  bool containsKorean(String text) {
    final koreanRegex = RegExp(r'[가-힣]');
    return koreanRegex.hasMatch(text);
  }

  String get _otherLang => (originalLang == 'KO') ? 'EN' : 'KO';

  String _moreToggleButtonText() {
    // 현재 원문을 보고 있으면 -> 반대 언어로 보기
    if (currentLang == originalLang) {
      return (originalLang == 'KO') ? "영어로 보기" : "한국어로 보기";
    }
    // 현재 번역본(반대 언어)을 보고 있으면 -> 원본으로 보기
    return "원본으로 보기";
  }

  // =====================
  // lifecycle
  // =====================
  @override
  void initState() {
    super.initState();

    _deepLService = DeepLService();
    _controller = OtherDiaryController();

    final originalContent = widget.writeProvider.otherDiaryModel.content;
    final originalTitle = widget.writeProvider.otherDiaryModel.title;

    originalLang = containsKorean(originalContent) ? 'KO' : 'EN';

    // ✅ 시작은 원문
    translatedContent = originalContent;
    translatedTitle = originalTitle;
    currentLang = originalLang;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ locale은 여기서 안전하게 접근 가능
    if (!_initTranslated) {
      _initTranslated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _initAutoTranslateByLocale();
      });
    }
  }

  // =====================
  // translation logic
  // =====================
  Future<void> _initAutoTranslateByLocale() async {
    final localeLang =
    Localizations.localeOf(context).languageCode.toLowerCase();
    final targetLang = (localeLang == 'ko') ? 'KO' : 'EN';

    // 원문 언어와 목표 언어가 같으면 번역 필요 없음
    if (targetLang == originalLang) {
      if (!mounted) return;
      setState(() {
        currentLang = originalLang;
        translatedTitle = widget.writeProvider.otherDiaryModel.title;
        translatedContent = widget.writeProvider.otherDiaryModel.content;
      });
      return;
    }

    // 캐시에 이미 있으면 재사용
    if (targetLang == 'KO' &&
        _cachedKoTitle != null &&
        _cachedKoContent != null) {
      if (!mounted) return;
      setState(() {
        translatedTitle = _cachedKoTitle!;
        translatedContent = _cachedKoContent!;
        currentLang = 'KO';
      });
      return;
    }
    if (targetLang == 'EN' &&
        _cachedEnTitle != null &&
        _cachedEnContent != null) {
      if (!mounted) return;
      setState(() {
        translatedTitle = _cachedEnTitle!;
        translatedContent = _cachedEnContent!;
        currentLang = 'EN';
      });
      return;
    }

    // 캐시 없으면 번역
    if (!mounted) return;
    setState(() => _isTranslating = true);

    try {
      final originalTitle = widget.writeProvider.otherDiaryModel.title;
      final originalContent = widget.writeProvider.otherDiaryModel.content;

      final tTitle = await _deepLService.translate(originalTitle, targetLang);
      final tContent = await _deepLService.translate(originalContent, targetLang);

      if (!mounted) return;
      setState(() {
        translatedTitle = tTitle;
        translatedContent = tContent;
        currentLang = targetLang;

        // ✅ 자동 번역 결과도 캐시에 저장
        if (targetLang == 'KO') {
          _cachedKoTitle = tTitle;
          _cachedKoContent = tContent;
        } else {
          _cachedEnTitle = tTitle;
          _cachedEnContent = tContent;
        }
      });
    } catch (e) {
      develop.log('auto translate failed: $e');
      if (!mounted) return;
      setState(() {
        translatedTitle = widget.writeProvider.otherDiaryModel.title;
        translatedContent = widget.writeProvider.otherDiaryModel.content;
        currentLang = originalLang;
      });
    } finally {
      if (!mounted) return;
      setState(() => _isTranslating = false);
    }
  }

  /// ✅ MoreSheet 버튼 토글:
  /// - 번역본 보고 있으면 -> 원문으로
  /// - 원문 보고 있으면 -> 반대 언어(캐시 있으면 사용 / 없으면 번역)
  Future<void> _toggleMoreLanguage() async {
    final originalTitle = widget.writeProvider.otherDiaryModel.title;
    final originalContent = widget.writeProvider.otherDiaryModel.content;

    // 1) 현재 번역본 -> 원문으로 복귀 (즉시)
    if (currentLang != originalLang) {
      if (!mounted) return;
      setState(() {
        translatedTitle = originalTitle;
        translatedContent = originalContent;
        currentLang = originalLang;
      });
      return;
    }

    // 2) 현재 원문 -> 반대 언어로 전환
    final targetLang = _otherLang;

    // 캐시 히트
    if (targetLang == 'KO' &&
        _cachedKoTitle != null &&
        _cachedKoContent != null) {
      if (!mounted) return;
      setState(() {
        translatedTitle = _cachedKoTitle!;
        translatedContent = _cachedKoContent!;
        currentLang = 'KO';
      });
      return;
    }
    if (targetLang == 'EN' &&
        _cachedEnTitle != null &&
        _cachedEnContent != null) {
      if (!mounted) return;
      setState(() {
        translatedTitle = _cachedEnTitle!;
        translatedContent = _cachedEnContent!;
        currentLang = 'EN';
      });
      return;
    }

    // 캐시 미스 -> 번역
    if (!mounted) return;
    setState(() => _isTranslating = true);

    try {
      final tTitle = await _deepLService.translate(originalTitle, targetLang);
      final tContent = await _deepLService.translate(originalContent, targetLang);

      if (!mounted) return;
      setState(() {
        translatedTitle = tTitle;
        translatedContent = tContent;
        currentLang = targetLang;

        if (targetLang == 'KO') {
          _cachedKoTitle = tTitle;
          _cachedKoContent = tContent;
        } else {
          _cachedEnTitle = tTitle;
          _cachedEnContent = tContent;
        }
      });
    } catch (e) {
      develop.log("moreSheet translate failed: $e");
    } finally {
      if (!mounted) return;
      setState(() => _isTranslating = false);
    }
  }

  // =====================
  // build
  // =====================
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BandiColor.neutralColor80(context),
        borderRadius: BandiEffects.radiusSmall,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 32),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    // ===== Header (… + X) =====
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _isTranslating ? "번역 중..." : translatedTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                              BandiFont.headlineMedium(context)?.copyWith(
                                color: BandiColor.foundationColor100(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () =>
                                _openMoreSheet(context, widget.writeProvider),
                            child: PhosphorIcon(
                              PhosphorIcons.dotsThreeVertical(),
                              size: 24,
                              color: BandiColor.foundationColor30(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () async {
                              final r1 =
                                  selectedReaction == DiaryReaction.cheer;
                              final r2 =
                                  selectedReaction == DiaryReaction.empathize;
                              final r3 =
                                  selectedReaction == DiaryReaction.together;

                              await _controller.handleCloseAndReaction(
                                writeProvider: widget.writeProvider,
                                reaction1: r1,
                                reaction2: r2,
                                reaction3: r3,
                                mailController: context.read<MailController>(),
                                alarmController:
                                context.read<AlarmController>(),
                                onDone: () =>
                                    widget.writeProvider.offDiaryOpen(),
                              );
                            },
                            child: PhosphorIcon(
                              PhosphorIcons.x(),
                              size: 24,
                              color: BandiColor.foundationColor30(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 13),
                    Divider(
                      color: BandiColor.foundationColor04(context),
                      thickness: 1,
                      height: 0,
                    ),

                    // ===== Content =====
                    const SizedBox(height: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    _isTranslating ? "번역 중..." : translatedContent,
                                    style: BandiFont.bodyLarge(context)
                                        ?.copyWith(
                                      color:
                                      BandiColor.foundationColor90(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              // ===== Bottom "chat-like" bar (reaction + send) =====
              _bottomChatBar(context, widget.writeProvider),
            ],
          ),
        ),
      ),
    );
  }

  // =====================
  // Bottom Chat Bar
  // =====================
  Widget _bottomChatBar(BuildContext context, HomeToWrite writeProvider) {
    final label = selectedReaction == null
        ? "공감해요"
        : reactionLabel(context, selectedReaction!);

    final icon = selectedReaction == null
        ? PhosphorIcons.heart(PhosphorIconsStyle.fill)
        : reactionIcon(selectedReaction!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // Left "reaction selector"
          Expanded(
            child: GestureDetector(
              onTap: () => _openReactionSheet(context),
              child: Container(
                decoration: BoxDecoration(
                  color: BandiColor.neutralColor40(context),
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Row(
                  children: [
                    PhosphorIcon(
                      icon,
                      size: 16,
                      color: BandiColor.foundationColor90(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: BandiFont.labelMedium(context)?.copyWith(
                        color: BandiColor.foundationColor100(context),
                      ),
                    ),
                    const Spacer(),
                    PhosphorIcon(
                      PhosphorIcons.caretDown(),
                      size: 16,
                      color: BandiColor.foundationColor20(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Right send button
          GestureDetector(
            onTap: () async {
              final mailController = context.read<MailController>();
              final alarmController = context.read<AlarmController>();

              final r1 = selectedReaction == DiaryReaction.cheer;
              final r2 = selectedReaction == DiaryReaction.empathize;
              final r3 = selectedReaction == DiaryReaction.together;

              await _controller.handleCloseAndReaction(
                writeProvider: writeProvider,
                reaction1: r1,
                reaction2: r2,
                reaction3: r3,
                mailController: mailController,
                alarmController: alarmController,
                onDone: () async {
                  if (!context.mounted) return;

                  await showFloatingToastSheet(
                    context,
                    message: "따뜻한 공감 메시지가 전달되었어요.",
                    buttonText: "완료",
                  );

                  if (context.mounted) {
                    writeProvider.offDiaryOpen();
                  }
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: BandiColor.foundationColor90(context),
                borderRadius: BandiEffects.radiusLarge,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: PhosphorIcon(
                  PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill),
                  size: 16,
                  color: BandiColor.neutralColor90(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================
  // Reaction Bottom Sheet
  // =====================
  void _openReactionSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPrimaryButton(
            icon: reactionIcon(DiaryReaction.cheer),
            title: "reaction_support".tr(context),
            onPrimaryButtonPressed: () {
              setState(() => selectedReaction = DiaryReaction.cheer);
              Navigator.pop(context);
            },
            size: "small",
            disableButton: false,
          ),
          const SizedBox(height: 8),
          CustomPrimaryButton(
            icon: reactionIcon(DiaryReaction.empathize),
            title: "reaction_relate".tr(context),
            onPrimaryButtonPressed: () {
              setState(() => selectedReaction = DiaryReaction.empathize);
              Navigator.pop(context);
            },
            size: "small",
            disableButton: false,
          ),
          const SizedBox(height: 8),
          CustomPrimaryButton(
            icon: reactionIcon(DiaryReaction.together),
            title: "reaction_with".tr(context),
            onPrimaryButtonPressed: () {
              setState(() => selectedReaction = DiaryReaction.together);
              Navigator.pop(context);
            },
            size: "small",
            disableButton: false,
          ),
        ],
      ),
    );
  }

  bool get _shouldShowTranslateControls {
    final localeLang = Localizations.localeOf(context).languageCode.toLowerCase();
    final userLang = (localeLang == 'ko') ? 'KO' : 'EN';
    return userLang != originalLang;
  }

  // =====================
  // More (...) Bottom Sheet
  // =====================
  void _openMoreSheet(BuildContext context, HomeToWrite writeProvider) {
    showAppBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ 번역이 필요한 경우에만 노출
          if (_shouldShowTranslateControls) ...[
            CustomPrimaryButton(
              title: _moreToggleButtonText(),
              onPrimaryButtonPressed: () async {
                Navigator.pop(context);
                await _toggleMoreLanguage();
              },
              size: "small",
              disableButton: _isTranslating,
            ),
            const SizedBox(height: 8),
          ],

          // 신고 버튼 (항상)
          CustomPrimaryButton(
            title: "dialogue_report_on_yes".tr(context),
            onPrimaryButtonPressed: () {
              Navigator.pop(context);
              _showReportDialog(context, writeProvider);
            },
            size: "small",
            disableButton: false,
          ),
        ],
      ),
    );
  }

  // =====================
  // Report Dialog
  // =====================
  void _showReportDialog(BuildContext context, HomeToWrite writeProvider) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return CustomResetDialogue(
          text: 'dialogue_report_message'.tr(ctx),
          onYesText: 'dialogue_report_on_yes'.tr(ctx),
          onNoText: 'dialogue_report_on_no'.tr(ctx),
          onYesFunction: () async {
            Navigator.pop(ctx, true);

            try {
              final userId = FirebaseAuth.instance.currentUser!.uid;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({
                'blockedUsersList': FieldValue.arrayUnion(
                    [writeProvider.otherDiaryModel.userId]),
              });

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(writeProvider.otherDiaryModel.userId)
                  .update({'reported_count': FieldValue.increment(1)});
            } on FirebaseException catch (e) {
              develop.log('Firestore error: ${e.message}');
            } catch (e) {
              develop.log('unknown error: $e');
            }

            writeProvider.offDiaryOpen();

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  elevation: 3,
                  content: Text(
                    "dialogue_report_snackBar_message".tr(context),
                    style: BandiFont.headlineMedium(context)?.copyWith(
                      color: BandiColor.neutralColor90(context),
                    ),
                  ),
                  margin: EdgeInsets.only(
                    left: 25.0,
                    right: 25.0,
                    bottom: MediaQuery.of(context).size.height * 0.1,
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BandiEffects.radiusSmall,
                  ),
                ),
              );
            }
          },
          onNoFunction: () => Navigator.pop(ctx, false),
        );
      },
    );
  }
}
