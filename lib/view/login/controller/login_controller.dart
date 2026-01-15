import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../controller/navigation_toggle_provider.dart';
import '../../../controller/securestorage_controller.dart';
import '../../../controller/user_info_controller.dart';
import '../data/auth_service.dart';

sealed class LoginUiEvent {
  const LoginUiEvent();
}

class ShowAgreementSheet extends LoginUiEvent {
  const ShowAgreementSheet();
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
  });

  void emit(LoginUiEvent e) {
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

    if (nav.getIndex() != -1) return;

    await storage.loadLoginInfo();

    if (storage.isLoggedIn && !authService.checkOnce) {
      authService.toggleCheckOnce();
      await tryAutoLogin();
    }
  }

  Future<void> tryAutoLogin() async {
    nav.selectIndex(100);

    try {
      User? user;

      if (storage.loginMethod == 'google' &&
          storage.googleAccessToken != null) {
        user = await authService
            .signInWithGoogleTokens(storage.googleAccessToken!);
      } else if (storage.loginMethod == 'apple' &&
          storage.appleIdentityToken != null) {
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

    // ✅ 가입 플로우는 -3에서만 처리
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

    nav.selectIndex(0);
  }

  /// 약관 동의 완료 시 UI에서 호출
  Future<void> onAgreementAccepted() async {
    final uid = userInfo.userId;
    if (uid.isEmpty) return;

    await authService.userProfileRepository.updateAgreement(
      userId: uid,
      isAgreed: true,
    );

    userInfo.updateIsAgreed(true);

    // 다음 단계로
    emit(const ShowNicknameSheet());
  }

  /// 닉네임 완료 시 UI에서 호출
  Future<void> onNicknameCompleted(String nickname) async {
    userInfo.updateNickname(nickname);
    nav.selectIndex(0);
  }
}
