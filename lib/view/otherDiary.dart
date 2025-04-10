import 'dart:math';
import 'dart:ui';
import 'dart:developer' as dev;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:bandi_official/controller/alarm_controller.dart';
import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../components/button/primary_button.dart';
import '../components/button/reaction_button.dart';

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

  String? cachedEnglishTranslation;
  String? cachedKoreanTranslation;
  String? cachedEnglishTitle;  // 🔹 영어 제목 캐시
  String? cachedKoreanTitle;  // 🔹 영어 제목 캐시

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

  Future<void> handleLanguageToggle(bool value) async {
    setState(() {
      isLoading = true;
    });

    if (originalLang == 'KO') {
      // 원문이 한글 → 영어로 번역
      if (!value) {
        // 한국어 → 영어
        if (cachedEnglishTranslation != null && cachedEnglishTitle != null) {
          setState(() {
            translatedContent = cachedEnglishTranslation!;
            translatedTitle = cachedEnglishTitle!;
            isKorean = false;
            isLoading = false;
          });
        } else {
          try {
            final content = await translateWithDeepL(
                widget.writeProvider.otherDiaryModel.content, 'EN');
            final title = await translateWithDeepL(
                widget.writeProvider.otherDiaryModel.title, 'EN');

            setState(() {
              cachedEnglishTranslation = content;
              cachedEnglishTitle = title;
              translatedContent = content;
              translatedTitle = title;
              isKorean = false;
              isLoading = false;
            });
          } catch (e) {
            setState(() {
              translatedContent = 'Translation failed.';
              translatedTitle = 'Title translation failed.';
              isKorean = false;
              isLoading = false;
            });
          }
        }
      } else {
        // 영어 → 한글 (원본 복원)
        setState(() {
          translatedContent = widget.writeProvider.otherDiaryModel.content;
          translatedTitle = widget.writeProvider.otherDiaryModel.title;
          isKorean = true;
          isLoading = false;
        });
      }
    } else {
      // 원문이 영어 → 한국어로 번역
      if (value) {
        // 영어 → 한국어
        if (cachedKoreanTranslation != null && cachedKoreanTitle != null) {
          setState(() {
            translatedContent = cachedKoreanTranslation!;
            translatedTitle = cachedKoreanTitle!;
            isKorean = true;
            isLoading = false;
          });
        } else {
          try {
            final content = await translateWithDeepL(
                widget.writeProvider.otherDiaryModel.content, 'KO');
            final title = await translateWithDeepL(
                widget.writeProvider.otherDiaryModel.title, 'KO');

            setState(() {
              cachedKoreanTranslation = content;
              cachedKoreanTitle = title;
              translatedContent = content;
              translatedTitle = title;
              isKorean = true;
              isLoading = false;
            });
          } catch (e) {
            setState(() {
              translatedContent = '번역에 실패했습니다.';
              translatedTitle = '제목 번역 실패';
              isKorean = true;
              isLoading = false;
            });
          }
        }
      } else {
        // 한국어 → 영어 (원본 복원)
        setState(() {
          translatedContent = widget.writeProvider.otherDiaryModel.content;
          translatedTitle = widget.writeProvider.otherDiaryModel.title;
          isKorean = false;
          isLoading = false;
        });
      }
    }
  }


  @override
  void dispose() {
    cachedEnglishTranslation = null; // ✅ 캐시 비우기
    super.dispose();
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
                          "반디님과 비슷한 친구에게\n공감을 전달해주세요!",
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
                    title: '일기 보기',
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
                                  DateFormat('yyyy년 M월 d일').format(writeProvider
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
                          padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                isKorean ? '한국어' : 'English',
                                style: BandiFont.titleSmall(context)
                                    ?.copyWith(
                                    color: BandiColor.foundationColor100(
                                        context)),
                              ),
                              const SizedBox(width: 10,),
                              Switch(
                                value: isKorean,
                                onChanged: handleLanguageToggle,
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

Future<String> translateWithDeepL(String text, String targetLang) async {
  String apiKey = dotenv.env['DEEPL_API_KEY']!; // 보안상 .env 처리 권장
  final response = await http.post(
    Uri.parse('https://api-free.deepl.com/v2/translate'),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'DeepL-Auth-Key $apiKey',
    },
    body: {
      'text': text,
      'target_lang': targetLang, // 'EN' or 'KO'
    },
  );

  if (response.statusCode == 200) {
    final decodedBody = utf8.decode(response.bodyBytes);
    dev.log('DeepL response body: $decodedBody'); // ✅ 추가
    final jsonResponse = json.decode(decodedBody);

    return jsonResponse['translations'][0]['text'];
  } else {
    throw Exception('Failed to translate: ${response.body}');
  }
}
