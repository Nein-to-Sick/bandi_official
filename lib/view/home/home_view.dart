import 'package:bandi_official/controller/alarm_controller.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/controller/permission_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/mail/new_letter_popup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/no_reuse/home_top_bar.dart';
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
      PermissionController permissionController = PermissionController();
      AlarmController alarmController =
          Provider.of<AlarmController>(context, listen: false);
      permissionController.requestNotificationPermission(context);
      // for fcm token changes
      alarmController.firebaseOnTokenRefresh();
    });
  }

  void newLetterPageReturn(BuildContext context) async {
    MailController mailController = Provider.of<MailController>(context);

    // read new letter data once after first login
    if (!mailController.loadNewLetterDataOnce) {
      Tuple<dynamic, dynamic> result =
          await mailController.checkForNewLetterAndsaveLetterToLocal();
      if (result.item1 && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const NewLetterPopuView(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        });
      }
    } else {
      dev.log('did not read new letter data');
    }
  }

  @override
  Widget build(BuildContext context) {
    newLetterPageReturn(context);

    return Scaffold(
      backgroundColor: BandiColor.transparent(context),
      body: const HomeTopBar(),
    );
  }
}
