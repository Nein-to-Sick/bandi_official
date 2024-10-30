import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../controller/navigation_toggle_provider.dart';

Widget buildNavigationItem(
  BuildContext context,
  NavigationToggleProvider navigationToggleProvider,
  int index,
  IconData iconFill,
  IconData iconRegular,
  String? label,
) {
  return GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () {
      navigationToggleProvider.selectIndex(index);
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(
            navigationToggleProvider.selectedIndex == index
                ? iconFill
                : iconRegular,
            color: navigationToggleProvider.selectedIndex == 3
                ? BandiColor.foundationColor60(context)
                : navigationToggleProvider.selectedIndex == index
                    ? BandiColor.neutralColor100(context)
                    : BandiColor.neutralColor60(context),
            size: 24,
          ),
          if (label != null) ...[
            const SizedBox(height: 5),
            Text(
              label,
              style: BandiFont.labelSmall(context)?.copyWith(
                color: navigationToggleProvider.selectedIndex == 3
                    ? BandiColor.foundationColor60(context)
                    : navigationToggleProvider.selectedIndex == index
                        ? BandiColor.neutralColor100(context)
                        : BandiColor.neutralColor60(context),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

Widget navigationBar(BuildContext context) {
  final navigationToggleProvider =
      Provider.of<NavigationToggleProvider>(context);

  return SafeArea(
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 5),
          buildNavigationItem(
            context,
            navigationToggleProvider,
            0,
            PhosphorIcons.house(PhosphorIconsStyle.fill),
            PhosphorIcons.house(PhosphorIconsStyle.regular),
            "홈",
          ),
          buildNavigationItem(
            context,
            navigationToggleProvider,
            1,
            PhosphorIcons.book(PhosphorIconsStyle.fill),
            PhosphorIcons.book(PhosphorIconsStyle.regular),
            "일기",
          ),
          buildNavigationItem(
            context,
            navigationToggleProvider,
            2,
            PhosphorIcons.tray(PhosphorIconsStyle.fill),
            PhosphorIcons.tray(PhosphorIconsStyle.regular),
            "보관함",
          ),
          buildNavigationItem(
            context,
            navigationToggleProvider,
            3,
            PhosphorIcons.gearSix(PhosphorIconsStyle.fill),
            PhosphorIcons.gearSix(PhosphorIconsStyle.regular),
            "설정",
          ),
          const SizedBox(width: 5),
        ],
      ),
    ),
  );
}
