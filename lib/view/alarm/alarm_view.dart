import 'package:bandi_official/components/appbar/appbar.dart';
import 'package:bandi_official/components/loading/loading_page.dart';
import 'package:bandi_official/controller/alarm_controller.dart';
import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/controller/navigation_toggle_provider.dart';
import 'package:bandi_official/main.dart';
import 'package:bandi_official/model/alarm.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/home/home_view.dart';
import 'package:bandi_official/view/mail/detail_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badge_control/flutter_app_badge_control.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

class AlarmView extends StatefulWidget {
  const AlarmView({super.key});

  @override
  State<AlarmView> createState() => _AlarmViewState();
}

class _AlarmViewState extends State<AlarmView> {
  MailController? mailController;
  AlarmController? alarmController;

  @override
  void initState() {
    super.initState();
    _initializeControllers(); // 비동기 초기화 메서드 호출
  }

  Future<void> _initializeControllers() async {
    mailController = Provider.of<MailController>(context, listen: false);
    mailController!.updateNotificationsDataToDB();
    // remove message badge
    FlutterAppBadgeControl.removeBadge();
  }

  @override
  Widget build(BuildContext context) {
    final AlarmController alarmController = context.watch<AlarmController>();
    final MailController mailController = context.watch<MailController>();
    final HomeToWrite writeProvider = context.watch<HomeToWrite>();
    final NavigationToggleProvider navigationToggleProvider =
        context.watch<NavigationToggleProvider>();

    return PopScope(
      canPop: false,
      onPopInvoked: (value) {
        alarmController.toggleAlarmOpen(false);
        mailController.initializeNewNotificaitonCount();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: BandiColor.neutralColor80(context),
        appBar: CustomAppBar(
          title: '알림',
          titleColor: BandiColor.foundationColor80(context),
          leadingIconColor: BandiColor.foundationColor80(context),
          onLeadingIconPressed: () {
            alarmController.toggleAlarmOpen(false);
            mailController.initializeNewNotificaitonCount();
          },
          isVisibleTrailingButton: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: StreamBuilder<QuerySnapshot>(
                stream: alarmController.alarmStreamQuery(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: MyFireFlyProgressbar(loadingText: '로딩 중...'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        '알림이 없습니다',
                        style: BandiFont.headlineMedium(context)?.copyWith(
                          color: BandiColor.foundationColor100(context),
                        ),
                      ),
                    );
                  }

                  List<Alarm> notifications = snapshot.data!.docs.map((doc) {
                    return Alarm.fromFirestore(doc);
                  }).toList();

                  return ListView.builder(
                    controller: alarmController.alarmScrollController,
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      String timeAgo = alarmController
                          .formatTimeAgo(notifications[index].alarmTime);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                        child: GestureDetector(
                          onTap: () async {
                            // 편지, 공감 페이지 이동
                            if (notifications[index].type ==
                                AlarmType.likedDiary) {
                              Diary diary = await alarmController
                                  .readLikedDiaryDataFromDB(
                                      notifications[index].dataId);
                              writeProvider.readMyDiary(diary);
                              navigationToggleProvider.selectIndex(0);
                              writeProvider.toggleWrite();
                            } else if (notifications[index].type ==
                                AlarmType.letter) {
                              navigationToggleProvider.selectIndex(2);
                              mailController.updateSavedCurrentIndex(1);
                              mailController.toggleDetailView(true);

                              Letter letter =
                                  await alarmController.readLetterDataFromDB(
                                      notifications[index].dataId);

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                showDialog(
                                  context: alarmController.navigationContext,
                                  barrierDismissible: false,
                                  barrierColor: BandiColor.transparent(context),
                                  builder: (BuildContext context) {
                                    return DetailView(
                                      item: letter,
                                      mailController: mailController,
                                    );
                                  },
                                );
                              });
                            }

                            alarmController.toggleAlarmOpen(false);
                            mailController.initializeNewNotificaitonCount();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PhosphorIcon(
                                    (notifications[index].type ==
                                            AlarmType.likedDiary)
                                        ? PhosphorIcons.heart(
                                            PhosphorIconsStyle.fill)
                                        : PhosphorIcons.envelope(
                                            PhosphorIconsStyle.fill),
                                    color:
                                        BandiColor.foundationColor100(context),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notifications[index].title,
                                        style: BandiFont.titleSmall(context)
                                            ?.copyWith(
                                          color: BandiColor.foundationColor100(
                                              context),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        timeAgo,
                                        style: BandiFont.labelSmall(context)
                                            ?.copyWith(
                                          color: BandiColor.foundationColor40(
                                              context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              (index < mailController.newNotificationCount)
                                  ? ClipOval(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        color: BandiColor.accentColorYellow(
                                            context),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
          ),
        ),
      ),
    );
  }
}
