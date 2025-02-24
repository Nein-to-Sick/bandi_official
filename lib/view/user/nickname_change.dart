// lib/views/user/nickname_change.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../components/button/primary_button.dart';
import '../../components/field/field.dart';
import '../../controller/user_info_controller.dart';
import '../../theme/custom_theme_data.dart';

class NicknameChange extends StatelessWidget {
  final VoidCallback onBack;
  const NicknameChange({super.key, required this.onBack,});

  @override
  Widget build(BuildContext context) {

    void updateNickname(BuildContext context, String newNickname) async {
      // Firebase Firestore에서 현재 사용자 문서를 업데이트
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'nickname': newNickname,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    return Scaffold(
      backgroundColor: BandiColor.neutralColor80(context).withOpacity(0.8),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BandiColor.transparent(context),
        title: Text(
          "닉네임 변경",
          style: BandiFont.displaySmall(context)?.copyWith(
            color: BandiColor.foundationColor80(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft()),
          onPressed: onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            String nickname =
                Provider.of<UserInfoValueModel>(context, listen: false)
                    .nickname;

            return ListView(
              children: [
                const SizedBox(height: 17),
                CustomField(
                  initialValue: nickname,
                  onChanged: (value) {
                    setState(() {
                      nickname = value;
                    });
                    // 프로바이더의 닉네임을 업데이트
                    Provider.of<UserInfoValueModel>(context, listen: false)
                        .updateNickname(value);
                  },
                  isPassword: false,
                  isEnabled: true,
                ),
                const SizedBox(height: 17),
                CustomPrimaryButton(
                  title: '확인',
                  onPrimaryButtonPressed: () {
                    if (nickname.isNotEmpty) {
                      // 비동기 작업을 호출하는 동기 함수로 래핑
                      updateNickname(context, nickname);
                      onBack();
                    }
                  },
                  disableButton: nickname.isEmpty,
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}
