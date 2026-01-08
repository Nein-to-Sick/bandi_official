import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/bottom_sheet/show_floating_confirm_sheet.dart';

class PermissionController with ChangeNotifier {
  bool notificationPermission = false;

  bool getNotificationPermissionState() {
    return notificationPermission;
  }

  Future<bool> checkNotificationPermission() async {
    // 현재 권한 상태를 가져옴
    bool currentPermissionStatus = await Permission.notification.isGranted;

    // 권한 상태가 변경된 경우에만 업데이트 및 notifyListeners 호출
    if (notificationPermission != currentPermissionStatus) {
      notificationPermission = currentPermissionStatus;
      notifyListeners();
    }

    return notificationPermission;
  }

  Future<void> requestNotificationPermission(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isNotificationPermissionRequested =
        prefs.getBool('isNotificationPermissionRequested') ?? false;

    // 권한 상태 확인 후 처리
    if (!isNotificationPermissionRequested &&
        await Permission.notification.isDenied &&
        !await Permission.notification.isPermanentlyDenied) {
      // 권한 요청
      PermissionStatus status = await Permission.notification.request();

      // 권한 거부 시 다이얼로그 표시
      if (!status.isGranted) {
        notificationPermission = false;
        if (context.mounted) {
          final ok = await showFloatingConfirmSheet(
            context,
            title: '알림을 받지 않으시나요?',
            description: '알림이 꺼지면 반디의 답장을 바로 확인할 수 없어요.',
            cancelText: '취소',
            confirmText: '알림 끄기',
          );

          if (ok == false) {
            openAppSettings();
          }
        }
      } else {
        notificationPermission = true;
      }
    } else if (await Permission.notification.isPermanentlyDenied) {
      notificationPermission = false;
    } else if (await Permission.notification.isGranted) {
      notificationPermission = true;
    }

    // 권한 요청 여부 저장
    await prefs.setBool('isNotificationPermissionRequested', true);
    // 상태 변경 알림
    notifyListeners();
  }
}
