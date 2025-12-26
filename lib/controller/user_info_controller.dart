import 'package:flutter/material.dart';

class UserInfoValueModel with ChangeNotifier {
  String userId = '';
  String userEmail = '';
  String nickname = '';
  bool isAgreed = false;

  void updateUserID(String value) {
    userId = value;
    notifyListeners();
  }

  void updateUserEmail(String value) {
    userEmail = value;
    notifyListeners();
  }

  void updateNickname(String value) {
    nickname = value;
    notifyListeners();
  }

  void updateIsAgreed(bool value) {
    isAgreed = value;
    notifyListeners();
  }

  void clearUserInfo() {
    userId = '';
    userEmail = '';
    nickname = '';
    isAgreed = false;
    notifyListeners();
  }

  String getNickName() => nickname;
}
