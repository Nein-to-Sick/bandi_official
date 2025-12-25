import 'dart:ui';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';

class FrostedNavBar extends StatelessWidget {
  const FrostedNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
    this.width = 327,
  });

  final int selectedIndex;
  final void Function(int index) onTap;
  final List<NavItem> items;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: width,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: BoxDecoration(
              color: BandiColor.neutralColor10(context),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(items.length, (i) {
                final active = i == selectedIndex;
                return _NavButton(
                  active: active,
                  icon: items[i].icon,
                  onTap: () => onTap(i),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class NavItem {
  final IconData icon;

  const NavItem({required this.icon});
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.active,
    required this.icon,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Icon(
        icon,
        size: 24,
        color: active
            ? BandiColor.neutralColor90(context).withOpacity(0.90)
            : BandiColor.neutralColor40(context),
        shadows: active
            ? [
                Shadow(
                  color: Colors.white.withOpacity(0.55),
                  blurRadius: 30,
                  offset: Offset.zero,
                ),
              ]
            : null,
      ),
    );
  }
}
