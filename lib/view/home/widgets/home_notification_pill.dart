import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/custom_theme_data.dart';

class HomeNotificationPill extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  /// ✅ 알림 표시 정책
  /// - null: 아무것도 안 보여줌
  /// - 1: 노란 점
  /// - 2+: 숫자 배지
  final int? notificationCount;

  /// drawer 리스트에서 오른쪽 아이콘이 필요하면 사용
  final Widget? trailingWidget;

  const HomeNotificationPill({
    super.key,
    required this.text,
    this.onTap,
    this.notificationCount,
    this.trailingWidget,
  });

  Widget _buildTrailing(BuildContext context) {
    // drawer 전용 trailingWidget 우선
    if (trailingWidget != null) return trailingWidget!;

    final c = notificationCount;
    if (c == null || c <= 0) return const SizedBox.shrink();

    // ✅ 1개면 노란 점
    if (c == 1) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: BandiColor.accentColorYellow(context),
          shape: BoxShape.circle,
        ),
      );
    }

    // ✅ 여러개면 숫자 배지
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: BandiColor.neutralColor20(context),
        borderRadius: BandiEffects.radiusLarge,
      ),
      child: Text(
        "$c",
        style: BandiFont.labelMedium(context)?.copyWith(
          color: BandiColor.neutralColor90(context),
        ),
      ),
    );
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
              sigmaX: BandiEffects.blurLarge, sigmaY: BandiEffects.blurLarge),
          child: Container(
            padding: notificationCount == 1
                ? const EdgeInsets.fromLTRB(16, 12, 18, 12)
                : const EdgeInsets.fromLTRB(20, 8, 8, 8),
            decoration: BoxDecoration(
              color: BandiColor.neutralColor04(context),
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
