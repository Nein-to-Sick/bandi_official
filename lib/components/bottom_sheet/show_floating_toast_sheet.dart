import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/custom_theme_data.dart';

Future<void> showFloatingToastSheet(
    BuildContext context, {
      required String message,
      String buttonText = '완료',
      bool barrierDismissible = true,
      VoidCallback? onClosed,
    }) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'dismiss',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
      final scale = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      final slide = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);

      return Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            // ===== 배경: Blur + Dim =====
            Positioned.fill(
              child: FadeTransition(
                opacity: fade,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: barrierDismissible ? () => Navigator.pop(ctx) : null,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: BandiEffects.blurLarge,
                      sigmaY: BandiEffects.blurLarge,
                    ),
                    child: Container(
                      color: BandiColor.foundationColor10(ctx),
                    ),
                  ),
                ),
              ),
            ),

            // ===== Floating 카드 =====
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(slide),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1.0).animate(scale),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: BandiColor.neutralColor90(ctx),
                          borderRadius: BandiEffects.radiusSmall,
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: BandiFont.titleMedium(ctx)?.copyWith(
                                color: BandiColor.foundationColor90(ctx),
                              ),
                            ),
                            const SizedBox(height: 20),

                            _SinglePrimarySheetButton(
                              text: buttonText,
                              background: BandiColor.accentColorYellow(ctx),
                              textColor: BandiColor.foundationColor90(ctx),
                              onTap: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  onClosed?.call();
}

class _SinglePrimarySheetButton extends StatelessWidget {
  final String text;
  final Color background;
  final Color textColor;
  final VoidCallback onTap;

  const _SinglePrimarySheetButton({
    required this.text,
    required this.background,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BandiEffects.radiusLarge,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: BandiFont.labelMedium(context)?.copyWith(
            color: textColor,
          ),
        ),
      ),
    );
  }
}
