import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserInfoValueModel with ChangeNotifier {
  String userId = '';
  String userEmail = '';
  String nickname = '';
  bool isAgreed = false;

  void updateUserID(String value) {
    userId = value;
    notifyListeners();
  }

  void updateUserEmail(String value) {
    userEmail = value;
    notifyListeners();
  }

  void updateNickname(String value) {
    nickname = value;
    notifyListeners();
  }

  void updateIsAgreed(bool value) {
    isAgreed = value;
    notifyListeners();
  }

  void clearUserInfo() {
    userId = '';
    userEmail = '';
    nickname = '';
    isAgreed = false;
    notifyListeners();
  }

  String getNickName() => nickname;

  Future<void> loadProfileFromServer(String uid) async {
    userId = uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!doc.exists) {
      // 문서 없으면 기본값 유지 (신규 유저일 수 있음)
      notifyListeners();
      return;
    }

    final data = doc.data() ?? {};

    // 🔽 필드명은 네 DB 스키마에 맞게 수정
    final agreed = (data['isAgreed'] as bool?) ?? false;
    final nick = (data['nickname'] as String?) ?? '';
    final email = (data['email'] as String?) ?? '';

    // 한번에 반영 + notify 1회
    isAgreed = agreed;
    nickname = nick;
    userEmail = email;

    notifyListeners();
  }
}
