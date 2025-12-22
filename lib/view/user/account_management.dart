// lib/views/user/account_management.dart
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../components/button/primary_button.dart';
import '../../components/button/secondary_button.dart';
import '../../components/dialogue/reset_dialogue.dart';
import '../../controller/mail_controller.dart';
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

    return Scaffold(
      backgroundColor: BandiColor.neutralColor80(context).withOpacity(0.8),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BandiColor.transparent(context),
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft()),
          onPressed: widget.onBack,
        ),
        title: Text(
          'settings_my_account'.tr(context),
          style: BandiFont.headlineMedium(context)?.copyWith(
            color: BandiColor.foundationColor80(context),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
          ),
          children: [
            _buildSettingOption(
              context: context,
              icon: PhosphorIcons.at(),
              text: 'settings_my_account_email'.tr(context),
              onTap: () {},
              trailing: Text(
                userInfo.userEmail.isNotEmpty ? userInfo.userEmail : "none",
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
            _buildSettingOption(
              context: context,
              icon: PhosphorIcons.user(),
              text: 'settings_my_account_nickname'.tr(context),
              onTap: () => widget.onNavigate(2),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.4,
                        ),
                        child: Text(
                          userInfo.nickname.isNotEmpty
                              ? userInfo.nickname
                              : "onboarding_nickname_empty".tr(context),
                          style: BandiFont.bodyMedium(context)?.copyWith(
                            color: BandiColor.foundationColor60(context),
                          ),
                          overflow: TextOverflow.clip,
                          softWrap: false,
                        ),
                      ),
                    ],
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
              title: 'settings_my_account_logout'.tr(context),
              onPrimaryButtonPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomResetDialogue(
                      text: 'settings_my_account_logout_text'.tr(context),
                      onYesText: 'dialogue_yes'.tr(context),
                      onNoText: 'dialogue_no'.tr(context),
                      onYesFunction: () async {
                        Navigator.pop(context);

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
                      },
                      onNoFunction: () {
                        if (mounted) {
                          Navigator.pop(context);
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
              title: 'settings_my_account_delete_account'.tr(context),
              onSecondaryButtonPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomResetDialogue(
                      text:
                          'settings_my_account_delete_account_text'.tr(context),
                      onYesText: 'dialogue_yes'.tr(context),
                      onNoText: 'dialogue_no'.tr(context),
                      onYesFunction: () async {
                        Navigator.pop(context);
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

                            // 로그인 페이지로 이동
                            navigationToggleProvider.selectIndex(-1);
                          }
                        } catch (e) {
                          // 로그인 페이지로 이동
                          navigationToggleProvider.selectIndex(-1);
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
                    overflow: TextOverflow.fade,
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
}
