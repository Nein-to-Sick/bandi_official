import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import '../tutorial_flow_page.dart';

enum TutorialStep {
  emotionalWriting,
  connectionAndEmpathy,
  retrospect,
  growth,
  done,
}

enum FirstWriteTutorialPhase {
  focusText,
  togglePublic,
  pressDone,
}

enum ConnectionTutorialPhase {
  focusHomeNotification,
  focusReactionSelector,
  sheetOneRing,
  focusSendButton,
  done,
}

enum RetrospectTutorialPhase {
  focusAiChatButton,
  focusMessageBar,
  messageSent,
}

enum GrowthTutorialPhase {
  focusHomeNotification,
  focusLetterCloseX,
  focusTrayNav,
  done,
}

enum TutorialPhase {
  explain,
  practice,
}

class TutorialController extends ChangeNotifier {
  // ============
  // Storage keys (✅ step/phase/active만 저장)
  // ============
  static const _kActive = 'tutorial.active';
  static const _kStep = 'tutorial.step';
  static const _kPhase = 'tutorial.phase';

  // =================
  // 기존 상태들
  // =================
  bool _active = false;
  TutorialStep _step = TutorialStep.emotionalWriting;
  TutorialPhase _phase = TutorialPhase.explain;

  // =================
  // 🔐 Flow control (NEW)
  // =================
  bool flowOpened = false;
  Timer? _pendingFlowTimer;

  bool get hasPendingFlow => _pendingFlowTimer != null;

  void _cancelPendingFlow() {
    _pendingFlowTimer?.cancel();
    _pendingFlowTimer = null;
  }

  // ✅ 서브스텝은 "메모리 전용" (스토리지 저장 X)
  FirstWriteTutorialPhase _firstWritePhase = FirstWriteTutorialPhase.focusText;
  ConnectionTutorialPhase _connectionPhase =
      ConnectionTutorialPhase.focusHomeNotification;
  RetrospectTutorialPhase _retrospectPhase =
      RetrospectTutorialPhase.focusAiChatButton;
  GrowthTutorialPhase _growthPhase = GrowthTutorialPhase.focusHomeNotification;

  Completer<void>? _practiceCompleter;

  // =========
  // Getters
  // =========
  bool get active => _active;
  TutorialStep get step => _step;
  TutorialPhase get phase => _phase;

  bool get locked => _active;
  bool get finished => !_active && _step == TutorialStep.done;

  bool get isFirstWriteFlow =>
      _active &&
      _phase == TutorialPhase.practice &&
      _step == TutorialStep.emotionalWriting;

  bool get isConnectionFlow =>
      _active &&
      _phase == TutorialPhase.practice &&
      _step == TutorialStep.connectionAndEmpathy;

  bool get isRetrospectFlow =>
      _active &&
      _phase == TutorialPhase.practice &&
      _step == TutorialStep.retrospect;

  bool get isGrowthFlow =>
      _active &&
      _phase == TutorialPhase.practice &&
      _step == TutorialStep.growth;

  FirstWriteTutorialPhase get firstWritePhase => _firstWritePhase;
  ConnectionTutorialPhase get connectionPhase => _connectionPhase;
  RetrospectTutorialPhase get retrospectPhase => _retrospectPhase;
  GrowthTutorialPhase get growthPhase => _growthPhase;

  int get explainIndex {
    return switch (_step) {
      TutorialStep.emotionalWriting => 0,
      TutorialStep.connectionAndEmpathy => 1,
      TutorialStep.retrospect => 2,
      TutorialStep.growth => 3,
      TutorialStep.done => 4,
    };
  }

  bool _retrospectAssistantPicked = false;
  bool get retrospectAssistantPicked => _retrospectAssistantPicked;

  void markRetrospectAssistantPicked() {
    if (!_active || _step != TutorialStep.retrospect) return;
    if (_retrospectAssistantPicked) return;
    _retrospectAssistantPicked = true;
    notifyListeners();
  }

  bool get retrospectMessageSent =>
      _retrospectPhase == RetrospectTutorialPhase.messageSent;

  void setRetrospectPhase(RetrospectTutorialPhase p) {
    _retrospectPhase = p;
    notifyListeners();
  }

  void setGrowthPhase(GrowthTutorialPhase p) {
    _growthPhase = p;
    notifyListeners();
  }

  void markRetrospectMessageSent() {
    if (!isRetrospectFlow) return;
    if (_retrospectPhase == RetrospectTutorialPhase.messageSent) return;
    _retrospectPhase = RetrospectTutorialPhase.messageSent;
    notifyListeners();
  }

