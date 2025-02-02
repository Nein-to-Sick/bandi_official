import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bandi_official/components/button/secondary_button.dart';
import 'package:bandi_official/components/no_reuse/reset_dialogue.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/controller/permission_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wrapped_korean_text/wrapped_korean_text.dart';

import '../../components/button/primary_button.dart';
import '../../components/field/field.dart';
import '../../controller/navigation_toggle_provider.dart';
import '../../controller/securestorage_controller.dart';
import '../../controller/user_info_controller.dart';
import '../../model/oss_licenses_model.dart';
import '../../model/settingsInfos.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> with WidgetsBindingObserver {
  int settings = 0; //0 = home, 1 = 계정관리, 2 = 닉네임 변경, 3
  String newNickname = '';
  late bool notificationTemp;
  late PermissionController permissionController2;
  late SecureStorageProvider _storageProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    permissionController2 =
        Provider.of<PermissionController>(context, listen: false);

    notificationTemp = permissionController2.getNotificationPermissionState();
    _storageProvider =
        Provider.of<SecureStorageProvider>(context, listen: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 앱이 포그라운드로 돌아왔을 때 권한 확인
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      permissionController2.checkNotificationPermission().then((isGranted) {
        if (context.mounted && notificationTemp != isGranted) {
          notificationTemp = isGranted;

          if (isGranted) {
            showSnackBar('알림 권한이 허용되었습니다.');
          } else {
            showSnackBar('알림 권한이 허용되지 않았습니다.');
          }
        }
      });
    } else if (state == AppLifecycleState.paused) {
      log('background');
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 3,
        content: Text(
          message,
          style: BandiFont.displaySmall(context)?.copyWith(
            color: BandiColor.neutralColor100(context),
          ),
        ),
        margin: EdgeInsets.only(
          left: 25.0,
          right: 25.0,
          bottom: MediaQuery.of(context).size.height * 0.1,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BandiEffects.radius(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);
    var userInfo = Provider.of<UserInfoValueModel>(context);
    final permissionController = Provider.of<PermissionController>(context);
    final mailController = Provider.of<MailController>(context);

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
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
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
              autotext: 0,
            ),
            const SizedBox(height: 8),
            buildSettingOption(
              icon: PhosphorIcons.bell(),
              text: "알림 설정",
              onTap: () {},
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (permissionController.getNotificationPermissionState())
                        ? "설정됨"
                        : "해제됨",
                    style: BandiFont.bodyMedium(context)?.copyWith(
                      color: BandiColor.foundationColor10(context),
                    ),
                  ),
                  const SizedBox(width: 12.5),
                  Switch(
                    value:
                        permissionController.getNotificationPermissionState(),
                    onChanged: (bool value) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomResetDialogue(
                              text: '알림 설정은 시스템 설정에서 진행됩니다.\n시스템 설정으로 이동하시겠나요?',
                              onYesFunction: () {
                                Navigator.pop(context);
                                openAppSettings();
                              },
                              onNoFunction: () {
                                Navigator.pop(context);
                              },
                            );
                          });
                    },
                    activeColor: BandiColor.accentColorYellow(context),
                    activeTrackColor: BandiColor.neutralColor100(context),
                    inactiveThumbColor: BandiColor.foundationColor80(context),
                    inactiveTrackColor: BandiColor.foundationColor40(context),
                  ),
                ],
              ),
              autotext: 0,
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
              autotext: 0,
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
              autotext: 0,
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
              autotext: 0,
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
              autotext: 0,
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
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
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
                userInfo.userEmail.isNotEmpty ? userInfo.userEmail : "이메일 없음",
                style: BandiFont.bodyMedium(context)?.copyWith(
                  color: BandiColor.foundationColor40(context),
                ),
              ),
              autotext: 1,
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
                    userInfo.nickname.isNotEmpty ? userInfo.nickname : "닉네임 없음",
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
              autotext: 1,
            ),
            const SizedBox(
              height: 34,
            ),
            CustomPrimaryButton(
              title: '로그아웃',
              onPrimaryButtonPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomResetDialogue(
                      text: '로그아웃 하시겠나요?',
                      onYesFunction: () async {
                        Navigator.pop(context);

                        // 만약 상태가 비활성화되어 있으면 추가 작업 중지
                        if (!mounted) return;
                        log("1");

                        // 로딩 화면 노출
                        navigationToggleProvider.selectIndex(100);
                        await Future.delayed(const Duration(seconds: 1));

                        log("2");
                        // if (!mounted) return;

                        // 구글 로그아웃
                        final GoogleSignIn googleSignIn = GoogleSignIn();
                        if (await googleSignIn.isSignedIn()) {
                          await googleSignIn.signOut();
                        }

                        log("3");
                        // if (!mounted) return;

                        // Firebase에서 로그아웃
                        await FirebaseAuth.instance.signOut();

                        // SecureStorage의 로그인 정보 삭제
                        await _storageProvider.clearLoginInfo();

                        // 사용자 정보 초기화
                        userInfo.clearUserInfo();

                        // 로그인 페이지로 이동
                        navigationToggleProvider.selectIndex(-1);
                        log("로그아웃");
                      },
                      onNoFunction: () {
                        if (mounted) {
                          Navigator.pop(context);

                          log("8");
                        }
                      },
                    );
                  },
                );
              },
              disableButton: false,
            ),
            const SizedBox(
              height: 12,
            ),
            CustomSecondaryButton(
              title: '계정 탈퇴',
              onSecondaryButtonPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomResetDialogue(
                      text: '계정 탈퇴를 하시겠나요?\n탈퇴한 계정은 복구할 수 없어요.',
                      onYesFunction: () async {
                        Navigator.pop(context);
                        try {
                          User? user = FirebaseAuth.instance.currentUser;

                          if (user != null) {
                            final storageProvider =
                                Provider.of<SecureStorageProvider>(context,
                                    listen: false);

                            // 로딩 화면 노출
                            navigationToggleProvider.selectIndex(100);
                            await Future.delayed(const Duration(seconds: 1));

                            // 로컬 저장소 데이터 삭제
                            mailController.deleteEveryMailDataFromLocal();

                            // Firestore에서 사용자 데이터 삭제
                            final userCollection =
                                FirebaseFirestore.instance.collection("users");
                            final userDataCollection = FirebaseFirestore
                                .instance
                                .collection("userDataCollection");

                            // Firestore 데이터 삭제
                            await Future.wait([
                              userCollection.doc(user.uid).delete(),
                              userDataCollection.doc(user.uid).delete(),
                            ]);

                            // Firebase에서 사용자 삭제
                            await user.delete();

                            // SecureStorage의 로그인 정보 삭제
                            await storageProvider.clearLoginInfo();

                            // 사용자 정보 초기화 및 로그인 페이지로 이동

                            userInfo.clearUserInfo();
                            navigationToggleProvider
                                .selectIndex(-1); // 로그인 페이지로 이동

                            log("계정 탈퇴 완료");
                          }
                        } catch (e) {
                          log("Error deleting account: $e");
                          // 오류가 발생한 경우 로딩 화면을 닫고 오류 메시지를 표시할 수 있습니다.
                          if (mounted) {
                            navigationToggleProvider
                                .selectIndex(-1); // 로그인 페이지로 이동
                          }
                        }
                      },
                      onNoFunction: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              disableButton: false,
            ),
          ],
        ),
      ),
    );

    void updateNickname(BuildContext context, String newNickname) async {
      // Firebase Firestore에서 현재 사용자 문서를 업데이트
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'nickname': newNickname,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // 설정 화면으로 돌아감
      settings = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationToggleProvider.selectIndex(-2);
      });
    }

    Widget changeNickName = Scaffold(
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
              settings = 1;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              navigationToggleProvider.selectIndex(-2);
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
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            String nickname =
                Provider.of<UserInfoValueModel>(context, listen: false)
                    .nickname;

            return ListView(
              children: [
                const SizedBox(height: 17),
                CustomField(
                  initialValue: nickname,
                  onChanged: (value) {
                    setState(() {
                      nickname = value;
                    });
                    // 프로바이더의 닉네임을 업데이트
                    Provider.of<UserInfoValueModel>(context, listen: false)
                        .updateNickname(value);
                  },
                  isPassword: false,
                  isEnabled: true,
                ),
                const SizedBox(height: 17),
                CustomPrimaryButton(
                  title: '확인',
                  onPrimaryButtonPressed: () {
                    if (nickname.isNotEmpty) {
                      // 비동기 작업을 호출하는 동기 함수로 래핑
                      updateNickname(context, nickname);
                    }
                  },
                  disableButton: nickname.isEmpty,
                ),
                const SizedBox(height: 16),
              ],
            );
          },
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
          padding: const EdgeInsets.symmetric(vertical: 16),
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
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
        child: ListView.builder(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.1),
          physics: const BouncingScrollPhysics(),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MiscOssLicenseSingle(
                          name: package.name,
                          version: package.version,
                          description: package.description,
                          licenseText: package.license ?? '',
                          homepage: package.homepage ?? '',
                        ),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1.0,
                  color: BandiColor.foundationColor10(context),
                ),
              ],
            );
          },
        ),
      ),
    );

    Widget termsOfUse = Scaffold(
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
              "이용약관",
              style: BandiFont.displaySmall(context)?.copyWith(
                color: BandiColor.foundationColor80(context),
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23.0),
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
                          style: BandiFont.headlineMedium(context)?.copyWith(
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
                const SizedBox(
                  height: 50,
                )
              ],
            ),
          ),
        ));

    Widget privacypolicy = Scaffold(
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
              "개인정보 처리방침",
              style: BandiFont.displaySmall(context)?.copyWith(
                color: BandiColor.foundationColor80(context),
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23.0),
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
                          style: BandiFont.headlineMedium(context)?.copyWith(
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
                const SizedBox(height: 60),
              ],
            ),
          ),
        ));

    Widget companyInfoView = Scaffold(
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
              "사업자 정보",
              style: BandiFont.displaySmall(context)?.copyWith(
                color: BandiColor.foundationColor80(context),
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23.0),
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
                const SizedBox(height: 50),
              ],
            ),
          ),
        ));

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
                            : changeNickName;
  }

  //ossLicensesScreen

  Widget buildSettingOption({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
    Widget? trailing,
    required int autotext,
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
            (autotext == 1)
                ? Text(
                    text,
                    style: BandiFont.bodyMedium(context)?.copyWith(
                      color: BandiColor.foundationColor80(context),
                    ),
                  )
                : AutoSizeText(
                    text,
                    style: BandiFont.bodyMedium(context)?.copyWith(
                      color: BandiColor.foundationColor80(context),
                    ),
                    maxLines: 1,
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

class MiscOssLicenseSingle extends StatelessWidget {
  final String name;
  final String version;
  final String description;
  final String licenseText;
  final String homepage;

  const MiscOssLicenseSingle({
    super.key,
    required this.name,
    required this.version,
    required this.description,
    required this.licenseText,
    required this.homepage,
  });

  String _bodyText() {
    return licenseText.split('\n').map((line) {
      if (line.startsWith('//')) line = line.substring(2);
      line = line.trim();
      return line;
    }).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "오픈소스 라이선스",
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text(name),
              subtitle: Text('version : $version'),
            ),
            if (description.isNotEmpty)
              Padding(
                  padding:
                      const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                  child: Text(description)),
            const Divider(),
            Padding(
              padding:
                  const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
              child: Text(
                _bodyText(),
                // style: Theme.of(context).textTheme.bodyText2
              ),
            ),
            const Divider(),
            // ListTile(
            //     title: Text('Homepage'),
            //     subtitle: Text(homepage),
            //     onTap: () async {
            //       if (await canLaunch(homepage)) {
            //         await launch(homepage);
            //       } else {
            //         throw 'Could not launch $homepage';
            //       }
            //     }),
          ],
        ),
      ),
    );
  }
}
