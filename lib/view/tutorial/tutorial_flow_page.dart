// tutorial/tutorial_flow_page.dart
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:bandi_official/controller/navigation_toggle_provider.dart';
import 'package:bandi_official/localization/string_extention.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/custom_theme_data.dart';
import '../../../components/button/primary_button.dart';
import '../alarm/controller/alarm_controller.dart';
import 'controller/tutorial_controller.dart';

class TutorialFlowResult {
  final TutorialStep step;
  final int nextIndex; // 다음 설명 페이지 index (0~4)
  const TutorialFlowResult({required this.step, required this.nextIndex});
}

class TutorialFlowPage extends StatefulWidget {
  final int startIndex;

  const TutorialFlowPage({super.key, this.startIndex = 0});

  static Future<TutorialFlowResult?> show(BuildContext context,
      {int startIndex = 0}) {
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
  late int _index;

  static const int _total = 5;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex;
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TutorialStep _stepForIndex(int i) {
    switch (i) {
      case 0:
        return TutorialStep.emotionalWriting;
      case 1:
        return TutorialStep.connectionAndEmpathy;
      case 2:
        return TutorialStep.retrospect;
      case 3:
        return TutorialStep.growth;
      case 4:
        return TutorialStep.done;
      default:
        return TutorialStep.emotionalWriting;
    }
  }

  Future<void> _next() async {
    String langCode = Localizations.localeOf(context).languageCode;
    final step = _stepForIndex(_index);
    final nextIndex = _index + 1;

    String nickname = 'OO';
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final userSnap = await userRef.get();
        final userData = userSnap.data();
        nickname = (userData?['nickname'] as String?)?.trim().isNotEmpty == true
            ? (userData?['nickname'] as String).trim()
            : 'OO';
      } catch (e, st) {
        log('[Tutorial] failed to load nickname: $e', stackTrace: st);
      }
    }

    if (step == TutorialStep.connectionAndEmpathy) {
      try {
        await _pushOtherDiaryNotificationForTutorial(nickname: nickname);
      } catch (e, st) {
        log('[Tutorial] failed to insert notification: $e', stackTrace: st);
      }
    }

    if (step == TutorialStep.growth) {
      try {
        await context.read<AlarmController>().createTutorialLetterAndAlarm(
              title: 'v2_onboarding_step_letter_title'.tr(context),
              content: (langCode == 'ko')
                  ? '''
사랑하는 $nickname에게,

이번 한 달은 어떤 색깔이었나요? 유난히 비가 많이 오던 날, $nickname이 찾았던 작은 행복을 기억해요.

아침부터 쏟아지는 할 일들에 마음이 참 무거웠지만, 포기하지 않고 카페로 향했던 그 마음이 참 기특해요. 그곳에서 마신 따뜻한 커피 한 잔이 부정적인 생각들을 긍정으로 바꾸어주었죠. 사소한 기쁨을 발견할 줄 아는 $nickname은 이미 충분히 빛나는 사람이에요.

이렇게 당신이 남긴 소중한 하루하루를 모아, 반디는 매달 끝자락에 당신만을 위한 편지를 보낼 거예요. 숫자로 표현된 통계보다 더 따뜻하게, 당신의 단단해진 마음을 비추어 드릴게요.

힘겨운 시작도 긍정으로 마무리할 줄 아는 당신의 마음을 반디가 항상 응원할게요. 우리 다음 달에도 이 편지함에서 다시 만나요.

당신의 곁에서 늘 따스하게 자라날 반디가
'''
                  : '''
Dear $nickname,

What was the hue of your world this past month? I still cherish the memory of that rainy afternoon when you found a hidden spark of joy amidst the gray.

I remember how heavy the morning felt, yet I was so moved by your spirit. Instead of giving up, you gently led yourself to that quiet cafe. It's amazing how a single cup of coffee could shift the tides, turning heavy thoughts into peace. Someone like you, who finds light in the smallest cracks, is already glowing from within.

Each month, I'll gather these fleeting moments into a letter just for you. Forget dry data; I'm here to reflect the quiet strength and warmth blooming inside you.

I'll always be rooting for your resilience—your beautiful way of turning a tough start into a graceful finish. Let's meet here again next month.

With love and warmth, Bandi
''',
            );
      } catch (e, st) {
        log('[Tutorial] failed to create tutorial letter/alarm: $e',
            stackTrace: st);
      }
    }

