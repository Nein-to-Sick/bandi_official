import 'package:flutter/material.dart';

class NavigationToggleProvider with ChangeNotifier {
  // _selectedIndex == 0 : home
  // _selectedIndex == 1 : book
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void selectIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}

