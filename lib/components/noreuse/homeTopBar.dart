import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

Widget homeTopBar() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PhosphorIcon(PhosphorIcons.speakerSimpleHigh(
              PhosphorIconsStyle.fill),
            color: Colors.white,),
          PhosphorIcon(PhosphorIcons.envelopeSimple(
              PhosphorIconsStyle.fill),
            color: Colors.white,)
        ]),
  );
}