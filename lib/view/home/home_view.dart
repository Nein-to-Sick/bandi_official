import 'package:bandi_official/view/alarm/controller/alarm_controller.dart';
import 'package:bandi_official/controller/permission_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_root_layer.dart';
import 'dart:developer' as dev;

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

  void checkNewLetterAndNewNotificationsPageReturn(BuildContext context) async {
    MailController mailController = Provider.of<MailController>(context);

    // read new letter data once after first login
    if (!mailController.loadNewLetterAndNotificationsDataOnce) {
      AlarmController alarmController = Provider.of<AlarmController>(context);
      String langCode = Localizations.localeOf(context).languageCode;
      alarmController.subscribeToDailyReminder(langCode);
      alarmController.firebaseLanguageSetting(
          Localizations.localeOf(context).languageCode);
      await mailController
          .checkForNewLetterNewNotificationsAndSaveLetterToLocal();
    } else {
      dev.log('did not read new letter and new notifications data');
    }
  }

  @override
  Widget build(BuildContext context) {
    checkNewLetterAndNewNotificationsPageReturn(context);

    return Scaffold(
      backgroundColor: BandiColor.transparent(context),
      body: const HomeRootLayer(),
    );
  }
}
