// lib/view/login/data/auth_service.dart
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;

import '../../../controller/securestorage_controller.dart';
import '../../../controller/user_info_controller.dart';
import 'user_profile_repository.dart';
import 'package:bandi_official/utils/apple_login_utils.dart' as custom_utils;

class AuthService {
  final SecureStorageProvider storage;
  final UserInfoValueModel userInfo;
  final UserProfileRepository userProfileRepository;

  final FirebaseAuth auth;

  bool checkOnce = false;

  AuthService({
    required this.storage,
    required this.userInfo,
    required this.userProfileRepository,
    FirebaseAuth? auth,
  }) : auth = auth ?? FirebaseAuth.instance;

  void toggleCheckOnce() => checkOnce = true;

  // ---------------------------
  // Google interactive login
  // ---------------------------
  Future<User?> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final gUser = await googleSignIn.signIn();
    if (gUser == null) return null;

    final gAuth = await gUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    if (credential.accessToken == null) {
      log("Google 로그인 실패: accessToken null");
      return null;
    }

    final result = await auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) return null;

    // ✅ secure storage 저장
    await storage.saveGoogleLoginInfo(credential.accessToken!);

    // ✅ firestore bootstrap + userInfo 반영
    final profile = await userProfileRepository.bootstrapUser(
      userId: user.uid,
      email: user.email,
      socialLoginProvider: "google",
    );
    _applyProfileToUserInfo(profile);

    return user;
  }

  // ---------------------------
  // Apple interactive login
  // ---------------------------
  Future<User?> signInWithApple() async {
    final rawNonce = custom_utils.generateNonce();
    final hashedNonce = custom_utils.hashNonce(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final oAuthProvider = OAuthProvider("apple.com");
    final credential = oAuthProvider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
      rawNonce: rawNonce,
    );

    final result = await auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) return null;

    await storage.saveAppleLoginInfo(
      appleCredential.identityToken!,
      appleCredential.authorizationCode,
      rawNonce,
    );

    final profile = await userProfileRepository.bootstrapUser(
      userId: user.uid,
      email: user.email,
      socialLoginProvider: "apple",
    );
    _applyProfileToUserInfo(profile);

    return user;
  }

  // ---------------------------
  // Google token login (auto)
  // ---------------------------
  Future<User?> signInWithGoogleTokens(String accessToken) async {
    // 1) token 유효성 체크 (선택)
    final isValid = await validateGoogleAccessToken(accessToken);
    if (!isValid) {
      log("Google token invalid -> auto login fail");
      return null;
    }

    // ✅ 중요: accessToken만으로는 Firebase 로그인 세션을 만들 수 없음.
    // 지금 구조는 "이미 FirebaseAuth 세션이 살아있다"를 전제로 함.
    final user = auth.currentUser;
    if (user == null) return null;

    final profile = await userProfileRepository.bootstrapUser(
      userId: user.uid,
      email: user.email,
      socialLoginProvider: "google",
    );
    _applyProfileToUserInfo(profile);

    return user;
  }

  // ---------------------------
  // Apple token login (auto)
  // ---------------------------
  Future<User?> signInWithAppleTokens() async {
    final user = auth.currentUser;
    if (user == null) return null;

    final profile = await userProfileRepository.bootstrapUser(
      userId: user.uid,
      email: user.email,
      socialLoginProvider: "apple",
    );
    _applyProfileToUserInfo(profile);

    return user;
  }

  Future<bool> validateGoogleAccessToken(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://oauth2.googleapis.com/tokeninfo?access_token=$accessToken'),
      );
      return response.statusCode == 200;
    } catch (e) {
      log("AccessToken validate error: $e");
      return false;
    }
  }

  void _applyProfileToUserInfo(BootstrappedProfile p) {
    userInfo.updateUserID(p.userId);
    userInfo.updateUserEmail(p.email);
    userInfo.updateNickname(p.nickname);
    userInfo.updateIsAgreed(p.isAgreed);
  }
}
