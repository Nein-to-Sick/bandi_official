import 'package:bandi_official/controller/mail_controller.dart';
import 'package:bandi_official/theme/custom_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

class MyLettersPage extends StatelessWidget {
  const MyLettersPage({super.key});

  @override
  Widget build(BuildContext context) {
    MailController mailController = context.watch<MailController>();
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: StreamBuilder(
        stream: mailController.getLettersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No letters available.'));
          }

          final letters = snapshot.data!;

          return ListView.builder(
            itemCount: letters.length,
            itemBuilder: (context, index) {
              final letter = letters[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: GestureDetector(
                  // 편지 열람 기능 추가
                  onTap: () {},
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(letter['title'] ?? '제목 없음',
                            style: BandiFont.headlineMedium(context)?.copyWith(
                                color: BandiColor.neutralColor100(context))),
                        const SizedBox(height: 8),
                        Text(
                          letter['content'] ?? '내용 없음',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: BandiFont.headlineSmall(context)?.copyWith(
                              color: BandiColor.neutralColor60(context)),
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
