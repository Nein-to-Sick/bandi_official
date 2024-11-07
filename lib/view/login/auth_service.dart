import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../controller/navigation_toggle_provider.dart';
import '../../controller/user_info_controller.dart';

class AuthService {
  Future<User?> signInWithGoogle(BuildContext context) async {
    //begin interactive sign in process
    GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount? gUser = await _googleSignIn.signIn();

    if (gUser == null) {
      return null;
    }

    //obtain auth details from request
    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    //create a new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // final userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);

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
}
