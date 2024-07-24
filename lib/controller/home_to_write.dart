import 'package:flutter/material.dart';

class HomeToWrite with ChangeNotifier {
  bool _write = false;

  bool get write => _write;

  void toggleWrite() {
    _write = !_write;
    notifyListeners();
  }
}
