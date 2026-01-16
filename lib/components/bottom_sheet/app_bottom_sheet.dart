import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/custom_theme_data.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,

  bool barrierDismissible = true,
  EdgeInsets contentPadding = const EdgeInsets.fromLTRB(24, 24, 24, 32),
  bool useSafeAreaBottomPadding = true,

  /// ✅ 튜토리얼일 때 true로 주면: 바깥 탭/드래그/뒤로가기 전부 막음
  bool lockDismiss = false,

  bool enableDragToDismiss = true,
}) {
  final effectiveBarrierDismissible = lockDismiss ? false : barrierDismissible;
  final effectiveEnableDrag = lockDismiss ? false : enableDragToDismiss;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: effectiveBarrierDismissible,
    barrierLabel: 'dismiss',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final fade = CurvedAnimation(parent: anim, curve: Curves.easeOut);
      final sheetCurve =
      CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);

      Widget sheetBody = Container(
        width: double.infinity,
        padding: contentPadding.copyWith(
          bottom: useSafeAreaBottomPadding
              ? (contentPadding.bottom +
              MediaQuery.of(ctx).padding.bottom)
              : contentPadding.bottom,
        ),
        decoration: BoxDecoration(
          color: BandiColor.neutralColor90(ctx),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: child,
      );

      // ✅ lockDismiss면 드래그 dismiss 자체를 아예 빼버림
      if (effectiveEnableDrag) {
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

      return PopScope(
        // ✅ 뒤로가기(시스템 back)도 막기
        canPop: !lockDismiss,
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              // ===== 배경: Blur + Dim =====
              Positioned.fill(
                child: FadeTransition(
                  opacity: fade,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: effectiveBarrierDismissible
                        ? () => Navigator.pop(ctx)
                        : null,
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

              // ===== 시트: Slide =====
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
        ),
      );
    },
  );
}
