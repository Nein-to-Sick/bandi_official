import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../../theme/custom_theme_data.dart';

class BottomBar extends StatelessWidget {
  final bool isPublic;
  final void Function(bool) onTogglePublic;
  final String publicLabel;

  final VoidCallback onExit;
  final VoidCallback onDone;
  final bool doneEnabled;

  const BottomBar({super.key, required this.isPublic, required this.onTogglePublic, required this.publicLabel, required this.onExit, required this.onDone, required this.doneEnabled});



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: BandiColor.neutralColor10(context), thickness: 1,),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 15, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1) Toggle 영역
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    FlutterSwitch(
                      value: isPublic,
                      onToggle: onTogglePublic,
                      width: 32.0,
                      height: 16.0,
                      padding: 2,
                      toggleSize: 12.0,
                      activeColor: BandiColor.accentColorYellow(context),
                      inactiveColor: BandiColor.foundationColor40(context),
                      inactiveToggleColor: BandiColor.foundationColor40(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        publicLabel,
                        overflow: TextOverflow.ellipsis,
                        style: BandiFont.labelMedium(context)?.copyWith(
                          color: BandiColor.neutralColor90(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  _BarButton(
                    title: "나가기",
                    onTap: onExit,
                  ),
                  const SizedBox(width: 8),
                  _BarButton(
                    title: "완료",
                    onTap: onDone,
                    disabled: !doneEnabled,
                  ),
                ],
              )

            ],
          ),
        ),
      ],
    );
  }
}

class _BarButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool disabled;

  const _BarButton({
    required this.title,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: BandiColor.neutralColor10(context)
        ),
        child: Text(
          title,
          style: BandiFont.labelMedium(context)?.copyWith(
            color: BandiColor.neutralColor90(context),
          ),
        ),
      ),
    );
  }
}