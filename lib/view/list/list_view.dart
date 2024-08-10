import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../components/appbar/appbar.dart';
import 'calendar.dart';
import 'diary_list.dart';

DateTime? _selectedDate;

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // custom appbar 일단 임시로 leading icon 변경
        appBar: CustomAppBar(
          title: '나의 일기',
          trailingIcon: PhosphorIcons.calendarDots(PhosphorIconsStyle.fill),
          onLeadingIconPressed: () {
            setState(() {
              _selectedDate = null;
            });
          },
          onTrailingIconPressed: () => _showCalendarBottomSheet(context),
          disableLeadingButton: false,
          disableTrailingButton: false,
          isVisibleLeadingButton: _selectedDate != null ? true : false,
          isVisibleTrailingButton: true,
        ),
        body: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.1),
          child: DiaryList(selectedDate: _selectedDate),
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
            selectedDate: _selectedDate ?? DateTime.now(),
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
                Navigator.pop(context); // Close the bottom sheet when a date is selected
              });
            },
          ),
        );
      },
    );
  }
}
