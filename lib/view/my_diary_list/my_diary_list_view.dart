import 'package:bandi_official/analytics/log_my_past_diary_tracking.dart';
import 'package:bandi_official/components/appbar/new_custom_appbar.dart';
import 'package:bandi_official/components/bottom_sheet/calendar_bottom_sheet.dart';
import 'package:bandi_official/components/loading/loading_page.dart';
import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/controller/navigation_toggle_provider.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/localization/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/my_diary_list/controller/my_diary_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

class MyDiaryListView extends StatefulWidget {
  const MyDiaryListView({super.key});

  @override
  State<MyDiaryListView> createState() => _MyDiaryListViewState();
}

class _MyDiaryListViewState extends State<MyDiaryListView>
    with SingleTickerProviderStateMixin {
  late MyDiaryListController myDiaryListController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      myDiaryListController =
          Provider.of<MyDiaryListController>(context, listen: false);

      myDiaryListController.initScrollControllers();

      myDiaryListController.loadDataAndSetting().then((value) {
        myDiaryListController.restoreMyDiaryScrollPosition();

        if (!myDiaryListController.isMyDiaryListenerAdded) {
          // when screen reached nearly bottom of the list load more past data
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            myDiaryListController.myDiaryScrollController
                .addListener(_scrollListener);
            myDiaryListController.toggleIsMyDiaryListenerAdded(true);
          });
        }
      });
    });

    super.initState();
  }

  void _scrollListener() async {
    if (!myDiaryListController.loadMoreMyDiaryData ||
        myDiaryListController.isLoadingMyDiary) {
      return;
    }

    final position = myDiaryListController.myDiaryScrollController.position;

    if (position.maxScrollExtent - position.pixels <= 200) {
      bool hasMore = await myDiaryListController.loadMoreMyDiary();
      myDiaryListController.toggleLoadMoreMyDiaryData(hasMore);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      myDiaryListController.myDiaryScrollController
          .removeListener(_scrollListener);
      myDiaryListController.toggleIsMyDiaryListenerAdded(false);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyDiaryListController myDiaryListController =
        context.watch<MyDiaryListController>();

    final allDiaries = myDiaryListController.myDiaryList;
    final DateTime? filterDate = myDiaryListController.myDiaryFilteredDate;

    // 선택된 날짜가 있으면 해당 날짜만, 없으면 전체 리스트
    final displayList = filterDate == null
        ? allDiaries
        : allDiaries.where((diary) {
            DateTime diaryDate = diary.createdAt.toDate();
            return diaryDate.year == filterDate.year &&
                diaryDate.month == filterDate.month &&
                diaryDate.day == filterDate.day;
          }).toList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: BandiColor.transparent(context),
        appBar: NewCustomAppBar(
          appBarType: AppBarType.subtitleNeutral,
          title: 'journal_title'.tr(context),
          // leftActionButtonIcon: PhosphorIcons.bell(PhosphorIconsStyle.thin),
          // onLeftActionButtonPressed: () async {
          //   AlarmController alarmController =
          //       Provider.of<AlarmController>(context, listen: false);

          //   // local noti test
          //   // alarmController.testAllNotificationTypes();
          //   // fcm noti test
          //   // await alarmController.runFcmTest();
          // },
          rightActionButtonIcon:
              PhosphorIcons.calendarBlank(PhosphorIconsStyle.thin),
          rightActionButtonColor:
              (myDiaryListController.myDiaryFilteredDate != null)
                  ? BandiColor.accentColorYellow(context)
                  : null,
          onRightActionButtonPressed: () async {
            List<DateTime> events =
                await myDiaryListController.getAllMyDiaryDatesFromLocal();

            if (!mounted) return;

            CalendarBottomSheet(
              initialDate: myDiaryListController.myDiaryFilteredDate,
              mode: CalendarMode.date,
              eventDates: events,
              onDateSelected: (date) {
                myDiaryListController.updateMyDiaryCalendarSelectedDate(date);
              },
            ).show(context);
          },
          disableLefttActionButton: false,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: (myDiaryListController.isLoading)
              ? MyFireFlyProgressbar(
                  loadingText: 'loading'.tr(context),
                )
              : (displayList.isEmpty)
                  ? _buildEmptyState(
                      filterDate != null, myDiaryListController, context)
                  : Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ListView.builder(
                        controller:
                            myDiaryListController.myDiaryScrollController,
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              myDiaryWidget(displayList[index],
                                  myDiaryListController, context),
                              if (index == displayList.length - 1)
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).padding.bottom +
                                          94,
                                )
                            ],
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}

// 데이터가 없을 때 표시할 위젯
Widget _buildEmptyState(bool isFiltered,
    MyDiaryListController myDiaryListController, BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'journal_no_diary'.tr(context),
          style: BandiFont.headlineMedium(context)?.copyWith(
            color: BandiColor.neutralColor80(context),
          ),
        ),
        // const SizedBox(height: 24),
        // if (isFiltered)
        //   TextButton(
        //     onPressed: () => myDiaryListController.updateCalendarSelectedDate(null),
        //     child: Text(
        //       'calendar_selection_reset'.tr(context),
        //       style: BandiFont.labelMedium(context)
        //           ?.copyWith(color: BandiColor.neutralColor80(context)),
        //     ),
        //   ),
      ],
    ),
  );
}

Widget myDiaryWidget(
    Diary diary, MyDiaryListController mailController, BuildContext context) {
  DateTime parsedDate = diary.createdAt.toDate();
  final writeProvider = Provider.of<HomeToWrite>(context);
  final navigationToggleProvider =
      Provider.of<NavigationToggleProvider>(context);

  String date = DateFormat('detail_view_diary_date_form'.tr(context),
          'detail_view_date_form_country'.tr(context))
      .format(parsedDate);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: GestureDetector(
      onTap: () {
        Diary diaryCopy = Diary(
          userId: diary.userId,
          title: diary.title,
          content: diary.content,
          emotion: diary.emotion,
          createdAt: diary.createdAt,
          updatedAt: diary.updatedAt,
          reaction: diary.reaction,
          diaryId: diary.diaryId,
          cheerText: diary.cheerText,
        );

        writeProvider.readMyDiary(diaryCopy);
        navigationToggleProvider.selectIndex(0);
        writeProvider.toggleWrite();
        logMyPastDiaryTracking();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: BandiColor.transparent(context),
          border: Border(
            bottom:
                BorderSide(color: BandiColor.neutralColor20(context), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              diary.title,
              style: BandiFont.titleSmall(context)
                  ?.copyWith(color: BandiColor.neutralColor90(context)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              date,
              style: BandiFont.labelSmall(context)
                  ?.copyWith(color: BandiColor.neutralColor60(context)),
            ),
          ],
        ),
      ),
    ),
  );
}
