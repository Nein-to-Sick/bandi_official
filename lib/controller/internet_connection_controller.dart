import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetConnectionController with ChangeNotifier {
  Future<bool> checkNetworkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      log('인터넷 연결 실패');
      return false;
    }

    // 실제 인터넷 연결 확인 (Google 핑 테스트)
    try {
      final url = Uri.parse('https://www.google.com');
      final request = await HttpClient().getUrl(url);
      final response = await request.close();

      if (response.statusCode == 200) {
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
