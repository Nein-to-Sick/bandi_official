import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../view/home/write_diary.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final writeProvider = Provider.of<HomeToWrite>(context);

    return Stack(
      children: [
        // 일기 open
        AnimatedOpacity(
            opacity: writeProvider.write ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: writeProvider.write ? const WriteDiary() : Container()),
        // home
        !writeProvider.write
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // top icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PhosphorIcon(
                            PhosphorIcons.speakerSimpleHigh(
                                PhosphorIconsStyle.fill),
                            color: BandiColor.neutralColor100(context),
                          ),
                          Row(
                            children: [
                              PhosphorIcon(
                                PhosphorIcons.chat(PhosphorIconsStyle.fill),
                                color: BandiColor.neutralColor100(context),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              PhosphorIcon(
                                PhosphorIcons.bell(PhosphorIconsStyle.fill),
                                color: BandiColor.neutralColor100(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // write button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 100.0, right: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                writeProvider.toggleWrite();
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    BandiColor.neutralColor60(context),
                                child: PhosphorIcon(
                                  PhosphorIcons.plus(PhosphorIconsStyle.bold),
                                  size: 21,
                                  color: BandiColor.foundationColor80(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Container()
      ],
    );
  }
}
