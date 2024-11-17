import 'dart:developer' as dev;
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../controller/navigation_toggle_provider.dart';
import '../../controller/securestorage_controller.dart';
import '../../controller/user_info_controller.dart';

class AuthService {
  Future<User?> signInWithGoogle(BuildContext context) async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount? gUser = await _googleSignIn.signIn();

    if (gUser == null) {
      return null;
    }

    // Google 인증 정보 가져오기
    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    // Firebase 자격 증명 생성 및 로그인
    OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // accessToken과 idToken이 null이 아닌지 확인
    if (credential.accessToken == null) {
      dev.log("Google 로그인 실패: accessToken 또는 idToken이 null입니다.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google 로그인에 실패했습니다. 다시 시도해주세요.")),
      );
      return null;
    }

    await FirebaseAuth.instance.signInWithCredential(credential);

    // Google 로그인 정보를 SecureStorage에 저장
    final storageProvider =
        Provider.of<SecureStorageProvider>(context, listen: false);
    await storageProvider.saveGoogleLoginInfo(credential.accessToken!);

    final userCollection = FirebaseFirestore.instance.collection("users");

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    final docRef = userCollection.doc(userId);
    DocumentSnapshot snapshot = await docRef.get();

    final userInfoProvider =
        Provider.of<UserInfoValueModel>(context, listen: false);

    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (snapshot.exists) {
      String nickname = (snapshot.data() as Map<String, dynamic>)['nickname'];
      // UserInfoValueModel 업데이트
      userInfoProvider.updateUserID(userId!);
      userInfoProvider.updateUserEmail(userEmail!);
      userInfoProvider.updateNickname(nickname);

      if (fcmToken != null) {
        // Check if the current token is different from the one in Firestore
        if (snapshot["fcmToken"] != fcmToken) {
          // Update the FCM token in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'fcmToken': fcmToken});
        }
      }
    } else {
      await docRef.set({
        "created_at": FieldValue.serverTimestamp(),
        "email": userEmail,
        "nickname": "null",
        "likedDiaryId": [],
        "myDiaryId": [],
        "socialLoginProvider": "google",
        "updatedAt": FieldValue.serverTimestamp(),
        "userId": userId,
        "newLetterAvailable": false,
        "newNotificationsAvailable": false,
        "fcmToken": fcmToken,
      });

      // 하위 컬렉션 생성
      final lettersCollectionRef = docRef.collection('letters');
      await lettersCollectionRef.doc('0000_docSummary').set({});

      final otherDiaryCollectionRef = docRef.collection('otherDiary');
      await otherDiaryCollectionRef.doc('0000_docSummary').set({});

      final notificationsCollectionRef = docRef.collection('notifications');
      await notificationsCollectionRef.doc('0000_docSummary').set({});

      userInfoProvider.updateUserID(userId!);
      userInfoProvider.updateUserEmail(userEmail!);
      userInfoProvider.updateNickname("");
    }

    return FirebaseAuth.instance.currentUser;
  }

  Future<User?> signInWithApple(BuildContext context) async {
    final AuthorizationCredentialAppleID appleCredential =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final OAuthProvider oAuthProvider = OAuthProvider("apple.com");
    final AuthCredential credential = oAuthProvider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    // Firebase 애플 로그인
    await FirebaseAuth.instance.signInWithCredential(credential);

    // Apple 로그인 정보를 SecureStorage에 저장
    final storageProvider =
        Provider.of<SecureStorageProvider>(context, listen: false);
    await storageProvider.saveAppleLoginInfo(
        appleCredential.identityToken!, appleCredential.authorizationCode);

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

    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (snapshot.exists) {
      String nickname = (snapshot.data() as Map<String, dynamic>)['nickname'];
      // UserInfoValueModel 업데이트
      userInfoProvider.updateUserID(userId!);
      userInfoProvider.updateUserEmail(userEmail!);
      userInfoProvider.updateNickname(nickname);
      if (fcmToken != null) {
        // Check if the current token is different from the one in Firestore
        if (snapshot["fcmToken"] != fcmToken) {
          // Update the FCM token in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'fcmToken': fcmToken});
        }
      }
    } else {
      await docRef.set({
        "created_at": FieldValue.serverTimestamp(),
        "email": userEmail,
        "nickname": "null",
        "likedDiaryId": [],
        "myDiaryId": [],
        "socialLoginProvider": "apple",
        "updatedAt": FieldValue.serverTimestamp(),
        "userId": userId,
        "newLetterAvailable": false,
        "newNotificationsAvailable": false,
        "fcmToken": fcmToken,
      });

      // 하위 컬렉션 생성
      final lettersCollectionRef = docRef.collection('letters');
      await lettersCollectionRef.doc('0000_docSummary').set({});

      final otherDiaryCollectionRef = docRef.collection('otherDiary');
      await otherDiaryCollectionRef.doc('0000_docSummary').set({});

      final notificationsCollectionRef = docRef.collection('notifications');
      await notificationsCollectionRef.doc('0000_docSummary').set({});

      userInfoProvider.updateUserID(userId!);
      userInfoProvider.updateUserEmail(userEmail!);
      userInfoProvider.updateNickname("");
    }

    return FirebaseAuth.instance.currentUser;
  }

  Future<User?> signInWithGoogleTokens(
      String accessToken, BuildContext context) async {
    try {
      if (accessToken.isEmpty) {
        throw Exception("Access Token이 비어있습니다.");
      }

      log("Access Token: $accessToken");

      // 함수 시작 시점에서 Provider 참조
      final userInfoProvider =
          Provider.of<UserInfoValueModel>(context, listen: false);

      final credential =
          GoogleAuthProvider.credential(accessToken: accessToken);
      log("a");

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      log("b");

      final userCollection = FirebaseFirestore.instance.collection("users");
      String? userId = userCredential.user?.uid;
      String? userEmail = userCredential.user?.email;
      log("c");

      if (userId == null || userEmail == null) {
        throw Exception("사용자 정보가 유효하지 않습니다.");
      }
      log("d");

      final docRef = userCollection.doc(userId);
      DocumentSnapshot snapshot = await docRef.get();
      log("e");

      String? fcmToken = await FirebaseMessaging.instance.getToken();
      log("g");

      if (snapshot.exists) {
        log("h");
        String userId = (snapshot.data() as Map<String, dynamic>)['userId'];
        String userEmail = (snapshot.data() as Map<String, dynamic>)['email'];
        String nickname = (snapshot.data() as Map<String, dynamic>)['nickname'];
        log("i");

        userInfoProvider.updateUserID(userId);
        userInfoProvider.updateUserEmail(userEmail);
        userInfoProvider.updateNickname(nickname);

        log("j");
        if (fcmToken != null && snapshot["fcmToken"] != fcmToken) {
          log("k");
          await docRef.update({'fcmToken': fcmToken});
        }
      } else {
        log("l");
        await docRef.set({
          "created_at": FieldValue.serverTimestamp(),
          "email": userEmail,
          "nickname": "null",
          "likedDiaryId": [],
          "myDiaryId": [],
          "socialLoginProvider": "google",
          "updatedAt": FieldValue.serverTimestamp(),
          "userId": userId,
          "newLetterAvailable": false,
          "newNotificationsAvailable": false,
          "fcmToken": fcmToken,
        });

        log("m");
        await docRef.collection('letters').doc('0000_docSummary').set({});
        await docRef.collection('otherDiary').doc('0000_docSummary').set({});
        await docRef.collection('notifications').doc('0000_docSummary').set({});
        log("n");

        userInfoProvider.updateUserID(userId);
        userInfoProvider.updateUserEmail(userEmail);
        userInfoProvider.updateNickname("");
      }

      log("Google 로그인 성공: ${userCredential.user?.email}");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        log("Google 토큰이 만료되었거나 잘못되었습니다.");
        throw Exception("Google Access Token expired or invalid.");
      } else {
        log("Google 인증 실패: ${e.message}");
        rethrow;
      }
    } catch (e) {
      log("알 수 없는 오류 발생: $e");
      rethrow;
    }
  }

  Future<User?> signInWithAppleTokens(String identityToken,
      String authorizationCode, BuildContext context) async {
    try {
      final credential = OAuthProvider("apple.com").credential(
        idToken: identityToken,
        accessToken: authorizationCode,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Firestore 사용자 데이터 처리
      await _handleUserData(userCredential.user, "apple", context);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      log("Apple 로그인 실패: ${e.message}");
      if (e.code == 'invalid-credential') {
        throw Exception("Apple 토큰이 만료되었거나 잘못되었습니다.");
      }
      rethrow;
    }
  }

  Future<void> _handleUserData(
      User? user, String provider, BuildContext context) async {
    if (user == null) {
      throw Exception("사용자 인증 실패");
    }

    final userCollection = FirebaseFirestore.instance.collection("users");
    final docRef = userCollection.doc(user.uid);
    final snapshot = await docRef.get();

    final userInfoProvider =
        Provider.of<UserInfoValueModel>(context, listen: false);
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      userInfoProvider.updateUserID(user.uid);
      log(user.uid);
      userInfoProvider.updateUserEmail(user.email ?? "");
      log(user.email!);
      userInfoProvider.updateNickname(data['nickname'] ?? "");
      log(user.uid);

      if (fcmToken != null && data["fcmToken"] != fcmToken) {
        await docRef.update({'fcmToken': fcmToken});
      }
    } else {
      await docRef.set({
        "created_at": FieldValue.serverTimestamp(),
        "email": user.email,
        "nickname": "",
        "likedDiaryId": [],
        "myDiaryId": [],
        "socialLoginProvider": provider,
        "updatedAt": FieldValue.serverTimestamp(),
        "userId": user.uid,
        "newLetterAvailable": false,
        "newNotificationsAvailable": false,
        "fcmToken": fcmToken,
      });

      // 하위 컬렉션 생성
      await docRef.collection('letters').doc('0000_docSummary').set({});
      await docRef.collection('otherDiary').doc('0000_docSummary').set({});
      await docRef.collection('notifications').doc('0000_docSummary').set({});

      userInfoProvider.updateUserID(user.uid);
      userInfoProvider.updateUserEmail(user.email ?? "");
      userInfoProvider.updateNickname("");
    }
  }
}
