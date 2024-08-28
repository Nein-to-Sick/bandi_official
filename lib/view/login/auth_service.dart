import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

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
    userInfoProvider.setValueEntered();

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
      });

      // 온보딩 페이지로 이동
      navigationToggleProvider.selectIndex(-3);
    } else {
      // 기존 사용자라면 바로 홈 페이지로 이동
      navigationToggleProvider.selectIndex(0);
    }

    return FirebaseAuth.instance.currentUser;
  }
}
