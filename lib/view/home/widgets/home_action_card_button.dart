import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../theme/custom_theme_data.dart';

class HomeActionCardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const HomeActionCardButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: BandiColor.neutralColor04(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: BandiColor.neutralColor20(context),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhosphorIcon(
                icon,
                size: 24,
                color: BandiColor.neutralColor100(context),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: BandiFont.labelMedium(context)?.copyWith(
                  color: BandiColor.neutralColor90(context),)
              ),
            ],
          ),
        ),
      ),
    );
  }
}