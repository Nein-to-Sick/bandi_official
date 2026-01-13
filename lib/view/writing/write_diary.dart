import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/home_to_write.dart';
import '../../theme/custom_theme_data.dart';
import 'first_step.dart';
import 'modify_step.dart';
import 'second_step.dart';

class WriteDiary extends StatelessWidget {
  const WriteDiary({super.key});

  @override
  Widget build(BuildContext context) {
    final writeProvider = Provider.of<HomeToWrite>(context);

    return PopScope(
      canPop: false,
      child: writeProvider.step == 1
          ? BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: BandiEffects.blurLarge,
                  sigmaY: BandiEffects.blurLarge),
              child: Container(
                  color: BandiColor.neutralColor10(context),
                  child: const FirstStep()))
          : writeProvider.step == 2
              ? const SecondStep()
              : BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: BandiEffects.blurLarge,
                      sigmaY: BandiEffects.blurLarge),
                  child: Container(
                      color: BandiColor.neutralColor10(context),
                      child: const ThirdStep())),
    );
  }
}
