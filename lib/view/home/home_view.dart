import 'package:bandi_official/view/alarm/controller/alarm_controller.dart';
import 'package:bandi_official/controller/permission_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_root_layer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PermissionController permissionController =
          Provider.of<PermissionController>(context, listen: false);

      AlarmController alarmController =
          Provider.of<AlarmController>(context, listen: false);
      permissionController.requestNotificationPermission(context);
      // for fcm token changes
      alarmController.firebaseOnTokenRefresh();
    });
  }

  /// 홈 화면에서 바로 편지 뜨는 거 방지 : 체크 후 삭제
  // void checkNewLetterAndNewNotificationsPageReturn(BuildContext context) async {
  //   MailController mailController = Provider.of<MailController>(context);
  //   AlarmController alarmController = Provider.of<AlarmController>(context);
  //
  //   // read new letter data once after first login
  //   if (!mailController.loadNewLetterAndNotificationsDataOnce) {
  //     alarmController.firebaseLanguageSetting(
  //         Localizations.localeOf(context).languageCode);
  //     Tuple<dynamic, dynamic> result = await mailController
  //         .checkForNewLetterNewNotificationsAndSaveLetterToLocal();
  //     if (result.item1 && mounted) {
  //       WidgetsBinding.instance.addPostFrameCallback((_) async {
  //         Navigator.push(
  //           context,
  //           PageRouteBuilder(
  //             pageBuilder: (context, animation, secondaryAnimation) =>
  //                 const NewLetterPopuView(),
  //             transitionsBuilder:
  //                 (context, animation, secondaryAnimation, child) {
  //               return FadeTransition(
  //                 opacity: animation,
  //                 child: child,
  //               );
  //             },
  //             transitionDuration: const Duration(milliseconds: 400),
  //           ),
  //         );
  //       });
  //     }
  //   } else {
  //     dev.log('did not read new letter and new notifications data');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // checkNewLetterAndNewNotificationsPageReturn(context);

    return Scaffold(
      backgroundColor: BandiColor.transparent(context),
      body: const HomeRootLayer(),
    );
  }
}