  // ==================
  // Overlay target info
  // ==================
  String? get targetId {
    if (!_active || _phase != TutorialPhase.practice) return null;

    if (_step == TutorialStep.connectionAndEmpathy) {
      return switch (_connectionPhase) {
        ConnectionTutorialPhase.focusHomeNotification =>
          'home.notificationButton',
        ConnectionTutorialPhase.focusReactionSelector =>
          'other.reactionSelector',
        ConnectionTutorialPhase.sheetOneRing => 'other.reactionOptionAnchor',
        ConnectionTutorialPhase.focusSendButton => 'other.sendButton',
        ConnectionTutorialPhase.done => null,
      };
    }

    if (_step == TutorialStep.retrospect) {
      return switch (_retrospectPhase) {
        RetrospectTutorialPhase.focusAiChatButton => 'home.aiChatButton',
        RetrospectTutorialPhase.focusMessageBar => 'aichat.messageBar',
        RetrospectTutorialPhase.messageSent => null,
      };
    }

    if (_step == TutorialStep.growth) {
      return switch (_growthPhase) {
        GrowthTutorialPhase.focusHomeNotification => 'home.notificationButton',
        GrowthTutorialPhase.focusLetterCloseX => 'mail.detail.closeX',
        GrowthTutorialPhase.focusTrayNav => 'nav.tray',
        GrowthTutorialPhase.done => null,
      };
    }

    // connectionAndEmpathy는 위에서 이미 처리함
    return switch (_step) {
      TutorialStep.emotionalWriting => 'home.writeButton',
      TutorialStep.retrospect => 'home.aiChatButton',
      TutorialStep.growth => null,
      TutorialStep.done => null,
      TutorialStep.connectionAndEmpathy => 'home.notificationButton',
    };
  }

  String get guideText {
    if (!_active || _phase != TutorialPhase.practice) return '';
    // 필요하면 여기서 step/substep별로 문구 넣기
    return '';
  }

  String? get firstWriteTargetId {
    if (!isFirstWriteFlow) return null;
    return switch (_firstWritePhase) {
      FirstWriteTutorialPhase.focusText => 'write.textField',
      FirstWriteTutorialPhase.togglePublic => 'write.togglePublic',
      FirstWriteTutorialPhase.pressDone => 'write.doneButton',
    };
  }

  // =================
  // Storage
  // =================
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedStepIndex = prefs.getInt(_kStep);
    if (savedStepIndex == null) {
      // 최초 진입 기본값
      _active = false;
      _step = TutorialStep.emotionalWriting;
      _phase = TutorialPhase.explain;

      // ✅ 서브스텝은 항상 step의 "처음"으로
      _resetSubPhasesForStep(_step);

      notifyListeners();
      return;
    }

    _active = prefs.getBool(_kActive) ?? false;

    final savedPhaseIndex =
        prefs.getInt(_kPhase) ?? TutorialPhase.explain.index;

    final stepIdx = savedStepIndex.clamp(0, TutorialStep.values.length - 1);
    final phaseIdx = savedPhaseIndex.clamp(0, TutorialPhase.values.length - 1);

    _step = TutorialStep.values[stepIdx];
    _phase = TutorialPhase.values[phaseIdx];

    // ✅ 핵심: 서브스텝은 저장/복구하지 않고 "항상 처음"으로 리셋
    _resetSubPhasesForStep(_step);

