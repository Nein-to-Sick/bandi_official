import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart'; // For date formatting and manipulation

import '../../components/appbar/appbar.dart';
import 'diary_list.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime? _highlightedDate; // Highlighted (selected) date
  bool _showMonthSelector = false; // Month selector dropdown visibility

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          title: '나의 일기',
          trailingIcon: PhosphorIcons.calendarDots(PhosphorIconsStyle.fill),
          onLeadingIconPressed: () {},
          onTrailingIconPressed: () async {
            await showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setModalState) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      padding: const EdgeInsets.only(left: 18, right: 18, top: 23),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    _selectedDate = DateTime(
                                      _selectedDate.year,
                                      _selectedDate.month - 1,
                                    );
                                  });
                                },
                                child: PhosphorIcon(
                                  PhosphorIcons.caretLeft(),
                                  color: BandiColor.foundationColor100(context),
                                  size: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  _showMonthSelector
                                      ? DropdownButton<int>(
                                    value: _selectedDate.month,
                                    isDense: true,
                                    items: List.generate(12, (index) {
                                      final monthValue = index + 1;
                                      final isDisabled = !_canSelectMonth(monthValue);
                                      return DropdownMenuItem<int>(
                                        value: monthValue,
                                        enabled: !isDisabled,
                                        child: Text(
                                          "$monthValue월",
                                          style: BandiFont.bodySmall(context)?.copyWith(
                                            color: isDisabled
                                                ? BandiColor.foundationColor40(context)
                                                : BandiColor.foundationColor100(context),
                                          ),
                                        ),
                                      );
                                    }),
                                    onChanged: (newMonth) {
                                      if (newMonth != null && _canSelectMonth(newMonth)) {
                                        setModalState(() {
                                          _selectedDate = DateTime(
                                            _selectedDate.year,
                                            newMonth,
                                          );
                                          _showMonthSelector = false;
                                        });
                                      }
                                    },
                                    underline: const SizedBox(), // Remove underline
                                    icon: const SizedBox.shrink(), // Remove the dropdown arrow
                                  )
                                      : GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        _showMonthSelector = true;
                                      });
                                    },
                                    child: Text(
                                      DateFormat('yyyy년 M월').format(_selectedDate),
                                      style: BandiFont.bodySmall(context)?.copyWith(
                                        color: BandiColor.foundationColor100(context),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _toggleYearMonthSelector(setModalState);
                                    },
                                    child: Image.asset(
                                      "./assets/images/icons/calendarToggle.png",
                                      scale: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_canGoToNextMonth()) {
                                    setModalState(() {
                                      _selectedDate = DateTime(
                                        _selectedDate.year,
                                        _selectedDate.month + 1,
                                      );
                                    });
                                  }
                                },
                                child: PhosphorIcon(
                                  PhosphorIcons.caretRight(),
                                  color: _canGoToNextMonth()
                                      ? BandiColor.foundationColor100(context)
                                      : BandiColor.foundationColor20(context), // Disable color
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: _buildCalendar(context, setModalState),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
            // When the bottom sheet is dismissed, set _showMonthSelector to false
            setState(() {
              _showMonthSelector = false;
            });
          },
          disableLeadingButton: false,
          disableTrailingButton: false,
          isVisibleLeadingButton: false,
          isVisibleTrailingButton: true,
        ),
        body: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.1),
          child: const DiaryList(),
        ),
      ),
    );
  }

  bool _canSelectMonth(int month) {
    final currentDate = DateTime.now();
    return _selectedDate.year < currentDate.year ||
        (_selectedDate.year == currentDate.year &&
            month <= currentDate.month);
  }

  bool _canGoToNextMonth() {
    final currentDate = DateTime.now();
    return _selectedDate.year < currentDate.year ||
        (_selectedDate.year == currentDate.year &&
            _selectedDate.month < currentDate.month);
  }

  bool _canSelectDay(int day) {
    final currentDate = DateTime.now();
    return !(_selectedDate.year == currentDate.year &&
        _selectedDate.month == currentDate.month &&
        day > currentDate.day);
  }

  void _toggleYearMonthSelector(setModalState) {
    // 현재 _showMonthSelector의 상태를 반전시킵니다.
    setModalState(() {
      _showMonthSelector = !_showMonthSelector;
    });
  }

  Widget _buildCalendar(BuildContext context, setModalState) {
    // Define the days of the week
    final daysOfWeek = ['일', '월', '화', '수', '목', '금', '토'];

    // Calculate the number of days in the selected month
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final numberOfDays = lastDayOfMonth.day;

    return Column(
      children: [
        // Row for days of the week
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: daysOfWeek.map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: BandiFont.labelSmall(context)?.copyWith(
                    color: BandiColor.foundationColor40(context),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8), // Space between the day names and the dates
        // Calendar grid for dates
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: numberOfDays, // Number of days in the month
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelectable = _canSelectDay(day);

              return GestureDetector(
                onTap: () {
                  if (isSelectable) {
                    setModalState(() {
                      _highlightedDate = DateTime(_selectedDate.year, _selectedDate.month, day);
                    });
                  }
                },
                child: Center(
                  child: Container(
                    width: 28, // Set fixed width
                    height: 28, // Set fixed height
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: _highlightedDate != null &&
                          _highlightedDate!.year == _selectedDate.year &&
                          _highlightedDate!.month == _selectedDate.month &&
                          _highlightedDate!.day == day
                          ? Border.all(color: BandiColor.foundationColor100(context))
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: BandiFont.bodySmall(context)?.copyWith(
                        color: isSelectable
                            ? BandiColor.foundationColor100(context)
                            : BandiColor.foundationColor20(context),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
