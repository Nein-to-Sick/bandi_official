import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/field/field.dart';
import '../../controller/user_info_controller.dart';
import '../../theme/custom_theme_data.dart';
import '../../components/button/primary_button.dart';
import '../../controller/navigation_toggle_provider.dart';

class NicknameSettingSheet {
  Future<void> showNicknameSettingSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      barrierColor: Colors.transparent,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: NicknameSettingStateful(),
        );
      },
    );
  }
}

class NicknameSettingStateful extends StatefulWidget {
  const NicknameSettingStateful({super.key});

  @override
  State<NicknameSettingStateful> createState() =>
      _NicknameSettingStatefulState();
}

class _NicknameSettingStatefulState extends State<NicknameSettingStateful> {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var navigationToggleProvider =
        Provider.of<NavigationToggleProvider>(context);

    String _nickname =
        Provider.of<UserInfoValueModel>(context, listen: false).nickname;

    void _updateNickname(BuildContext context, String newNickname) async {
      // 프로바이더에서 닉네임을 가져옴
      var userInfoProvider =
          Provider.of<UserInfoValueModel>(context, listen: false);

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationToggleProvider.selectIndex(0);
      });
    }

    return WillPopScope(
        onWillPop: () => Future(() => false),
        child: Container(
          decoration: BoxDecoration(
            color: BandiColor.neutralColor80(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          height: 280,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "사용할 닉네임을 정해주세요",
                style: BandiFont.displayMedium(context)
                    ?.copyWith(color: BandiColor.foundationColor80(context)),
              ),
              const SizedBox(height: 6),
              Text(
                "나중에 언제든지 바꿀 수 있어요",
                style: BandiFont.titleMedium(context)
                    ?.copyWith(color: BandiColor.foundationColor40(context)),
              ),
              const SizedBox(height: 32),
              // Nickname input field
              CustomField(
                initialValue: _nickname,
                onChanged: (value) {
                  setState(() {
                    _nickname = value;
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
                  if (_nickname.isNotEmpty) {
                    // 비동기 작업을 호출하는 동기 함수로 래핑

                    // Navigator.pop(context, true); // Navigator.pop에서 true 반환
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    _updateNickname(context, _nickname);
                  }
                },
                disableButton: _nickname.isEmpty,
              ),
            ],
          ),
        ));
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../theme/custom_theme_data.dart';
// import '../../components/button/primary_button.dart';
// import '../../controller/navigation_toggle_provider.dart';

// class NicknameSettingSheet {
//   Future<void> showNicknameSettingSheet(BuildContext context) {
//     return showModalBottomSheet<void>(
//       context: context,
//       isScrollControlled: true,
//       isDismissible: false,
//       barrierColor: Colors.transparent,
//       enableDrag: false,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(10),
//           topRight: Radius.circular(10),
//         ),
//       ),
//       builder: (BuildContext context) {
//         return NicknameSettingStateful();
//       },
//     );
//   }
// }

// class NicknameSettingStateful extends StatefulWidget {
//   const NicknameSettingStateful({super.key});

//   @override
//   State<NicknameSettingStateful> createState() =>
//       _NicknameSettingStatefulState();
// }

// class _NicknameSettingStatefulState extends State<NicknameSettingStateful> {
//   final TextEditingController _nicknameController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     var navigationToggleProvider =
//         Provider.of<NavigationToggleProvider>(context);

//     return WillPopScope(
//         onWillPop: () {
//           return Future(() => false);
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             color: BandiColor.neutralColor80(context).withOpacity(0.9),
//             borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(10),
//               topRight: Radius.circular(10),
//             ),
//           ),
//           height: 280,
//           width: MediaQuery.of(context).size.width,
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 "사용할 닉네임을 정해주세요",
//                 style: BandiFont.displayMedium(context)
//                     ?.copyWith(color: BandiColor.foundationColor80(context)),
//               ), 
//               const SizedBox(height: 6),
//               Text(
//                 "나중에 언제든지 바꿀 수 있어요",
//                 style: BandiFont.titleMedium(context)
//                     ?.copyWith(color: BandiColor.foundationColor40(context)),
//               ),
//               const SizedBox(height: 20),

//               //여기에 넣어줘.
              
//               const SizedBox(height: 20),
//               // PrimaryButton(
//               //   text: "Confirm",
//               //   onPressed: () {
//               //     // Handle click event
//               //     // Placeholder for your code
//               //   },
//               // ),
//             ],
//           ),
//         ));
//   }
// }