// lib/views/user/account_management.dart
import 'dart:developer';

import 'package:bandi_official/localization/string_extention.dart';
import 'package:bandi_official/view/my_diary_list/controller/my_diary_list_controller.dart';
import 'package:bandi_official/view/settings/controller/user_view_controller.dart';
import 'package:bandi_official/view/settings/widget/frosted_settings_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../components/bottom_sheet/show_floating_confirm_sheet.dart';
import '../../components/button/primary_button.dart';
import '../../components/button/secondary_button.dart';
import '../mail/controller/mail_controller.dart';
import '../../controller/navigation_toggle_provider.dart';
import '../../controller/securestorage_controller.dart';
import '../../controller/user_info_controller.dart';
import '../../theme/custom_theme_data.dart';

class AccountManagement extends StatefulWidget {
  final Function(int) onNavigate;
  final VoidCallback onBack;

  const AccountManagement(
      {super.key, required this.onBack, required this.onNavigate});

  @override
  State<AccountManagement> createState() => _AccountManagementState();
}

class _AccountManagementState extends State<AccountManagement> {
  late SecureStorageProvider _storageProvider;

  @override
  void initState() {
    super.initState();
    _storageProvider =
        Provider.of<SecureStorageProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserInfoValueModel>(context);
    final navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);
    final mailController = Provider.of<MailController>(context);
    final storageProvider = Provider.of<SecureStorageProvider>(context);
    final myDiaryListController = Provider.of<MyDiaryListController>(context);
    final userViewController = Provider.of<UserViewController>(context);

    return FrostedSettingsScaffold(
        title: 'settings_my_account'.tr(context),
        onBack: widget.onBack,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            children: [
              _buildSettingOption(
                context: context,
                text: 'settings_my_account_email'.tr(context),
                onTap: () {},
                value: userInfo.userEmail,
              ),
              _buildSettingOption(
                context: context,
                text: 'settings_my_account_nickname'.tr(context),
                onTap: () => widget.onNavigate(2),
                value: userInfo.nickname,
                trailing: PhosphorIcon(
                  PhosphorIcons.caretRight(),
                  size: 16,
                  color: BandiColor.foundationColor20(context),
                ),
              ),
              Expanded(child: Container()),
              CustomPrimaryButton(
                title: 'settings_my_account_logout'.tr(context),
                onPrimaryButtonPressed: () async {
                  final ok = await showFloatingConfirmSheet(
                    context,
                    title: 'settings_my_account_logout_title'.tr(context),
                    description:
                        'settings_my_account_logout_content'.tr(context),
                    cancelText:
                        'settings_my_account_logout_button_1'.tr(context),
                    confirmText:
                        'settings_my_account_logout_button_2'.tr(context),
                  );

                  if (ok == true) {
                    try {
                      // 만약 상태가 비활성화되어 있으면 추가 작업 중지
                      if (!mounted) return;

                      // 로딩 화면 노출
                      navigationToggleProvider.selectIndex(100);
                      await Future.delayed(const Duration(seconds: 1));

                      // 로컬 저장소 데이터 삭제
                      mailController.deleteEveryMailDataFromLocal();
                      myDiaryListController.deleteEveryMyDiaryDataFromLocal();

                      // 로컬 저장소 로드 변수 초기화
                      mailController.initializeLoadValue();
                      myDiaryListController.initializeLoadValue();

                      // 설정 화면 위치 이동
                      userViewController.updateSettingValue(0);

                      // 구글 로그아웃
                      final GoogleSignIn googleSignIn = GoogleSignIn();
                      if (await googleSignIn.isSignedIn()) {
                        await googleSignIn.signOut();
                      }

                      // Firebase에서 로그아웃
                      await FirebaseAuth.instance.signOut();

                      // SecureStorage의 로그인 정보 삭제
                      await _storageProvider.clearLoginInfo();

                      // 사용자 정보 초기화
                      userInfo.clearUserInfo();

                      // 로그인 페이지로 이동
                      navigationToggleProvider.selectIndex(-1);
                    } catch (e) {
                      // 로그인 페이지로 이동
                      navigationToggleProvider.selectIndex(-1);
                    }
                  }
                },
                size: "small",
                disableButton: false,
              ),
              const SizedBox(
                height: 12,
              ),
              CustomSecondaryButton(
                title: 'settings_my_account_delete_account'.tr(context),
                onSecondaryButtonPressed: () async {
                  final ok = await showFloatingConfirmSheet(
                    context,
                    title:
                        'settings_my_account_delete_account_title'.tr(context),
                    description: 'settings_my_account_delete_account_content'
                        .tr(context),
                    cancelText: 'settings_my_account_delete_account_button_1'
                        .tr(context),
                    confirmText: 'settings_my_account_delete_account_button_2'
                        .tr(context),
                  );
                  if (ok == true) {
                    try {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        // 로딩 화면 노출
                        navigationToggleProvider.selectIndex(100);
                        await Future.delayed(const Duration(seconds: 1));

                        // 로컬 저장소 데이터 삭제
                        mailController.deleteEveryMailDataFromLocal();
                        myDiaryListController.deleteEveryMyDiaryDataFromLocal();

                        // 로컬 저장소 로드 변수 초기화
                        mailController.initializeLoadValue();
                        myDiaryListController.initializeLoadValue();

                        // 설정 화면 위치 이동
                        userViewController.updateSettingValue(0);

                        // 사용자 정보 초기화
                        userInfo.clearUserInfo();

                        // firebase DB 삭제
                        await deleteUserData(user.uid);

                        // SecureStorage의 로그인 정보 삭제
                        await storageProvider.clearLoginInfo();

                        // 계정 삭제를 위한 재인증 + 삭제 실행
                        await reauthenticateAndDeleteUser();

                        // 로그인 페이지로 이동
                        navigationToggleProvider.selectIndex(-1);
                      }
                    } catch (e) {
                      // 로그인 페이지로 이동
                      navigationToggleProvider.selectIndex(-1);
                    }
                  }
                },
                disableButton: false,
              ),
            ],
          ),
        ));
  }

