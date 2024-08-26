import 'package:bandi_official/components/button/secondary_button.dart';
import 'package:bandi_official/components/field/custom_text_field.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wrapped_korean_text/wrapped_korean_text.dart';

import '../../components/appbar/appbar.dart';
import '../../components/button/primary_button.dart';
import '../../controller/navigation_toggle_provider.dart';
import '../../model/oss_licenses_model.dart';
import '../../model/settingsInfos.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  int settings = 0; //0 = home, 1 = 계정관리, 2 = 닉네임 변경, 3
  bool _isSwitched = false;

  @override
  Widget build(BuildContext context) {
    var navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);

    Widget settingHome = Scaffold(
      backgroundColor: BandiColor.neutralColor80(context).withOpacity(0.8),
      // custom appbar 일단 임시로 leading icon 변경
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BandiColor.transparent(context),
        title: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Text(
            "설정",
            style: BandiFont.displaySmall(context)?.copyWith(
              color: BandiColor.foundationColor80(context),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 23.0),
        child: ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
          ),
          children: [
            buildSettingOption(
              icon: PhosphorIcons.user(),
              text: "계정 관리",
              onTap: () {
                setState(() {
                  settings = 1;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  navigationToggleProvider.selectIndex(-2);
                });
              },
            ),
            const SizedBox(height: 8),
            buildSettingOption(
              icon: PhosphorIcons.bell(),
              text: "알림 설정",
              onTap: () {
                setState(() {
                  _isSwitched = !_isSwitched;
                });
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "00:00",
                    style: BandiFont.bodyMedium(context)?.copyWith(
                      color: BandiColor.foundationColor10(context),
                    ),
                  ),
                  const SizedBox(width: 12.5),
                  Switch(
                    value: _isSwitched,
                    onChanged: (bool value) {
                      setState(() {
                        _isSwitched = value;
                      });
                    },
                    activeColor: BandiColor.accentColorYellow(context),
                    activeTrackColor: BandiColor.neutralColor100(context),
                    inactiveThumbColor: BandiColor.foundationColor80(context),
                    inactiveTrackColor: BandiColor.foundationColor40(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Divider(
              height: 1.0,
              color: BandiColor.foundationColor10(context),
            ),
            const SizedBox(height: 16),
            buildSettingOption(
              text: "오픈 라이센스",
              onTap: () {
                setState(() {
                  settings = 2;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  navigationToggleProvider.selectIndex(-2);
                });
              },
            ),
            const SizedBox(height: 8),
            buildSettingOption(
              text: "이용 약관",
              onTap: () {
                setState(() {
                  settings = 3;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  navigationToggleProvider.selectIndex(-2);
                });
              },
            ),
            const SizedBox(height: 8),
            buildSettingOption(
              text: "개인정보 처리방침",
              onTap: () {
                setState(() {
                  settings = 4;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  navigationToggleProvider.selectIndex(-2);
                });
              },
            ),
            const SizedBox(height: 8),
            buildSettingOption(
              text: "사업자 정보",
              onTap: () {
                setState(() {
                  settings = 5;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  navigationToggleProvider.selectIndex(-2);
                });
              },
            ),
          ],
        ),
      ),
    );

    Widget manageAccount = Scaffold(
      backgroundColor: BandiColor.neutralColor80(context).withOpacity(0.8),
      // custom appbar 일단 임시로 leading icon 변경
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BandiColor.transparent(context),
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.caretLeft(),
          ),
          onPressed: () {
            setState(() {
              settings = 0;
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              navigationToggleProvider.selectIndex(3);
            });
          },
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Text(
            "계정 관리",
            style: BandiFont.displaySmall(context)?.copyWith(
              color: BandiColor.foundationColor80(context),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 23.0),
        child: ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
          ),
          children: [
            buildSettingOption(
              icon: PhosphorIcons.at(),
              text: "이메일",
              onTap: () {},
              trailing: Text(
                "xxx.gmail.com",
                style: BandiFont.bodyMedium(context)?.copyWith(
                  color: BandiColor.foundationColor40(context),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Divider(
              height: 1.0,
              color: BandiColor.foundationColor10(context),
            ),
            const SizedBox(height: 10),
            buildSettingOption(
              icon: PhosphorIcons.user(),
              text: "닉네임",
              onTap: () {
                setState(() {
                  settings = 6;
                });
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "반디",
                    style: BandiFont.bodyMedium(context)?.copyWith(
                      color: BandiColor.foundationColor60(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    PhosphorIcons.caretRight(),
                    color: BandiColor.foundationColor20(context),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 34,
            ),
            CustomPrimaryButton(
              title: '로그아웃',
              onPrimaryButtonPressed: () {},
              disableButton: false,
            ),
            const SizedBox(
              height: 12,
            ),
            CustomSecondaryButton(
              title: '계정 탈퇴',
              onSecondaryButtonPressed: () {},
              disableButton: true,
            ),
          ],
        ),
      ),
    );

    Widget ossLicensesScreen = Scaffold(
      backgroundColor: BandiColor.neutralColor80(context).withOpacity(0.8),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BandiColor.transparent(context),
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.caretLeft(),
          ),
          onPressed: () {
            setState(() {
              settings = 0;
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              navigationToggleProvider.selectIndex(3);
            });
          },
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Text(
            "오픈 라이센스",
            style: BandiFont.displaySmall(context)?.copyWith(
              color: BandiColor.foundationColor80(context),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 23.0),
        child: Expanded(
          child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: ossLicenses.length,
              itemBuilder: (context, index) {
                final package = ossLicenses[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        package.name,
                        style: BandiFont.bodyMedium(context)?.copyWith(
                          color: BandiColor.foundationColor80(context),
                        ),
                      ),
                      subtitle: Text(
                        package.description,
                        style: BandiFont.bodySmall(context)?.copyWith(
                          color: BandiColor.foundationColor20(context),
                        ),
                      ),
                      onTap: () {
                        // 패키지 상세 페이지로 이동
                      },
                    ),
                    Divider(
                      height: 1.0,
                      color: BandiColor.foundationColor10(context),
                    ),
                  ],
                );
              }),
        ),
      ),

      // Column(
      //   children: [
      //     Padding(
      //       padding: EdgeInsets.symmetric(horizontal: 23.0),
      //       child: ListView.builder(
      //         padding: EdgeInsets.only(
      //           bottom: MediaQuery.of(context).size.height * 0.1,
      //         ),
      //         itemCount: ossLicenses.length,
      //         itemBuilder: (context, index) {
      //           final package = ossLicenses[index];
      //           return Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               ListTile(
      //                 title: Text(
      //                   package.name,
      //                   style: BandiFont.bodyMedium(context)?.copyWith(
      //                     color: BandiColor.foundationColor40(context),
      //                   ),
      //                 ),
      //                 subtitle: Text(
      //                   package.description,
      //                   style: BandiFont.bodySmall(context)?.copyWith(
      //                     color: BandiColor.foundationColor20(context),
      //                   ),
      //                 ),
      //                 onTap: () {
      //                   // 패키지 상세 페이지로 이동
      //                 },
      //               ),
      //               Divider(
      //                 height: 1.0,
      //                 color: BandiColor.foundationColor10(context),
      //               ),
      //             ],
      //           );
      //         },
      //       ),
      //     ),
      //   ],
      // ),
    );

    Widget termsOfUse = Scaffold(
        backgroundColor: BandiColor.neutralColor80(context).withOpacity(0.8),
        // custom appbar 일단 임시로 leading icon 변경
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: BandiColor.transparent(context),
          // leading: IconButton(
          //   icon: Icon(
          //     PhosphorIcons.caretLeft(),
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       settings = 0;
          //     });

          //     WidgetsBinding.instance.addPostFrameCallback((_) {
          //       navigationToggleProvider.selectIndex(3);
          //     });
          //   },
          // ),
          title: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Text(
              "이용약관",
              style: BandiFont.displaySmall(context)?.copyWith(
                color: BandiColor.foundationColor80(context),
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
                padding: EdgeInsets.symmetric(horizontal: 23.0),
                child: Column(
                  children: [
                    for (int i = 0; i < CompanyInfo().termsOfUse.length; i++)
                      Column(
                        children: [
                          if (i != 0) const SizedBox(height: 80),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: WrappedKoreanText(
                              CompanyInfo().termsOfUse[i][0],
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
                              CompanyInfo().termsOfUse[i][1],
                              style: BandiFont.bodySmall(context)?.copyWith(
                                color: BandiColor.foundationColor80(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 10),
            CustomPrimaryButton(
              title: '닫기',
              onPrimaryButtonPressed: () {
                setState(() {
                  settings = 0;
                });

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  navigationToggleProvider.selectIndex(3);
                });
              },
              disableButton: false,
            ),
            const SizedBox(height: 32),
          ],
        ));

    Widget privacypolicy = Scaffold(
        backgroundColor: BandiColor.neutralColor80(context).withOpacity(0.8),
        // custom appbar 일단 임시로 leading icon 변경
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: BandiColor.transparent(context),
          // leading: IconButton(
          //   icon: Icon(
          //     PhosphorIcons.caretLeft(),
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       settings = 0;
          //     });

          //     WidgetsBinding.instance.addPostFrameCallback((_) {
          //       navigationToggleProvider.selectIndex(3);
          //     });
          //   },
          // ),
          title: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Text(
              "개인정보 처리방침",
              style: BandiFont.displaySmall(context)?.copyWith(
                color: BandiColor.foundationColor80(context),
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
                padding: EdgeInsets.symmetric(horizontal: 23.0),
                child: Column(
                  children: [
                    for (int i = 0; i < CompanyInfo().privacyPolicy.length; i++)
                      Column(
                        children: [
                          if (i != 0) const SizedBox(height: 44),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: WrappedKoreanText(
                              CompanyInfo().privacyPolicy[i][0],
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
                              CompanyInfo().privacyPolicy[i][1],
                              style: BandiFont.bodySmall(context)?.copyWith(
                                color: BandiColor.foundationColor80(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: WrappedKoreanText(
                        CompanyInfo().privacyPolicyExplain,
                        style: BandiFont.bodySmall(context)?.copyWith(
                          color: BandiColor.foundationColor80(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 10),
            CustomPrimaryButton(
              title: '닫기',
              onPrimaryButtonPressed: () {
                setState(() {
                  settings = 0;
                });

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  navigationToggleProvider.selectIndex(3);
                });
              },
              disableButton: false,
            ),
            const SizedBox(height: 32),
          ],
        ));

    Widget companyInfoView = Scaffold(
        backgroundColor: BandiColor.neutralColor80(context).withOpacity(0.8),
        // custom appbar 일단 임시로 leading icon 변경
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: BandiColor.transparent(context),
          // leading: IconButton(
          //   icon: Icon(
          //     PhosphorIcons.caretLeft(),
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       settings = 0;
          //     });

          //     WidgetsBinding.instance.addPostFrameCallback((_) {
          //       navigationToggleProvider.selectIndex(3);
          //     });
          //   },
          // ),
          title: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Text(
              "사업자 정보",
              style: BandiFont.displaySmall(context)?.copyWith(
                color: BandiColor.foundationColor80(context),
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
                  padding: EdgeInsets.symmetric(horizontal: 23.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CompanyInfo().companyName,
                        style: BandiFont.headlineLarge(context)?.copyWith(
                          color: BandiColor.foundationColor80(context),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Divider(
                        height: 1.0,
                        color: BandiColor.foundationColor10(context),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "대표",
                        style: BandiFont.headlineMedium(context)?.copyWith(
                          color: BandiColor.foundationColor80(context),
                        ),
                      ),
                      Text(
                        CompanyInfo().ceo,
                        style: BandiFont.bodySmall(context)?.copyWith(
                          color: BandiColor.foundationColor80(context),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Divider(
                        height: 1.0,
                        color: BandiColor.foundationColor10(context),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "주소",
                        style: BandiFont.headlineMedium(context)?.copyWith(
                          color: BandiColor.foundationColor80(context),
                        ),
                      ),
                      Text(
                        CompanyInfo().address,
                        style: BandiFont.bodySmall(context)?.copyWith(
                          color: BandiColor.foundationColor80(context),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Divider(
                        height: 1.0,
                        color: BandiColor.foundationColor10(context),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "전화",
                        style: BandiFont.headlineMedium(context)?.copyWith(
                          color: BandiColor.foundationColor80(context),
                        ),
                      ),
                      Text(
                        CompanyInfo().pn,
                        style: BandiFont.bodySmall(context)?.copyWith(
                          color: BandiColor.foundationColor80(context),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Divider(
                        height: 1.0,
                        color: BandiColor.foundationColor10(context),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "이메일",
                        style: BandiFont.headlineMedium(context)?.copyWith(
                          color: BandiColor.foundationColor80(context),
                        ),
                      ),
                      Text(
                        CompanyInfo().email,
                        style: BandiFont.bodySmall(context)?.copyWith(
                          color: BandiColor.foundationColor80(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            CustomPrimaryButton(
              title: '닫기',
              onPrimaryButtonPressed: () {
                setState(() {
                  settings = 0;
                });

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  navigationToggleProvider.selectIndex(3);
                });
              },
              disableButton: false,
            ),
            const SizedBox(height: 32),
          ],
        ));

    Widget changeNickname = Scaffold(
      backgroundColor: BandiColor.neutralColor80(context).withOpacity(0.8),
      // custom appbar 일단 임시로 leading icon 변경
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BandiColor.transparent(context),
        leading: IconButton(
          icon: Icon(
            PhosphorIcons.caretLeft(),
          ),
          onPressed: () {
            setState(() {
              settings = 1;
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              navigationToggleProvider.selectIndex(3);
            });
          },
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Text(
            "닉네임 변경",
            style: BandiFont.displaySmall(context)?.copyWith(
              color: BandiColor.foundationColor80(context),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 23.0),
        child: ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
          ),
          children: [
            Expanded(child: CustomTextField()),
          ],
        ),
      ),
    );

    return settings == 0
        ? settingHome
        : settings == 1
            ? manageAccount
            : settings == 2
                ? ossLicensesScreen
                : settings == 3
                    ? termsOfUse
                    : settings == 4
                        ? privacypolicy
                        : settings == 5
                            ? companyInfoView
                            : changeNickname;
  }

  //ossLicensesScreen

  Widget buildSettingOption({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onTap,
      child: SizedBox(
        height: 42.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 24,
                color: BandiColor.foundationColor80(context),
              ),
            if (icon != null) const SizedBox(width: 8),
            Text(
              text,
              style: BandiFont.bodyMedium(context)?.copyWith(
                color: BandiColor.foundationColor80(context),
              ),
            ),
            if (trailing != null) ...[
              const Spacer(),
              trailing,
            ] else ...[
              const Spacer(),
              Icon(
                PhosphorIcons.caretRight(),
                size: 24,
                color: BandiColor.foundationColor20(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Future<void> _showCalendarBottomSheet(BuildContext context) async {
  //   await showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: const EdgeInsets.only(left: 18, right: 18, top: 23),
  //         // child: CupertinoTimerPicker(onTimerDurationChanged: onTimerDurationChanged)
  //       );
  //     },
  //   );
  // }
}
