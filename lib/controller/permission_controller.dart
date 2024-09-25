import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController with ChangeNotifier {
  Future<void> requestNotificationPermission(BuildContext context) async {
    // permission handler
    if (await Permission.notification.isDenied &&
        !await Permission.notification.isPermanentlyDenied) {
      PermissionStatus status = await Permission.notification.request();

      //  불허용 경우
      if (!status.isGranted) {
        // 권한없음을 다이얼로그로 알림
        // TODO: 권한 설정 방법 논의 및 디자인 필요
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                content: const Text("권한 설정을 확인해주세요."),
                actions: [
                  TextButton(
                    onPressed: () {
                      // 앱 설정으로 이동
                      openAppSettings();
                    },
                    child: const Text('설정하기'),
                  ),
                ],
              );
            });
      }
    }
  }
}
