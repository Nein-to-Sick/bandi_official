import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Color fireflyColor = const Color(0xffFFDB5B);

class FireFly extends StatefulWidget {
  const FireFly({
    super.key,
  });

  // final UserInfoValueModel userInfoController;

  @override
  FireFlyState createState() => FireFlyState();
}

class FireFlyState extends State<FireFly> with TickerProviderStateMixin {
  int fireFlyCount = 1;
  late List<AnimationController> controller = [];
  List<Animation<double>> animation = [];

  List<AnimationController> blurController = [];
  List<Animation<double>> blurAnimation = [];

  final List<Duration> _animationDurations = []; // 움직임 시간
  final List<Duration> _blurDurations = []; // 반짝이 시간

  final List<double> _beginBlurValue = []; // 블러 작은 크기
  final List<double> _endBlurValue = []; // 블러 큰 크기
  final List<double> _size = []; // 동그라미 크기

  AnimationController? _spreadAnimationController;
  Animation<double>? _spreadAnimation;

  // late int? greenFieldValue;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // String? userId = FirebaseAuth.instance.currentUser?.uid;
  // late Stream<DocumentSnapshot> _firestoreDocumentStream;

  @override
  void initState() {
    super.initState();
    fireFlyCount = 20;
    // _firestoreDocumentStream =
    //     _firestore.collection('users').doc(userId).snapshots();
    for (int i = 0; i < fireFlyCount; i++) {
      int randomSeconds = Random().nextInt(21) + 30;
      _animationDurations.add(Duration(seconds: randomSeconds));

      int randomMilliseconds = Random().nextInt(1001) + 1000;
      _blurDurations.add(Duration(milliseconds: randomMilliseconds));

      double randomDouble = Random().nextDouble() * 1 + 2;
      _beginBlurValue.add(randomDouble);
      randomDouble = Random().nextDouble() * 3 + 3;
      _endBlurValue.add(randomDouble);
      randomDouble = Random().nextDouble() * 8 + 3;
      _size.add(randomDouble);

      controller.add(
          AnimationController(vsync: this, duration: _animationDurations[i]));
      Animation<double> curvedAnimation =
          CurvedAnimation(parent: controller[i], curve: Curves.ease)
            ..addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                controller[i].reverse();
              } else if (status == AnimationStatus.dismissed) {
                controller[i].forward();
              }
            });
      animation.add(curvedAnimation);
      controller[i].repeat();
      blurController
          .add(AnimationController(vsync: this, duration: _blurDurations[i]));
      blurController[i].repeat(reverse: true);
      blurAnimation.add(
          Tween<double>(begin: _beginBlurValue[i], end: _endBlurValue[i])
              .animate(blurController[i]));
    }
    _spreadAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _spreadAnimation =
        Tween<double>(begin: 10, end: 16).animate(_spreadAnimationController!)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _spreadAnimationController!.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _spreadAnimationController!.forward();
            }
          });

    _spreadAnimationController!.forward();
  }

  // newX and newY starting positions
  final List<double> _startX = [];
  final List<double> _startY = [];
  final List<double> onTwo = [];
  final List<int> hundred = [];
  final List<int> plusOrMinus = [];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height; // 852

    // Generate random starting positions
    for (int i = 0; i < fireFlyCount; i++) {
      _startX.add(screenWidth * 0.03 +
          Random().nextDouble() * (screenWidth * 0.97 - screenWidth * 0.03));
      _startY.add(screenHeight * 0.45 +
          Random().nextDouble() * (screenHeight - screenHeight * 0.45));
      onTwo.add(Random().nextInt(3) + 1);
      hundred.add(Random().nextInt(141) + 10);
      plusOrMinus.add(Random().nextInt(2) * 2 - 1);
    }

    return SafeArea(
      child: Stack(
        children: [
          for (int i = 0; i < fireFlyCount; i++)
            AnimatedBuilder(
              animation: animation[i],
              builder: (context, child) {
                double value = animation[i].value;
                double newX =
                    _startX[i] + hundred[i] * sin(value * pi) * plusOrMinus[i];
                double newY = _startY[i] +
                    hundred[i] * sin((value * onTwo[i]) * pi) * plusOrMinus[i];
                return Transform.translate(
                  offset: Offset(newX, newY),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          // greenFieldValue == 0
                          //     ? BoxShadow(
                          //     spreadRadius: 1,
                          //     color: fireflyColor,
                          //     blurRadius: 5, // 20
                          //     blurStyle: BlurStyle.normal)
                          //     :
                          BoxShadow(
                              spreadRadius: _spreadAnimation!.value,
                              color: fireflyColor,
                              blurRadius: 30,
                              blurStyle: BlurStyle.normal),
                        ]),
                    child: CustomPaint(
                      size: Size(_size[i], _size[i]),
                      foregroundPainter: CircleBlurPainter(
                          circleWidth: 7, blurSigma: blurAnimation[i].value),
                    ),
                  ),
                );
              },
            )
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (int i = 0; i < fireFlyCount; i++) {
      controller[i].dispose();
      blurController[i].dispose();
    }
    _spreadAnimationController!.dispose();

    super.dispose();
  }
}

class CircleBlurPainter extends CustomPainter {
  CircleBlurPainter({required this.circleWidth, required this.blurSigma});

  double circleWidth;
  double blurSigma;

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
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
