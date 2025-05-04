import 'dart:developer';
import 'dart:io';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/utils/apple_login_utils.dart' as custom_utils;

import 'package:bandi_official/controller/navigation_toggle_provider.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/login/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../components/button/primary_button.dart';
import '../../components/button/secondary_button.dart';
import '../../controller/securestorage_controller.dart';
import '../../controller/user_info_controller.dart';
import '../../utils/apple_login_utils.dart';
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

  @override
  void initState() {
    super.initState();

    final navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context, listen: false);
    if (navigationToggleProvider.getIndex() == -1) {
      _initializeSecureStorage(); // SecureStorage 초기화 및 정보 로드
    }
  }

  // SecureStorage 초기화 및 로그인 정보 로드
  Future<void> _initializeSecureStorage() async {
    final storageProvider =
        Provider.of<SecureStorageProvider>(context, listen: false);
    await storageProvider.loadLoginInfo(); // SecureStorage에서 정보 로드

    if (storageProvider.isLoggedIn) {
      // 자동 로그인 시도
      log("storageProvider.isLoggedIn");
      await _checkAutoLogin();
    }
  }

  // 자동 로그인 처리
  Future<void> _checkAutoLogin() async {
    final storageProvider =
        Provider.of<SecureStorageProvider>(context, listen: false);
    final navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context, listen: false);

    try {
      print("loading start");
      // navigationToggleProvider.selectIndex(100); // 로딩 화면 표시

      // Google 로그인 처리
      if (storageProvider.loginMethod == 'google' &&
          storageProvider.googleAccessToken != null) {
        log(" Google 로그인 처리");
        navigationToggleProvider.selectIndex(100);
        await AuthService()
            .signInWithGoogleTokens(
          storageProvider.googleAccessToken!,
          context,
        )
            .then((value) {
          navigationToggleProvider.selectIndex(0);
        });
      }
      // Apple 로그인 처리
      else if (storageProvider.loginMethod == 'apple' &&
          storageProvider.appleIdentityToken != null) {
        navigationToggleProvider.selectIndex(100);
        await AuthService()
            .signInWithAppleTokens(
          context,
        )
            .then((value) {
          navigationToggleProvider.selectIndex(0);
        });
        log("자동 Apple 로그인 성공");
      }

      // 로그인 성공 시 홈 화면으로 이동
      // if (mounted) {
      //   print("mounted");
      //   navigationToggleProvider.selectIndex(0);
      // }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'missing-or-invalid-nonce') {
        log("Firebase 인증 오류: 잘못된 또는 중복된 Nonce - ${e.message}");
      } else {
        log("FirebaseAuthException 발생: ${e.code} - ${e.message}");
      }
      rethrow;
    } catch (e) {
      log("자동 로그인 실패: $e");
      print("자동 로그인 실패: $e");
      navigationToggleProvider.selectIndex(-1); // 로그인 화면으로 이동
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
                        'login_title'.tr(context),
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
                    'login_subtitle'.tr(context),
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
                              user = value;

                              if (user != null) {
                                final storageProvider =
                                    Provider.of<SecureStorageProvider>(context,
                                        listen: false);

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) async {
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
                                    // 로딩 화면 노출
                                    navigationToggleProvider.selectIndex(100);
                                    await Future.delayed(
                                        const Duration(seconds: 1));
                                    navigationToggleProvider.selectIndex(0);
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
                                'login_google'.tr(context),
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
                                user = value;

                                if (user != null) {
                                  final storageProvider =
                                      Provider.of<SecureStorageProvider>(
                                          context,
                                          listen: false);

                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) async {
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
                                      // 로딩 화면 노출
                                      navigationToggleProvider.selectIndex(100);
                                      await Future.delayed(
                                          const Duration(seconds: 1));
                                      navigationToggleProvider.selectIndex(0);
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
                                  'login_apple'.tr(context),
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
                      ? "onboarding_step_title_1".tr(context)
                      : _onboarding == 2
                          ? "onboarding_step_title_2".tr(context)
                          : "onboarding_step_title_3".tr(context),
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
                      ? "onboarding_step_subtitle_1".tr(context)
                      : _onboarding == 2
                          ? "onboarding_step_subtitle_2".tr(context)
                          : "onboarding_step_subtitle_3".tr(context),
                  style: BandiFont.displaySmall(context)
                      ?.copyWith(color: BandiColor.neutralColor60(context)),
                  textAlign: TextAlign.center,
                ),
              if (_onboarding < 4)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.5),
                    child: _onboarding != 4
                        ? Image.asset(
                            "assets/images/onboarding/onboarding_${_onboarding}_${'onboarding_step_image_country'.tr(context)}.png",
                            fit: BoxFit.contain,
                          )
                        : Container(),
                  ),
                ),
              if (_onboarding < 3)
                CustomSecondaryButton(
                  title: 'onboarding_step_button_1'.tr(context),
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
                  title: _onboarding < 3
                      ? 'onboarding_step_button_2'.tr(context)
                      : 'onboarding_step_button_3'.tr(context),
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
        ),
      ),
    );

    return (navigationToggleProvider.getIndex() == -4)
        ? OnboardPage
        : LoginPage;
  }
}
