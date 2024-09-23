import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../controller/navigation_toggle_provider.dart';
import '../../controller/user_info_controller.dart';

class AuthService {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  Future signInWithGoogle(BuildContext context) async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount? gUser = await _googleSignIn.signIn();

    if (gUser == null) {
      return null;
    }

    final GoogleSignInAuthentication gAuth = await gUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final userCollection = FirebaseFirestore.instance.collection("users");

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    final docRef = userCollection.doc(userId);
    DocumentSnapshot snapshot = await docRef.get();

    final userInfoProvider =
        Provider.of<UserInfoValueModel>(context, listen: false);
    userInfoProvider.updateUserEmail(userEmail ?? '');
    userInfoProvider.userId = userId ?? '';
    // userInfoProvider.setValueEntered();

    // NavigationToggleProvider를 사용하여 화면 전환
    final navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context, listen: false);

    if (!snapshot.exists) {
      // 처음 로그인한 사용자라면
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

      // 하위 컬렉션 생성: letters
      final lettersCollectionRef = docRef.collection('letters');

      // 하위 컬렉션: letters에 대표 문서 추가
      await lettersCollectionRef.doc('0000_docSummary').set({
        // 빈 데이터 또는 초기 데이터
      });

      // 하위 컬렉션 생성: otherDiary
      final otherDiaryCollectionRef = docRef.collection('otherDiary');

      // 하위 컬렉션: otherDiary에 빈 문서 추가
      await otherDiaryCollectionRef.doc('0000_docSummary').set({
        // 빈 데이터 또는 초기 데이터
      });

      // 온보딩 페이지로 이동
      navigationToggleProvider.selectIndex(-3);
    } else {
      // 기존 사용자라면 바로 홈 페이지로 이동
      navigationToggleProvider.selectIndex(0);
    }

    return FirebaseAuth.instance.currentUser;
  }

  Future signInWithApple(BuildContext context) async {
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

      final userCollection = FirebaseFirestore.instance.collection("users");

      String? userId = FirebaseAuth.instance.currentUser?.uid;
      String? userEmail = FirebaseAuth.instance.currentUser?.email;

      final docRef = userCollection.doc(userId);
      DocumentSnapshot snapshot = await docRef.get();

      final userInfoProvider =
          Provider.of<UserInfoValueModel>(context, listen: false);
      userInfoProvider.updateUserEmail(userEmail ?? '');
      userInfoProvider.userId = userId ?? '';
      // userInfoProvider.setValueEntered();

      // NavigationToggleProvider를 사용하여 화면 전환
      final navigationToggleProvider =
          Provider.of<NavigationToggleProvider>(context, listen: false);

      if (!snapshot.exists) {
        // 처음 로그인한 사용자라면
        await docRef.set({
          "created_at": FieldValue.serverTimestamp(),
          "email": userEmail,
          "nickname": "",
          "likedDiaryId": [],
          "myDiaryId": [],
          "socialLoginProvider": "apple", // 구글 대신 애플로 설정
          "updatedAt": FieldValue.serverTimestamp(),
          "userId": userId,
          "newLetterAvailable": false,
        });

        // 하위 컬렉션 생성: letters
        final lettersCollectionRef = docRef.collection('letters');

        // 하위 컬렉션: letters에 대표 문서 추가
        await lettersCollectionRef.doc('0000_docSummary').set({
          // 빈 데이터 또는 초기 데이터
        });

        // 하위 컬렉션 생성: otherDiary
        final otherDiaryCollectionRef = docRef.collection('otherDiary');

        // 하위 컬렉션: otherDiary에 빈 문서 추가
        await otherDiaryCollectionRef.doc('0000_docSummary').set({
          // 빈 데이터 또는 초기 데이터
        });

        // 온보딩 페이지로 이동
        navigationToggleProvider.selectIndex(-3);
      } else {
        // 기존 사용자라면 바로 홈 페이지로 이동
        navigationToggleProvider.selectIndex(0);
      }

      return FirebaseAuth.instance.currentUser;
    } catch (error) {
      print('애플 로그인 중 오류 발생: $error');
      return null;
    }
  }
}
