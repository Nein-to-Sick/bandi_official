import 'package:bandi_official/components/button/primary_button.dart';
import 'package:bandi_official/components/button/reaction_button.dart';
import 'package:bandi_official/model/diary.dart';
import 'package:bandi_official/model/letter.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DetailView extends StatelessWidget {
  final Object item;
  const DetailView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    String title = '';
    String date = '';
    String content = '';

    if (item is Letter) {
      Letter letter = item as Letter;
      title = '반디가 보낸 편지';
      date = DateFormat('yyyy년 MM월').format(letter.date.toDate());
      content = letter.content;
    } else if (item is Diary) {
      Diary diary = item as Diary;
      title = diary.title;
      DateTime dateTime =
          DateFormat('yyyy-MM-dd').parse(diary.otherUserLikedAt);
      date = DateFormat('yyyy년 MM월 dd일').format(dateTime);
      content = diary.content;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: BandiColor.neutralColor100(context),
                    borderRadius: BandiEffects.radius()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                              onTap: () {
                                //Navigator.pop(context);
                              },
                              child: const SizedBox.shrink()
                              // PhosphorIcon(
                              //   PhosphorIcons.x(),
                              //   color: BandiColor.foundationColor40(context),
                              // ),
                              ),
                        ),
                      ),
                      Text(
                        title,
                        style: BandiFont.displaySmall(context)?.copyWith(
                          color: BandiColor.foundationColor100(context),
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        date,
                        style: BandiFont.headlineSmall(context)?.copyWith(
                          color: BandiColor.foundationColor100(context),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Text(
                            content,
                            style: BandiFont.titleSmall(context)?.copyWith(
                              color: BandiColor.foundationColor100(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            CustomPrimaryButton(
              title: '닫기',
              onPrimaryButtonPressed: () {
                Navigator.pop(context);
              },
              disableButton: false,
            )
          ],
        ),
      ),
    );
  }
}
