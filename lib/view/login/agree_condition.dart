import 'dart:async';
import 'package:bandi_official/model/settingsInfos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wrapped_korean_text/wrapped_korean_text.dart';
import '../../components/button/primary_button.dart';
import '../../controller/navigation_toggle_provider.dart';
import '../../controller/user_info_controller.dart';
import '../../theme/custom_theme_data.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart'; // 아이콘 패키지 임포트

// 다이얼로그에 표시할 "이용약관"과 "개인정보처리동의서" 내용을 정의
final String termsOfUseContent = "이용약관 내용 여기에 표시됩니다.";
final String privacyPolicyContent = "개인정보처리동의서 내용 여기에 표시됩니다.";

class AgreementSheet {
  Future<bool?> agreementTermSheet(BuildContext context) {
    return showModalBottomSheet<bool>(
      backgroundColor: BandiColor.neutralColor40(context),
      // barrierColor: Colors.black.withAlpha(1),
      // backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      barrierColor: Colors.transparent,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (BuildContext context) {
        return AgreementStatful();
      },
    );
  }
}

class AgreementStatful extends StatefulWidget {
  const AgreementStatful({super.key});

  @override
  State<AgreementStatful> createState() => _AgreementStatfulState();
}

class _AgreementStatfulState extends State<AgreementStatful> {
  bool allSelected = false;
  bool option1Selected = false;
  bool option2Selected = false;
  bool option3Selected = false;

