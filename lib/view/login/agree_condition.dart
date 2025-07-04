import 'dart:async';
import 'package:bandi_official/model/settingsInfos.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wrapped_korean_text/wrapped_korean_text.dart';
import '../../components/button/primary_button.dart';
import '../../controller/navigation_toggle_provider.dart';
import '../../theme/custom_theme_data.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart'; // 아이콘 패키지 임포트

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
        return const AgreementStatful();
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
  bool option4Selected = false;

  @override
  Widget build(BuildContext context) {
    String langCode = Localizations.localeOf(context).languageCode;
    List<List<String>>? terms = CompanyInfo().localizedTermsOfUse[langCode] ??
        CompanyInfo().localizedTermsOfUse['ko'];

    List<List<String>>? privacy =
        CompanyInfo().localizedPrivacyPolicy[langCode] ??
            CompanyInfo().localizedPrivacyPolicy['ko'];

    List<List<String>>? eulaContent = CompanyInfo().localizedEula[langCode] ??
        CompanyInfo().localizedEula['ko'];

    var navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);

    return WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Container(
        decoration: BoxDecoration(
          color: BandiColor.neutralColor40(context).withOpacity(0.8),
          // color: Colors.black,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        height: 480,
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
                  "onboarding_agreement_condition_title".tr(context),
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
                  'onboarding_agreement_condition_header'.tr(context),
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
                      option4Selected = allSelected;
                    });
                  },
                  child: allSelected
                      ? PhosphorIcon(
                          size: 26,
                          PhosphorIconsFill.checkCircle,
                          color: BandiColor.foundationColor80(context),
                        )
                      : PhosphorIcon(
                          size: 26,
                          PhosphorIcons.checkCircle(),
                          color: BandiColor.foundationColor20(context),
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
                  'onboarding_agreement_condition_1'.tr(context),
                  style: BandiFont.bodySmall(context)?.copyWith(
                    color: BandiColor.foundationColor80(context),
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () {
                    setState(() {
                      option1Selected = !option1Selected;
                      allSelected = option1Selected &&
                          option2Selected &&
                          option3Selected &&
                          option4Selected;
                    });
                  },
                  child: option1Selected
                      ? PhosphorIcon(
                          size: 26,
                          PhosphorIconsFill.checkCircle,
                          color: BandiColor.foundationColor80(context),
                        )
                      : PhosphorIcon(
                          size: 26,
                          PhosphorIcons.checkCircle(),
                          color: BandiColor.foundationColor20(context),
                        ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: GestureDetector(
                  onTap: () {
                    // 웹뷰 또는 다이얼로그로 약관을 보여주는 로직을 구현
                    // "개인정보처리동의서"를 눌렀을 때
                    detailsOfAgreementPage(
                        context, privacy!, "onboarding_agreement_condition_2");
                  },
                  child: RichText(
                    text: TextSpan(
                      style: BandiFont.bodySmall(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                      children: (langCode == 'ko')
                          ? const [
                              TextSpan(text: '(필수) '),
                              TextSpan(
                                text: '개인정보처리동의서',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: '에 동의하시나요?'),
                            ]
                          : const [
                              TextSpan(text: '(Required) '),
                              TextSpan(text: 'Do you agree to the '),
                              TextSpan(
                                text: 'Privacy Policy?',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () {
                    setState(() {
                      option2Selected = !option2Selected;
                      allSelected = option1Selected &&
                          option2Selected &&
                          option3Selected &&
                          option4Selected;
                    });
                  },
                  child: option2Selected
                      ? PhosphorIcon(
                          size: 26,
                          PhosphorIconsFill.checkCircle,
                          color: BandiColor.foundationColor80(context),
                        )
                      : PhosphorIcon(
                          size: 26,
                          PhosphorIcons.checkCircle(),
                          color: BandiColor.foundationColor20(context),
                        ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: GestureDetector(
                  onTap: () {
                    // 웹뷰 또는 다이얼로그로 약관을 보여주는 로직을 구현
                    // "이용약관"을 눌렀을 때
                    detailsOfAgreementPage(
                        context, terms!, "onboarding_agreement_condition_3");
                  },
                  child: RichText(
                    text: TextSpan(
                      style: BandiFont.bodySmall(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                      children: (langCode == 'ko')
                          ? const [
                              TextSpan(text: '(필수) '),
                              TextSpan(
                                text: '이용약관',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: '에 동의하시나요?'),
                            ]
                          : const [
                              TextSpan(text: '(Required) '),
                              TextSpan(text: 'Do you agree to the '),
                              TextSpan(
                                text: 'Terms of Use?',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () {
                    setState(() {
                      option3Selected = !option3Selected;
                      allSelected = option1Selected &&
                          option2Selected &&
                          option3Selected &&
                          option4Selected;
                    });
                  },
                  child: option3Selected
                      ? PhosphorIcon(
                          size: 26,
                          PhosphorIconsFill.checkCircle,
                          color: BandiColor.foundationColor80(context),
                        )
                      : PhosphorIcon(
                          size: 26,
                          PhosphorIcons.checkCircle(),
                          color: BandiColor.foundationColor20(context),
                        ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: GestureDetector(
                  onTap: () {
                    // 웹뷰 또는 다이얼로그로 약관을 보여주는 로직을 구현
                    // "EULA"을 눌렀을 때
                    detailsOfAgreementPage(context, eulaContent!,
                        "onboarding_agreement_condition_4");
                  },
                  child: RichText(
                    text: TextSpan(
                      style: BandiFont.bodySmall(context)?.copyWith(
                        color: BandiColor.foundationColor80(context),
                      ),
                      children: (langCode == 'ko')
                          ? const [
                              TextSpan(text: '(필수) '),
                              TextSpan(
                                text: '최종사용자사용권계약서(EULA)',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: '에 동의하시나요?'),
                            ]
                          : const [
                              TextSpan(text: '(Required) '),
                              TextSpan(text: 'Do you agree to the '),
                              TextSpan(
                                text: 'End User License Agreement(EULA)',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () {
                    setState(() {
                      option4Selected = !option4Selected;
                      allSelected = option1Selected &&
                          option2Selected &&
                          option3Selected &&
                          option4Selected;
                    });
                  },
                  child: option4Selected
                      ? PhosphorIcon(
                          size: 26,
                          PhosphorIconsFill.checkCircle,
                          color: BandiColor.foundationColor80(context),
                        )
                      : PhosphorIcon(
                          size: 26,
                          PhosphorIcons.checkCircle(),
                          color: BandiColor.foundationColor20(context),
                        ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomPrimaryButton(
                title: 'onboarding_button_confirm'.tr(context),
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

Future detailsOfAgreementPage(
  BuildContext context,
  List<List<String>> data,
  String title,
) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return Scaffold(
        backgroundColor: BandiColor.neutralColor80(context).withOpacity(0.8),
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: BandiColor.transparent(context),
          title: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Text(
              title.tr(context),
              style: BandiFont.displaySmall(context)?.copyWith(
                color: BandiColor.foundationColor80(context),
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(
              size: 26,
              PhosphorIcons.caretLeft(),
              color: BandiColor.foundationColor80(context),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
                child: Column(
                  children: [
                    for (int i = 0; i < data.length; i++)
                      Column(
                        children: [
                          if (i != 0) const SizedBox(height: 80),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: WrappedKoreanText(
                              data[i][0],
                              style:
                                  BandiFont.headlineMedium(context)?.copyWith(
                                color: BandiColor.foundationColor80(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: 11),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: WrappedKoreanText(
                              data[i][1],
                              style: BandiFont.bodySmall(context)?.copyWith(
                                color: BandiColor.foundationColor80(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 150,
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: CustomPrimaryButton(
                  title: 'onboarding_button'.tr(context),
                  onPrimaryButtonPressed: () {
                    Navigator.pop(context);
                  },
                  disableButton: false,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
