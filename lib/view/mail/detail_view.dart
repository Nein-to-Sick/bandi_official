import 'dart:ui';
import 'package:bandi_official/components/appbar/new_custom_appbar.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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

class DetailView extends StatelessWidget {
  final Object item;
  final MailController mailController;
  const DetailView(
      {super.key, required this.item, required this.mailController});

  @override
  Widget build(BuildContext context) {
    String title = '';
    String date = '';
    String content = '';

    if (item is Letter) {
      Letter letter = item as Letter;
      title = 'detail_view_letter_title'.tr(context);
      date = DateFormat('detail_view_letter_date_form'.tr(context),
              'detail_view_date_form_country'.tr(context))
          .format(letter.date.toDate());
      content = letter.content;
    } else if (item is Diary) {
      Diary diary = item as Diary;
      title = diary.title;
      DateTime dateTime =
          DateFormat('yyyy-MM-dd').parse(diary.otherUserLikedAt);
      date =
          '${'detail_view_header_1'.tr(context)}: ${DateFormat('detail_view_diary_date_form'.tr(context), 'detail_view_date_form_country'.tr(context)).format(dateTime)}';
      content = diary.content;
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) mailController.toggleDetailView(false);
      },
      child: Scaffold(
        backgroundColor: BandiColor.transparent(context),
        extendBodyBehindAppBar: true,
        body: Stack(
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
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: NewCustomAppBar(
                    appBarType: AppBarType.headLineFoundation,
                    title: title,
                    rightActionButtonIcon:
                        PhosphorIcons.x(PhosphorIconsStyle.thin),
                    onRightActionButtonPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SingleChildScrollView(
                      child: Text(
                        '\n$content\n\n$date\n\n',
                        style: BandiFont.bodyLarge(context)?.copyWith(
                          color: BandiColor.foundationColor100(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
