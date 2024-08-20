import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../components/appbar/appbar.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  bool _isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BandiColor.neutralColor80(context).withOpacity(0.8),
      // custom appbar 일단 임시로 leading icon 변경
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BandiColor.transparent(context),
        title: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Text(
            "설정",
            style: BandiFont.displaySmall(context)?.copyWith(
              color: BandiColor.foundationColor80(context),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 23.0),
        child: ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
          ),
          children: [
            // buildSettingOption(
            //   icon: PhosphorIcons.creditCard(),
            //   text: "구독 하기",
            //   onTap: () {},
            // ),
            // const SizedBox(height: 8),
            buildSettingOption(
              icon: PhosphorIcons.user(),
              text: "계정 관리",
              onTap: () {},
            ),
            const SizedBox(height: 8),
            buildSettingOption(
              icon: PhosphorIcons.bell(),
              text: "알림 설정",
              onTap: () {
                setState(() {
                  _isSwitched = !_isSwitched;
                });
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "00:00",
                    style: BandiFont.bodyMedium(context)?.copyWith(
                      color: BandiColor.foundationColor10(context),
                    ),
                  ),
                  const SizedBox(width: 12.5),
                  Switch(
                    value: _isSwitched,
                    onChanged: (bool value) {
                      setState(() {
                        _isSwitched = value;
                      });
                    },
                    activeColor: BandiColor.accentColorYellow(context),
                    activeTrackColor: BandiColor.neutralColor100(context),
                    inactiveThumbColor: BandiColor.foundationColor80(context),
                    inactiveTrackColor: BandiColor.foundationColor40(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Divider(
              height: 1.0,
              color: BandiColor.foundationColor10(context),
            ),
            const SizedBox(height: 16),
            buildSettingOption(
              text: "오픈 라이센스",
              onTap: () {},
            ),
            const SizedBox(height: 8),
            buildSettingOption(
              text: "이용 약관",
              onTap: () {},
            ),
            const SizedBox(height: 8),
            buildSettingOption(
              text: "개인정보 처리방침",
              onTap: () {},
            ),
            const SizedBox(height: 8),
            buildSettingOption(
              text: "사업자 정보",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSettingOption({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 42.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 24,
                color: BandiColor.foundationColor80(context),
              ),
            if (icon != null) const SizedBox(width: 8),
            Text(
              text,
              style: BandiFont.bodyMedium(context)?.copyWith(
                color: BandiColor.foundationColor80(context),
              ),
            ),
            if (trailing != null) ...[
              const Spacer(),
              trailing,
            ] else ...[
              const Spacer(),
              Icon(
                PhosphorIcons.caretRight(),
                size: 24,
                color: BandiColor.foundationColor20(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Future<void> _showCalendarBottomSheet(BuildContext context) async {
  //   await showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: const EdgeInsets.only(left: 18, right: 18, top: 23),
  //         // child: CupertinoTimerPicker(onTimerDurationChanged: onTimerDurationChanged)
  //       );
  //     },
  //   );
  // }
}
