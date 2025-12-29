import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/custom_theme_data.dart';

/// ✅ floating confirm sheet (사진 스타일)
/// - Blur+Dim 배경 (showAppBottomSheet와 동일한 방식)
/// - 카드 시트: 사방 라운드 + 바닥과 간격(24) + 좌우 16
/// - 제목/설명/버튼 텍스트/색상/리턴값을 파라미터로 제어
Future<bool?> showFloatingConfirmSheet(
    BuildContext context, {
      required String title,
      required String description,
      String cancelText = '취소',
      String confirmText = '확인',
      bool barrierDismissible = true,
      bool returnFalseOnBarrierTap = true,
    }) {
  return showGeneralDialog<bool>(
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
            // ===== 배경: Blur + Dim (Fade) =====
            Positioned.fill(
              child: FadeTransition(
                opacity: fade,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: barrierDismissible
                      ? () => Navigator.pop(ctx, returnFalseOnBarrierTap ? false : null)
                      : null,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: BandiEffects.backgroundBlur(),
                      sigmaY: BandiEffects.backgroundBlur(),
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
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: BandiFont.titleMedium(ctx)?.copyWith(
                                color: BandiColor.foundationColor90(ctx),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              description,
                              style: BandiFont.bodyMedium(ctx)?.copyWith(
                                color: BandiColor.accentColorRed(ctx),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),

                            _SheetButton(
                              text: cancelText,
                              background: BandiColor.foundationColor10(ctx),
                              textColor: BandiColor.foundationColor80(ctx),
                              onTap: () => Navigator.pop(ctx, false),
                            ),
                            const SizedBox(height: 8),
                            _SheetButton(
                              text: confirmText,
                              background: BandiColor.accentColorRed(ctx),
                              textColor: BandiColor.neutralColor90(ctx),
                              onTap: () => Navigator.pop(ctx, true),
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
}

class _SheetButton extends StatelessWidget {
  final String text;
  final Color background;
  final Color textColor;
  final VoidCallback onTap;

  const _SheetButton({
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
          borderRadius: BorderRadius.circular(40),
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
