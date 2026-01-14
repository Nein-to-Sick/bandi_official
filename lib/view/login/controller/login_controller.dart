import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../controller/navigation_toggle_provider.dart';
import '../../../controller/securestorage_controller.dart';
import '../../../controller/user_info_controller.dart';
import '../../tutorial/controller/tutorial_controller.dart';
import '../data/auth_service.dart';

sealed class LoginUiEvent {
  const LoginUiEvent();
}

class ShowAgreementSheet extends LoginUiEvent {
  const ShowAgreementSheet();
}

class ShowTutorialFlow extends LoginUiEvent {
  const ShowTutorialFlow();
}

class ShowNicknameSheet extends LoginUiEvent {
  const ShowNicknameSheet();
}

class LoginErrorToast extends LoginUiEvent {
  final String message;
  const LoginErrorToast(this.message);
}

class LoginController extends ChangeNotifier {
  final AuthService authService;
  final SecureStorageProvider storage;
  final NavigationToggleProvider nav;
  final UserInfoValueModel userInfo;
  final TutorialController tutorial;

  bool _disposed = false;
  bool _initialized = false;

  // ✅ 구독자 없을 때 이벤트 유실 방지용 버퍼
  final List<LoginUiEvent> _pending = [];

  late final StreamController<LoginUiEvent> _events =
  StreamController<LoginUiEvent>.broadcast(
    onListen: () {
      // ✅ 리스너가 붙는 순간, 밀린 이벤트 모두 재전달
      for (final e in List<LoginUiEvent>.from(_pending)) {
        if (_events.isClosed) break;
        _events.add(e);
      }
      _pending.clear();
    },
  );

  Stream<LoginUiEvent> get events => _events.stream;

  LoginController({
    required this.authService,
    required this.storage,
    required this.nav,
    required this.userInfo,
    required this.tutorial,
  });

  void emit(LoginUiEvent e) {
    log('emit $e hasListener=${_events.hasListener} closed=${_events.isClosed}');

    if (_disposed) return;
    if (_events.isClosed) return;

    // ✅ 리스너 없으면 pending에 쌓아두고, 있으면 즉시 발행
    if (_events.hasListener) {
      _events.add(e);
    } else {
      _pending.add(e);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _events.close();
    super.dispose();
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await storage.loadLoginInfo();

    final current = FirebaseAuth.instance.currentUser;
    log('[LOGIN init] storage.isLoggedIn=${storage.isLoggedIn} current=${current?.uid}');

    // ✅ 핵심: 저장소 기준 "로그인 아님"인데 currentUser가 살아있으면 => 유령 세션
    if (!storage.isLoggedIn && current != null) {
      await _hardSignOut(); // 아래 함수
    }

    final current2 = FirebaseAuth.instance.currentUser;
    if (current2 != null) {
      await _routeAfterAuth(current2);
      return;
    }

    // 저장소 기준 자동로그인 시도
    if (storage.isLoggedIn && !authService.checkOnce) {
      authService.toggleCheckOnce();
      await tryAutoLogin();
    } else {
      nav.selectIndex(-1);
    }
  }

  Future<void> _hardSignOut() async {
    try {
      // Google 세션까지 완전히 끊기
      final g = GoogleSignIn();
      await g.signOut();
      await g.disconnect(); // 중요: 캐시 계정 끊기

      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // ignore
    }
  }

  Future<void> tryAutoLogin() async {
    nav.selectIndex(100);

    try {
      User? user;

      if (storage.loginMethod == 'google' && storage.googleAccessToken != null) {
        user = await authService.signInWithGoogleTokens(storage.googleAccessToken!);
      } else if (storage.loginMethod == 'apple' && storage.appleIdentityToken != null) {
        user = await authService.signInWithAppleTokens();
      } else {
        nav.selectIndex(-1);
        return;
      }
      await _routeAfterAuth(user);
    } on FirebaseAuthException catch (e) {
      log("auto login error: ${e.code} ${e.message}");
      nav.selectIndex(-1);
      emit(LoginErrorToast("자동 로그인 실패: ${e.code}"));
    } catch (e) {
      log("auto login error: $e");
      nav.selectIndex(-1);
      emit(const LoginErrorToast("자동 로그인 실패"));
    }
  }

  Future<void> loginWithGoogle() async {
    nav.selectIndex(100);

    try {
      final user = await authService.signInWithGoogle();
      await _routeAfterAuth(user);
    } catch (e) {
      nav.selectIndex(-1);
      emit(LoginErrorToast("구글 로그인 실패: $e"));
    }
  }

  Future<void> loginWithApple() async {
    nav.selectIndex(100);

    try {
      final user = await authService.signInWithApple();
      await _routeAfterAuth(user);
    } catch (e) {
      nav.selectIndex(-1);
      emit(LoginErrorToast("애플 로그인 실패: $e"));
    }
  }

  Future<void> _routeAfterAuth(User? user) async {
    if (user == null) {
      nav.selectIndex(-1);
      emit(const LoginErrorToast("로그인에 실패했어요."));
      return;
    }

    // ✅ 1) 가장 먼저 uid 주입
    userInfo.updateUserID(user.uid);

    // ✅ 2) 이제 온보딩 분기
    if (!userInfo.isAgreed) {
      nav.selectIndex(-3);
      emit(const ShowAgreementSheet());
      return;
    }

    if (userInfo.getNickName().trim().isEmpty) {
      nav.selectIndex(-3);
      emit(const ShowNicknameSheet());
      return;
    }

    if (!tutorial.finished) {
      nav.selectIndex(-3);
      emit(const ShowTutorialFlow());
      return;
    }

    nav.selectIndex(0);
  }

  Future<void> onAgreementAccepted() async {
    final uid = userInfo.userId;
    if (uid.isEmpty) return;

    await authService.userProfileRepository.updateAgreement(
      userId: uid,
      isAgreed: true,
    );
    userInfo.updateIsAgreed(true);

    nav.selectIndex(-3);
    emit(const ShowNicknameSheet());
  }


  Future<void> onTutorialFinished() async {
    nav.selectIndex(0);
  }

  Future<void> onNicknameCompleted(String nickname) async {
    userInfo.updateNickname(nickname);

    nav.selectIndex(-3);
    emit(const ShowTutorialFlow());
  }
}
