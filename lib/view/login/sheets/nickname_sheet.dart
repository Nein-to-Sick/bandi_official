import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../components/button/primary_button.dart';
import '../../../components/field/field.dart';
import '../../../controller/user_info_controller.dart';
import '../../../theme/custom_theme_data.dart';
import '../../../localization/string_extention.dart';
import '../data/user_profile_repository.dart';

class NicknameSheet {
  Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NicknameStateful(),
    );
  }
}

class _NicknameStateful extends StatefulWidget {
  const _NicknameStateful();

  @override
  State<_NicknameStateful> createState() => _NicknameStatefulState();
}

class _NicknameStatefulState extends State<_NicknameStateful> {
  String nickname = '';

  @override
  void initState() {
    super.initState();
    // ✅ 최초 1회만 Provider 값으로 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userInfo = context.read<UserInfoValueModel>();
      setState(() {
        nickname = userInfo.nickname;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = context.read<UserInfoValueModel>();
    final repo = context.read<UserProfileRepository>();

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: BandiColor.neutralColor80(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    "onboarding_nickname_title".tr(context),
                    style: BandiFont.headlineMedium(context)?.copyWith(
                        color: BandiColor.foundationColor90(context)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "onboarding_nickname_subtitle".tr(context),
                    style: BandiFont.labelSmall(context)?.copyWith(
                        color: BandiColor.foundationColor40(context)),
                  ),
                  const SizedBox(height: 40),
                  CustomField(
                    initialValue: nickname,
                    onChanged: (value) => setState(() => nickname = value),
                    isPassword: false,
                    isEnabled: true,
                  ),
                  const SizedBox(height: 17),
                  CustomPrimaryButton(
                    title: 'onboarding_nickname_button'.tr(context),
                    disableButton: nickname.trim().isEmpty,
                    onPrimaryButtonPressed: () async {
                      final nick = nickname.trim();
                      if (nick.isEmpty) return;

                      final uid = userInfo.userId;
                      if (uid.isEmpty) return;

                      await repo.updateNickname(userId: uid, nickname: nick);
                      userInfo.updateNickname(nick);

                      if (!mounted) return;

                      // ✅ bool이 아니라 닉네임을 반환
                      Navigator.pop(context, nick);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