  @override
  Widget build(BuildContext context) {
    var navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);

    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Container(
        decoration: BoxDecoration(
          color: BandiColor.neutralColor40(context).withOpacity(1.0),
          // color: Colors.black,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        height: 420,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  "약관 동의",
                  style: BandiFont.bodyMedium(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '전체 동의',
                  style: BandiFont.bodySmall(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () {
                    setState(() {
                      allSelected = !allSelected;
                      option1Selected = allSelected;
                      option2Selected = allSelected;
                      option3Selected = allSelected;
                    });
                  },
                  child: allSelected
                      ? PhosphorIcon(
                          PhosphorIconsFill.checkCircle,
                          color: BandiColor.foundationColor80(context),
                        )
                      : PhosphorIcon(
                          PhosphorIcons.checkCircle(),
                          color: BandiColor.foundationColor20(context),
                          // fill: 1.0,
                        ),
                ),
              ),
              Container(
                width: double.maxFinite,
                height: 1.5,
                decoration: BoxDecoration(
                  color: BandiColor.foundationColor10(context),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '(필수) 만 14세 이상이신가요?',
                  style: BandiFont.bodySmall(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () {
                    setState(() {
                      option1Selected = !option1Selected;
                      allSelected =
                          option1Selected && option2Selected && option3Selected;
                    });
                  },
                  child: option1Selected
                      ? PhosphorIcon(
                          PhosphorIconsFill.checkCircle,
                          color: BandiColor.foundationColor80(context),
                        )
                      : PhosphorIcon(
                          PhosphorIcons.checkCircle(),
                          color: BandiColor.foundationColor20(context),
                          // fill: 1.0,
                        ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: GestureDetector(
                  onTap: () {
                    // 웹뷰 또는 다이얼로그로 약관을 보여주는 로직을 구현
                    // "개인정보처리동의서"를 눌렀을 때
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        var screenSize = MediaQuery.of(context).size;
                        return Scaffold(
                            backgroundColor: BandiColor.neutralColor80(context)
                                .withOpacity(0.8),
                            // custom appbar 일단 임시로 leading icon 변경
                            appBar: AppBar(
                              scrolledUnderElevation: 0,
                              automaticallyImplyLeading: false,
                              backgroundColor: BandiColor.transparent(context),
                              // leading: null,
                              title: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Text(
                                  "개인정보 처리방침",
                                  style:
                                      BandiFont.displaySmall(context)?.copyWith(
                                    color:
                                        BandiColor.foundationColor80(context),
                                  ),
                                ),
                              ),
                              centerTitle: true,
                            ),
                            body: Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 23.0),
                                      child: Column(
                                        children: [
                                          for (int i = 0;
                                              i <
                                                  CompanyInfo()
                                                      .privacyPolicy
                                                      .length;
                                              i++)
                                            Column(
                                              children: [
                                                if (i != 0)
                                                  const SizedBox(height: 44),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: WrappedKoreanText(
                                                    CompanyInfo()
                                                        .privacyPolicy[i][0],
                                                    style: BandiFont
                                                            .headlineMedium(
                                                                context)
                                                        ?.copyWith(
                                                      color: BandiColor
                                                          .foundationColor80(
                                                              context),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 11),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: WrappedKoreanText(
                                                    CompanyInfo()
                                                        .privacyPolicy[i][1],
                                                    style: BandiFont.bodySmall(
                                                            context)
                                                        ?.copyWith(
                                                      color: BandiColor
                                                          .foundationColor80(
                                                              context),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: WrappedKoreanText(
                                              CompanyInfo()
                                                  .privacyPolicyExplain,
                                              style:
                                                  BandiFont.bodySmall(context)
                                                      ?.copyWith(
                                                color: BandiColor
                                                    .foundationColor80(context),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 60),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                CustomPrimaryButton(
                                  title: '닫기',
                                  onPrimaryButtonPressed: () {
                                    Navigator.pop(context);
                                  },
                                  disableButton: false,
                                ),
                                const SizedBox(
                                  height: 32,
                                )
                              ],
                            ));
                      },
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: BandiFont.bodySmall(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                      children: const [
                        TextSpan(text: '(필수) '),
                        TextSpan(
                          text: '개인정보처리동의서',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: '에 동의하시나요?'),
                      ],
                    ),
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () {
                    setState(() {
                      option2Selected = !option2Selected;
                      allSelected =
                          option1Selected && option2Selected && option3Selected;
                    });
                  },
                  child: option2Selected
                      ? PhosphorIcon(
                          PhosphorIconsFill.checkCircle,
                          color: BandiColor.foundationColor80(context),
                        )
                      : PhosphorIcon(
                          PhosphorIcons.checkCircle(),
                          color: BandiColor.foundationColor20(context),
                          // fill: 1.0,
                        ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: GestureDetector(
                  onTap: () {
                    // 웹뷰 또는 다이얼로그로 약관을 보여주는 로직을 구현
                    // "이용약관"을 눌렀을 때
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        var screenSize = MediaQuery.of(context).size;
                        return Scaffold(
                            backgroundColor: BandiColor.neutralColor80(context)
                                .withOpacity(0.8),
                            // custom appbar 일단 임시로 leading icon 변경
                            appBar: AppBar(
                              scrolledUnderElevation: 0,
                              backgroundColor: BandiColor.transparent(context),
                              automaticallyImplyLeading: false,
                              title: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Text(
                                  "이용약관",
                                  style:
                                      BandiFont.displaySmall(context)?.copyWith(
                                    color:
                                        BandiColor.foundationColor80(context),
                                  ),
                                ),
                              ),
                              centerTitle: true,
                            ),
                            body: Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 23.0),
                                      child: Column(
                                        children: [
                                          for (int i = 0;
                                              i <
                                                  CompanyInfo()
                                                      .termsOfUse
                                                      .length;
                                              i++)
                                            Column(
                                              children: [
                                                if (i != 0)
                                                  const SizedBox(height: 80),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: WrappedKoreanText(
                                                    CompanyInfo().termsOfUse[i]
                                                        [0],
                                                    style: BandiFont
                                                            .headlineMedium(
                                                                context)
                                                        ?.copyWith(
                                                      color: BandiColor
                                                          .foundationColor80(
                                                              context),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 11),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: WrappedKoreanText(
                                                    CompanyInfo().termsOfUse[i]
                                                        [1],
                                                    style: BandiFont.bodySmall(
                                                            context)
                                                        ?.copyWith(
                                                      color: BandiColor
                                                          .foundationColor80(
                                                              context),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          const SizedBox(
                                            height: 50,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                CustomPrimaryButton(
                                  title: '닫기',
                                  onPrimaryButtonPressed: () {
                                    Navigator.pop(context);
                                  },
                                  disableButton: false,
                                ),
                                const SizedBox(
                                  height: 32,
                                )
                              ],
                            ));
                      },
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      style: BandiFont.bodySmall(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                      children: const [
                        TextSpan(text: '(필수) '),
                        TextSpan(
                          text: '이용약관',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: '에 동의하시나요?'),
                      ],
                    ),
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () {
                    setState(() {
                      option3Selected = !option3Selected;
                      allSelected =
                          option1Selected && option2Selected && option3Selected;
                    });
                  },
                  child: option3Selected
                      ? PhosphorIcon(
                          PhosphorIconsFill.checkCircle,
                          color: BandiColor.foundationColor80(context),
                        )
                      : PhosphorIcon(
                          PhosphorIcons.checkCircle(),
                          color: BandiColor.foundationColor20(context),
                          // fill: 1.0,
                        ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomPrimaryButton(
                title: '확인',
                onPrimaryButtonPressed: () async {
                  if (allSelected) {
                    // await userAgreementFirebaseUpdate();
                    navigationToggleProvider.selectIndex(-4);
                    Navigator.pop(context, true); // Navigator.pop에서 true 반환
                  }
                },
                disableButton: allSelected ? false : true,
              ),
              const SizedBox(
                height: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> userAgreementFirebaseUpdate() async {
    final userCollection = FirebaseFirestore.instance.collection("users");
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    await userCollection.doc(userId).update(
      {
        "isAgreed": true,
        "last_agreed_at": DateTime.now(),
      },
    );
  }
}
