import 'package:bandi_official/string_extention.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';

class Calendar extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const Calendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late DateTime _selectedDate;
  bool _showMonthSelector = false;
  final int _minYear = 2000; // 최소 선택 연도 (필요에 따라 조정)

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate; // 초기 선택 날짜 지정
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        children: [
          _buildCalendarHeader(),
          const SizedBox(height: 20),
          Expanded(child: _buildCalendar(context)),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final locale = Localizations.localeOf(context).languageCode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMonthNavigationIcon(
          PhosphorIcons.caretLeft(),
          onTap: () => _changeMonth(-1),
          isEnabled: _canGoToPreviousMonth(),
        ),
        Row(
          children: [
            _showMonthSelector
                ? Row(
              children: locale == 'ko'
                  ? [
                _buildYearDropdown(),
                const SizedBox(width: 4),
                _buildMonthDropdown(),
              ]
                  : [
                _buildMonthDropdown(),
                const SizedBox(width: 4),
                _buildYearDropdown(),
              ],
            )
                : _buildMonthDisplay(),
            const SizedBox(width: 4),
            _buildCalendarToggleIcon(),
          ],
        ),
        _buildMonthNavigationIcon(
          PhosphorIcons.caretRight(),
          onTap: () => _changeMonth(1),
          isEnabled: _canGoToNextMonth(),
        ),
      ],
    );
  }

  Widget _buildMonthNavigationIcon(IconData icon, {required VoidCallback onTap, required bool isEnabled}) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: PhosphorIcon(
        icon,
        color: isEnabled
            ? BandiColor.foundationColor100(context)
            : BandiColor.foundationColor20(context),
        size: 14,
      ),
    );
  }

  Widget _buildYearDropdown() {
    final currentYear = DateTime.now().year;
    final locale = Localizations.localeOf(context).languageCode;

    return DropdownButton<int>(
      value: _selectedDate.year,
      isDense: true,
      alignment: Alignment.bottomCenter,
      menuMaxHeight: 150,
      items: List.generate(currentYear - _minYear + 1, (index) {
        final yearValue = _minYear + index;
        final yearText = locale == 'ko' ? "$yearValue년" : "$yearValue";

        return DropdownMenuItem<int>(
          value: yearValue,
          child: Text(
            yearText,
            style: BandiFont.bodySmall(context)?.copyWith(
              color: BandiColor.foundationColor100(context),
            ),
          ),
        );
      }),
      onChanged: (newYear) {
        if (newYear != null) {
          setState(() {
            final currentDate = DateTime.now();
            // 만약 선택한 연도가 현재 연도라면, 월이 현재월보다 클 경우 현재월로 조정
            int newMonth = _selectedDate.month;
            if (newYear == currentDate.year && newMonth > currentDate.month) {
              newMonth = currentDate.month;
            }
            _selectedDate = DateTime(newYear, newMonth, _selectedDate.day);
          });
        }
      },
      underline: const SizedBox(),
      icon: const SizedBox.shrink(),
    );
  }

  Widget _buildMonthDropdown() {
    return DropdownButton<int>(
      value: _selectedDate.month,
      isDense: true,
      alignment: Alignment.bottomCenter,
      menuMaxHeight: 150,
      items: List.generate(12, (index) {
        final monthValue = index + 1;
        final isDisabled = !_canSelectMonth(monthValue);
        final monthName = DateFormat.MMMM(Localizations.localeOf(context).toLanguageTag())
            .format(DateTime(0, monthValue));

        return DropdownMenuItem<int>(
          value: monthValue,
          enabled: !isDisabled,
          child: Text(
            monthName,
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
          setState(() {
            _selectedDate = DateTime(_selectedDate.year, newMonth, _selectedDate.day);
            _showMonthSelector = false;
          });
        }
      },
      underline: const SizedBox(),
      icon: const SizedBox.shrink(),
    );
  }

  Widget _buildMonthDisplay() {
    return GestureDetector(
      onTap: _toggleYearMonthSelector,
      child: Text(
        DateFormat('journal_calendar_header_1'.tr(context)).format(_selectedDate),
        style: BandiFont.bodySmall(context)?.copyWith(
          color: BandiColor.foundationColor100(context),
        ),
      ),
    );
  }

  Widget _buildCalendarToggleIcon() {
    return GestureDetector(
      onTap: _toggleYearMonthSelector,
      child: Image.asset(
        "./assets/images/icons/calendarToggle.png",
        scale: 1.3,
      ),
    );
  }

  void _toggleYearMonthSelector() {
    setState(() {
      _showMonthSelector = !_showMonthSelector;
    });
  }

  void _changeMonth(int increment) {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + increment);
    });
  }

  Widget _buildCalendar(BuildContext context) {
    final firstDayOfWeek = DateTime(2023, 1, 1); // 일요일
    final daysOfWeek = List.generate(7, (index) {
      final date = firstDayOfWeek.add(Duration(days: index));
      return DateFormat.E(Localizations.localeOf(context).toLanguageTag()).format(date);
    });

    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final numberOfDays = lastDayOfMonth.day;

    return Column(
      children: [
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
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: numberOfDays,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelectable = _canSelectDay(day);

              return GestureDetector(
                onTap: () {
                  if (isSelectable) {
                    setState(() {
                      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, day);
                      widget.onDateSelected(_selectedDate);
                    });
                  }
                },
                child: Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: _isHighlighted(day)
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

  bool _canSelectMonth(int month) {
    final currentDate = DateTime.now();
    return _selectedDate.year < currentDate.year ||
        (_selectedDate.year == currentDate.year && month <= currentDate.month);
  }

  bool _canGoToNextMonth() {
    final currentDate = DateTime.now();
    return _selectedDate.year < currentDate.year ||
        (_selectedDate.year == currentDate.year && _selectedDate.month < currentDate.month);
  }

  bool _canGoToPreviousMonth() {
    final minDate = DateTime(_minYear, 1, 1);
    // 이전 월로 갈 수 있는 조건: 현재 선택된 날짜가 최소 날짜 이후여야 함.
    return _selectedDate.isAfter(minDate);
  }

  bool _canSelectDay(int day) {
    final currentDate = DateTime.now();
    return !(_selectedDate.year == currentDate.year &&
        _selectedDate.month == currentDate.month &&
        day > currentDate.day);
  }

  bool _isHighlighted(int day) {
    return _selectedDate.day == day;
  }
}
