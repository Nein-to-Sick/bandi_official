import 'package:flutter/cupertino.dart';

class UserViewController with ChangeNotifier {
  int settings = 0;

  void updateSettingValue(int value) {
    settings = value;
    notifyListeners();
  }
}
