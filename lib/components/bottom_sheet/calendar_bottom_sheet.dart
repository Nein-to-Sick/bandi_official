import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// 프로젝트 환경에 맞춰 import 경로 확인
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/localization/string_extention.dart';

/// 캘린더 모드 정의
enum CalendarMode {
  date, // 연, 월, 일 선택 (기본)
  month, // 연, 월 선택
}

class CalendarBottomSheet {
  final DateTime? initialDate;
  final ValueChanged<DateTime?> onDateSelected;
  final List<DateTime>? eventDates;
  final CalendarMode mode;

  CalendarBottomSheet({
    this.initialDate,
    required this.onDateSelected,
    this.eventDates,
    this.mode = CalendarMode.date,
  });

  Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: BandiColor.transparent(context),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            height: 420,
            decoration: BoxDecoration(
              color: BandiColor.neutralColor80(context),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(BandiEffects.radiusValueSmall)),
            ),
            child: _CalendarContent(
              initialDate: initialDate,
              onDateSelected: onDateSelected,
              eventDates: eventDates ?? [],
              mode: mode,
            ),
          ),
        );
      },
    );
  }
}

class _CalendarContent extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime?> onDateSelected;
  final List<DateTime> eventDates;
  final CalendarMode mode;

  const _CalendarContent({
    required this.initialDate,
    required this.onDateSelected,
    required this.eventDates,
    required this.mode,
  });

  @override
  State<_CalendarContent> createState() => _CalendarContentState();
}

class _CalendarContentState extends State<_CalendarContent> {
  late DateTime _focusedDate; // 현재 보고 있는 달력의 기준 (항상 1일)
  DateTime? _selectedDate; // 유저가 선택한 날짜
  late bool _isMonthSelectorVisible; // 월 선택 그리드 활성화 여부

  // [설정] 날짜 제한 범위
  final int _minYear = 2023; // 최소 연도
  late final DateTime _maxDate; // 최대 날짜 (현재 시점)

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    final initialFocus = widget.initialDate ?? DateTime.now();
    _focusedDate = DateTime(initialFocus.year, initialFocus.month, 1);

    // 최대 날짜는 현재 시간(오늘)으로 설정
    _maxDate = DateTime.now();

    // Month 모드라면 처음부터 월 선택 그리드를 보여줌
    _isMonthSelectorVisible = widget.mode == CalendarMode.month;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 헤더 (연도/월 내비게이션)
          _buildHeader(),
          const SizedBox(height: 24),

