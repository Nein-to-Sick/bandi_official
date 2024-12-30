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
import 'package:http/http.dart' as http;

import '../../controller/navigation_toggle_provider.dart';
import '../../controller/securestorage_controller.dart';
import '../../controller/user_info_controller.dart';
import 'package:bandi_official/utils/apple_login_utils.dart' as custom_utils;

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
    // Generate nonce for security
    final rawNonce = custom_utils.generateNonce();
    final hashedNonce = custom_utils.hashNonce(rawNonce);

    print("Generated rawNonce: $rawNonce");
    print("Generated hashedNonce: $hashedNonce");


    final AuthorizationCredentialAppleID appleCredential =
        await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final OAuthProvider oAuthProvider = OAuthProvider("apple.com");
    final AuthCredential credential = oAuthProvider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
      rawNonce: rawNonce, // Pass raw nonce for verification
    );

    // Firebase 애플 로그인
    await FirebaseAuth.instance.signInWithCredential(credential);

    // Apple 로그인 정보를 SecureStorage에 저장
    final storageProvider =
        Provider.of<SecureStorageProvider>(context, listen: false);
    await storageProvider.saveAppleLoginInfo(
        appleCredential.identityToken!, appleCredential.authorizationCode, rawNonce);

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
      final storageProvider =
          Provider.of<SecureStorageProvider>(context, listen: false);
      final userInfoProvider =
          Provider.of<UserInfoValueModel>(context, listen: false);

      // 1. Access Token 검증 (Optional)
      final isValidToken = await validateGoogleAccessToken(accessToken);
      if (accessToken.isEmpty || !isValidToken) {
        log("Access Token이 유효하지 않습니다. 새로 발급을 시도합니다.");

        // 새로운 Access Token 발급 시도
        GoogleSignIn _googleSignIn = GoogleSignIn();
        GoogleSignInAccount? gUser = await _googleSignIn.signIn();
        if (gUser != null) {
          final GoogleSignInAuthentication gAuth = await gUser.authentication;
          accessToken = gAuth.accessToken!;
          log("새로운 Access Token 발급 성공: $accessToken");

          await storageProvider.saveGoogleLoginInfo(gAuth.accessToken!);
        } else {
          log("새로운 Access Token 발급 실패");
          return null; // 실패 시 함수 종료
        }
      }

      final userCollection = FirebaseFirestore.instance.collection("users");
      User? userCredential = FirebaseAuth.instance.currentUser;
      if (userCredential == null) {
        throw Exception("사용자 정보가 유효하지 않습니다.");
      }
      String? userId = userCredential.uid;
      String? userEmail = userCredential.email;

      final docRef = userCollection.doc(userId);
      DocumentSnapshot snapshot = await docRef.get();

      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (snapshot.exists) {
        String userId = (snapshot.data() as Map<String, dynamic>)['userId'];
        String userEmail = (snapshot.data() as Map<String, dynamic>)['email'];
        String nickname = (snapshot.data() as Map<String, dynamic>)['nickname'];

        userInfoProvider.updateUserID(userId);
        userInfoProvider.updateUserEmail(userEmail);
        userInfoProvider.updateNickname(nickname);

        if (fcmToken != null && snapshot["fcmToken"] != fcmToken) {
          await docRef.update({'fcmToken': fcmToken});
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

        await docRef.collection('letters').doc('0000_docSummary').set({});
        await docRef.collection('otherDiary').doc('0000_docSummary').set({});
        await docRef.collection('notifications').doc('0000_docSummary').set({});

        userInfoProvider.updateUserID(userId);
        userInfoProvider.updateUserEmail(userEmail!);
        userInfoProvider.updateNickname("");
      }

      log("Google 로그인 성공: ${userCredential.email}");
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        log("Google 토큰이 잘못되었거나 만료되었습니다.");
        throw Exception("Google Access Token expired or invalid. 다시 로그인 해주세요.");
      } else {
        log("Google 인증 실패: ${e.message}");
        rethrow;
      }
    } catch (e) {
      log("알 수 없는 오류 발생: $e");
      rethrow;
    }
  }

// Google Access Token 검증 함수
  Future<bool> validateGoogleAccessToken(String accessToken) async {
    try {
      final response = await http.get(Uri.parse(
          'https://oauth2.googleapis.com/tokeninfo?access_token=$accessToken'));
      if (response.statusCode == 200) {
        log("Access Token 검증 성공: ${response.body}");
        return true;
      } else {
        log("Access Token 검증 실패: ${response.body}");
        return false;
      }
    } catch (e) {
      log("Access Token 검증 중 오류 발생: $e");
      return false;
    }
  }

  Future<User?> signInWithAppleTokens(BuildContext context) async {
    final userInfoProvider =
    Provider.of<UserInfoValueModel>(context, listen: false);
      User? userCredential = FirebaseAuth.instance.currentUser;
      if (userCredential == null) {
        throw Exception("사용자 정보가 유효하지 않습니다.");
      }
      final userCollection = FirebaseFirestore.instance.collection("users");
      String? userId = userCredential.uid;
      String? userEmail = userCredential.email;

      final docRef = userCollection.doc(userId);
      DocumentSnapshot snapshot = await docRef.get();

      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (snapshot.exists) {
        // 기존 사용자 데이터 업데이트
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        String nickname = userData['nickname'];

        userInfoProvider.updateUserID(userId);
        userInfoProvider.updateUserEmail(userEmail!);
        userInfoProvider.updateNickname(nickname);

        if (fcmToken != null && userData["fcmToken"] != fcmToken) {
          await docRef.update({'fcmToken': fcmToken});
        }
      } else {
        // Firestore에 새 사용자 데이터 저장
        await docRef.set({
          "created_at": FieldValue.serverTimestamp(),
          "email": userEmail,
          "nickname": "",
          "likedDiaryId": [],
          "myDiaryId": [],
          "socialLoginProvider": "apple",
          "updatedAt": FieldValue.serverTimestamp(),
          "userId": userId,
          "newLetterAvailable": false,
          "newNotificationsAvailable": false,
          "fcmToken": fcmToken,
        });

        // 하위 컬렉션 초기화
        await docRef.collection('letters').doc('0000_docSummary').set({});
        await docRef.collection('otherDiary').doc('0000_docSummary').set({});
        await docRef.collection('notifications').doc('0000_docSummary').set({});

        userInfoProvider.updateUserID(userId);
        userInfoProvider.updateUserEmail(userEmail!);
        userInfoProvider.updateNickname("");
      }
      return userCredential;
  }
}
