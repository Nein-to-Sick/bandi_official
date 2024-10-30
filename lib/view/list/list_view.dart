import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../components/appbar/appbar.dart';
import '../../controller/date_provider.dart';
import 'calendar.dart';
import 'diary_list.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: BandiColor.transparent(context),
        // custom appbar 일단 임시로 leading icon 변경
        appBar: CustomAppBar(
          title: '나의 일기',
          trailingIcon: PhosphorIcons.calendarDots(PhosphorIconsStyle.fill),
          onLeadingIconPressed: () {
            setState(() {
              dateProvider.clearDate();
            });
          },
          onTrailingIconPressed: () => _showCalendarBottomSheet(context),
          isVisibleLeadingButton: dateProvider.selectedDate != null,
        ),
        body: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.1),
          child: DiaryList(selectedDate: dateProvider.selectedDate),
        ),
      ),
    );
  }

  Future<void> _showCalendarBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 18, right: 18, top: 23),
          child: Calendar(
            selectedDate: Provider.of<DateProvider>(context, listen: false)
                .selectedDate ??
                DateTime.now(),
            onDateSelected: (date) {
              Provider.of<DateProvider>(context, listen: false)
                  .setSelectedDate(date);
              Navigator.pop(context); // Close the bottom sheet when a date is selected
            },
          ),
        );
      },
    );
  }
}
