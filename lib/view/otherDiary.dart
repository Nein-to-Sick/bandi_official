import 'dart:ui';

import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../components/button/primary_button.dart';

class OtherDiary extends StatelessWidget {
  const OtherDiary({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
          sigmaX: BandiEffects.backgroundBlur(),
          sigmaY: BandiEffects.backgroundBlur()),
      child: Container(
        color: BandiColor.neutralColor10(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                actions: [
                  PhosphorIcon(
                    PhosphorIcons.x(),
                    color: BandiColor.neutralColor40(context),
                  )
                ],
              ),
              body: Center(
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "반디님과 비슷한 친구에게\n공감을 전달해주세요!",
                            textAlign: TextAlign.center,
                            style: BandiFont.headlineMedium(context)
                                ?.copyWith(color: BandiColor.neutralColor100(context)),
                          ),
                          const SizedBox(height: 40,),
                          Image.asset(
                            "./assets/images/icons/otherDiary.png",
                            scale: 2,
                          ),
                          const SizedBox(height: 20,),
                        ],
                      ),
                    ),
                    CustomPrimaryButton(title: '일기 보기', onPrimaryButtonPressed: (){}, disableButton: false,)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
