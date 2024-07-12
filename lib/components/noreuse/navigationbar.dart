import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../controller/navigationToggleProvider.dart';

Widget navigationBar(BuildContext context) {
  final navigationToggleProvider = Provider.of<NavigationToggleProvider>(context);

  return Center(
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.white),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                navigationToggleProvider.selectIndex(0);
              },
              child: PhosphorIcon(
                navigationToggleProvider.selectedIndex == 0
                    ? PhosphorIcons.houseSimple(PhosphorIconsStyle.fill)
                    : PhosphorIcons.houseSimple(PhosphorIconsStyle.regular),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 24),
            GestureDetector(
              onTap: () {
                navigationToggleProvider.selectIndex(1);
              },
              child: PhosphorIcon(
                navigationToggleProvider.selectedIndex == 1
                    ? PhosphorIcons.book(PhosphorIconsStyle.fill)
                    : PhosphorIcons.book(PhosphorIconsStyle.regular),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
