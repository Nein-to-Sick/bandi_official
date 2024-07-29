import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeToWrite with ChangeNotifier {
  bool _write = false;

  bool get write => _write;

  void toggleWrite() {
    _write = !_write;
    notifyListeners();
  }

  Future<void> saveDiary(String title, String content, List emotion) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final userId = "21jPhIHrf7iBwVAh92ZW"; // 실제 사용자 ID로 교체 필요

    try {
      // Get the current user's document
      DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();

      // Check if the document exists
      if (!userDoc.exists) {
        log("User document does not exist.");
        return;
      }

      // Cast the document data to a Map
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Get the current number of diaries
      List<dynamic> myDiaryId = userData['myDiaryId'] ?? [];
      int diaryCount = myDiaryId.length;

      // Generate a new diary ID
      String newDiaryId = "${userId}${diaryCount + 1}";

      // Create the diary data
      final diaryData = {
        'userId': userId,
        'title': title,
        'content': content,
        'emotion': emotion,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'reaction': [0, 0, 0],
        'diaryId': newDiaryId,
      };

      // Add the new diary to the allDiary collection
      await firestore.collection('allDiary').doc(newDiaryId).set(diaryData);

      // Update the user's document in the users collection
      await firestore.collection('users').doc(userId).update({
        'myDiaryId': FieldValue.arrayUnion([newDiaryId]),
      });

    } catch (e) {
      log("Error saving diary: $e");
    }
  }
}