          // 본문 (AnimatedSwitcher로 뷰 전환)
          Expanded(
            child: widget.mode == CalendarMode.month
                ? _buildMonthSelectorGrid() // Month 모드는 오직 월 선택 그리드만
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _isMonthSelectorVisible
                        ? _buildMonthSelectorGrid()
                        : _buildCalendarBody(),
                  ),
          ),

          Align(alignment: Alignment.bottomRight, child: _buildResetButton())
        ],
      ),
    );
  }

  // --- reset button ---

  Widget _buildResetButton() {
    if (_selectedDate != null) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedDate = null;
            _focusedDate =
                DateTime(DateTime.now().year, DateTime.now().month, 1);
          });
          // null 전달 -> 필터 초기화
          widget.onDateSelected(null);
          // Navigator.pop(context);
        },
        child: Container(
          decoration: BoxDecoration(
            color: BandiColor.foundationColor90(context),
            borderRadius: BandiEffects.radiusLarge,
            border: Border.all(
              color: BandiColor.foundationColor10(context),
            ),
          ),
          constraints: const BoxConstraints(
            minHeight: 28,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: Text(
              'calendar_selection_reset'.tr(context),
              style: BandiFont.labelMedium(context)?.copyWith(
                color: BandiColor.neutralColor90(context),
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // --- Header Section ---

  Widget _buildHeader() {
    final String locale = 'detail_view_date_form_country'.tr(context);
    final String headerPattern =
        'calendar_header_format'.tr(context); // "yyyy년 M월"
    final String yearPattern = 'calendar_year_format'.tr(context); // "yyyy년"

    // 표시할 텍스트 결정
    String titleText;
    if (widget.mode == CalendarMode.month) {
      // Month 모드: 연도만 표시
      titleText = DateFormat(yearPattern, locale).format(_focusedDate);
    } else {
      // Date 모드: 월 선택 중이면 연도, 아니면 연+월
      titleText = _isMonthSelectorVisible
          ? DateFormat(yearPattern, locale).format(_focusedDate)
          : DateFormat(headerPattern, locale).format(_focusedDate);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // [이전] 버튼
        _buildNavIcon(
          PhosphorIcons.caretLeft(),
          onTap: () {
            if (_isMonthSelectorVisible || widget.mode == CalendarMode.month) {
              _changeYear(-1);
            } else {
              _changeMonth(-1);
            }
          },
          isEnabled: _canGoToPrevious(),
        ),

        // [중앙] 타이틀 (클릭 시 뷰 전환)
        GestureDetector(
          onTap: widget.mode == CalendarMode.month
              ? null // Month 모드는 전환 불가
              : () {
                  setState(() {
                    _isMonthSelectorVisible = !_isMonthSelectorVisible;
                  });
                },
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Text(
                titleText,
                style: BandiFont.headlineMedium(context)?.copyWith(
                  color: BandiColor.foundationColor90(context),
                ),
              ),
              // Date 모드일 때만 토글 아이콘 표시
              if (widget.mode == CalendarMode.date) ...[
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _isMonthSelectorVisible ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: PhosphorIcon(
                    PhosphorIcons.caretDown(),
                    size: 18,
                    color: BandiColor.foundationColor90(context),
                  ),
                ),
              ],
            ],
          ),
        ),

        _buildNavIcon(
          PhosphorIcons.caretRight(),
          onTap: () {
            if (_isMonthSelectorVisible || widget.mode == CalendarMode.month) {
              _changeYear(1);
            } else {
              _changeMonth(1);
            }
          },
          isEnabled: _canGoToNext(),
        ),
      ],
    );
  }

  Widget _buildNavIcon(IconData icon,
      {required VoidCallback onTap, bool isEnabled = true}) {
    return IconButton(
      onPressed: isEnabled ? onTap : null,
      icon: PhosphorIcon(
        icon,
        size: 20,
        color: isEnabled
            ? BandiColor.foundationColor90(context)
            : BandiColor.foundationColor20(context),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      splashRadius: 20,
    );
  }

  // --- 1. Date Mode: Calendar Grid (일자 선택) ---

  Widget _buildCalendarBody() {
    return Column(
      key: const ValueKey('CalendarBody'),
      children: [
        _buildDaysOfWeek(),
        const SizedBox(height: 12),
        Expanded(child: _buildCalendarGrid()),
      ],
    );
  }

  Widget _buildDaysOfWeek() {
    final String locale = 'detail_view_date_form_country'.tr(context);
    final sunday = DateTime(2023, 1, 1); // 요일 추출용 임시 날짜 (일요일)
    final days = List.generate(
        7,
        (index) =>
            DateFormat.E(locale).format(sunday.add(Duration(days: index))));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: BandiFont.labelMedium(context)?.copyWith(
                      color: BandiColor.foundationColor40(context),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final weekdayOffset =
        firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
    final lastDayOfMonth =
        DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: weekdayOffset + lastDayOfMonth,
      itemBuilder: (context, index) {
        if (index < weekdayOffset) return const SizedBox.shrink();

        final date = DateTime(
            _focusedDate.year, _focusedDate.month, index - weekdayOffset + 1);
        return _buildDayItem(date);
      },
    );
  }

  Widget _buildDayItem(DateTime date) {
    final bool isSelected =
        _selectedDate != null && isSameDay(date, _selectedDate!);
    final bool isToday = isSameDay(date, DateTime.now());

    // [제한] 2023년 이전이거나 현재보다 미래인 경우 선택 불가
    final bool isBeforeMin = date.year < _minYear;
    final bool isAfterMax = date.isAfter(_maxDate);
    final bool isDisabled = isBeforeMin || isAfterMax;

    final bool hasEvent = widget.eventDates.any((d) => isSameDay(d, date));

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() => _selectedDate = date);
              widget.onDateSelected(date);
              Navigator.pop(context);
            },
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (!isSelected && isToday)
                  ? BandiColor.foundationColor10(context)
                  : BandiColor.transparent(context),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: BandiColor.foundationColor90(context), width: 1)
                  : null,
            ),
            child: Text(
              '${date.day}',
              style: BandiFont.bodyMedium(context)?.copyWith(
                color: isDisabled
                    ? BandiColor.foundationColor20(context)
                    : BandiColor.foundationColor90(context),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (hasEvent && !isSelected)
            Positioned(
              bottom: 6,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDisabled
                      ? BandiColor.foundationColor20(context)
                      : BandiColor.foundationColor90(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- 2. Month Selector Grid (월 선택) ---

  Widget _buildMonthSelectorGrid() {
    final String locale = 'detail_view_date_form_country'.tr(context);

    return GridView.builder(
      key: const ValueKey('MonthSelector'),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.8,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final currentMonthDate = DateTime(_focusedDate.year, month, 1);

        final isSelected = _selectedDate != null &&
            month == _selectedDate!.month &&
            _focusedDate.year == _selectedDate!.year;
        final isCurrentMonth = month == DateTime.now().month &&
            _focusedDate.year == DateTime.now().year;

        // [제한] 2023년 이전이거나 현재 월보다 미래인 경우 비활성화
        // 연도가 최소연도보다 작으면 전체 비활성
        // 연도가 최대연도(올해)이면서 월이 현재월보다 크면 비활성
        final bool isBeforeMin = _focusedDate.year < _minYear;
        final bool isAfterMax =
            _focusedDate.year == _maxDate.year && month > _maxDate.month;
        final bool isDisabled = isBeforeMin || isAfterMax;

        // [핵심] 해당 월에 이벤트가 있는지 확인
        final bool hasEvent =
            widget.eventDates.any((d) => isSameMonth(d, currentMonthDate));

        final String monthName =
            DateFormat.MMM(locale).format(DateTime(2023, month));

        return GestureDetector(
          onTap: isDisabled
              ? null
              : () {
                  if (widget.mode == CalendarMode.month) {
                    // [Month 모드] 선택 즉시 완료
                    final selected = DateTime(_focusedDate.year, month, 1);
                    setState(() => _selectedDate = selected);
                    widget.onDateSelected(selected);
                    Navigator.pop(context);
                  } else {
                    // [Date 모드] 해당 월 달력으로 진입
                    setState(() {
                      _focusedDate = DateTime(_focusedDate.year, month, 1);
                      _isMonthSelectorVisible = false;
                    });
                  }
                },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? BandiColor.foundationColor90(context)
                      : (isCurrentMonth
                          ? BandiColor.foundationColor10(context)
                          : BandiColor.transparent(context)),
                  borderRadius: BandiEffects.radiusSmall,
                  border: isSelected
                      ? null
                      : Border.all(
                          color: BandiColor.foundationColor10(context),
                          width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  monthName,
                  style: BandiFont.bodyMedium(context)?.copyWith(
                    color: isDisabled
                        ? BandiColor.foundationColor20(context)
                        : (isSelected
                            ? BandiColor.neutralColor90(context)
                            : BandiColor.foundationColor90(context)),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              // 이벤트 도트 표시 (선택되지 않은 경우에만)
              if (hasEvent && !isSelected)
                Positioned(
                  bottom: 6,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDisabled
                          ? BandiColor.foundationColor20(context)
                          : (isSelected
                              ? BandiColor.neutralColor90(context)
                              : BandiColor.foundationColor90(context)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // --- Logic Helpers ---

  void _changeMonth(int increment) {
    setState(() => _focusedDate =
        DateTime(_focusedDate.year, _focusedDate.month + increment, 1));
  }

  void _changeYear(int increment) {
    setState(() => _focusedDate =
        DateTime(_focusedDate.year + increment, _focusedDate.month, 1));
  }

  // [다음 이동 제한]
  bool _canGoToNext() {
    // 월 선택 중이거나 Month모드일 때: '연도'가 최대 연도(올해)보다 작아야 함
    if (_isMonthSelectorVisible || widget.mode == CalendarMode.month) {
      return _focusedDate.year < _maxDate.year;
    }
    // 달력 모드일 때: 현재 월이 최대 월(이번달)보다 작아야 함
    else {
      return !(_focusedDate.year == _maxDate.year &&
          _focusedDate.month == _maxDate.month);
    }
  }

  // [이전 이동 제한]
  bool _canGoToPrevious() {
    // 월 선택 중이거나 Month모드일 때: '연도'가 최소 연도(2023)보다 커야 함
    if (_isMonthSelectorVisible || widget.mode == CalendarMode.month) {
      return _focusedDate.year > _minYear;
    }
    // 달력 모드일 때: 2023년 1월보다 이후여야 함
    else {
      return !(_focusedDate.year == _minYear && _focusedDate.month == 1);
    }
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
