import 'dart:async';

import 'package:flutter/material.dart';

sealed class OnboardingUiEvent {
  const OnboardingUiEvent();
}

class ShowNicknameSheet extends OnboardingUiEvent {
  const ShowNicknameSheet();
}

class OnboardingController extends ChangeNotifier {
  int _step = 1;
  int get step => _step;

  final StreamController<OnboardingUiEvent> _events =
  StreamController<OnboardingUiEvent>.broadcast();

  Stream<OnboardingUiEvent> get events => _events.stream;

  @override
  void dispose() {
    _events.close();
    super.dispose();
  }

  void next() {
    _step++;
    notifyListeners();

    if (_step >= 4) {
      _events.add(const ShowNicknameSheet());
    }
  }

  void skipToNickname() {
    _step = 4;
    notifyListeners();
    _events.add(const ShowNicknameSheet());
  }
}
