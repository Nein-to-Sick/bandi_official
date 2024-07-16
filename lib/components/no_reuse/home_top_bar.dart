import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/home/write_diary.dart';
import 'package:flutter/material.dart';
import 'package:page_animation_transition/animations/bottom_to_top_faded_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

Widget homeTopBar(context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PhosphorIcon(
                PhosphorIcons.speakerSimpleHigh(PhosphorIconsStyle.fill),
                color: BandiColor.neutralColor100(context),
              ),
              PhosphorIcon(
                PhosphorIcons.bell(PhosphorIconsStyle.fill),
                color: BandiColor.neutralColor100(context),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 62.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => WriteDiary()));
                    // Navigator.of(context).push(PageAnimationTransition(
                    //     page: const WriteDiary(),
                    //     pageAnimationType: BottomToTopFadedTransition()));
                  },
                  child: CircleAvatar(
                    radius: 20.5,
                    backgroundColor: BandiColor.neutralColor60(context),
                    child: Icon(
                      Icons.create,
                      size: 21,
                      color: BandiColor.foundationColor80(context),
                    ),
                  ),
                ),
              ],
            ),
          )
        ]),
  );
}
