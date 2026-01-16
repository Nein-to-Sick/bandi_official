import 'dart:ui';
import 'package:bandi_official/components/appbar/new_custom_appbar.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:bandi_official/localization/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../tutorial/controller/tutorial_controller.dart';
import '../tutorial/tutorial_overlay.dart';

class DetailViewSheet {
  final Object item;
  final MailController mailController;

  DetailViewSheet({required this.item, required this.mailController});

  Future<T?> show<T>(BuildContext context) async {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark, // Android
      statusBarBrightness: Brightness.light, // iOS
    ));

    final result = await showGeneralDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierColor: BandiColor.transparent(context),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) {
        return DetailView(
          item: item,
          mailController: mailController,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light, // Android
      statusBarBrightness: Brightness.dark, // iOS
    ));

    return result;
  }
}

class DetailView extends StatefulWidget {
  final Object item;
  final MailController mailController;

  const DetailView({
    super.key,
    required this.item,
    required this.mailController,
  });

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  final GlobalKey _tutorialCloseXKey = GlobalKey();

  Rect? _localRect;

  Rect? _calcLocalRect() {
    final keyCtx = _tutorialCloseXKey.currentContext;
    if (keyCtx == null) return null;

    final render = keyCtx.findRenderObject();
    if (render is! RenderBox || !render.hasSize) return null;

    final tlGlobal = render.localToGlobal(Offset.zero);
    final brGlobal = render.localToGlobal(render.size.bottomRight(Offset.zero));
    final raw = Rect.fromPoints(tlGlobal, brGlobal);

    final overlayBox = context.findRenderObject();
    if (overlayBox is! RenderBox || !overlayBox.hasSize) return null;

    final tlLocal = overlayBox.globalToLocal(raw.topLeft);
    final brLocal = overlayBox.globalToLocal(raw.bottomRight);

    return Rect.fromPoints(tlLocal, brLocal).inflate(6).shift(const Offset(7, -7));
  }

  void _refreshRectIfNeeded() {
    final tc = context.read<TutorialController>();
    final focusingCloseX =
        tc.isGrowthFlow && tc.growthPhase == GrowthTutorialPhase.focusLetterCloseX;

    if (!focusingCloseX) {
      if (_localRect != null) {
        setState(() => _localRect = null);
      }
      return;
    }

    final r = _calcLocalRect();
    if (r == null) return;

    // 불필요한 rebuild 방지
    if (_localRect == null || (_localRect! != r)) {
      setState(() => _localRect = r);
    }
  }

  @override
  void initState() {
    super.initState();
    // 첫 프레임 이후 rect 계산
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshRectIfNeeded());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 튜토리얼 phase 변경 등으로 rebuild 되었을 때도 다시 계산
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshRectIfNeeded());
  }

  @override
  Widget build(BuildContext context) {
    final tc = context.watch<TutorialController>();

    final focusingCloseX =
        tc.isGrowthFlow && tc.growthPhase == GrowthTutorialPhase.focusLetterCloseX;

    String title = '';
    String date = '';
    String content = '';

    final item = widget.item;

    if (item is Letter) {
      title = 'detail_view_letter_title'.tr(context);
      date = DateFormat(
        'detail_view_letter_date_form'.tr(context),
        'detail_view_date_form_country'.tr(context),
      ).format(item.date.toDate());
      content = item.content;
    } else if (item is Diary) {
      title = item.title;
      final dateTime = DateFormat('yyyy-MM-dd').parse(item.otherUserLikedAt);
      date =
      '${'detail_view_header_1'.tr(context)}: ${DateFormat('detail_view_diary_date_form'.tr(context), 'detail_view_date_form_country'.tr(context)).format(dateTime)}';
      content = item.content;
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) widget.mailController.toggleDetailView(false);
      },
      child: Scaffold(
        backgroundColor: BandiColor.transparent(context),
        extendBodyBehindAppBar: true,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(color: BandiColor.neutralColor80(context)),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: BandiEffects.blurSmall,
                  sigmaY: BandiEffects.blurSmall,
                ),
                child: Container(color: Colors.transparent),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: NewCustomAppBar(
                    appBarType: AppBarType.headLineFoundation,
                    title: title,
                    rightActionButtonIcon: PhosphorIcons.x(PhosphorIconsStyle.thin),
                    rightActionButtonKey: _tutorialCloseXKey,
                    onRightActionButtonPressed: () {
                      final tc = context.read<TutorialController>();
                      if (tc.isGrowthFlow &&
                          tc.growthPhase == GrowthTutorialPhase.focusLetterCloseX) {
                        tc.setGrowthPhase(GrowthTutorialPhase.focusTrayNav);
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          '\n$content\n\n$date\n\n',
                          textAlign: TextAlign.start,
                          style: BandiFont.bodyLarge(context)?.copyWith(
                            color: BandiColor.foundationColor100(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ✅ 오버레이는 반드시 Positioned.fill로 “최상단”에
            if (focusingCloseX && _localRect != null)
              Positioned.fill(
                child: TutorialOverlay(
                  targetRect: _localRect!,
                  radius: 14,
                  guide: const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
