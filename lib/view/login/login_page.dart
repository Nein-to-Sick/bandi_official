import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/custom_theme_data.dart';

import 'controller/login_controller.dart';
import 'widgets/login_header.dart';
import 'widgets/google_login_button.dart';
import 'widgets/apple_login_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<LoginController>();

    return Scaffold(
      backgroundColor: BandiColor.transparent(context),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.19,
                ),
                child: const LoginHeader(),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 55),
                child: Column(
                  children: [
                    GoogleLoginButton(onPressed: controller.loginWithGoogle),
                    if (Platform.isIOS) const SizedBox(height: 16),
                    if (Platform.isIOS)
                      AppleLoginButton(onPressed: controller.loginWithApple),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
