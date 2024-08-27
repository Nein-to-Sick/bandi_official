import 'package:bandi_official/controller/navigation_toggle_provider.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/login/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    var navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
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
                          fontWeight: FontWeight.w400, // Regular
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
                              shadowColor:
                                  WidgetStateProperty.all(Colors.transparent),
                              shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ))),
                          onPressed: () async {
                            AuthService()
                                .signInWithGoogle(context) // context를 전달합니다.
                                .then((value) async {
                              setState(() {
                                user = value;
                              });

                              // if (user != null) {
                              //   WidgetsBinding.instance
                              //       .addPostFrameCallback((_) {
                              //     navigationToggleProvider.selectIndex(0);
                              //   });
                              // }
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
                  const SizedBox(
                    height: 16,
                  ),
                  // apple login button
                  GestureDetector(
                    child: SizedBox(
                      height: 46,
                      width: 327,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  BandiColor.foundationColor100(context)),
                              shadowColor:
                                  WidgetStateProperty.all(Colors.transparent),
                              shape: WidgetStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ))),
                          onPressed: () {
                            // AuthService().signInWithGoogle().then((value) async {
                            //   setState(() {
                            //     user = value;
                            //   });

                            //   if (user != null) {
                            //     WidgetsBinding.instance.addPostFrameCallback((_) {
                            //       if (controller.scrollController.hasClients) {
                            //         controller.movePage(600);
                            //         controller.changeColor(2);
                            //       }
                            //     });
                            //   }
                            // });
                            // signUserIn();
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
                                style: BandiFont.labelMedium(context)?.copyWith(
                                    color: BandiColor.neutralColor100(context)),
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
  }
}
