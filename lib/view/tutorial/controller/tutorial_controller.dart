import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

enum TutorialPhase {
  explain,
  practice,
}

class TutorialController extends ChangeNotifier {
  // ============
  // Storage keys
  // ============
  static const _kActive = 'tutorial.active';
  static const _kStep = 'tutorial.step';
  static const _kPhase = 'tutorial.phase';

  // ✅ 1단계(일기쓰기) 내부 서브 단계 저장
  static const _kFirstWritePhase = 'tutorial.firstWritePhase';

  bool _active = false;
  TutorialStep _step = TutorialStep.emotionalWriting;
  TutorialPhase _phase = TutorialPhase.explain;

  // ✅ 1단계 내부 서브 단계
  FirstWriteTutorialPhase _firstWritePhase = FirstWriteTutorialPhase.focusText;

  bool get isFirstWriteFlow =>
      _active && _phase == TutorialPhase.practice && _step == TutorialStep.emotionalWriting;

  FirstWriteTutorialPhase get firstWritePhase => _firstWritePhase;

  Future<void> setFirstWritePhase(FirstWriteTutorialPhase p) async {
    _firstWritePhase = p;
    // 저장한다면 저장도 같이
    notifyListeners();
  }

  Future<void> beginPracticeForStep(TutorialStep step) async {
    _active = true;
    _step = step;
    _phase = TutorialPhase.practice;

    // ✅ 1단계 글쓰기면 서브단계도 초기화
    if (step == TutorialStep.emotionalWriting) {
      _firstWritePhase = FirstWriteTutorialPhase.focusText;
    }

    _resetPracticeCompleter();
    await _saveToStorage();
    notifyListeners();
  }

  Completer<void>? _practiceCompleter;

  // =========
  // Getters
  // =========
  bool get active => _active;
  TutorialStep get step => _step;
  TutorialPhase get phase => _phase;

  bool get locked => _active;
  bool get finished => !_active && _step == TutorialStep.done;


  int get explainIndex {
    return switch (_step) {
    TutorialStep.emotionalWriting => 0,
    TutorialStep.connectionAndEmpathy => 1,
    TutorialStep.retrospect => 2,
    TutorialStep.growth => 3,
    TutorialStep.done => 4,
    };
  }

  // ==================
  // Overlay target info (홈 탭용)
  // ==================
  String? get targetId {
    if (!_active || _phase != TutorialPhase.practice) return null;

    return switch (_step) {
    TutorialStep.emotionalWriting => 'home.writeButton',
    TutorialStep.connectionAndEmpathy => 'home.notificationButton',
    TutorialStep.retrospect => 'home.aiChatButton',
    TutorialStep.growth => 'home.mailButton',
    TutorialStep.done => null,
  };
  }

  String get guideText {
    if (!_active || _phase != TutorialPhase.practice) return '';

    return switch (_step) {
    TutorialStep.emotionalWriting => '',
    TutorialStep.connectionAndEmpathy => '',
    TutorialStep.retrospect => '',
    TutorialStep.done => '',
    TutorialStep.growth => '',
    };
  }

  // ==========================
  // ✅ 1단계(Write 화면)에서 쓸 타겟 id
  // ==========================
  String? get firstWriteTargetId {
    if (!isFirstWriteFlow) return null;
    return switch (_firstWritePhase) {
    FirstWriteTutorialPhase.focusText => 'write.textField',
    FirstWriteTutorialPhase.togglePublic => 'write.togglePublic',
    FirstWriteTutorialPhase.pressDone => 'write.doneButton',
  };
  }

  // =================
  // Storage (public)
  // =================
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final savedStepIndex = prefs.getInt(_kStep);
    if (savedStepIndex == null) {
      _active = false;
      _step = TutorialStep.emotionalWriting;
      _phase = TutorialPhase.explain;
      _firstWritePhase = FirstWriteTutorialPhase.focusText;
      notifyListeners();
      return;
    }

    final savedActive = prefs.getBool(_kActive) ?? false;
    final savedPhaseIndex = prefs.getInt(_kPhase) ?? TutorialPhase.explain.index;

