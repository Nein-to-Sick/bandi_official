import 'dart:developer';

import 'package:bandi_official/view/alarm/controller/alarm_controller.dart';
import 'package:bandi_official/controller/home_to_write.dart';
import 'package:bandi_official/view/mail/controller/mail_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../analytics/log_other_diary_reacted.dart';

class OtherDiaryController {
  bool _isProcessing = false;
  bool _isAlarmSendOnce = false;

  Future<void> handleCloseAndReaction({
    required HomeToWrite writeProvider,
    required bool reaction1,
    required bool reaction2,
    required bool reaction3,
    required MailController mailController,
    required AlarmController alarmController,
    required void Function() onDone,
  }) async {
    // 1) 중복 탭 방지
    if (_isProcessing) {
      return;
    }
    _isProcessing = true;

    try {
      // 2) 어떤 반응인지 결정
      int reactionValue = -1;
      if (reaction1) {
        reactionValue = 0;
      } else if (reaction2) {
        reactionValue = 1;
      } else if (reaction3) {
        reactionValue = 2;
      }

      // 반응 안 골랐으면 그냥 닫고 끝
      if (reactionValue == -1) {
        onDone();
        return;
      }

      await logOtherDiaryReacted(
          kind: reactionValue == 0
              ? "응원해요"
              : reactionValue == 1
                  ? "공감해요"
                  : "함께해요");

      final diaryModel = writeProvider.otherDiaryModel;
      final diaryId = diaryModel.diaryId;
      final userId = diaryModel.userId;

      // 3) 로컬 저장
      mailController.saveLikedDiaryToLocal(diaryModel, reactionValue);

      // 4) Firestore에 반응 업데이트
      final diaryRef =
          FirebaseFirestore.instance.collection('allDiary').doc(diaryId);
      final docSnapshot = await diaryRef.get();

      if (docSnapshot.exists) {
        await saveReactionInDB(
          diaryId,
          diaryModel.reaction,
          reaction1,
          reaction2,
          reaction3,
        );
      } else {
        log("Diary document not found: $diaryId");
      }

      // 5) FCM 알림 전송
      final userDocSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final fcmToken = userDocSnapshot.data()?['fcmToken'];

      if (!_isAlarmSendOnce &&
          fcmToken != null &&
          fcmToken is String &&
          fcmToken.isNotEmpty) {
        _isAlarmSendOnce = true;
        alarmController.sendLikedDiaryNotification(
          diaryId,
          userId,
          reactionValue,
        );
      } else {
        log("Invalid or missing FCM token for user: $userId");
      }
    } catch (e, stack) {
      log("Error in reaction process: $e\n$stack");
    } finally {
      // 6) 화면 닫기 콜백
      onDone();
    }
  }
}

Future<void> saveReactionInDB(
  String diaryId,
  List currReaction,
  bool reaction1,
  bool reaction2,
  bool reaction3,
) async {
  try {
    if (currReaction.length != 3) {
      log("currReaction does not have 3 elements: $currReaction");
      return;
    }

    int newReaction1 = currReaction[0] ?? 0;
    int newReaction2 = currReaction[1] ?? 0;
    int newReaction3 = currReaction[2] ?? 0;

    if (reaction1) newReaction1++;
    if (reaction2) newReaction2++;
    if (reaction3) newReaction3++;

    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('allDiary').doc(diaryId);

    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      log("Diary document not found in saveReactionInDB: $diaryId");
      return;
    }

    await docRef.update({
      'reaction': [newReaction1, newReaction2, newReaction3],
    });

    log(
      "Reaction updated in Firestore: "
      "[$newReaction1, $newReaction2, $newReaction3]",
    );
  } catch (e, stack) {
    log("Error in saveReactionInDB: $e\n$stack");
  }
}
