import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../theme/custom_theme_data.dart';
import 'home_notification_pill.dart';

enum HomeNotiType { dailyReminder, otherDiary, likedDiary, letter }

class HomeNotiItem {
  final String id;
  final String text;
  final HomeNotiType type;
  final DateTime createdAt;
  final VoidCallback onTap;

  final String? refId;
  final dynamic payload;

  HomeNotiItem({
    required this.id,
    required this.text,
    required this.type,
    required this.createdAt,
    required this.onTap,
    this.refId,
    this.payload,
  });
}

class HomeNotificationStack extends StatefulWidget {
  final List<HomeNotiItem> items;
  final ValueChanged<bool>? onDropdownOpenChanged;

  final bool showNewDot;

  static const double pillHeight = 44;
  static const double peek = 2;

  const HomeNotificationStack({
    super.key,
    required this.items,
    this.onDropdownOpenChanged,
    required this.showNewDot,
  });

  @override
  State<HomeNotificationStack> createState() => _HomeNotificationStackState();
}

class _HomeNotificationStackState extends State<HomeNotificationStack>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  bool _isOpen = false;

  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<double> _expand;

  @override
  void initState() {
    super.initState();

    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _fade = CurvedAnimation(
      parent: _c,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _expand = CurvedAnimation(
      parent: _c,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _removeEntry(immediate: true);
    _c.dispose();
    super.dispose();
  }

  List<HomeNotiItem> _sortedByTime(List<HomeNotiItem> items) {
    final sorted = [...items]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  IconData _iconFor(HomeNotiType t) {
    switch (t) {
      case HomeNotiType.letter:
        return PhosphorIcons.envelope();
      case HomeNotiType.likedDiary:
        return PhosphorIcons.envelope(); /// 공감마다 변경 필요
      case HomeNotiType.otherDiary:
        return PhosphorIcons.envelope();
      case HomeNotiType.dailyReminder:
        return PhosphorIcons.envelope();
    }
  }

  void _openDropdown() {
    if (_entry != null) return;

    setState(() => _isOpen = true);
    widget.onDropdownOpenChanged?.call(true);

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _entry = OverlayEntry(
      builder: (context) {
        final items = widget.items;

        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned.fill(
                child: FadeTransition(
                  opacity: _fade,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _closeDropdown,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: BandiEffects.blurLarge,
                        sigmaY: BandiEffects.blurLarge,
                      ),
                      child: Container(
                        color: BandiColor.foundationColor10(context),
                      ),
                    ),
                  ),
                ),
              ),
              CompositedTransformFollower(
                link: _link,
                showWhenUnlinked: false,
                offset: const Offset(0, 0),
                child: Material(
                  color: Colors.transparent,
                  child: FadeTransition(
                    opacity: _fade,
                    child: _AnchoredDropdownSheet(
                      expand: _expand,
                      items: items,
                      iconFor: _iconFor,
                      onItemTap: (item) {
                        _closeDropdown();
                        item.onTap();
                      },
                      onClose: _closeDropdown,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlay.insert(_entry!);
    _c.forward(from: 0);
  }

  void _closeDropdown() => _removeEntry();

  void _removeEntry({bool immediate = false}) async {
    if (_entry == null) return;

    if (!immediate) {
      widget.onDropdownOpenChanged?.call(false);
    }

    if (immediate) {
      _entry?.remove();
      _entry = null;
      _isOpen = false;
      return;
    }

    try {
      await _c.reverse();
    } catch (_) {}
    _entry?.remove();
    _entry = null;

    if (mounted) setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final rawItems = widget.items;
    if (rawItems.isEmpty) return const SizedBox.shrink();

    final items = _sortedByTime(rawItems);
    final top = items.first;

    final stackItems = items.take(4).toList();
    final backCount = stackItems.length - 1;

    final height =
        HomeNotificationStack.pillHeight + backCount * HomeNotificationStack.peek;

    final showNewDot = widget.showNewDot;

    final Widget? singleIcon = (!showNewDot && items.length == 1)
        ? PhosphorIcon(
      _iconFor(top.type),
      size: 20,
      color: BandiColor.neutralColor100(context),
    )
        : null;

    final int badgeCount = (!showNewDot && items.length >= 2) ? items.length : 0;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: CompositedTransformTarget(
              link: _link,
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: _isOpen,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 80),
                opacity: _isOpen ? 0.0 : 1.0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (int i = backCount; i >= 1; i--)
                      Positioned(
                        top: i * HomeNotificationStack.peek,
                        left: 0,
                        right: 0,
                        height: HomeNotificationStack.pillHeight,
                        child: const _PillBackLayer(),
                      ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: HomeNotificationStack.pillHeight,
                      child: HomeNotificationPill(
                        text: top.text,
                        showNewDot: showNewDot,
                        badgeCount: badgeCount,
                        trailingWidget: singleIcon,
                        onTap: () {
                          if (items.length == 1) {
                            top.onTap();
                          } else {
                            _openDropdown();
                          }
                        }, backgroundColor: BandiColor.neutralColor04(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillBackLayer extends StatelessWidget {
  const _PillBackLayer();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRRect(
        borderRadius: BandiEffects.radiusLarge,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: BandiEffects.blurLarge,
            sigmaY: BandiEffects.blurLarge,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: BandiColor.neutralColor04(context),
              borderRadius: BandiEffects.radiusLarge,
            ),
          ),
        ),
      ),
    );
  }
}

class _AnchoredDropdownSheet extends StatelessWidget {
  final Animation<double> expand;
  final List<HomeNotiItem> items;
  final IconData Function(HomeNotiType) iconFor;
  final void Function(HomeNotiItem) onItemTap;
  final VoidCallback onClose;

  const _AnchoredDropdownSheet({
    required this.expand,
    required this.items,
    required this.iconFor,
    required this.onItemTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.of(context).size.width - 48;

    return ClipRRect(
      borderRadius: BandiEffects.radiusSmall,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: BandiEffects.blurLarge,
          sigmaY: BandiEffects.blurLarge,
        ),
        child: AnimatedBuilder(
          animation: expand,
          builder: (context, _) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxW),
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: expand.value,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BandiColor.neutralColor04(context),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: (HomeNotificationStack.pillHeight + 12) * 6,
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (final item in items) ...[
                                  HomeNotificationPill(
                                    text: item.text,
                                    showNewDot: false,
                                    badgeCount: 0,
                                    trailingWidget: PhosphorIcon(
                                      iconFor(item.type),
                                      size: 20,
                                      color: BandiColor.neutralColor90(context),
                                    ),
                                    onTap: () => onItemTap(item), backgroundColor: BandiColor.neutralColor10(context),
                                    
                                  ),
                                  if (item != items.last) const SizedBox(height: 8),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onClose,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: PhosphorIcon(
                              PhosphorIcons.caretUp(PhosphorIconsStyle.light),
                              size: 20,
                              color: BandiColor.neutralColor40(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
