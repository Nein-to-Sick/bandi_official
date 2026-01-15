import 'dart:ui' show lerpDouble;
import 'package:bandi_official/localization/string_extention.dart';
import 'package:flutter/material.dart';
import '../../../theme/custom_theme_data.dart';

class AiSavingLoadingDialog extends StatefulWidget {
  const AiSavingLoadingDialog({super.key});

  @override
  State<AiSavingLoadingDialog> createState() => AiSavingLoadingDialogState();
}

class AiSavingLoadingDialogState extends State<AiSavingLoadingDialog>
    with TickerProviderStateMixin {
  late final AnimationController _timeline; // 0..1 (8초)
  late final AnimationController _pulse; // 0..1 (숨쉬기)

  @override
  void initState() {
    super.initState();

    // 4단계 문구 + 로딩 흐름(8초) : 끝나면 마지막에서 멈추게 하고 싶으면 forward() 유지
    _timeline = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..forward();

    // glow가 살아있는 느낌만 주는 매우 약한 pulse
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timeline.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void finishImmediately() {
    _timeline.stop();
    _pulse.stop();
  }

  // 문구 단계(2초씩)
  int _currentStep(double t) => (t * 4).floor().clamp(0, 3);

  // 전체 진행률 0..1
  double _globalProgress(double t) =>
      Curves.easeInOut.transform(t.clamp(0.0, 1.0));

  // 링 고정값
  static const double _outerRingR = 77.0;
  static const double _innerRingR = 39.0;

  @override
  Widget build(BuildContext context) {
    final messages = [
      "v2_loading_comment_1".tr(context),
      "v2_loading_comment_2".tr(context),
      "v2_loading_comment_3".tr(context),
      "v2_loading_comment_4".tr(context),
    ];

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage('assets/images/backgrounds/background_dark.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: AnimatedBuilder(
            animation: Listenable.merge([_timeline, _pulse]),
            builder: (_, __) {
              final t = _timeline.value; // 0..1 (8초)
              final step = _currentStep(t);

              final g = _globalProgress(t);

              // glow radius / blur를 더 강하게
              final glowRadius =
                  lerpDouble(_innerRingR * 0.85, _outerRingR * 0.985, g)!;
              final blurSigma = lerpDouble(18.0, 48.0, g)!; // ✅ 더 뿌옇게

              // ✅ inner ring은 후반으로 갈수록 완전 사라지게
              // g=0.0~0.35: 1 유지 / 이후 0으로 떨어짐
              final innerRingOpacity =
                  (1.0 - ((g - 0.35) / 0.25).clamp(0.0, 1.0));

              // ✅ inner 영역을 덮는 뿌연 베일 강도(후반에 강하게)
              final veilOpacity = lerpDouble(0.05, 0.55, g)!;

              // pulse
              final pulse = 0.985 + 0.03 * _pulse.value;
              final pulsedGlowRadius = glowRadius * pulse;

              final message = messages[step];

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    message,
                    style: BandiFont.titleMedium(context)?.copyWith(
                      color: BandiColor.neutralColor90(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: 156,
                    height: 156,
                    child: CustomPaint(
                      painter: _FireflyLikePainter(
                        outerRingRadius: _outerRingR,
                        innerRingRadius: _innerRingR,
                        innerRingOpacity: innerRingOpacity,
                        coreRadius: 6.0,
                        glowRadius: pulsedGlowRadius,
                        glowBlurSigma: blurSigma,
                        veilOpacity: veilOpacity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FireflyLikePainter extends CustomPainter {
  final double outerRingRadius;
  final double innerRingRadius;

  final double innerRingOpacity; // ✅ 추가 (0이면 안 보임)

  final double coreRadius;
  final double glowRadius;
  final double glowBlurSigma;

  final double veilOpacity; // ✅ 추가 (inner 영역을 뿌옇게 덮는 막)

  _FireflyLikePainter({
    required this.outerRingRadius,
    required this.innerRingRadius,
    required this.innerRingOpacity,
    required this.coreRadius,
    required this.glowRadius,
    required this.glowBlurSigma,
    required this.veilOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    // =====================
    // 1) Outer ring (항상)
    // =====================
    final outerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.10);

    canvas.drawCircle(c, outerRingRadius, outerRingPaint);

    // =====================
    // 2) Inner ring (후반에 완전 사라짐)
    // =====================
    if (innerRingOpacity > 0.001) {
      final innerRingPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withOpacity(0.10 * innerRingOpacity);

      canvas.drawCircle(c, innerRingRadius, innerRingPaint);
    }

    // =====================
    // 3) Glow (더 진하고 더 뿌옇게)
    // =====================
    final glowRect = Rect.fromCircle(center: c, radius: glowRadius);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFDB5B).withOpacity(1.0), // ✅ 더 진하게
          const Color(0xFFFFDB5B).withOpacity(0.85),
          const Color(0xFFFFDB5B).withOpacity(0.45),
          const Color(0x00FFDB5B),
        ],
        stops: const [0.0, 0.40, 0.78, 1.0],
      ).createShader(glowRect)
      ..blendMode = BlendMode.plus
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlurSigma);

    canvas.drawCircle(c, glowRadius, glowPaint);

    // =====================
    // 4) Veil (inner ring이 안 보이게 "뿌연 막" 덮기)
    //    - inner ring 근처만 부드럽게 덮어서 테두리가 사라짐
    // =====================
    final veilR = innerRingRadius * 1.25;
    final veilRect = Rect.fromCircle(center: c, radius: veilR);

    final veilPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFDB5B).withOpacity(veilOpacity), // ✅ 막 강도
          const Color(0x00FFDB5B),
        ],
        stops: const [0.0, 1.0],
      ).createShader(veilRect)
      ..blendMode = BlendMode.plus
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.drawCircle(c, veilR, veilPaint);

    // =====================
    // 5) Core (항상 존재하지만, 결국 glow/veil에 묻혀 안 보이게)
    // =====================
    final corePaint = Paint()
      ..color = const Color(0xFFFFDB5B)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawCircle(c, coreRadius, corePaint);
  }

  @override
  bool shouldRepaint(covariant _FireflyLikePainter oldDelegate) {
    return oldDelegate.glowRadius != glowRadius ||
        oldDelegate.glowBlurSigma != glowBlurSigma ||
        oldDelegate.innerRingOpacity != innerRingOpacity ||
        oldDelegate.veilOpacity != veilOpacity;
  }
}
