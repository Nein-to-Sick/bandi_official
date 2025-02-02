import 'dart:ui';

import 'package:bandi_official/components/appbar/appbar.dart';
import 'package:bandi_official/components/button/primary_button.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/controller/navigation_toggle_provider.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/mail/detail_view.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class NewLetterPopuView extends StatelessWidget {
  const NewLetterPopuView({super.key, this.newLetter});
  final Letter? newLetter;

  @override
  Widget build(BuildContext context) {
    final navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);
    MailController mailController = context.watch<MailController>();
    // 정규 표현식을 사용하여 'n월 편지' 부분을 추출
    final RegExp regex = RegExp(r'(\d+월 편지)$');
    RegExpMatch? match;
    Letter? letter;

    if (newLetter == null) {
      // mailController.newLetter가 초기화된 경우
      letter = mailController.newLetter;
      match = regex.firstMatch(letter.title);
    } else {
      // mailController.newLetter가 초기화되지 않은 경우
      letter = newLetter;
      match = regex.firstMatch(letter!.title);
    }

    return Scaffold(
      backgroundColor: BandiColor.transparent(context),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/backgrounds/background.png'),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: BandiEffects.backgroundBlur(),
              sigmaY: BandiEffects.backgroundBlur(),
            ),
            child: Container(
              color: BandiColor.transparent(context),
            ),
          ),
          Scaffold(
            backgroundColor: BandiColor.transparent(context),
            appBar: CustomAppBar(
              trailingIcon: PhosphorIcons.x(),
              onTrailingIconPressed: () {
                Navigator.pop(context);
              },
              isVisibleLeadingButton: false,
            ),
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              (match != null)
                                  ? '${match.group(1)}가 도착했어요!'
                                  : '편지가 도착했어요!',
                              style: BandiFont.headlineMedium(context)
                                  ?.copyWith(
                                      color:
                                          BandiColor.neutralColor100(context)),
                            ),
                            const SizedBox(
                              height: 32,
                            ),
                            const Image(
                              image: AssetImage(
                                  "assets/images/new_letter/new_letter.png"),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                          ],
                        ),
                      ),
                      CustomPrimaryButton(
                        title: '편지 보기',
                        onPrimaryButtonPressed: () {
                          // 추가적인 상태 업데이트 로직
                          navigationToggleProvider.selectIndex(2);
                          mailController.updateSavedCurrentIndex(1);
                          mailController.toggleDetailView(true);

                          // 애니메이션을 사용하여 현재 페이지를 닫고 새로운 페이지로 전환
                          // Navigator.pushReplacement 대신에 PageRouteBuilder 사용
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              opaque: false, // 투명 배경을 위해 false로 설정
                              barrierColor: BandiColor.transparent(
                                  context), // 배경을 투명하게 설정
                              transitionDuration:
                                  const Duration(milliseconds: 400),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                return DetailView(
                                  item: letter!,
                                  mailController: mailController,
                                );
                              },
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return Stack(
                                  children: [
                                    // 기존 화면이 페이드아웃 되도록 설정
                                    FadeTransition(
                                      opacity:
                                          Tween<double>(begin: 1.0, end: 0.0)
                                              .animate(animation),
                                      child: Scaffold(
                                        backgroundColor:
                                            BandiColor.transparent(context),
                                        body:
                                            Container(), // 기존 페이지 내용이 들어갈 수 있음
                                      ),
                                    ),
                                    // 새 화면이 페이드인 되도록 설정
                                    FadeTransition(
                                      opacity:
                                          Tween<double>(begin: 0.0, end: 1.0)
                                              .animate(animation),
                                      child: child,
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                        disableButton: false,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
