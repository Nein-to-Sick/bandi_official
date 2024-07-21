import 'package:flutter/material.dart';

class NavigationToggleProvider with ChangeNotifier {
  // _selectedIndex == 0 : 홈
  // _selectedIndex == 1 : 일기
  // _selectedIndex == 2 : 보관함
  // _selectedIndex == 3 : 설정
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void selectIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}

