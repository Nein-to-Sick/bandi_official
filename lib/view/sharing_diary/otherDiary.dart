import 'dart:developer';
import 'dart:ui';

import 'package:bandi_official/components/dialogue/reset_dialogue.dart';
import 'package:bandi_official/controller/alarm_controller.dart';
import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/string_extention.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../components/button/primary_button.dart';
import '../../components/button/reaction_button.dart';
import '../../components/toggle/language_toggle_switch.dart';
import '../../controller/other_diary_controller.dart';



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

  // 반응 선택 상태 (UI state)
  bool reaction1 = false;
  bool reaction2 = false;
  bool reaction3 = false;

  // 컨트롤러 (로직 담당)
  late OtherDiaryController _controller;

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

    _controller = OtherDiaryController();
  }

  void _togglePage() {
    setState(() {
      showFirstPage = !showFirstPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showFirstPage
        ? _firstPage(context, widget.writeProvider)
        : _secondPage(context, widget.writeProvider);
  }

  Widget _firstPage(context, HomeToWrite writeProvider) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: BandiEffects.backgroundBlur(),
        sigmaY: BandiEffects.backgroundBlur(),
      ),
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
                            color: BandiColor.neutralColor100(context),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Image.asset(
                          "./assets/images/icons/otherDiary.png",
                          scale: 2,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  CustomPrimaryButton(
                    title: 'other_diary_view'.tr(context),
                    onPrimaryButtonPressed: _togglePage,
                    disableButton: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _secondPage(BuildContext context, HomeToWrite writeProvider) {
    final mailController = context.watch<MailController>();
    final alarmController = context.watch<AlarmController>();

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
                          padding:
                          const EdgeInsets.only(top: 16.0, right: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // 신고 버튼
                              GestureDetector(
                                onTap: () {
                                  showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return CustomResetDialogue(
                                        text: 'dialogue_report_message'
                                            .tr(context),
                                        onYesText: 'dialogue_report_on_yes'
                                            .tr(context),
                                        onNoText:
                                        'dialogue_report_on_no'.tr(context),
                                        onYesFunction: () async {
                                          Navigator.pop(context, true);

                                          try {
                                            // 개인의 공유 일기 사용자 차단 목록 추가
                                            final userId = FirebaseAuth
                                                .instance.currentUser!.uid;
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(userId)
                                                .update({
                                              'blockedUsersList':
                                              FieldValue.arrayUnion([
                                                writeProvider
                                                    .otherDiaryModel.userId
                                              ]),
                                            });
                                            log('update blocked user list');

                                            // 신고 받은 일기 작성자의 신고 카운트 추가
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(writeProvider
                                                .otherDiaryModel.userId)
                                                .update({
                                              'reported_count':
                                              FieldValue.increment(1),
                                            });
                                            log(
                                                'update other user\'s reported count');
                                          } on FirebaseException catch (e) {
                                            log('Firestore error: ${e.message}');
                                          } catch (e) {
                                            log('unkown error: $e');
                                          }

                                          // 공유 일기 창 닫기
                                          writeProvider.offDiaryOpen();
                                        },
                                        onNoFunction: () {
                                          Navigator.pop(context, false);
                                        },
                                      );
                                    },
                                  ).then((result) {
                                    if (result! && context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          elevation: 3,
                                          content: Text(
                                            "dialogue_report_snackBar_message"
                                                .tr(context),
                                            style: BandiFont.displaySmall(
                                              context,
                                            )?.copyWith(
                                              color: BandiColor.neutralColor90(
                                                context,
                                              ),
                                            ),
                                          ),
                                          margin: EdgeInsets.only(
                                            left: 25.0,
                                            right: 25.0,
                                            bottom: MediaQuery.of(context)
                                                .size
                                                .height *
                                                0.1,
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BandiEffects.radius(),
                                          ),
                                        ),
                                      );
                                    }
                                  });
                                },
                                child: PhosphorIcon(
                                  PhosphorIcons.siren(),
                                  size: 24,
                                  color: BandiColor.foundationColor40(context),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // 닫기 + 반응 저장 버튼
                              GestureDetector(
                                onTap: () async {
                                  await _controller.handleCloseAndReaction(
                                    writeProvider: writeProvider,
                                    reaction1: reaction1,
                                    reaction2: reaction2,
                                    reaction3: reaction3,
                                    mailController: mailController,
                                    alarmController: alarmController,
                                    onDone: () {
                                      // UI 마무리: 페이지 닫기
                                      writeProvider.offDiaryOpen();
                                    },
                                  );
                                },
                                child: PhosphorIcon(
                                  PhosphorIcons.x(),
                                  size: 24,
                                  color: BandiColor.foundationColor40(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 제목
                                Text(
                                  translatedTitle,
                                  style: BandiFont.displaySmall(context)
                                      ?.copyWith(
                                    color: BandiColor.foundationColor100(
                                      context,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // 날짜
                                Text(
                                  DateFormat(
                                    'journal_calendar_header_2'.tr(context),
                                  ).format(
                                    writeProvider.otherDiaryModel.createdAt
                                        .toDate(),
                                  ),
                                  style: BandiFont.headlineSmall(context)
                                      ?.copyWith(
                                    color: BandiColor.foundationColor100(
                                      context,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // 내용
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      translatedContent,
                                      style: BandiFont.titleSmall(context)
                                          ?.copyWith(
                                        color: BandiColor.foundationColor100(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),

                        // 언어 토글
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LanguageToggleSwitch(
                                originalContent: widget
                                    .writeProvider.otherDiaryModel.content,
                                originalTitle:
                                widget.writeProvider.otherDiaryModel.title,
                                initialLanguage: originalLang,
                                onToggleCompleted: (translatedContent,
                                    translatedTitle, currentLanguage) {
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
                        ? const Row(
                      children: [
                        SizedBox(width: 5),
                        Center(child: CircularProgressIndicator()),
                      ],
                    )
                        : Container(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 공감 버튼 3개
            Row(
              children: [
                Expanded(
                  child: CustomReactionButton(
                    onFirstButtonPressed: () {
                      setState(() {
                        reaction1 = true;
                        reaction2 = false;
                        reaction3 = false;
                      });
                    },
                    onSecondButtonPressed: () {
                      setState(() {
                        reaction1 = false;
                        reaction2 = true;
                        reaction3 = false;
                      });
                    },
                    onThirdButtonPressed: () {
                      setState(() {
                        reaction1 = false;
                        reaction2 = false;
                        reaction3 = true;
                      });
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
