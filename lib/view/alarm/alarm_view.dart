import 'package:bandi_official/components/appbar/appbar.dart';
import 'package:bandi_official/controller/alarm_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

// TODO: 공감한 일기 추가, 편지 발송 시 알람 전송 구현 필요
// 구현 방법 논의 필요
class AlarmView extends StatelessWidget {
  const AlarmView({super.key});

  @override
  Widget build(BuildContext context) {
    final AlarmController alarmController = context.watch<AlarmController>();

    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        alarmController.toggleAlarmOpen(false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: BandiColor.neutralColor80(context),
        appBar: CustomAppBar(
          title: '알림',
          titleColor: BandiColor.foundationColor80(context),
          trailingIcon:
              PhosphorIcons.arrowCounterClockwise(PhosphorIconsStyle.regular),
          leadingIconColor: BandiColor.foundationColor80(context),
          onLeadingIconPressed: () {
            alarmController.toggleAlarmOpen(false);
          },
          onTrailingIconPressed: () {},
          disableLeadingButton: false,
          disableTrailingButton: true,
          isVisibleLeadingButton: true,
          isVisibleTrailingButton: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ListView.builder(
              controller: alarmController.alarmScrollController,
              itemCount: 100,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: GestureDetector(
                    onTap: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.heart(PhosphorIconsStyle.fill),
                              color: BandiColor.foundationColor100(context),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '누군가 나의 기록에 공감했어요',
                                  style:
                                      BandiFont.titleSmall(context)?.copyWith(
                                    color:
                                        BandiColor.foundationColor100(context),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  '1분 전',
                                  style:
                                      BandiFont.labelSmall(context)?.copyWith(
                                    color:
                                        BandiColor.foundationColor40(context),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ClipOval(
                          child: Container(
                            width: 10,
                            height: 10,
                            color: BandiColor.accentColorYellow(context),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
