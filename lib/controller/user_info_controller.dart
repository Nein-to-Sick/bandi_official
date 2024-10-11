import 'package:flutter/material.dart';

class UserInfoValueModel with ChangeNotifier {
  String userId = '';
  String userEmail = '';
  String nickname = '';

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

  void clearUserInfo() {
    userId = '';
    userEmail = '';
    nickname = '';
    notifyListeners();
  }

  String getNickName() {
    return (nickname);
  }
}
