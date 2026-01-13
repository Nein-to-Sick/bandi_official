import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../theme/custom_theme_data.dart';

class TutorialSpeechBubble extends StatelessWidget {
  final Rect targetRect;
  final String title;
  final String subtitle;

  final Offset bubbleOffset;
  final double gap;

  final double arrowOffsetX;
  final double? anchorDx;
  final double bubbleWidth;

  /// 말풍선이 화면 밖으로 나가지 않게 패딩
  final EdgeInsets screenPadding;

  const TutorialSpeechBubble({
    super.key,
    required this.targetRect,
    required this.title,
    required this.subtitle,
    this.bubbleOffset = Offset.zero,
    this.gap = 12.0,
    this.arrowOffsetX = 0,
    this.anchorDx,
    this.bubbleWidth = 320.0,
    this.screenPadding = const EdgeInsets.fromLTRB(16, 80, 16, 16),
  });

  @override
  Widget build(BuildContext context) {
    const arrowH = 7.0;
    const arrowW = 9.24;

    final screen = MediaQuery.of(context).size;
    final anchorX = anchorDx ?? targetRect.center.dx;

    // =========================
    // 1) bubble 실제 높이 계산
    // =========================
    final titleStyle = BandiFont.titleSmall(context)?.copyWith(
      color: BandiColor.foundationColor90(context),
      height: 1.25,
    );

    final subtitleStyle = BandiFont.labelSmall(context)?.copyWith(
      color: BandiColor.foundationColor40(context),
      height: 1.25,
    );

    double textHeight(TextSpan span) {
      final tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
        maxLines: null,
      )..layout(maxWidth: bubbleWidth - 32); // padding 16*2 제외
      return tp.height;
    }

    final titleH = textHeight(TextSpan(text: title, style: titleStyle));
    final subH = textHeight(TextSpan(text: subtitle, style: subtitleStyle));

    // Container padding: 16 top + 16 bottom = 32
    // title/subtitle spacing: 8
    final bubbleBodyH = 32 + titleH + 8 + subH;

    // bubble 전체 높이 = body + arrow
    final bubbleTotalH = bubbleBodyH + arrowH;

    // =========================
    // 2) left / top 계산 (clamp를 실제 높이 기준으로)
    // =========================
    double left = (anchorX - bubbleWidth / 2)
        .clamp(screenPadding.left, screen.width - bubbleWidth - screenPadding.right);

    // ✅ 핵심: 상한을 "screen.height - bubbleTotalH - paddingBottom"으로
    double topIdeal = targetRect.top - gap - bubbleTotalH;
    double top = topIdeal.clamp(
      screenPadding.top,
      screen.height - bubbleTotalH - screenPadding.bottom,
    );

    // ✅ 미세 오프셋 적용 후에도 동일 기준으로 clamp
    left = (left + bubbleOffset.dx).clamp(
      screenPadding.left,
      screen.width - bubbleWidth - screenPadding.right,
    );
    top = (top + bubbleOffset.dy).clamp(
      screenPadding.top,
      screen.height - bubbleTotalH - screenPadding.bottom,
    );

    // arrow x (bubble 내부 좌표)
    final arrowCxIdeal = anchorX - left;
    final arrowCx = (arrowCxIdeal + arrowOffsetX).clamp(24.0, bubbleWidth - 24.0);

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        Text(title, style: titleStyle),
                        const SizedBox(height: 8),
                        Text(subtitle, style: subtitleStyle),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: arrowH,
                width: bubbleWidth,
                child: CustomPaint(
                  painter: _BubbleArrowPainter(
                    cx: arrowCx,
                    w: arrowW,
                    h: arrowH,
                    color: Colors.white.withOpacity(0.80),
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

  _BubbleArrowPainter({
    required this.cx,
    required this.w,
    required this.h,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(cx - w / 2, 0)
      ..lineTo(cx, h)
      ..lineTo(cx + w / 2, 0)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _BubbleArrowPainter oldDelegate) {
    return oldDelegate.cx != cx ||
        oldDelegate.w != w ||
        oldDelegate.h != h ||
        oldDelegate.color != color;
  }
}
