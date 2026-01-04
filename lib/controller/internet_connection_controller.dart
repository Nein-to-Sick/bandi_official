import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetConnectionController with ChangeNotifier {
  // 현재 인터넷 연결 상태를 저장하는 변수
  bool _hasConnection = false;

  // 외부에서 상태를 읽을 수 있게 하는 getter
  bool get hasConnection => _hasConnection;

  // 네트워크 상태 변화를 감지하는 스트림 구독 변수
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  InternetConnectionController() {
    // 컨트롤러가 생성될 때 모니터링 시작
    _initialize();
  }

  void _initialize() {
    // 1. 앱 시작 시 현재 상태 확인
    checkNetworkConnectivity();

    // 2. 실시간 네트워크 상태 변화 감지 리스너 등록
    // (connectivity_plus 최신 버전은 List<ConnectivityResult>를 반환합니다)
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      log('네트워크 상태 변화 감지됨: $results');
      checkNetworkConnectivity();
    });
  }

  /// 네트워크 연결 상태를 확인하고 _hasConnection을 업데이트하는 함수
  Future<bool> checkNetworkConnectivity() async {
    // 1단계: 기기의 하드웨어적 연결 상태 확인 (Wi-Fi, 모바일 데이터 등)
    final connectivityResult = await Connectivity().checkConnectivity();

    // 연결된 네트워크 인터페이스가 없는 경우
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _updateConnectionStatus(false);
      return false;
    }

    // 2단계: 실제 인터넷 통신이 가능한지 확인 (DNS Lookup)
    bool isConnected = await _checkRealInternetAccess();

    // 상태 업데이트
    _updateConnectionStatus(isConnected);

    return isConnected;
  }

  /// 실제 인터넷 접속 가능 여부를 확인하는 내부 함수
  Future<bool> _checkRealInternetAccess() async {
    try {
      // 1차 시도: Google DNS 조회
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      // 1차 실패 시 2차 시도: Cloudflare DNS 조회 (백업)
      try {
        final result = await InternetAddress.lookup('one.one.one.one');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (e) {
        log('실제 인터넷 연결 확인 실패: $e');
      }
    }
    return false;
  }

  /// 상태가 변경되었을 때만 리스너들에게 알림
  void _updateConnectionStatus(bool status) {
    // 기존 상태와 다를 경우에만 notifyListeners 호출 (불필요한 리빌드 방지)
    if (_hasConnection != status) {
      _hasConnection = status;
      log('인터넷 연결 상태 업데이트: $_hasConnection');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // 컨트롤러가 해제될 때 스트림 구독도 반드시 취소해야 메모리 누수 방지
    _subscription.cancel();
    super.dispose();
  }
}
