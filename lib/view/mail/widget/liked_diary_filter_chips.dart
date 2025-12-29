import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LikedDiaryFilterChips extends StatefulWidget {
  const LikedDiaryFilterChips({super.key});

  @override
  State<LikedDiaryFilterChips> createState() => _LikedDiaryFilterChipsState();
}

class _LikedDiaryFilterChipsState extends State<LikedDiaryFilterChips> {
  @override
  Widget build(BuildContext context) {
    MailController mailController = context.watch<MailController>();

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 0.0,
        runSpacing: 8,
        children: mailController.chipLabels.map((label) {
          int chipLabelsIndex = mailController.chipLabels.indexOf(label);
          bool isSelected =
              (mailController.filteredchipLabels.contains(chipLabelsIndex));
          return (chipLabelsIndex != 0)
              ? Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IntrinsicWidth(
                    child: GestureDetector(
                      onTap: () {
                        mailController.updateFilter(label);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? BandiColor.foundationColor90(context)
                              : BandiColor.transparent(context),
                          borderRadius: BandiEffects.radiusLarge,
                          border: Border.all(
                            color: BandiColor.foundationColor10(context),
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minHeight: 28,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Center(
                            child: Text(
                              label.tr(context),
                              style: BandiFont.labelMedium(context)?.copyWith(
                                color: isSelected
                                    ? BandiColor.neutralColor90(context)
                                    : BandiColor.foundationColor40(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }).toList(),
      ),
    );
  }
}
