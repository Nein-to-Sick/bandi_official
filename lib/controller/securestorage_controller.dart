import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as dev;

class SecureStorageProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // 저장할 로그인 정보
  String? _loginMethod;
  String? _googleAccessToken;
  String? _appleIdentityToken;
  String? _appleAuthorizationCode;

  String? _userID;
  // String? email;
  // String? nickname;

  // 게터
  String? get loginMethod => _loginMethod;
  String? get googleAccessToken => _googleAccessToken;
  String? get appleIdentityToken => _appleIdentityToken;
  String? get appleAuthorizationCode => _appleAuthorizationCode;

  void setUID(String userID) {
    _userID = userID;
    return;
  }

  // 로그인 후 Google 토큰 및 로그인 방식 저장
  Future<void> saveGoogleLoginInfo(String accessToken) async {
    try {
      await _storage.write(key: 'login_method', value: 'google');
      await _storage.write(key: 'google_access_token', value: accessToken);
      _loginMethod = 'google';
      _googleAccessToken = accessToken;

      // 로그 출력
      dev.log("Google login saved with access token and ID token");

      notifyListeners();
    } catch (error) {
      dev.log("Error saving Google login info: $error");
    }
  }

  // 로그인 후 Apple 토큰 및 로그인 방식 저장
  Future<void> saveAppleLoginInfo(
      String identityToken, String authorizationCode) async {
    try {
      await _storage.write(key: 'login_method', value: 'apple');
      await _storage.write(key: 'apple_identity_token', value: identityToken);
      await _storage.write(
          key: 'apple_authorization_code', value: authorizationCode);
      _loginMethod = 'apple';
      _appleIdentityToken = identityToken;
      _appleAuthorizationCode = authorizationCode;

      // 로그 출력
      dev.log("Apple login saved with identity token and authorization code");

      notifyListeners();
    } catch (error) {
      dev.log("Error saving Apple login info: $error");
    }
  }

  // 앱 시작 시 로그인 정보 로드
  Future<void> loadLoginInfo() async {
    try {
      _loginMethod = await _storage.read(key: 'login_method');
      if (_loginMethod == 'google') {
        _googleAccessToken = await _storage.read(key: 'google_access_token');
      } else if (_loginMethod == 'apple') {
        _appleIdentityToken = await _storage.read(key: 'apple_identity_token');
        _appleAuthorizationCode =
            await _storage.read(key: 'apple_authorization_code');
      }

      // 로그 출력
      dev.log("Login method: $_loginMethod loaded with associated tokens");

      notifyListeners();
    } catch (error) {
      dev.log("Error loading login info: $error");
    }
  }

  // 로그아웃 또는 계정 탈퇴 시 모든 로그인 정보 삭제
  Future<void> clearLoginInfo() async {
    try {
      await _storage.deleteAll();
      _loginMethod = null;
      _googleAccessToken = null;
      _appleIdentityToken = null;
      _appleAuthorizationCode = null;

      // 로그 출력
      dev.log("All login information cleared from SecureStorage");

      notifyListeners();
    } catch (error) {
      dev.log("Error clearing login info: $error");
    }
  }

  bool get isLoggedIn => _loginMethod != null;
}