    notifyListeners();
  }

  Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kActive);
    await prefs.remove(_kStep);
    await prefs.remove(_kPhase);
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kActive, _active);
    await prefs.setInt(_kStep, _step.index);
    await prefs.setInt(_kPhase, _phase.index);
  }

  // =========================
  // Step/Phase control
  // =========================
  Future<void> start() async {
    _active = true;

    if (_step == TutorialStep.done) {
      _step = TutorialStep.emotionalWriting;
    }

    _phase = TutorialPhase.explain;

    // ✅ 서브스텝은 항상 "처음"
    _resetSubPhasesForStep(_step);

    _clearPracticeCompleter();
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> beginPracticeForStep(TutorialStep step) async {
    _active = true;
    _step = step;
    _phase = TutorialPhase.practice;

    // ✅ practice 시작 시도 항상 "처음"
    _resetSubPhasesForStep(step);

    _resetPracticeCompleter();
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> restartFromExplain() async {
    if (!_active || _step == TutorialStep.done) return;

    _phase = TutorialPhase.explain;

    // explain으로 돌아가도, 서브스텝은 어차피 다시 시작할 때 처음부터라면
    // 여기서 굳이 리셋해도 되고 안 해도 됨. (안전하게 리셋)
    _resetSubPhasesForStep(_step);

    _clearPracticeCompleter();
    await _saveToStorage();
    notifyListeners();
  }

  // =========================
  // ✅ 단일 진입: 즉시 설명 페이지
  // =========================
  Future<TutorialFlowResult?> showExplainFlowNow(
    BuildContext context,
  ) async {
    if (flowOpened) return null;

    flowOpened = true;
    _cancelPendingFlow();

    try {
      return await TutorialFlowPage.show(
        context,
        startIndex: explainIndex,
      );
    } finally {
      flowOpened = false;
    }
  }

  // =========================
  // ✅ 단일 진입: 지연 설명 페이지 (3초 등)
  // =========================
  void scheduleExplainFlow(
    BuildContext context, {
    Duration delay = const Duration(seconds: 3),
  }) {
    if (flowOpened) return;

    _cancelPendingFlow();

    _pendingFlowTimer = Timer(delay, () async {
      final rootCtx = navigatorKey.currentContext;
      if (rootCtx == null) return;
      final res = await showExplainFlowNow(rootCtx);
      if (res != null) beginPracticeForStep(res.step);
    });
  }

  Future<void> advanceAfterPractice() async {
    if (!_active) return;

    _step = _nextOf(_step);

    if (_step == TutorialStep.done) {
      await finishAll();
      return;
    }

    _active = true;
    _phase = TutorialPhase.explain;
    _resetSubPhasesForStep(_step);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> finishAll() async {
    _cancelPendingFlow();
    flowOpened = false;

    _active = false;
    _step = TutorialStep.done;
    _phase = TutorialPhase.explain;

    await _saveToStorage();
    notifyListeners();
  }

  // =========================
  // Sub-phase control (메모리 전용)
  // =========================
  void setFirstWritePhase(FirstWriteTutorialPhase p) {
    _firstWritePhase = p;
    notifyListeners();
  }

  void setConnectionPhase(ConnectionTutorialPhase p) {
    _connectionPhase = p;
    notifyListeners();
  }

  Future<void> advanceFirstWritePhase() async {
    if (!_active || _step != TutorialStep.emotionalWriting) return;

    _firstWritePhase = switch (_firstWritePhase) {
      FirstWriteTutorialPhase.focusText => FirstWriteTutorialPhase.togglePublic,
      FirstWriteTutorialPhase.togglePublic => FirstWriteTutorialPhase.pressDone,
      FirstWriteTutorialPhase.pressDone => FirstWriteTutorialPhase.pressDone,
    };

    notifyListeners();
  }

  Future<void> advanceConnectionPhase() async {
    if (!isConnectionFlow) return;

    _connectionPhase = switch (_connectionPhase) {
      ConnectionTutorialPhase.focusHomeNotification =>
        ConnectionTutorialPhase.focusReactionSelector,
      ConnectionTutorialPhase.focusReactionSelector =>
        ConnectionTutorialPhase.sheetOneRing,
      ConnectionTutorialPhase.sheetOneRing =>
        ConnectionTutorialPhase.focusSendButton,
      ConnectionTutorialPhase.focusSendButton => ConnectionTutorialPhase.done,
      ConnectionTutorialPhase.done => ConnectionTutorialPhase.done,
    };

    notifyListeners();
  }

  // =========================
  // Practice completion (기존 유지)
  // =========================
  void markPracticeDone() {
    if (!_active || _phase != TutorialPhase.practice) return;
    _practiceCompleter?.complete();
    _practiceCompleter = null;
  }

  Future<void> waitPracticeDone() {
    _practiceCompleter ??= Completer<void>();
    return _practiceCompleter!.future;
  }

  // 호환용
  Future<void> startStep(TutorialStep step) async {
    await beginPracticeForStep(step);
    return waitPracticeDone();
  }

  Future<void> completeStep() => advanceAfterPractice();
  Future<void> resetCurrentPhase() => restartFromExplain();
  Future<void> restartCurrentStep() => restartFromExplain();

  // =========================
  // Reset all
  // =========================
  Future<void> resetAll() async {
    await clearStorage();

    _active = false;
    _step = TutorialStep.emotionalWriting;
    _phase = TutorialPhase.explain;

    _resetSubPhasesForStep(_step);

    _practiceCompleter?.complete();
    _practiceCompleter = null;

    notifyListeners();
  }

  // ==========
  // Internals
  // ==========
  TutorialStep _nextOf(TutorialStep s) {
    return switch (s) {
      TutorialStep.emotionalWriting => TutorialStep.connectionAndEmpathy,
      TutorialStep.connectionAndEmpathy => TutorialStep.retrospect,
      TutorialStep.retrospect => TutorialStep.growth,
      TutorialStep.growth => TutorialStep.done,
      TutorialStep.done => TutorialStep.done,
    };
  }

  void _resetSubPhasesForStep(TutorialStep step) {
    // ✅ 정책: 서브스텝은 항상 해당 step의 "처음"으로
    _firstWritePhase = FirstWriteTutorialPhase.focusText;
    _connectionPhase = ConnectionTutorialPhase.focusHomeNotification;
    _retrospectPhase = RetrospectTutorialPhase.focusAiChatButton;
    _retrospectAssistantPicked = false;
    _growthPhase = GrowthTutorialPhase.focusHomeNotification;

    // step별로 더 명확하게 하고 싶으면 아래처럼 분기해도 됨.
    if (step == TutorialStep.emotionalWriting) {
      _firstWritePhase = FirstWriteTutorialPhase.focusText;
    }
    if (step == TutorialStep.connectionAndEmpathy) {
      _connectionPhase = ConnectionTutorialPhase.focusHomeNotification;
    }
    if (step == TutorialStep.retrospect) {
      _retrospectPhase = RetrospectTutorialPhase.focusAiChatButton;
      _retrospectAssistantPicked = false;
    }
    if (step == TutorialStep.growth) {
      _growthPhase = GrowthTutorialPhase.focusHomeNotification;
    }
  }

  void _resetPracticeCompleter() {
    _practiceCompleter?.complete();
    _practiceCompleter = Completer<void>();
  }

  void _clearPracticeCompleter() {
    _practiceCompleter?.complete();
    _practiceCompleter = null;
  }
}
