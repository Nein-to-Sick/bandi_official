import 'dart:math';
import 'package:flutter/material.dart';

Color fireflyColor = const Color(0xffFFDB5B);

class FireFly extends StatefulWidget {
  const FireFly({super.key});

  @override
  FireFlyState createState() => FireFlyState();
}

class FireFlyState extends State<FireFly> with TickerProviderStateMixin {
  int fireFlyCount = 10;
  late List<AnimationController> controllers;
  late List<Animation<double>> animations;
  late List<AnimationController> blurControllers;
  late List<Animation<double>> blurAnimations;

  final List<Duration> _animationDurations = [];
  final List<Duration> _blurDurations = [];
  final List<double> _beginBlurValues = [];
  final List<double> _endBlurValues = [];
  final List<double> _sizes = [];
  final List<double> _startX = [];
  final List<double> _startY = [];
  final List<double> _onTwo = [];
  final List<int> _hundred = [];
  final List<int> _plusOrMinus = [];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers and properties
    controllers = [];
    animations = [];
    blurControllers = [];
    blurAnimations = [];

    for (int i = 0; i < fireFlyCount; i++) {
      // Movement and blur durations
      _animationDurations.add(Duration(seconds: Random().nextInt(21) + 30));
      _blurDurations.add(Duration(milliseconds: Random().nextInt(1001) + 1000));

      // Blur values
      _beginBlurValues.add(Random().nextDouble() * 1 + 2);
      _endBlurValues.add(Random().nextDouble() * 3 + 3);

      // Sizes of fireflies
      _sizes.add(Random().nextDouble() * 8 + 3);

      // Create animation controllers
      controllers.add(
          AnimationController(vsync: this, duration: _animationDurations[i]));
      animations.add(
        CurvedAnimation(parent: controllers[i], curve: Curves.easeInOut)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              controllers[i].reverse();
            } else if (status == AnimationStatus.dismissed) {
              controllers[i].forward();
            }
          }),
      );
      controllers[i].repeat();

      // Blur animations
      blurControllers
          .add(AnimationController(vsync: this, duration: _blurDurations[i]));
      blurAnimations.add(
        Tween<double>(begin: _beginBlurValues[i], end: _endBlurValues[i])
            .animate(blurControllers[i]),
      );
      blurControllers[i].repeat(reverse: true);
    }

    // Calculate starting positions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;

      for (int i = 0; i < fireFlyCount; i++) {
        _startX.add(screenWidth * 0.03 +
            Random().nextDouble() * (screenWidth * 0.97 - screenWidth * 0.03));
        _startY.add(screenHeight * 0.45 +
            Random().nextDouble() * (screenHeight - screenHeight * 0.45));
        _onTwo.add(Random().nextInt(3) + 1);
        _hundred.add(Random().nextInt(141) + 10);
        _plusOrMinus.add(Random().nextInt(2) * 2 - 1);
      }
      // Only call setState once to trigger the first layout
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_startX.isEmpty || _startY.isEmpty) {
      // Return a placeholder or loading widget until positions are initialized
      return Container();
    }

    return SafeArea(
      child: RepaintBoundary(
        child: Stack(
          children: List.generate(fireFlyCount, (i) {
            return AnimatedBuilder(
              animation: animations[i],
              builder: (context, child) {
                double value = animations[i].value;
                double newX = _startX[i] +
                    _hundred[i] * sin(value * pi) * _plusOrMinus[i];
                double newY = _startY[i] +
                    _hundred[i] *
                        sin((value * _onTwo[i]) * pi) *
                        _plusOrMinus[i];

                return Transform.translate(
                  offset: Offset(newX, newY),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 1,
                          color: fireflyColor,
                          blurRadius: blurAnimations[i].value,
                          blurStyle: BlurStyle.normal,
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      size: Size(_sizes[i], _sizes[i]),
                      painter: CircleBlurPainter(
                          circleWidth: 7, blurSigma: blurAnimations[i].value),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of all controllers
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var blurController in blurControllers) {
      blurController.dispose();
    }
    super.dispose();
  }
}

class CircleBlurPainter extends CustomPainter {
  final double circleWidth;
  final double blurSigma;

  CircleBlurPainter({required this.circleWidth, required this.blurSigma});

  @override
  void paint(Canvas canvas, Size size) {
    Paint line = Paint()
      ..color = fireflyColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = circleWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
