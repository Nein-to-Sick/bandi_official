// lib/view/login/data/user_profile_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class BootstrappedProfile {
  final String userId;
  final String email;
  final String nickname;
  final bool isAgreed;

  const BootstrappedProfile({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.isAgreed,
  });

  bool get needsAgreement => !isAgreed;
  bool get needsNickname => nickname.trim().isEmpty;
}

class UserProfileRepository {
  final FirebaseFirestore firestore;
  final FirebaseMessaging fcm;

  UserProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseMessaging? fcm,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        fcm = fcm ?? FirebaseMessaging.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      firestore.collection('users');

  Future<BootstrappedProfile> bootstrapUser({
    required String userId,
    required String? email,
    required String socialLoginProvider,
  }) async {
    final docRef = _users.doc(userId);
    final snap = await docRef.get();

    final fcmToken = await fcm.getToken();

    if (snap.exists) {
      final data = snap.data() ?? {};

      // fcmToken 최신화
      final prev = data['fcmToken'];
      if (fcmToken != null && prev != fcmToken) {
        await docRef.update({'fcmToken': fcmToken});
      }

      // email이 비어있는데 파라미터로 들어오면 채워주기(Apple에서 종종 null)
      final savedEmail = (data['email'] ?? '') as String;
      final incomingEmail = email ?? '';
      if (savedEmail.isEmpty && incomingEmail.isNotEmpty) {
        await docRef.update({'email': incomingEmail});
      }

      final refreshed = await docRef.get();
      final d = refreshed.data() ?? {};
      return BootstrappedProfile(
        userId: userId,
        email: (d['email'] ?? '') as String,
        nickname: (d['nickname'] ?? '') as String,
        isAgreed: (d['isAgreed'] ?? false) as bool,
      );
    }

    // ✅ 신규 유저: nickname을 비워둬야 온보딩 플로우를 탐
    await docRef.set({
      "created_at": FieldValue.serverTimestamp(),
      "email": email ?? "",
      "nickname": "", // ✅ 여기 핵심
      "likedDiaryId": [],
      "myDiaryId": [],
      "socialLoginProvider": socialLoginProvider,
      "updatedAt": FieldValue.serverTimestamp(),
      "userId": userId,
      "newLetterAvailable": false,
      "newNotificationsAvailable": false,
      "fcmToken": fcmToken,
      "isAgreed": false,
      "last_agreed_at": null,
    });

    await docRef.collection('letters').doc('0000_docSummary').set({});
    await docRef.collection('otherDiary').doc('0000_docSummary').set({});
    await docRef.collection('notifications').doc('0000_docSummary').set({});

    return BootstrappedProfile(
      userId: userId,
      email: email ?? "",
      nickname: "",
      isAgreed: false,
    );
  }

  Future<void> updateNickname({
    required String userId,
    required String nickname,
  }) async {
    await _users.doc(userId).update({
      'nickname': nickname,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAgreement({
    required String userId,
    required bool isAgreed,
  }) async {
    await _users.doc(userId).update({
      'isAgreed': isAgreed,
      'last_agreed_at': isAgreed ? DateTime.now() : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String userId) {
    return _users.doc(userId).get();
  }
}
