import 'dart:io';

import 'package:bandi_official/controller/navigation_toggle_provider.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/login/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/button/primary_button.dart';
import '../../components/button/secondary_button.dart';
import '../../controller/user_info_controller.dart';
import 'agree_condition.dart';
import 'nickname.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  User? user = FirebaseAuth.instance.currentUser;
  int _onboarding = 1;

  // @override
  // void initState() {
  //   super.initState();

  //   if (user != null) {
  //     final navigationToggleProvider =
  //         Provider.of<NavigationToggleProvider>(context);
  //     navigationToggleProvider.selectIndex(0);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    final userInfoProvider =
        Provider.of<UserInfoValueModel>(context, listen: false);

    final navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context, listen: false);

    if (user != null && userInfoProvider.getNickName() != "") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationToggleProvider.selectIndex(0);
      });
    } else if (navigationToggleProvider.getIndex() == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);
    final userInfoProvider = Provider.of<UserInfoValueModel>(context);

    Widget LoginPage = Scaffold(
      backgroundColor: BandiColor.transparent(context),
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.19),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "반디",
                        style: TextStyle(
                          fontFamily: "IBMPlexSansKR",
                          fontSize: 50,
                          fontWeight: FontWeight.bold, // Regular
                          color: BandiColor.neutralColor100(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    "마음을 밝히는 작은 불빛",
                    style: BandiFont.bodyMedium(context)
                        ?.copyWith(color: BandiColor.neutralColor100(context)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 55.0),
              child: Column(
                children: [
                  GestureDetector(
                    child: SizedBox(
                      height: 46,
                      width: 327,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  BandiColor.neutralColor80(context)),
                              shadowColor: WidgetStateProperty.all(
                                BandiColor.transparent(context),
                              ),
                              shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ))),
                          onPressed: () {
                            AuthService()
                                .signInWithGoogle(context)
                                .then((value) async {
                              setState(() {
                                user = value;
                              });

                              if (user != null) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (userInfoProvider.getNickName() == "") {
                                    navigationToggleProvider.selectIndex(-3);
                                    AgreementSheet()
                                        .agreementTermSheet(context)
                                        .then((accepted) {
                                      if (accepted != null && accepted) {
                                        // 약관 동의가 완료되면 다음 단계로 넘어감
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      navigationToggleProvider.selectIndex(0);
                                    });
                                  }
                                });
                              }
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Image(
                                image: AssetImage(
                                    "assets/images/login/logoGoogle.png"),
                                width: 32,
                                height: 32,
                              ),
                              const SizedBox(width: 8), // 아이콘과 텍스트 사이에 간격을 추가
                              Text(
                                "구글로 시작하기",
                                style: BandiFont.labelMedium(context)?.copyWith(
                                    color:
                                        BandiColor.foundationColor100(context)),
                              ),
                            ],
                          )),
                    ),
                  ),
                  if (Platform.isIOS)
                    const SizedBox(
                      height: 16,
                    ),
                  // apple login button
                  if (Platform.isIOS)
                    GestureDetector(
                      child: SizedBox(
                        height: 46,
                        width: 327,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    BandiColor.foundationColor100(context)),
                                shadowColor: WidgetStateProperty.all(
                                  BandiColor.transparent(context),
                                ),
                                shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ))),
                            onPressed: () {
                              AuthService()
                                  .signInWithApple(context)
                                  .then((value) async {
                                setState(() {
                                  user = value;
                                });

                                if (user != null) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (userInfoProvider.getNickName() == "") {
                                      navigationToggleProvider.selectIndex(-3);
                                      AgreementSheet()
                                          .agreementTermSheet(context)
                                          .then((accepted) {
                                        if (accepted != null && accepted) {
                                          // 약관 동의가 완료되면 다음 단계로 넘어감
                                        }
                                      });
                                    } else {
                                      setState(() {
                                        navigationToggleProvider.selectIndex(0);
                                      });
                                    }
                                  });
                                }
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Image(
                                  image: AssetImage(
                                      "assets/images/login/logoApple.png"),
                                  width: 32,
                                  height: 32,
                                ),
                                const SizedBox(width: 8), // 아이콘과 텍스트 사이에 간격을 추가
                                Text(
                                  "애플로 시작하기",
                                  style: BandiFont.labelMedium(context)
                                      ?.copyWith(
                                          color: BandiColor.neutralColor100(
                                              context)),
                                ),
                              ],
                            )),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      )),
    );

    Widget OnboardPage = Scaffold(
      backgroundColor: BandiColor.transparent(context),
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (_onboarding < 4)
              const SizedBox(
                height: 116,
              ),
            if (_onboarding < 4)
              Text(
                _onboarding == 1
                    ? "일상을 기록해보세요"
                    : _onboarding == 2
                        ? "자신과 대화해보세요"
                        : "다른 사람의 기록에 공감해주세요",
                style: BandiFont.displayMedium(context)
                    ?.copyWith(color: BandiColor.neutralColor90(context)),
              ),
            if (_onboarding < 4)
              const SizedBox(
                height: 6,
              ),
            if (_onboarding < 4)
              Text(
                _onboarding == 1
                    ? "사진, 감정, 글로 간단하게 기록할 수 있어요."
                    : _onboarding == 2
                        ? "나의 기록을 학습한 AI와 대화할 수 있어요."
                        : "당신과 비슷한 누군가의 기록을 보고 응원해주세요.",
                style: BandiFont.displaySmall(context)
                    ?.copyWith(color: BandiColor.neutralColor60(context)),
              ),
            if (_onboarding < 4)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.5),
                  child: _onboarding != 4
                      ? Image.asset(
                          "assets/images/onboarding/onboarding$_onboarding.png",
                          fit: BoxFit.contain,
                        )
                      : Container(),
                ),
              ),
            if (_onboarding < 3)
              CustomSecondaryButton(
                title: '건너뛰기',
                onSecondaryButtonPressed: () {
                  setState(() {
                    // setState() 추가.
                    _onboarding = 4;
                  });

                  if (_onboarding >= 4) {
                    NicknameSettingSheet()
                        .showNicknameSettingSheet(context)
                        .then((_) {
                      // 닉네임 설정 완료 후 추가 처리
                      // 닉네임 설정 완료 후의 로직을 여기에 작성
                    });
                  }
                },
                disableButton: false,
              ),
            const SizedBox(
              height: 12,
            ),
            if (_onboarding < 4)
              CustomPrimaryButton(
                title: _onboarding < 3 ? '다음' : '모두 이해했습니다.',
                onPrimaryButtonPressed: () {
                  setState(() {
                    // setState() 추가.
                    _onboarding++;
                  });
                  if (_onboarding >= 4) {
                    NicknameSettingSheet()
                        .showNicknameSettingSheet(context)
                        .then((_) {
                      // 닉네임 설정 완료 후 추가 처리
                      // 닉네임 설정 완료 후의 로직을 여기에 작성
                    });
                  }
                },
                disableButton: false,
              ),
            const SizedBox(
              height: 32,
            ),
          ],
        ),
      )),
    );

    return (navigationToggleProvider.getIndex() == -4)
        ? OnboardPage
        : LoginPage;
  }
}
