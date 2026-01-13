import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../theme/custom_theme_data.dart';

class TutorialSpeechBubble extends StatelessWidget {
  final Rect targetRect;
  final String title;
  final String subtitle;

  const TutorialSpeechBubble({
    super.key,
    required this.targetRect,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    // 말풍선 위치: targetRect 위쪽에 띄우되, 화면 밖으로 안 나가게 clamp
    const bubbleWidth = 320.0;
    const arrowH = 7.0;
    const arrowW = 9.24;

    final screen = MediaQuery.of(context).size;

    // bubble의 left: target 중심 기준으로 배치
    final idealLeft = targetRect.center.dx - bubbleWidth / 2;
    final left = idealLeft.clamp(16.0, screen.width - bubbleWidth - 16.0);

    // bubble의 top: target 위로
    final top = (targetRect.top - 14 - arrowH - 82).clamp(80.0, screen.height - 200.0);

    // arrow의 x: target 중심에 맞추되 bubble 범위 내로 clamp
    final arrowCxIdeal = targetRect.center.dx - left;
    final arrowCx = arrowCxIdeal.clamp(24.0, bubbleWidth - 24.0);

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bubble
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: BandiEffects.blurLarge,
                    sigmaY: BandiEffects.blurLarge,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: BandiColor.neutralColor80(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: BandiFont.titleSmall(context)?.copyWith(
                            color: BandiColor.foundationColor90(context),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: BandiFont.labelSmall(context)?.copyWith(
                            color: BandiColor.foundationColor40(context),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Arrow (tail)
              SizedBox(
                height: arrowH,
                width: bubbleWidth,
                child: CustomPaint(
                  painter: _BubbleArrowPainter(
                    cx: arrowCx,
                    w: arrowW,
                    h: arrowH,
                    color: Colors.white.withOpacity(0.80),
                    blurSigma: BandiEffects.blurLarge / 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BubbleArrowPainter extends CustomPainter {
  final double cx;
  final double w;
  final double h;
  final Color color;
  final double blurSigma;

  _BubbleArrowPainter({
    required this.cx,
    required this.w,
    required this.h,
    required this.color,
    required this.blurSigma,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(cx - w / 2, 0)
      ..lineTo(cx, h)
      ..lineTo(cx + w / 2, 0)
      ..close();

    // 꼬리도 말풍선처럼 반투명 느낌만 주면 충분해서 blur는 생략해도 됨.
    // (원하면 saveLayer+imageFilter로 더 꾸밀 수 있음)
    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BubbleArrowPainter oldDelegate) {
    return oldDelegate.cx != cx ||
        oldDelegate.w != w ||
        oldDelegate.h != h ||
        oldDelegate.color != color;
  }
}
