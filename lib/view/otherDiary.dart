import 'dart:ui';

import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SafeArea(
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
      ),
    );
  }

  Widget secondPage(BuildContext context, HomeToWrite writeProvider) {
    bool reaction1 = false;
    bool reaction2 = false;
    bool reaction3 = false;
    int reactionValue = -1;

    MailController mailController = context.watch<MailController>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: BandiColor.neutralColor90(context),
                    borderRadius: BandiEffects.radius()),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                              onTap: () {
                                Diary updatedDiary = Diary(
                                  userId: writeProvider.userId!,
                                  title: writeProvider.otherDiaryTitle,
                                  content: writeProvider.otherDiaryContent,
                                  emotion: writeProvider.otherDiaryEmotion,
                                  createdAt: writeProvider.otherDiaryCreatedDay,
                                  updatedAt: writeProvider.otherDiaryUpdatedDay,
                                  reaction: writeProvider.otherDiaryReaction,
                                  diaryId: writeProvider.otherDiaryId,
                                );

                                if (reaction1) {
                                  reactionValue = 0;
                                } else if (reaction2) {
                                  reactionValue = 1;
                                } else if (reaction3) {
                                  reactionValue = 2;
                                }

                                // 반응을 추가한 경우에만 기록
                                if (reactionValue != -1) {
                                  mailController.saveLikedDiaryToLocal(
                                      updatedDiary, reactionValue);

                                  // TODO: 상대에게 알림 보내는 로직 추가
                                  saveReactionInDB(
                                      writeProvider.otherDiaryId,
                                      writeProvider.otherDiaryReaction,
                                      reaction1,
                                      reaction2,
                                      reaction3);
                                }

                                writeProvider.offDiaryOpen();
                              },
                              child: PhosphorIcon(
                                PhosphorIcons.x(),
                                color: BandiColor.foundationColor40(context),
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            writeProvider.otherDiaryTitle,
                            style: BandiFont.displaySmall(context)?.copyWith(
                                color: BandiColor.foundationColor100(context)),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            writeProvider.otherDiaryDay,
                            style: BandiFont.headlineSmall(context)?.copyWith(
                                color: BandiColor.foundationColor100(context)),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          SingleChildScrollView(
                              child: Text(
                            writeProvider.otherDiaryContent,
                            style: BandiFont.titleSmall(context)?.copyWith(
                                color: BandiColor.foundationColor100(context)),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
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
                )),
              ],
            )
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
