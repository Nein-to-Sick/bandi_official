import 'dart:developer';

import 'package:bandi_official/controller/emotion_provider.dart';
import 'package:bandi_official/controller/permission_controller.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/user/eula_agreement.dart';
import 'package:bandi_official/view/user/privacy_policy.dart';
import 'package:bandi_official/view/user/settings_home.dart';
import 'package:bandi_official/view/user/terms_of_use.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/navigation_toggle_provider.dart';
import 'account_management.dart';
import 'company_info.dart';
import 'nickname_change.dart';
import 'oss_licenses.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> with WidgetsBindingObserver {
  // 0: 설정 홈, 1: 계정 관리, 2: 닉네임 변경, 3: 오픈 라이센스,
  // 4: 이용 약관, 5: 개인정보, 6: 사업자 정보, 7: 오픈 라이센스 상세
  // 8: 최종 사용자 사용권 계약서 (EULA)
  int settings = 0;

  late bool notificationTemp;
  late PermissionController permissionController2;

  // 오픈 라이센스 상세 정보를 담을 변수
  Map<String, dynamic>? selectedLicenseData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    permissionController2 =
        Provider.of<PermissionController>(context, listen: false);
    notificationTemp = permissionController2.getNotificationPermissionState();
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
            showSnackBar('alarm_permission_approved'.tr(context));
          } else {
            showSnackBar('alarm_permission_denied'.tr(context));
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
          style: BandiFont.headlineMedium(context)?.copyWith(
            color: BandiColor.neutralColor90(context),
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

  // OssLicensesScreen -> UserView로 라이센스 정보를 넘겨주어 상세 화면을 띄우는 함수
  void onNavigateLicenseDetail(Map<String, dynamic> licenseData) {
    setState(() {
      selectedLicenseData = licenseData;
      settings = 7; // 오픈 라이센스 상세 화면
    });
  }

  @override
  Widget build(BuildContext context) {
    var navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);

    // settings가 0 이상이면 네비게이션 토글바 숨기기
    if (settings > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationToggleProvider.selectIndex(-2);
      });
    }

    switch (settings) {
      case 0:
        return SettingsHome(
          onNavigate: (int index) {
            setState(() {
              settings = index;
            });
          },
        );
      case 1:
        return AccountManagement(
          onNavigate: (int index) {
            setState(() {
              settings = index;
            });
          },
          onBack: () {
            setState(() {
              settings = 0;
            });
            navigationToggleProvider.selectIndex(3);
          },
        );
      case 2:
        return NicknameChange(
          onBack: () {
            setState(() {
              settings = 1;
            });
          },
        );
      case 3:
        // 오픈 라이센스 목록
        return OssLicensesScreen(
          onBack: () {
            setState(() {
              settings = 0;
            });
            navigationToggleProvider.selectIndex(3);
          },
          // 상세 라이센스 페이지로 이동하기 위한 콜백
          onNavigateLicenseDetail: onNavigateLicenseDetail,
        );
      case 4:
        return TermsOfUseScreen(
          onBack: () {
            setState(() {
              settings = 0;
            });
            navigationToggleProvider.selectIndex(3);
          },
        );
      case 5:
        return PrivacyPolicyScreen(
          onBack: () {
            setState(() {
              settings = 0;
            });
            navigationToggleProvider.selectIndex(3);
          },
        );
      case 6:
        return CompanyInfoScreen(
          onBack: () {
            setState(() {
              settings = 0;
            });
            navigationToggleProvider.selectIndex(3);
          },
        );
      case 7:
        return MiscOssLicenseSingle(
          onBack: () {
            // 상세화면 뒤로가기 시 다시 라이센스 목록 화면(3)으로
            setState(() {
              settings = 3;
            });
          },
          // selectedLicenseData가 null일 경우 대비
          name: selectedLicenseData?['name'] ?? '',
          version: selectedLicenseData?['version'] ?? '',
          description: selectedLicenseData?['description'] ?? '',
          licenseText: selectedLicenseData?['license'] ?? '',
          homepage: selectedLicenseData?['homepage'] ?? '',
        );
      case 8:
        return EulaAgreementScreen(
          onBack: () {
            setState(() {
              settings = 0;
            });
            navigationToggleProvider.selectIndex(3);
          },
        );

      default:
        return SettingsHome(onNavigate: (index) {});
    }
  }
}
