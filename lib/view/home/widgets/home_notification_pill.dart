import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/custom_theme_data.dart';

class HomeNotificationPill extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  /// ✅ NEW dot 표시 여부(새 알림이 있을 때만 true)
  final bool showNewDot;

  /// ✅ NEW dot이 없을 때, 여러 개면 숫자 배지 표시용
  final int badgeCount;

  /// ✅ NEW dot이 없고, badgeCount도 없을 때(= 1개) 타입 아이콘 표시용
  final Widget? trailingWidget;

  final Color backgroundColor;

  const HomeNotificationPill({
    super.key,
    required this.text,
    this.onTap,
    this.showNewDot = false,
    this.badgeCount = 0,
    this.trailingWidget,
    required this.backgroundColor
  });

  Widget _buildTrailing(BuildContext context) {
    // 1) NEW dot 우선
    if (showNewDot) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: BandiColor.accentColorYellow(context),
          shape: BoxShape.circle,
        ),
      );
    }

    // 2) 여러 개면 숫자 배지
    if (badgeCount >= 2) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: BandiColor.neutralColor20(context),
          borderRadius: BandiEffects.radiusLarge,
        ),
        child: Text(
          "$badgeCount",
          style: BandiFont.labelMedium(context)?.copyWith(
            color: BandiColor.neutralColor90(context),
          ),
        ),
      );
    }

    // 3) 1개면 타입 아이콘
    if (trailingWidget != null) return trailingWidget!;

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BandiEffects.radiusLarge,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: BandiEffects.blurLarge,
            sigmaY: BandiEffects.blurLarge,
          ),
          child: Container(
            padding: badgeCount < 2
                ? const EdgeInsets.fromLTRB(20, 12, 18, 12)
                : const EdgeInsets.fromLTRB(20, 8, 8, 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BandiEffects.radiusLarge,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BandiFont.titleSmall(context)?.copyWith(
                      color: BandiColor.neutralColor90(context),
                    ),
                  ),
                ),
                _buildTrailing(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
