import 'package:flutter/material.dart';

import '../../../theme/custom_theme_data.dart';
import '../../../localization/string_extention.dart';

class AppleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AppleLoginButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: 327,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            BandiColor.foundationColor100(context),
          ),
          shadowColor: WidgetStateProperty.all(
            BandiColor.transparent(context),
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100.0),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage("assets/images/login/logoApple.png"),
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            Text(
              'login_apple'.tr(context),
              style: BandiFont.labelLarge(context)?.copyWith(
                color: BandiColor.neutralColor100(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
