import 'dart:ui';

import 'package:bandi_official/controller/alarm_controller.dart';
import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../components/button/primary_button.dart';
import '../components/button/reaction_button.dart';
import '../components/toggle/language_toggle_switch.dart';

class OtherDiary extends StatefulWidget {
  const OtherDiary({super.key, required this.writeProvider});

  final HomeToWrite writeProvider;

  @override
  _OtherDiaryState createState() => _OtherDiaryState();
}

class _OtherDiaryState extends State<OtherDiary> {
  bool showFirstPage = true;

  bool isKorean = true;
  bool isLoading = false;
  String originalLang = 'KO'; // 초기 언어 ('KO' or 'EN')
  String translatedContent = '';
  String translatedTitle = '';

  bool containsKorean(String text) {
    final koreanRegex = RegExp(r'[가-힣]');
    return koreanRegex.hasMatch(text);
  }

  @override
  void initState() {
    super.initState();
    final originalContent = widget.writeProvider.otherDiaryModel.content;
    final originalTitle = widget.writeProvider.otherDiaryModel.title;

    originalLang = containsKorean(originalContent) ? 'KO' : 'EN';

    translatedContent = originalContent;
    translatedTitle = originalTitle;
    isKorean = originalLang == 'KO'; // 기본 토글 상태
  }


  void _togglePage() {
    setState(() {
      showFirstPage = !showFirstPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showFirstPage
        ? firstPage(context, widget.writeProvider)
        : secondPage(context, widget.writeProvider);
  }

  Widget firstPage(context, HomeToWrite writeProvider) {
    return BackdropFilter(
      filter: ImageFilter.blur(
          sigmaX: BandiEffects.backgroundBlur(),
          sigmaY: BandiEffects.backgroundBlur()),
      child: Container(
        color: BandiColor.neutralColor10(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Scaffold(
            backgroundColor: BandiColor.transparent(context),
            appBar: AppBar(
              backgroundColor: BandiColor.transparent(context),
              actions: [
                GestureDetector(
                  onTap: () {
                    writeProvider.offDiaryOpen();
                  },
                  child: PhosphorIcon(
                    PhosphorIcons.x(),
                    color: BandiColor.neutralColor40(context),
                  ),
                )
              ],
            ),
            body: Center(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'other_diary_title'.tr(context),
                          textAlign: TextAlign.center,
                          style: BandiFont.headlineMedium(context)?.copyWith(
                              color: BandiColor.neutralColor100(context)),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Image.asset(
                          "./assets/images/icons/otherDiary.png",
                          scale: 2,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  CustomPrimaryButton(
                    title: 'other_diary_view'.tr(context),
                    onPrimaryButtonPressed: _togglePage,
                    disableButton: false,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget secondPage(BuildContext context, HomeToWrite writeProvider) {
    bool reaction1 = false;
    bool reaction2 = false;
    bool reaction3 = false;
    int reactionValue = -1;

    MailController mailController = context.watch<MailController>();
    AlarmController alarmController = context.watch<AlarmController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: BandiColor.neutralColor90(context),
                  borderRadius: BandiEffects.radius(),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  if (reaction1) {
                                    reactionValue = 0;
                                  } else if (reaction2) {
                                    reactionValue = 1;
                                  } else if (reaction3) {
                                    reactionValue = 2;
                                  }

                                  if (reactionValue != -1) {
                                    mailController.saveLikedDiaryToLocal(
                                        writeProvider.otherDiaryModel,
                                        reactionValue);

                                    saveReactionInDB(
                                        writeProvider.otherDiaryModel.diaryId,
                                        writeProvider.otherDiaryModel.reaction,
                                        reaction1,
                                        reaction2,
                                        reaction3);

                                    String fcmToken = (await FirebaseFirestore
                                            .instance
                                            .collection('users')
                                            .doc(writeProvider
                                                .otherDiaryModel.userId)
                                            .get())
                                        .data()?['fcmToken'];

                                    alarmController.sendLikedDiaryNotification(
                                      writeProvider.otherDiaryModel.diaryId,
                                      fcmToken,
                                      writeProvider.otherDiaryModel.userId,
                                    );
                                  }
                                  writeProvider.offDiaryOpen();
                                },
                                child: PhosphorIcon(
                                  PhosphorIcons.x(),
                                  color: BandiColor.foundationColor40(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  translatedTitle,
                                  style: BandiFont.displaySmall(context)?.copyWith(
                                      color:
                                          BandiColor.foundationColor100(context)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('journal_calendar_header_2'.tr(context)).format(writeProvider
                                      .otherDiaryModel.createdAt
                                      .toDate()),
                                  style: BandiFont.headlineSmall(context)?.copyWith(
                                      color:
                                          BandiColor.foundationColor100(context)),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      translatedContent,
                                      style: BandiFont.titleSmall(context)
                                          ?.copyWith(
                                              color: BandiColor.foundationColor100(
                                                  context)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LanguageToggleSwitch(
                                originalContent: widget.writeProvider.otherDiaryModel.content,
                                originalTitle: widget.writeProvider.otherDiaryModel.title,
                                initialLanguage: originalLang, // 초기 언어 설정 ('KO' 또는 'EN')
                                onToggleCompleted: (translatedContent, translatedTitle, currentLanguage) {
                                  setState(() {
                                    this.translatedContent = translatedContent;
                                    this.translatedTitle = translatedTitle;
                                    isKorean = currentLanguage == 'KO';
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    isLoading
                        ? const Center(child: CircularProgressIndicator()) : Container()
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomReactionButton(
                    onFirstButtonPressed: () {
                      reaction1 = true;
                      reaction2 = false;
                      reaction3 = false;
                    },
                    onSecondButtonPressed: () {
                      reaction1 = false;
                      reaction2 = true;
                      reaction3 = false;
                    },
                    onThirdButtonPressed: () {
                      reaction1 = false;
                      reaction2 = false;
                      reaction3 = true;
                    },
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

Future<void> saveReactionInDB(String diaryId, List currReaction, bool reaction1,
    bool reaction2, bool reaction3) async {
  int newReaction1 = currReaction[0];
  int newReaction2 = currReaction[1];
  int newReaction3 = currReaction[2];
  if (reaction1) newReaction1++;
  if (reaction2) newReaction2++;
  if (reaction3) newReaction3++;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  await firestore.collection('allDiary').doc(diaryId).update({
    'reaction': [newReaction1, newReaction2, newReaction3]
  });
}