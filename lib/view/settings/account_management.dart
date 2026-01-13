// lib/views/user/account_management.dart
import 'dart:developer';

import 'package:bandi_official/string_extention.dart';
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
import '../tutorial/controller/tutorial_controller.dart';

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
  late TutorialController _tutorial;

  @override
  void initState() {
    super.initState();
    _storageProvider =
        Provider.of<SecureStorageProvider>(context, listen: false);
    _tutorial = Provider.of<TutorialController>(context, listen: false); // ✅ 미리 잡기

  }

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<UserInfoValueModel>(context);
    final navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);
    final mailController = Provider.of<MailController>(context);
    final storageProvider = Provider.of<SecureStorageProvider>(context);

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
                    title: '정말로 로그아웃 하시겠어요?',
                    description: '위로가 필요하면 언제든 다시 로그인해 주세요.',
                    cancelText: '취소',
                    confirmText: '로그아웃',
                  );

                  if (ok == true) {
                    // 만약 상태가 비활성화되어 있으면 추가 작업 중지
                    if (!mounted) return;

                    // 로딩 화면 노출
                    navigationToggleProvider.selectIndex(100);
                    await Future.delayed(const Duration(seconds: 1));

                    // if (!mounted) return;

                    // 구글 로그아웃
                    final GoogleSignIn googleSignIn = GoogleSignIn();
                    if (await googleSignIn.isSignedIn()) {
                      await googleSignIn.signOut();
                    }

                    // if (!mounted) return;

                    // Firebase에서 로그아웃
                    await FirebaseAuth.instance.signOut();

                    // SecureStorage의 로그인 정보 삭제
                    await _storageProvider.clearLoginInfo();

                    // 사용자 정보 초기화
                    userInfo.clearUserInfo();

                    // 로그인 페이지로 이동
                    navigationToggleProvider.selectIndex(-1);
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
                    title: '계정을 정말로 탈퇴하시겠어요?',
                    description: '탈퇴 시 모든 일기와 편지는 복구할 수 없어요.',
                    cancelText: '취소',
                    confirmText: '탈퇴',
                  );
                  if (ok == true) {
                    try {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        // 로딩 화면 노출
                        navigationToggleProvider.selectIndex(100);

                        // 로컬 저장소 데이터 삭제
                        mailController.deleteEveryMailDataFromLocal();

                        // 사용자 정보 초기화
                        userInfo.clearUserInfo();

                        // firebase DB 삭제
                        await deleteUserData(user.uid);

                        // SecureStorage의 로그인 정보 삭제
                        await storageProvider.clearLoginInfo();

                        // 계정 삭제를 위한 재인증 + 삭제 실행
                        await reauthenticateAndDeleteUser();

                        await _tutorial.resetAll();

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

  Future<void> deleteUserData(String userId) async {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    // 1. 하위 컬렉션(letters, notifications 등) 삭제
    Future<void> deleteSubCollection(String collectionName) async {
      final subColRef = userDocRef.collection(collectionName);
      final snapshots = await subColRef.get();
      for (final doc in snapshots.docs) {
        await doc.reference.delete();
      }
    }

    await deleteSubCollection('letters');
    await deleteSubCollection('notifications');

    // 2. 사용자 문서 삭제
    await userDocRef.delete();
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