    // 기존 흐름 유지
    if (_index == _total - 1) {
      context.read<NavigationToggleProvider>().selectIndex(0);
      Navigator.pop(context);
    } else {
      Navigator.of(context).pop(
        TutorialFlowResult(step: step, nextIndex: nextIndex),
      );
    }
  }

  Future<void> _pushOtherDiaryNotificationForTutorial(
      {required String nickname}) async {
    String langCode = Localizations.localeOf(context).languageCode;
    const tempDiary = 'KzHjbSE3LCQVnxxk9jGK9PJexnU251';

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      log('[Tutorial] uid is null -> skip notification insert');
      return;
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final notiRef = userRef.collection('notifications').doc();

    await notiRef.set({
      'dataId': tempDiary,
      'date': Timestamp.now(),
      'notificationId': notiRef.id,
      'title': (langCode == 'ko')
          ? '$nickname님과 비슷한 친구가 있어요.'
          : 'Found someone who feels just like you!',
      'type': 'otherDiary',
    });
  }

  @override
  Widget build(BuildContext context) {
    final sysBottom = MediaQuery.of(context).viewPadding.bottom;
    final extraBottom = Platform.isAndroid ? math.min(sysBottom, 48.0) : 0.0;

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
                          title: 'v2_onboarding_step_title_1'.tr(context),
                          description:
                              'v2_onboarding_step_description_1'.tr(context),
                          comment: 'v2_onboarding_step_comment_1'.tr(context),
                          image: Image.asset(
                              'assets/images/onboarding/onboarding_img1.png'),
                        ),
                        _TutorialStep(
                          title: 'v2_onboarding_step_title_2'.tr(context),
                          description:
                              'v2_onboarding_step_description_2'.tr(context),
                          comment: 'v2_onboarding_step_comment_2'.tr(context),
                          image: Image.asset(
                              'assets/images/onboarding/onboarding_img2.png'),
                        ),
                        _TutorialStep(
                          title: 'v2_onboarding_step_title_3'.tr(context),
                          description:
                              'v2_onboarding_step_description_3'.tr(context),
                          comment: 'v2_onboarding_step_comment_3'.tr(context),
                          image: Image.asset(
                              'assets/images/onboarding/onboarding_img3.png'),
                        ),
                        _TutorialStep(
                          title: 'v2_onboarding_step_title_4'.tr(context),
                          description:
                              'v2_onboarding_step_description_4'.tr(context),
                          comment: 'v2_onboarding_step_comment_4'.tr(context),
                          image: Image.asset(
                              'assets/images/onboarding/onboarding_img4.png'),
                        ),
                        _TutorialStep(
                          title: 'v2_onboarding_step_title_5'.tr(context),
                          description:
                              'v2_onboarding_step_description_5'.tr(context),
                        ),
                      ],
                    ),
                  ),

                  // 하단 버튼
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 32 + extraBottom),
                    child: CustomPrimaryButton(
                      title: _index == _total - 1
                          ? 'v2_onboarding_step_button_1'.tr(context)
                          : 'v2_onboarding_step_button_2'.tr(context),
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
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (image != null) image!,
              ],
            ),
          ),
          if (comment != null)
            Text(
              comment!,
              style: BandiFont.bodyLarge(context)?.copyWith(
                  color: BandiColor.neutralColor100(context),
                  height: 1.2,
                  fontSize: 16),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