    final stepIdx = savedStepIndex.clamp(0, TutorialStep.values.length - 1);
    final phaseIdx = savedPhaseIndex.clamp(0, TutorialPhase.values.length - 1);

    _step = TutorialStep.values[stepIdx];
    _phase = TutorialPhase.values[phaseIdx];
    _active = savedActive;

    // ✅ 1단계 서브 단계 복구
    final savedFirstWrite = prefs.getInt(_kFirstWritePhase) ?? FirstWriteTutorialPhase.focusText.index;
    final fwIdx = savedFirstWrite.clamp(0, FirstWriteTutorialPhase.values.length - 1);
    _firstWritePhase = FirstWriteTutorialPhase.values[fwIdx];

    // ✅ 여기서 "무조건 explain로 돌리기" 같은 건 하지 말아야
    // (중간에 그만둔 단계부터 재개하려면 저장된 phase/firstWritePhase를 그대로 둬야 함)

    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kActive, _active);
    await prefs.setInt(_kStep, _step.index);
    await prefs.setInt(_kPhase, _phase.index);
    await prefs.setInt(_kFirstWritePhase, _firstWritePhase.index);
  }

  Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kActive);
    await prefs.remove(_kStep);
    await prefs.remove(_kPhase);
    await prefs.remove(_kFirstWritePhase);
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
    _firstWritePhase = FirstWriteTutorialPhase.focusText;
    _clearPracticeCompleter();
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> advanceFirstWritePhase() async {
    if (!_active || _step != TutorialStep.emotionalWriting) return;

    _firstWritePhase = switch (_firstWritePhase) {
    FirstWriteTutorialPhase.focusText => FirstWriteTutorialPhase.togglePublic,
    FirstWriteTutorialPhase.togglePublic => FirstWriteTutorialPhase.pressDone,
    FirstWriteTutorialPhase.pressDone => FirstWriteTutorialPhase.pressDone,
    };

    await _saveToStorage();
    notifyListeners();
  }

  // 기존 practice 완료 신호
  void markPracticeDone() {
    if (!_active || _phase != TutorialPhase.practice) return;
    _practiceCompleter?.complete();
    _practiceCompleter = null;
  }

  Future<void> waitPracticeDone() {
    _practiceCompleter ??= Completer<void>();
    return _practiceCompleter!.future;
  }

  Future<void> advanceAfterPractice() async {
    if (!_active) return;

    _step = _nextOf(_step);

    if (_step == TutorialStep.done) {
      _active = false;
      _phase = TutorialPhase.explain;
      _clearPracticeCompleter();
      await _saveToStorage();
      notifyListeners();
      return;
    }

    _active = true;
    _phase = TutorialPhase.explain;
    _clearPracticeCompleter();
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> restartFromExplain() async {
    if (!_active || _step == TutorialStep.done) return;
    _phase = TutorialPhase.explain;
    _clearPracticeCompleter();
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> finishAll() async {
    _active = false;
    _step = TutorialStep.done;
    _phase = TutorialPhase.explain;
    _firstWritePhase = FirstWriteTutorialPhase.focusText;
    _clearPracticeCompleter();
    await _saveToStorage();
    notifyListeners();
  }

  // 호환용
  Future<void> startStep(TutorialStep step) async {
    await beginPracticeForStep(step);
    return waitPracticeDone();
  }

  Future<void> completeStep() => advanceAfterPractice();
  Future<void> resetCurrentPhase() => restartFromExplain();
  Future<void> restartCurrentStep() => restartFromExplain();

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

  void _resetPracticeCompleter() {
    _practiceCompleter?.complete();
    _practiceCompleter = Completer<void>();
  }

  void _clearPracticeCompleter() {
    _practiceCompleter?.complete();
    _practiceCompleter = null;
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kActive);
    await prefs.remove(_kStep);
    await prefs.remove(_kPhase);
    await prefs.remove(_kFirstWritePhase);

    _active = false;
    _step = TutorialStep.emotionalWriting;
    _phase = TutorialPhase.explain;
    _firstWritePhase = FirstWriteTutorialPhase.focusText;
    _practiceCompleter?.complete();
    _practiceCompleter = null;

    notifyListeners();
  }
}
