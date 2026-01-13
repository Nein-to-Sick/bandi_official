import 'dart:ui';

import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';

class TutorialOverlay extends StatelessWidget {
  final Rect targetRect; // ✅ 여기만 터치 통과
  final double radius; // 14 (28/2)
  final Widget guide;

  const TutorialOverlay({
    super.key,
    required this.targetRect,
    required this.radius,
    required this.guide,
  });

  @override
  Widget build(BuildContext context) {
    // targetRect(28x28)을 기준으로 "원"을 만들 건데
    // 터치 통과는 안전하게 "사각형 영역"으로 둬도 충분해 (28x28)
    final hole = targetRect;

    return Stack(
      children: [
        // ✅ 1) 구멍을 제외한 영역만 터치 차단 (투명)
        // top
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: hole.top,
          child: const AbsorbPointer(child: SizedBox.expand()),
        ),
        // bottom
        Positioned(
          left: 0,
          right: 0,
          top: hole.bottom,
          bottom: 0,
          child: const AbsorbPointer(child: SizedBox.expand()),
        ),
        // left
        Positioned(
          left: 0,
          top: hole.top,
          width: hole.left,
          height: hole.height,
          child: const AbsorbPointer(child: SizedBox.expand()),
        ),
        // right
        Positioned(
          left: hole.right,
          right: 0,
          top: hole.top,
          height: hole.height,
          child: const AbsorbPointer(child: SizedBox.expand()),
        ),

        // ✅ 2) 원형 링(시각 표시) - 이것도 터치는 통과시켜야 함
        Positioned(
          left: targetRect.center.dx - radius,
          top: targetRect.center.dy - radius,
          width: radius * 2,
          height: radius * 2,
          child: IgnorePointer(
              ignoring: true, child: _TutorialRing(radius: radius)),
        ),

        // ✅ 3) 가이드(말풍선) - 말풍선도 터치 먹지 않게 하려면 ignoring:true
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
                offset: const Offset(0, 4)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
