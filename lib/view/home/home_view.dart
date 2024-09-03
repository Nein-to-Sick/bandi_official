import 'package:bandi_official/controller/mail_controller.dart';
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
  MailController? mailController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      mailController = Provider.of<MailController>(context, listen: false);

      if (!mailController!.loadNewLetterDataOnce &&
          await mailController!.checkForNewLetterAndsaveLetterToLocal()) {
        if (mounted) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BandiColor.transparent(context),
      body: const HomeTopBar(),
    );
  }
}
