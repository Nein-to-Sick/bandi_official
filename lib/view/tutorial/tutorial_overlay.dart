import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';

class TutorialOverlay extends StatelessWidget {
  final Rect targetRect; // (보통 global rect)
  final double radius;   // 14
  final Widget guide;

  const TutorialOverlay({
    super.key,
    required this.targetRect,
    required this.radius,
    required this.guide,
  });

  @override
  Widget build(BuildContext context) {
    final hole = targetRect;

    return Stack(
      children: [
        // ✅ 1) 구멍을 제외한 영역만 터치 차단
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: hole.top,
          child: const AbsorbPointer(child: SizedBox.expand()),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: hole.bottom,
          bottom: 0,
          child: const AbsorbPointer(child: SizedBox.expand()),
        ),
        Positioned(
          left: 0,
          top: hole.top,
          width: hole.left,
          height: hole.height,
          child: const AbsorbPointer(child: SizedBox.expand()),
        ),
        Positioned(
          left: hole.right,
          right: 0,
          top: hole.top,
          height: hole.height,
          child: const AbsorbPointer(child: SizedBox.expand()),
        ),

        // ✅ 2) 링(시각) - 터치 통과
        Positioned(
          left: targetRect.center.dx - radius,
          top: targetRect.center.dy - radius,
          width: radius * 2,
          height: radius * 2,
          child: IgnorePointer(
            ignoring: true,
            child: _TutorialRing(radius: radius),
          ),
        ),

        // ✅ 3) 말풍선(가이드) - 터치 통과
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: guide,
          ),
        ),
      ],
    );
  }
}

/// ✅ BottomSheet 안에서 쓰는 링 오버레이
/// - "버튼 클릭을 막지 않는다"
/// - registry의 rectOf가 보통 global 좌표이므로, sheet-local로 변환해서 링 위치를 맞춘다.
class SheetRingOverlay extends StatelessWidget {
  final Rect globalTargetRect;
  final double radius;

  const SheetRingOverlay({
    super.key,
    required this.globalTargetRect,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ 터치 완전 통과
    return IgnorePointer(
      ignoring: true,
      child: LayoutBuilder(
        builder: (_, __) {
          final ro = context.findRenderObject();
          if (ro is! RenderBox) return const SizedBox.shrink();

          // sheet(Stack) 기준의 global origin
          final origin = ro.localToGlobal(Offset.zero);

          // global -> local rect
          final localRect = globalTargetRect.shift(-origin);

          return Stack(
            children: [
              Positioned(
                left: localRect.center.dx + 20,
                top: localRect.center.dy + 25,
                width: radius * 2,
                height: radius * 2,
                child: _TutorialRing(radius: radius),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TutorialRing extends StatelessWidget {
  final double radius;

  const _TutorialRing({required this.radius});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: BandiEffects.blurSmall,
          sigmaY: BandiEffects.blurSmall,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BandiColor.neutralColor20(context),
            border: Border.all(
              color: BandiColor.neutralColor50(context),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
