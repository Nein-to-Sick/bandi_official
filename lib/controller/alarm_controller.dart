import 'package:flutter/material.dart';

// TODO: 알람 보내기 이후 편지를 로컬에 저장하는 함수 호춣 필요
class AlarmController with ChangeNotifier {
  // determine whether to display the alarm view
  bool isAlarmOpen = false;

  // manage the page scroll
  final alarmScrollController = ScrollController();

  // toggle the chat page view
  void toggleAlarmOpen(value) {
    isAlarmOpen = value;
    notifyListeners();
  }
}
