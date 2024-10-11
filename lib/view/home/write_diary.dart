import 'dart:ui';
import 'package:bandi_official/view/home/write/first_step.dart';
import 'package:bandi_official/view/home/write/second_step.dart';
import 'package:bandi_official/view/home/write/modify_step.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/home_to_write.dart';
import '../../theme/custom_theme_data.dart';

class WriteDiary extends StatelessWidget {
  const WriteDiary({super.key});

  @override
  Widget build(BuildContext context) {
    final writeProvider = Provider.of<HomeToWrite>(context);

    return BackdropFilter(
      filter: ImageFilter.blur(
          sigmaX: BandiEffects.backgroundBlur(),
          sigmaY: BandiEffects.backgroundBlur()),
      child: Container(
        color: BandiColor.neutralColor10(context),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
            child: writeProvider.step == 1
                ? const FirstStep() :
            writeProvider.step == 2 ?
                const SecondStep() : const ThirdStep(),
          ),
        ),
      ),
    );
  }
}
