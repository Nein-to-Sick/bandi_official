import 'package:flutter/material.dart';

class UserInfoValueModel with ChangeNotifier {
  String userId = '';
  String userEmail = '';
  String nickname = '';
  bool isValueEntered = false;

  void updateUserEmail(String value) {
    userEmail = value;
    notifyListeners();
  }

  void updateNickname(String value) {
    nickname = value;
    notifyListeners();
  }

  void setValueEntered() {
    isValueEntered = true;
    notifyListeners();
  }

  void clearUserInfo() {
    userId = '';
    userEmail = '';
    nickname = '';
    isValueEntered = false;
    notifyListeners();
  }
}
