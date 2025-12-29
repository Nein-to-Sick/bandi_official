import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/custom_theme_data.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  EdgeInsets contentPadding = const EdgeInsets.fromLTRB(24, 24, 24, 32),
  bool useSafeAreaBottomPadding = true,
  bool enableDragToDismiss = true,
}) {

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'dismiss',
    barrierColor: Colors.transparent, // 배경은 우리가 직접 그림
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
      final sheetCurve =
      CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);

      // ===== Sheet content (컨테이너) =====
      Widget sheetBody = Container(
        width: double.infinity,
        padding: contentPadding,
        decoration: BoxDecoration(
          color: BandiColor.neutralColor90(ctx),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: child,
      );

      if (enableDragToDismiss) {
        sheetBody = Dismissible(
          key: const ValueKey('app_bottom_sheet'),
          direction: DismissDirection.down,
          dismissThresholds: const {DismissDirection.down: 0.22},
          resizeDuration: null,
          background: const SizedBox.shrink(),
          onDismissed: (_) => Navigator.pop(ctx),
          child: sheetBody,
        );
      }

      return Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            // ===== 배경: Blur + Dim (Fade만) =====
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

            // ===== 시트: 등장 애니메이션은 SlideTransition으로만 (중복 translate 금지) =====
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(sheetCurve),
                child: sheetBody,
              ),
            ),
          ],
        ),
      );
    },
  );
}
