import 'package:bandi_official/controller/alarm_controller.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/controller/permission_controller.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/mail/new_letter_popup.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../components/no_reuse/home_top_bar.dart';
import 'dart:developer' as dev;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MailController? mailController;
  InheritedWidget? _myInheritedWidget;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PermissionController permissionController = PermissionController();
      AlarmController alarmController =
          Provider.of<AlarmController>(context, listen: false);
      permissionController.requestNotificationPermission(context);
      mailController = Provider.of<MailController>(context, listen: false);

      // for fcm token changes
      alarmController.firebaseOnTokenRefresh();

      // read new letter data once after first login
      if (!mailController!.loadNewLetterDataOnce) {
        Tuple<dynamic, dynamic> result =
            await mailController!.checkForNewLetterAndsaveLetterToLocal();
        if (result.item1 && mounted) {
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
        }
      } else {
        dev.log('did not read new letter data');
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtain and store a reference to the ancestor widget
    _myInheritedWidget =
        context.dependOnInheritedWidgetOfExactType<InheritedWidget>();
  }

  @override
  void dispose() {
    // Safely refer to the ancestor widget
    if (_myInheritedWidget != null) {
      // Perform actions involving _myInheritedWidget
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BandiColor.transparent(context),
      body: const HomeTopBar(),
    );
  }
}
