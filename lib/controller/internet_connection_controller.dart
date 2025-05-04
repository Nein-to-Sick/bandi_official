import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetConnectionController with ChangeNotifier {
  bool checkOnce = false;
  Future<bool> checkNetworkConnectivity() async {
    // 한번만 체크하도록 설정
    if (checkOnce) return true;

    // 네트워크 연결 상태 확인
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      log('인터넷 연결 실패');
      return false;
    }

    // Google 서버를 통해 실제 인터넷 연결 확인
    try {
      final url = Uri.parse('https://www.google.com');
      final request = await HttpClient().getUrl(url);
      final response = await request.close();

      // 상태 코드가 200이면 인터넷 연결 성공
      if (response.statusCode == 200) {
        checkOnce = true;
        log('인터넷 연결 성공');
        return true;
      }
    } catch (e) {
      log('인터넷 연결 실패: $e');
      return false;
    }

    return false;
  }
}
