import 'package:flutter/material.dart';

import '../../../theme/custom_theme_data.dart';
import '../../../string_extention.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'login_title'.tr(context),
              style: BandiFont.displayLarge(context)?.copyWith(
                color: BandiColor.neutralColor90(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'login_subtitle'.tr(context),
          style: BandiFont.bodyLarge(context)?.copyWith(
            color: BandiColor.neutralColor70(context),
          ),
        ),
      ],
    );
  }
}
