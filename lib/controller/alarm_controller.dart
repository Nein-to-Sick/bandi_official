import 'package:flutter/material.dart';

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
