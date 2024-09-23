import 'package:flutter/material.dart';

class NavigationToggleProvider with ChangeNotifier {
  // _selectedIndex == -2 : 설정페이지 바텀 네비 없어야할떄
  // _selectedIndex == -1 : 로그인
  // _selectedIndex == 0 : 홈
  // _selectedIndex == 1 : 일기
  // _selectedIndex == 2 : 보관함
  // _selectedIndex == 3 : 설정
  int _selectedIndex = -1;

  int get selectedIndex => _selectedIndex;

  void selectIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  int getIndex() {
    return (_selectedIndex);
  }
}
