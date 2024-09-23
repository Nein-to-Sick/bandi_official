import 'package:flutter/material.dart';

class UserInfoValueModel with ChangeNotifier {
  String userId = '';
  String userEmail = '';
  String nickname = '';

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
}
