// lib/views/user/nickname_change.dart
import 'package:bandi_official/localization/string_extention.dart';
import 'package:bandi_official/view/settings/widget/frosted_settings_scaffold.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/bottom_sheet/show_floating_toast_sheet.dart';
import '../../components/button/primary_button.dart';
import '../../components/field/field.dart';
import '../../controller/user_info_controller.dart';

class NicknameChange extends StatefulWidget {
  final VoidCallback onBack;

  const NicknameChange({
    super.key,
    required this.onBack,
  });

  @override
  State<NicknameChange> createState() => _NicknameChangeState();
}

class _NicknameChangeState extends State<NicknameChange> {
  String? _originalNickname; // ✅ null이면 아직 미초기화
  String _nickname = '';

  bool get isChanged {
    final o = (_originalNickname ?? '').trim();
    final c = _nickname.trim();
    return c.isNotEmpty && c != o;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ 최초 1회만 세팅
    if (_originalNickname != null) return;

    final providerNickname =
        Provider.of<UserInfoValueModel>(context, listen: false).nickname;

    _originalNickname = providerNickname;
    _nickname = providerNickname;
  }

  Future<void> updateNickname(String newNickname) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'nickname': newNickname,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final originalNickname = _originalNickname ?? '';

    // 아직 초기화 전이면(거의 없지만) 안전 처리
    if (_originalNickname == null) return const SizedBox.shrink();

    return FrostedSettingsScaffold(
      title: 'settings_nickname_change'.tr(context),
      onBack: widget.onBack,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 32),
            child: Column(
              children: [
                CustomField(
                  initialValue: originalNickname,
                  onChanged: (value) {
                    setState(() {
                      _nickname = value;
                    });
                  },
                  isPassword: false,
                  isEnabled: true,
                ),
                const Spacer(),
                CustomPrimaryButton(
                  title: 'settings_nickname_change_save'.tr(context),
                  size: 'small',
                  onPrimaryButtonPressed: () async {
                    final trimmed = _nickname.trim();
                    if (!isChanged) return;

                    FocusScope.of(context).unfocus();

                    await updateNickname(trimmed);

                    Provider.of<UserInfoValueModel>(context, listen: false)
                        .updateNickname(trimmed);

                    setState(() {
                      _originalNickname = trimmed;
                      _nickname = trimmed;
                    });

                    await showFloatingToastSheet(
                      context,
                      message:
                          "settings_nickname_change_toast_title".tr(context),
                      buttonText:
                          "settings_nickname_change_toast_button".tr(context),
                    );
                  },
                  disableButton: !isChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
