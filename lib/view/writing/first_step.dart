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

  Timer? _toTogglePhaseTimer;

  // ✅ 로컬 UI 상태 (튜토리얼 표시/락 제어용)
  bool _hideTextFocusRing = false; // focusText 링을 한번 누르면 즉시 숨김
  bool _toggleUnlocked = false; // toggle 단계에서만 true
  bool _didRegisterTargets = false;

  TutorialTargetRegistry? _tutorialReg;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();

    // writeProvider content 동기화는 onChanged에서 처리
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _tutorialReg ??= context.read<TutorialTargetRegistry>();

    // ✅ 타겟 등록은 1회만
    if (!_didRegisterTargets) {
      _didRegisterTargets = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final reg = context.read<TutorialTargetRegistry>();
        reg.register('write.hintAnchor', _hintAnchorKey);
        reg.register('write.togglePublic', _toggleKey);
        reg.register('write.doneButton', _doneKey);

        reg.refreshAll();

        // ✅ 진입 시 포커스 끔 (요구사항)
        _focusNode.unfocus();

        // ✅ 튜토 상태에 맞춰 로컬 상태 동기화
        _syncLocalUiWithTutorial();
      });
    } else {
      // ✅ controller 변화로 rebuild 될 때도 local 상태 동기화 필요
      // (예: phase가 외부에서 바뀌어 들어오는 경우)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncLocalUiWithTutorial();
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
      reg.unregister('write.hintAnchor');
      reg.unregister('write.togglePublic');
      reg.unregister('write.doneButton');
    } catch (_) {}

    super.dispose();
  }

  // ==========================
  // ✅ Tutorial <-> Local UI Sync
  // ==========================
  void _syncLocalUiWithTutorial() {
    final t = context.read<TutorialController>();

    if (!t.isFirstWriteFlow) {
      // 튜토리얼 아니면 로컬 상태 초기화
      _toTogglePhaseTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _hideTextFocusRing = false;
        _toggleUnlocked = false;
      });
      return;
    }

    switch (t.firstWritePhase) {
      case FirstWriteTutorialPhase.focusText:
        _toTogglePhaseTimer?.cancel();
        if (!mounted) return;
        setState(() {
          _hideTextFocusRing = false;
          _toggleUnlocked = false;
        });
        return;

      case FirstWriteTutorialPhase.togglePublic:
        _toTogglePhaseTimer?.cancel();
        if (!mounted) return;
        setState(() {
          _hideTextFocusRing = true; // text 링은 숨김 상태
          _toggleUnlocked = true; // 토글만 허용
        });
        return;

      case FirstWriteTutorialPhase.pressDone:
        _toTogglePhaseTimer?.cancel();
        if (!mounted) return;
        setState(() {
          _hideTextFocusRing = true;
          _toggleUnlocked = false; // 토글 단계 종료
        });
        return;
    }
  }

  // ==========================
  // ✅ Overlay target 결정 (단 하나만!)
  // ==========================
  String? _currentPracticeTargetId(TutorialController t) {
    if (!t.isFirstWriteFlow) return null;

    switch (t.firstWritePhase) {
      case FirstWriteTutorialPhase.focusText:
        // ✅ 링 클릭하면 즉시 사라져야 하므로 숨김이면 target도 null (overlay off)
        return _hideTextFocusRing ? null : 'write.hintAnchor';

      case FirstWriteTutorialPhase.togglePublic:
        return 'write.togglePublic';

      case FirstWriteTutorialPhase.pressDone:
        return 'write.doneButton';
    }
  }

  // ==========================
  // Exit / Done handlers
  // ==========================
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

    if (t.active &&
        t.phase == TutorialPhase.practice &&
        t.step == TutorialStep.emotionalWriting) {
      await t.advanceAfterPractice();
    }
  }

  // ==========================
  // tutorial focusText tap -> 10초 후 togglePublic 이동
  // ==========================
  void _scheduleToTogglePhase() {
    _toTogglePhaseTimer?.cancel();
    _toTogglePhaseTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;

      final t = context.read<TutorialController>();
      if (!t.isFirstWriteFlow) return;

      // ✅ focusText 중에만 이동
      if (t.firstWritePhase != FirstWriteTutorialPhase.focusText) return;

      t.setFirstWritePhase(FirstWriteTutorialPhase.togglePublic);

      // toggle 단계 unlock
      setState(() {
        _toggleUnlocked = true;
      });
    });
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

    // ✅ 말풍선: togglePublic 단계에서만
    final guideWidget = (t.isFirstWriteFlow &&
            t.firstWritePhase == FirstWriteTutorialPhase.togglePublic &&
            rawRect != null)
        ? TutorialSpeechBubble(
            targetRect: rawRect,
            title: '공유를 통해 따뜻한 공감을 받고, \n또 누군가에게 힘이 되어주세요. ',
            subtitle: '기록마다 개별 설정 가능합니다.',
          )
        : const SizedBox.shrink();

    // ✅ 링 위치 오프셋 (원래 로직 유지)
    final offset = switch (t.firstWritePhase) {
      FirstWriteTutorialPhase.focusText => Offset.zero,
      FirstWriteTutorialPhase.togglePublic => const Offset(0, -10),
      FirstWriteTutorialPhase.pressDone => const Offset(16, -7),
    };

    // ✅ pointRect: overlay의 “뚫린 원”
    final pointRect = (rawRect == null)
        ? null
        : Rect.fromCenter(
            center: rawRect.center + offset,
            width: 28,
            height: 28,
          );

    // ✅ overlay/락: targetId/rect가 유효할 때만!
    final lockAllExceptTarget =
        t.isFirstWriteFlow && practiceTargetId != null && pointRect != null;

    // ✅ 단계별 클릭 허용 정책
    final allowTextTap = t.isFirstWriteFlow &&
        t.firstWritePhase == FirstWriteTutorialPhase.focusText &&
        !_hideTextFocusRing;

    final allowToggleTap = t.isFirstWriteFlow &&
        t.firstWritePhase == FirstWriteTutorialPhase.togglePublic &&
        _toggleUnlocked;

    final allowDoneTap = t.isFirstWriteFlow &&
        t.firstWritePhase == FirstWriteTutorialPhase.pressDone;

    // ✅ 튜토리얼 중엔 나가기 금지 (너 정책 유지)
    final allowExitTap = !t.isFirstWriteFlow;

    final doneEnabled = writeProvider.diaryModel.content.isNotEmpty;

    return Stack(
      children: [
        // =======================
        // 1) 기존 화면
        // =======================
        GestureDetector(
          onTap: () {
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
                          onTap: () {
                            if (!allowTextTap) return;

                            // 1) 포커스 주고 키보드 올림
                            _focusNode.requestFocus();

                            // 2) 링 즉시 사라지게 + overlay off
                            setState(() {
                              _hideTextFocusRing = true;
                            });

                            // 3) 10초 뒤 toggle 단계로
                            _scheduleToTogglePhase();
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

                        // hintAnchor (rect 앵커)
                        const SizedBox.shrink(),
                        Positioned(
                          left: 5,
                          top: 10,
                          child: SizedBox(
                            key: _hintAnchorKey,
                            width: 1,
                            height: 1,
                          ),
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
                      context.read<TutorialController>().setFirstWritePhase(
                          FirstWriteTutorialPhase.pressDone);

                      setState(() {
                        _toggleUnlocked = false;
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
