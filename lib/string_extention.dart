import 'package:flutter/cupertino.dart';
import '../local.dart';

extension StringExtension on String {
  String tr(BuildContext context) {
    return Local.of(context)?.trans(this) ?? this;
  }
}