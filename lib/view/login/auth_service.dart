import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../controller/navigation_toggle_provider.dart';
import '../../controller/user_info_controller.dart';

class AuthService {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  final storage = FlutterSecureStorage();

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      // 이미 선언된 GoogleSignIn 인스턴스 사용
      GoogleSignInAccount? gUser = await googleSignIn.signIn();

      if (gUser == null) {
        return null; // 사용자가 로그인 취소
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Firebase 인증
      UserCredential userCredential =
          await auth.signInWithCredential(credential);

      String? token = await userCredential.user!.getIdToken();
      await storage.write(key: 'authToken', value: token);

      final userCollection = FirebaseFirestore.instance.collection("users");

      String? userId = auth.currentUser?.uid;
      String? userEmail = auth.currentUser?.email;

      if (userId == null || userEmail == null) {
        throw Exception("User not found after authentication.");
      }

      final docRef = userCollection.doc(userId);
      DocumentSnapshot snapshot = await docRef.get();

      final userInfoProvider =
          Provider.of<UserInfoValueModel>(context, listen: false);
      final navigationToggleProvider =
          Provider.of<NavigationToggleProvider>(context, listen: false);

      // snapshot이 존재하고 nickname이 null인 경우 처리
      if (snapshot.exists &&
          (snapshot.data() as Map<String, dynamic>)['nickname'] != null) {
        // Firestore에서 userId, userEmail, nickname 가져오기
        String nickname = (snapshot.data() as Map<String, dynamic>)['nickname'];

        // UserInfoValueModel 업데이트
        userInfoProvider.updateUserID(userId);
        userInfoProvider.updateUserEmail(userEmail);
        userInfoProvider.updateNickname(nickname);

        // 기존 사용자면 홈으로 이동
        navigationToggleProvider.selectIndex(0);
        return auth.currentUser;
      }

      // 사용자 문서가 없으면 새로 생성
      if (!snapshot.exists ||
          (snapshot.data() as Map<String, dynamic>)['nickname'] == null) {
        await docRef.set({
          "created_at": FieldValue.serverTimestamp(),
          "email": userEmail,
          "nickname": "",
          "likedDiaryId": [],
          "myDiaryId": [],
          "socialLoginProvider": "google",
          "updatedAt": FieldValue.serverTimestamp(),
          "userId": userId,
          "newLetterAvailable": false,
        });

        // 하위 컬렉션 생성
        final lettersCollectionRef = docRef.collection('letters');
        await lettersCollectionRef.doc('0000_docSummary').set({});

        final otherDiaryCollectionRef = docRef.collection('otherDiary');
        await otherDiaryCollectionRef.doc('0000_docSummary').set({});

        // 온보딩 페이지로 이동
        navigationToggleProvider.selectIndex(-3);
      }

      return auth.currentUser;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      // 사용자에게 에러 메시지를 제공하거나 로깅 처리
      return null;
    }
  }

  Future<User?> signInWithApple(BuildContext context) async {
    try {
      // 1. 애플 로그인 자격 증명 가져오기
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. Firebase 자격 증명 생성
      final OAuthProvider oAuthProvider = OAuthProvider("apple.com");
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 3. Firebase에 로그인
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      String? token = await userCredential.user!.getIdToken();
      await storage.write(key: 'authToken', value: token);

      final userCollection = FirebaseFirestore.instance.collection("users");

      String? userId = FirebaseAuth.instance.currentUser?.uid;
      String? userEmail = FirebaseAuth.instance.currentUser?.email;

      if (userId == null || userEmail == null) {
        throw Exception("User not found after authentication.");
      }

      final docRef = userCollection.doc(userId);
      DocumentSnapshot snapshot = await docRef.get();

      final userInfoProvider =
          Provider.of<UserInfoValueModel>(context, listen: false);
      final navigationToggleProvider =
          Provider.of<NavigationToggleProvider>(context, listen: false);

      // snapshot이 존재하고 nickname이 null이 아닌 경우 처리
      if (snapshot.exists &&
          (snapshot.data() as Map<String, dynamic>)['nickname'] != null) {
        // Firestore에서 userId, userEmail, nickname 가져오기
        String nickname = (snapshot.data() as Map<String, dynamic>)['nickname'];

        // UserInfoValueModel 업데이트
        userInfoProvider.updateUserID(userId);
        userInfoProvider.updateUserEmail(userEmail);
        userInfoProvider.updateNickname(nickname);

        // 기존 사용자면 홈으로 이동
        navigationToggleProvider.selectIndex(0);
        return FirebaseAuth.instance.currentUser;
      }

      // 사용자 문서가 없거나 nickname이 없는 경우 처리
      if (!snapshot.exists ||
          (snapshot.data() as Map<String, dynamic>)['nickname'] == null) {
        await docRef.set({
          "created_at": FieldValue.serverTimestamp(),
          "email": userEmail,
          "nickname": "",
          "likedDiaryId": [],
          "myDiaryId": [],
          "socialLoginProvider": "apple", // 소셜 로그인 제공자를 apple로 설정
          "updatedAt": FieldValue.serverTimestamp(),
          "userId": userId,
          "newLetterAvailable": false,
        });

        // 하위 컬렉션 생성: letters
        final lettersCollectionRef = docRef.collection('letters');
        await lettersCollectionRef.doc('0000_docSummary').set({});

        final otherDiaryCollectionRef = docRef.collection('otherDiary');
        await otherDiaryCollectionRef.doc('0000_docSummary').set({});

        // 온보딩 페이지로 이동
        navigationToggleProvider.selectIndex(-3);
      }

      return FirebaseAuth.instance.currentUser;
    } catch (error) {
      print('애플 로그인 중 오류 발생: $error');
      return null;
    }
  }
}
