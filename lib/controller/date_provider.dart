import 'package:flutter/material.dart';

class DateProvider extends ChangeNotifier {
  DateTime? _selectedDate;

  DateTime? get selectedDate => _selectedDate;

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void clearDate() {
    _selectedDate = null;
    notifyListeners();
  }
}
