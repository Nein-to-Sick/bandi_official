import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

Widget navigationBar() {
  return Container(
    decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.white),
        borderRadius: BorderRadius.circular(30)
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(
            PhosphorIcons.houseSimple(),
            color: Colors.white,
          ),
          const SizedBox(width: 24,),
          PhosphorIcon(
            PhosphorIcons.book(),
            color: Colors.white,
          )
        ],
      ),
    ),
  );
}