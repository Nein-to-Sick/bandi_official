import 'dart:math';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';

class MyFireFlyProgressbarAndDotPainter extends CustomPainter {
  final double rotationAngle;
  final double progress;
  final BuildContext context;

  MyFireFlyProgressbarAndDotPainter({
    required this.rotationAngle,
    required this.progress,
    required this.context,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final Paint glowPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    // Create a gradient shader
    final Shader shader = LinearGradient(
      colors: [
        Colors.yellow.withOpacity(0.75),
        Colors.yellow.withOpacity(0.05)
      ],
      stops: const [0.0, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Paint dotPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    final Paint dotPaintHead = Paint()
      ..color = BandiColor.accentColorYellow(context)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Set the shader to the paint
    //glowPaint.shader = shader;
    dotPaint.shader = shader;
    dotPaintHead.shader = shader;

    const double startAngle = -pi / 2;
    final double sweepAngle = 2 * pi * progress;

    // 빛나는 듯한 원 그리기, 뒤쪽 잔상 부분
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      startAngle + rotationAngle * pi / 180,
      sweepAngle,
      false,
      glowPaint,
    );

    // // 원호 그리기, 앞쪽 명확한 부분
    // canvas.drawArc(
    //   Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
    //   startAngle + rotationAngle * pi / 180,
    //   sweepAngle * 0.75,
    //   false,
    //   arcPaint,
    // );

    // 머리 그리기 (프로그래스바 앞쪽 끝 부분에 위치)
    double dotAngle = -1 * startAngle + sweepAngle + rotationAngle * pi / 180;
    double dotX = centerX + (radius) * cos(dotAngle);
    double dotY = centerY + (radius) * sin(dotAngle);

    canvas.drawCircle(Offset(dotX, dotY), 20, dotPaint);

    // 머리 그리기 2
    canvas.drawCircle(Offset(dotX, dotY), 10, dotPaintHead);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class MyFireFlyProgressbar extends StatefulWidget {
  final String loadingText;
  const MyFireFlyProgressbar({
    super.key,
    required this.loadingText,
  });

  @override
  MyFireFlyProgressbarState createState() => MyFireFlyProgressbarState();
}

class MyFireFlyProgressbarState extends State<MyFireFlyProgressbar>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double progress = 0.5;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SizedBox(
                height: 130,
                width: 130,
                child: CustomPaint(
                  painter: MyFireFlyProgressbarAndDotPainter(
                    rotationAngle: _animation.value * -360,
                    progress: progress,
                    context: context,
                  ),
                  child: Container(),
                ),
              );
            },
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            widget.loadingText,
            style: BandiFont.titleMedium(context)?.copyWith(
              color: BandiColor.neutralColor100(context),
            ),
          ),
        ],
      ),
    );
  }
}
