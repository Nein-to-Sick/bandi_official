import 'dart:async';

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
import '../tutorial/controller/tutorial_controller.dart';
import '../tutorial/controller/tutorial_target_registry.dart';
import '../tutorial/tutorial_overlay.dart';
import '../tutorial/tutorial_speech_bubble.dart';

class FirstStep extends StatefulWidget {
  const FirstStep({Key? key}) : super(key: key);

  @override
  State<FirstStep> createState() => _FirstStepState();
}

class _FirstStepState extends State<FirstStep> {
  late final TextEditingController _textEditingController;
  late final FocusNode _focusNode;

  // ✅ 튜토리얼 타겟 키들
  final GlobalKey _hintAnchorKey = GlobalKey();
  final GlobalKey _toggleKey = GlobalKey();
  final GlobalKey _doneKey = GlobalKey();

  // ✅ "텍스트 링 클릭하면 즉시 사라짐" + "5초 뒤 토글 단계로"
  Timer? _toTogglePhaseTimer;
  bool _hideFocusRing = false;

  // ✅ 토글 unlock
  bool _toggleUnlocked = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final t = context.read<TutorialController>();

      // ✅ homeWriteButton practice 상태일 때만 첫 서브 단계 시작
      if (t.active &&
          t.phase == TutorialPhase.practice &&
          t.step == TutorialStep.emotionalWriting) {
        await t.setFirstWritePhase(FirstWriteTutorialPhase.focusText);
      }

      // ✅ 진입 시 포커스 끔(요구사항)
      _focusNode.unfocus();

      // ✅ 튜토리얼 target 등록
      final reg = context.read<TutorialTargetRegistry>();
      reg.register('write.hintAnchor', _hintAnchorKey);
      reg.register('write.togglePublic', _toggleKey);
      reg.register('write.doneButton', _doneKey);

      reg.refreshAll();

