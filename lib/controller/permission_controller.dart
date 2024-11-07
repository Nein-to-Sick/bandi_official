import 'package:bandi_official/components/dialogue/dialogue.dart';
import 'package:bandi_official/components/no_reuse/reset_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController with ChangeNotifier {
  bool notificationPermission = false;

  bool getNotificationPermissionState() {
    return notificationPermission;
  }

  void toggleNotificationState(bool value) {
    notificationPermission = value;
    notifyListeners();
  }

  Future<bool> checkNotificationPermission() async {
    notificationPermission = await Permission.notification.isGranted;
    notifyListeners();
    return notificationPermission;
  }

  Future<void> requestNotificationPermission(BuildContext context) async {
    // 권한 상태 확인 후 처리
    if (await Permission.notification.isDenied &&
        !await Permission.notification.isPermanentlyDenied) {
      // 권한 요청
      PermissionStatus status = await Permission.notification.request();

      // 권한 거부 시 다이얼로그 표시
      if (!status.isGranted) {
        notificationPermission = false;
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomResetDialogue(
                text:
                    '알림 받지 않기를 선택하셨습니다.\n알림 권한 설정은 시스템 설정에서\n언제든지 변경할 수 있습니다.',
                onYesText: '닫기',
                onNoText: '설정하러 가기',
                onYesFunction: () {
                  Navigator.pop(context);
                },
                onNoFunction: () {
                  Navigator.pop(context);
                  openAppSettings(); // 시스템 설정으로 이동
                },
              );
            },
          );
        }
      } else {
        notificationPermission = true;
      }
    } else if (await Permission.notification.isPermanentlyDenied) {
      notificationPermission = false;
    } else if (await Permission.notification.isGranted) {
      notificationPermission = true;
    }

    // 상태 변경 알림
    notifyListeners();
  }
}
