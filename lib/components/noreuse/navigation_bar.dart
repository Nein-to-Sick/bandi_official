import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../controller/navigation_toggle_provider.dart';

Widget navigationBar(BuildContext context) {
  final navigationToggleProvider = Provider.of<NavigationToggleProvider>(context);

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
              color: Colors.white,
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
              color: Colors.white,
              size: 24,
            ),
          ),
          GestureDetector(
            onTap: () {
              navigationToggleProvider.selectIndex(2);
            },
            child: PhosphorIcon(
              navigationToggleProvider.selectedIndex == 2
                  ? PhosphorIcons.envelopeSimple(PhosphorIconsStyle.fill)
                  : PhosphorIcons.envelopeSimple(PhosphorIconsStyle.regular),
              color: Colors.white,
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
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    ),
  );
}
