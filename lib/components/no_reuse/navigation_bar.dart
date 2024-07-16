import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../controller/navigation_toggle_provider.dart';

Widget navigationBar(BuildContext context) {
  final navigationToggleProvider = Provider.of<NavigationToggleProvider>(context);

  return Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            navigationToggleProvider.selectIndex(0);
          },
          child: PhosphorIcon(
            navigationToggleProvider.selectedIndex == 0
                ? PhosphorIcons.house(PhosphorIconsStyle.fill)
                : PhosphorIcons.house(PhosphorIconsStyle.regular),
            color: navigationToggleProvider.selectedIndex == 0 ? BandiColor.neutralColor100(context) : BandiColor.neutralColor60(context),
            size: 24,
          ),
        ),
        GestureDetector(
          onTap: () {
            navigationToggleProvider.selectIndex(1);
          },
          child: PhosphorIcon(
            navigationToggleProvider.selectedIndex == 1
                ? PhosphorIcons.book(PhosphorIconsStyle.fill)
                : PhosphorIcons.book(PhosphorIconsStyle.regular),
            color: navigationToggleProvider.selectedIndex == 1 ? BandiColor.neutralColor100(context) : BandiColor.neutralColor60(context),
            size: 24,
          ),
        ),
        GestureDetector(
          onTap: () {
            navigationToggleProvider.selectIndex(2);
          },
          child: PhosphorIcon(
            navigationToggleProvider.selectedIndex == 2
                ? PhosphorIcons.boxArrowDown(PhosphorIconsStyle.fill)
                : PhosphorIcons.boxArrowDown(PhosphorIconsStyle.regular),
            color: navigationToggleProvider.selectedIndex == 2 ? BandiColor.neutralColor100(context) : BandiColor.neutralColor60(context),
            size: 24,
          ),
        ),
        GestureDetector(
          onTap: () {
            navigationToggleProvider.selectIndex(3);
          },
          child: PhosphorIcon(
            navigationToggleProvider.selectedIndex == 3
                ? PhosphorIcons.userCircle(PhosphorIconsStyle.fill)
                : PhosphorIcons.userCircle(PhosphorIconsStyle.regular),
            color: navigationToggleProvider.selectedIndex == 3 ? BandiColor.neutralColor100(context) : BandiColor.neutralColor60(context),
            size: 24,
          ),
        ),
      ],
    ),
  );
}
