// tutorial/tutorial_flow_page.dart
import 'package:flutter/material.dart';

import '../../../theme/custom_theme_data.dart';
import '../../../components/button/primary_button.dart';
import 'controller/tutorial_controller.dart';

class TutorialFlowResult {
  final TutorialStep step;
  final int nextIndex; // 다음 설명 페이지 index (0~4)
  const TutorialFlowResult({required this.step, required this.nextIndex});
}

class TutorialFlowPage extends StatefulWidget {
  final int startIndex;

  const TutorialFlowPage({super.key, this.startIndex = 0});

  static Future<TutorialFlowResult?> show(BuildContext context, {int startIndex = 0}) {
    return Navigator.of(context).push<TutorialFlowResult>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => TutorialFlowPage(startIndex: startIndex),
        transitionsBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
          return FadeTransition(opacity: curved, child: child);
        },
      ),
    );
  }

  @override
  State<TutorialFlowPage> createState() => _TutorialFlowPageState();
}

class _TutorialFlowPageState extends State<TutorialFlowPage> {
  final _controller = PageController();
  late int _index;

  static const int _total = 5;

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpToPage(_index);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TutorialStep _stepForIndex(int i) {
    switch (i) {
      case 0: return TutorialStep.emotionalWriting;
      case 1: return TutorialStep.connectionAndEmpathy;
      case 2: return TutorialStep.retrospect;
      case 3: return TutorialStep.growth;
      case 4: return TutorialStep.done;
      default: return TutorialStep.emotionalWriting;
    }
  }

  void _next() {
    final step = _stepForIndex(_index);
    final nextIndex = _index + 1;

    Navigator.pop(
      context,
      TutorialFlowResult(step: step, nextIndex: nextIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/backgrounds/background_night.png',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // 본문
                  Expanded(
                    child: PageView(
                      controller: _controller,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) => setState(() => _index = i),
                      children: [
                        _TutorialStep(
                          title: '감정 기록',
                          description: '반디 AI는 당신의 마음을 키워드로\n 정리하고 이해하도록 돕습니다.',
                          comment: '하루 5분, 솔직하게 기록해보세요.',
                          image: Image.asset(
                              'assets/images/onboarding/onboarding_img1.png'),
                        ),
                        _TutorialStep(
                          title: '연결과 공감',
                          description:
                              '익명으로 나와 비슷한 사람들의 기록에\n 공감의 선물을 건네고 받을 수 있습니다.',
                          comment: '혼자가 아님을 확인해보세요.',
                          image: Image.asset(
                              'assets/images/onboarding/onboarding_img2.png'),
                        ),
                        _TutorialStep(
                          title: '회고',
                          description:
                              '당신의 기록을 기억하는 반디와\n부담 없이 대화하며 오늘을 회고해 보세요.',
                          comment: '대화를 통해 더 깊이 있게 자신을 이해하세요.',
                          image: Image.asset(
                              'assets/images/onboarding/onboarding_img3.png'),
                        ),
                        _TutorialStep(
                          title: '성장',
                          description: '당신의 마음이 얼마나 단단하게\n변화했는지 되돌아볼 수 있습니다.',
                          comment: '단순한 수치 대신, 반디의 편지를 확인하세요.',
                          image: Image.asset(
                              'assets/images/onboarding/onboarding_img4.png'),
                        ),
                        const _TutorialStep(
                          title: '이제 당신의 이야기를\n들려주세요.',
                          description: '나의 감정을 분석하고, 힘들 때 나에게\n가장 필요한 한마디를 건네줄 거에요.',
                        ),
                      ],
                    ),
                  ),

                  // 하단 버튼
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: CustomPrimaryButton(
                      title: _index == _total - 1 ? '시작하기' : '확인',
                      onPrimaryButtonPressed: _next,
                      disableButton: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialStep extends StatelessWidget {
  final String title;
  final String description;
  final String? comment;
  final Image? image;

  const _TutorialStep({
    required this.title,
    required this.description,
    this.comment,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, image != null ? 98 : 267, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: BandiFont.headlineLarge(context)?.copyWith(
              color: BandiColor.neutralColor100(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: BandiFont.titleSmall(context)?.copyWith(
              color: BandiColor.neutralColor60(context),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 53,
          ),
          if (image != null) image!,
          const Spacer(),
          if (comment != null)
          Text(
            comment!,
            style: BandiFont.bodyLarge(context)?.copyWith(
                color: BandiColor.neutralColor100(context),
                height: 1.2,
                fontSize: 16),
          ),
        ],
      ),
    );
  }
}
