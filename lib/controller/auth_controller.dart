import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'user_info_controller.dart';
import 'navigation_toggle_provider.dart';

class AccountController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final storage = FlutterSecureStorage(); // SecureStorage 초기화

  // 로그아웃 함수
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    _clearUserInfo(context);
    await storage.delete(key: 'token'); // 저장된 토큰 삭제
    _navigateToLogin(context);
  }

  // 계정 탈퇴 함수
  Future<void> deleteUserAccount(BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _deleteUserData(user.uid);
        await storage.delete(key: 'token'); // 저장된 토큰 삭제
        await user.delete();
        _clearUserInfo(context);
        _navigateToLogin(context);
      }
    } catch (e) {
      // 오류 처리 로직
      debugPrint("Error deleting account: $e");
    }
  }

  // Firestore에서 사용자 데이터 삭제
  Future<void> _deleteUserData(String userId) async {
    final docRef = _firestore.collection('users').doc(userId);
    await docRef.delete();
  }

  // UserInfo 초기화
  void _clearUserInfo(BuildContext context) {
    final userInfoProvider =
        Provider.of<UserInfoValueModel>(context, listen: false);
    userInfoProvider.clearUserInfo();
  }

  // 로그인 화면으로 이동
  void _navigateToLogin(BuildContext context) {
    final navigationProvider =
        Provider.of<NavigationToggleProvider>(context, listen: false);
    navigationProvider.selectIndex(-1);
  }

  // 닉네임 변경
  Future<void> updateNickname(BuildContext context, String newNickname) async {
    final user = _auth.currentUser;
    if (user != null) {
      // Firestore에 닉네임 업데이트
      await _firestore.collection('users').doc(user.uid).update({
        'nickname': newNickname,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // UserInfoValueModel 업데이트
      Provider.of<UserInfoValueModel>(context, listen: false)
          .updateNickname(newNickname);

      notifyListeners(); // 변경사항을 리스너에게 알림
    }
  }
}