      // ✅ 재진입/리빌드 시 현재 튜토 상태에 맞춰 내부 상태 동기화
      _syncWithTutorialState();
    });
  }

  void _syncWithTutorialState() {
    final t = context.read<TutorialController>();

    if (!t.isFirstWriteFlow) return;

    // focusText면: 링 보이게, 토글 잠금
    if (t.firstWritePhase == FirstWriteTutorialPhase.focusText) {
      _toTogglePhaseTimer?.cancel();
      setState(() {
        _hideFocusRing = false;
        _toggleUnlocked = false;
      });
      return;
    }

    // togglePublic이면: 토글 링 보이고 클릭 가능(여기서는 이미 5초가 지난 상태라고 가정)
    if (t.firstWritePhase == FirstWriteTutorialPhase.togglePublic) {
      _toTogglePhaseTimer?.cancel();
      setState(() {
        _hideFocusRing = true;
        _toggleUnlocked = true;
      });
      return;
    }

    // pressDone이면: 완료만 가능
    if (t.firstWritePhase == FirstWriteTutorialPhase.pressDone) {
      _toTogglePhaseTimer?.cancel();
      setState(() {
        _hideFocusRing = true;
        _toggleUnlocked = false;
      });
    }
  }

  @override
  void dispose() {
    _toTogglePhaseTimer?.cancel();
    _textEditingController.dispose();
    _focusNode.dispose();

    // ✅ target 해제
    try {
      final reg = context.read<TutorialTargetRegistry>();
      reg.unregister('write.togglePublic');
      reg.unregister('write.doneButton');
      reg.unregister('write.hintAnchor');
    } catch (_) {}

    super.dispose();
  }

  // ✅ 현재 튜토리얼 서브단계에서 “딱 이 target만” 클릭 가능하도록 targetId 반환
  String? _currentPracticeTargetId(TutorialController t) {
    if (!t.isFirstWriteFlow) return null;

    switch (t.firstWritePhase) {
      case FirstWriteTutorialPhase.focusText:
        // ✅ 링 클릭하면 즉시 사라져야 하므로, 숨긴 상태면 overlay도 꺼버림
        return _hideFocusRing ? null : 'write.hintAnchor';
      case FirstWriteTutorialPhase.togglePublic:
        return 'write.togglePublic';
      case FirstWriteTutorialPhase.pressDone:
        return 'write.doneButton';
    }
  }

  Future<void> _handleExit(HomeToWrite writeProvider) async {
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
  }

  Future<void> _handleDone(HomeToWrite writeProvider) async {
    if (writeProvider.diaryModel.content.isEmpty) return;

    final navigator = Navigator.of(context);
    final t = context.read<TutorialController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AiSavingLoadingDialog(),
    );

    try {
      await writeProvider.aiAndSaveDiary(context);
    } finally {
      if (!mounted) return;
      if (navigator.canPop()) navigator.pop();
    }

    if (!mounted) return;

    writeProvider.nextWrite(2);

    await logJournalCreate(usedAI: writeProvider.isPublic);
    if (writeProvider.isPublic) {
      await logJournalShare();
    }

    if (t.active && t.phase == TutorialPhase.practice && t.step == TutorialStep.emotionalWriting) {
      await t.advanceAfterPractice();
    }
  }

  @override
  Widget build(BuildContext context) {
    final writeProvider = context.watch<HomeToWrite>();
    final t = context.watch<TutorialController>();
    final reg = context.watch<TutorialTargetRegistry>();

    // ✅ 튜토리얼 중이면 rect 갱신
    if (t.isFirstWriteFlow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<TutorialTargetRegistry>().refreshAll();
      });
    }

    // ✅ 현재 클릭 가능한 대상 (서브단계 기준)
    final practiceTargetId = _currentPracticeTargetId(t);
    final rawRect =
        (practiceTargetId == null) ? null : reg.rectOf(practiceTargetId);

    final guideWidget = (t.isFirstWriteFlow &&
            t.firstWritePhase == FirstWriteTutorialPhase.togglePublic &&
            rawRect != null)
        ? TutorialSpeechBubble(
            targetRect: rawRect,
            title: '공유를 통해 따뜻한 공감을 받고, \n또 누군가에게 힘이 되어주세요. ',
            subtitle: '기록마다 개별 설정 가능합니다.',
          )
        : const SizedBox.shrink();

    final offset = switch (t.firstWritePhase) {
      FirstWriteTutorialPhase.focusText => Offset.zero,
      FirstWriteTutorialPhase.togglePublic => const Offset(0, -10), // 토글 링만 이동
      FirstWriteTutorialPhase.pressDone => const Offset(16, -7), // 완료 링만 이동
    };

    final pointRect = (rawRect == null)
        ? null
        : Rect.fromCenter(
            center: rawRect.center + offset,
            width: 28,
            height: 28,
          );

    final lockAllExceptTarget =
        t.isFirstWriteFlow && practiceTargetId != null && pointRect != null;

    // ✅ 단계별 bottom bar 허용 정책
    final allowTextTap = t.isFirstWriteFlow &&
        t.firstWritePhase == FirstWriteTutorialPhase.focusText &&
        !_hideFocusRing; // ✅ 링 클릭 후엔 더 이상 클릭 단계 아님(이미 진행 중)

    final allowToggleTap = t.isFirstWriteFlow &&
        t.firstWritePhase == FirstWriteTutorialPhase.togglePublic &&
        _toggleUnlocked;

    final allowDoneTap = t.isFirstWriteFlow &&
        t.firstWritePhase == FirstWriteTutorialPhase.pressDone;

    final allowExitTap = !t.isFirstWriteFlow; // 튜토리얼 중엔 나가기 금지

    final doneEnabled = writeProvider.diaryModel.content.isNotEmpty;

    return Stack(
      children: [
        // =======================
        // 1) 기존 화면
        // =======================
        GestureDetector(
          onTap: () {
            // 튜토리얼 중에는 빈 곳 탭으로 unfocus 금지
            if (t.isFirstWriteFlow) return;
            _focusNode.unfocus();
          },
          child: SafeArea(
            child: Column(
              children: [
                // ====== Body (TextField) ======
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Stack(
                      children: [
                        TextField(
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
                          onTap: () async {
                            if (!allowTextTap) return;

                            // 1) 포커스 주고 키보드 올림
                            _focusNode.requestFocus();

                            // 2) 링 즉시 사라지게
                            setState(() {
                              _hideFocusRing = true;
                            });

                            // 3) 5초 뒤에 togglePublic로 phase 변경 + 토글 클릭 허용
                            _toTogglePhaseTimer?.cancel();
                            _toTogglePhaseTimer =
                                Timer(const Duration(seconds: 10), () async {
                              if (!mounted) return;

                              await context
                                  .read<TutorialController>()
                                  .setFirstWritePhase(
                                    FirstWriteTutorialPhase.togglePublic,
                                  );

                              setState(() {
                                _toggleUnlocked = true;
                              });
                            });
                          },
                          onChanged: (_) {
                            setState(() {
                              writeProvider.diaryModel.content =
                                  _textEditingController.text;
                            });
                          },
                          maxLines: null,
                          expands: true,
                        ),

                        // (left/top 값)
                        Positioned(
                          left: 5,
                          top: 10,
                          child: SizedBox(
                              key: _hintAnchorKey, width: 1, height: 1),
                        ),
                      ],
                    ),
                  ),
                ),

                // ====== Bottom Bar ======
                BottomBar(
                  isPublic: writeProvider.isPublic,
                  publicLabel: writeProvider.isPublic
                      ? "sharing_diary_on".tr(context)
                      : "sharing_diary_off".tr(context),

                  // ✅ tutorial key 전달
                  publicSwitchKey: _toggleKey,
                  doneButtonKey: _doneKey,

                  // ✅ 단계별 클릭 허용
                  allowTogglePublic:
                      !t.isFirstWriteFlow ? true : allowToggleTap,
                  allowExit: allowExitTap,
                  allowDone: !t.isFirstWriteFlow ? true : allowDoneTap,

                  onTogglePublic: (v) async {
                    if (t.isFirstWriteFlow) {
                      if (!allowToggleTap) return;

                      // ✅ 요구사항: “FlutterSwitch을 켜게”
                      writeProvider.setIsPublic(true);

                      // 다음 서브 단계(완료 버튼)
                      await context
                          .read<TutorialController>()
                          .setFirstWritePhase(
                            FirstWriteTutorialPhase.pressDone,
                          );

                      setState(() {
                        _toggleUnlocked = false; // 토글 단계 끝났으니 다시 잠금
                      });
                      return;
                    }

                    writeProvider.setIsPublic(v);
                  },

                  onExit: () async {
                    if (!allowExitTap) return;
                    await _handleExit(writeProvider);
                  },

                  onDone: () async {
                    if (t.isFirstWriteFlow && !allowDoneTap) return;
                    await _handleDone(writeProvider);
                  },

                  doneEnabled: doneEnabled,
                ),
              ],
            ),
          ),
        ),

        // =======================
        // 2) 튜토리얼 오버레이 (딱 한 곳만 클릭 허용)
        // =======================
        if (lockAllExceptTarget)
          TutorialOverlay(
            targetRect: pointRect!,
            radius: 14,
            guide: guideWidget,
          ),
      ],
    );
  }
}
