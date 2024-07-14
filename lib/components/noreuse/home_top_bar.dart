import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

Widget homeTopBar() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PhosphorIcon(PhosphorIcons.speakerSimpleHigh(
              PhosphorIconsStyle.fill),
            color: Colors.white,),
          const Padding(
            padding: EdgeInsets.only(bottom: 62.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 20.5,
                  child: Icon(Icons.create, size: 21,),
                ),
              ],
            ),
          )
        ]),
  );
}