// 사용자 데이터 삭제 함수 (프로필 및 모든 하위 컬렉션 삭제)
  Future<void> deleteUserData(String userId) async {
    final firestore = FirebaseFirestore.instance;
    final userDocRef = firestore.collection('users').doc(userId);

    try {
      // 1. 하위 컬렉션 삭제 (Batch 적용)
      // letters, notifications, otherDiary 컬렉션을 모두 비웁니다.
      await _deleteCollectionInBatch(
          firestore, userDocRef.collection('letters'));
      await _deleteCollectionInBatch(
          firestore, userDocRef.collection('notifications'));

      // [추가] otherDiary 컬렉션 삭제
      await _deleteCollectionInBatch(
          firestore, userDocRef.collection('otherDiary'));

      // 2. 사용자 문서(프로필 등) 삭제
      await userDocRef.delete();

      log('User profile and all sub-collections (letters, notifications, otherDiary) deleted successfully.');
    } catch (e) {
      log('Error deleting user data: $e');
      rethrow;
    }
  }

  // (기존 헬퍼 함수 유지) 배치 삭제 함수
  Future<void> _deleteCollectionInBatch(
      FirebaseFirestore firestore, CollectionReference collectionRef) async {
    final snapshots = await collectionRef.get();
    if (snapshots.docs.isEmpty) return;

    // 500개씩 끊어서 처리 (Firestore Batch 제한 준수)
    for (var i = 0; i < snapshots.docs.length; i += 500) {
      final batch = firestore.batch();
      final end =
          (i + 500 < snapshots.docs.length) ? i + 500 : snapshots.docs.length;
      final chunk = snapshots.docs.sublist(i, end);

      for (final doc in chunk) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<void> reauthenticateAndDeleteUser() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user == null) {
      log("No user is currently signed in.");
      return;
    }

    try {
      // 로그인 제공자 확인
      final providerId = user.providerData.first.providerId;

      if (providerId == 'google.com') {
        // Google 로그인 재인증
        final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
        if (gUser == null) {
          log("Google login cancelled by user.");
          return;
        }

        final GoogleSignInAuthentication gAuth = await gUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );

        await user.reauthenticateWithCredential(credential);
        log("Google reauthentication successful.");
      } else if (providerId == 'apple.com') {
        // 🔹 Apple 로그인 재인증
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName
          ],
        );

        final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        await user.reauthenticateWithCredential(oauthCredential);
        log("Apple reauthentication successful.");
      } else {
        log("Unsupported provider: $providerId");
        return;
      }

      // ✅ 재인증 후 계정 삭제
      await user.delete();
      log("User account deleted successfully.");
    } catch (e) {
      log("Error during reauthentication or deletion: $e");
    }
  }

  Widget _buildSettingOption({
    context,
    required String text,
    required String value,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        text,
                        style: BandiFont.titleSmall(context)?.copyWith(
                          color: BandiColor.foundationColor90(context),
                        ),
                      ),
                      if (trailing != null) trailing
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    value,
                    style: BandiFont.labelSmall(context)?.copyWith(
                      color: BandiColor.foundationColor60(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          height: 0,
          color: BandiColor.foundationColor04(context),
          thickness: 1,
        ),
      ],
    );
  }
}
