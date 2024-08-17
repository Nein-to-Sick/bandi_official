import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class LikedDiaryPage extends StatelessWidget {
  const LikedDiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    MailController mailController = context.watch<MailController>();
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: StreamBuilder(
        stream: mailController.getLikedDiariesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No diarys available.'));
          }

          final diarys = snapshot.data!;

          return ListView.builder(
            itemCount: diarys.length,
            itemBuilder: (context, index) {
              final diary = diarys[index];
              String combinedEmotions =
                  (diary['emotion'] as List<dynamic>).join(', ');
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: GestureDetector(
                  // 일기 열람 기능 추가
                  onTap: () {},
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(diary['title'] ?? '제목 없음',
                            style: BandiFont.headlineMedium(context)?.copyWith(
                                color: BandiColor.neutralColor100(context))),
                        const SizedBox(height: 8),
                        Text(
                          diary['content'] ?? '내용 없음',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: BandiFont.headlineSmall(context)?.copyWith(
                              color: BandiColor.neutralColor60(context)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              DateFormat('yyyy.M.d').format(
                                  (diary['createdAt'] as Timestamp).toDate()),
                              style: BandiFont.headlineSmall(context)?.copyWith(
                                  color: BandiColor.neutralColor60(context)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                combinedEmotions,
                                style: BandiFont.headlineSmall(context)
                                    ?.copyWith(
                                        color:
                                            BandiColor.neutralColor60(context)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(
                          color: BandiColor.neutralColor20(context),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
