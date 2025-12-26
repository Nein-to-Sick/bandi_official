import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../theme/custom_theme_data.dart';

class HomeNotificationPill extends StatelessWidget {
  final String text;
  final bool showDot;
  final VoidCallback? onTap;

  const HomeNotificationPill({
    super.key,
    required this.text,
    required this.showDot,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            height: 44,
            padding: const EdgeInsets.fromLTRB(16, 12, 18, 12),
            decoration: BoxDecoration(
              color: BandiColor.neutralColor04(context),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BandiFont.titleSmall(context)?.copyWith(color: BandiColor.neutralColor90(context))
                  ),
                ),
                if (showDot)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: BandiColor.accentColorYellow(context),
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(width: 10, height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}