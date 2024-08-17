import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class MailController with ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot? lastDocumentForLetter;
  DocumentSnapshot? lastDocumentForlikedDiary;

  // Get current user from FirebaseAuth
  User? get currentUser => FirebaseAuth.instance.currentUser;

  // Last fetched index for pagination
  int _lastFetchedIndex = 0;
  // maximun fetch limit
  int fetchItemLimit = 10;

  Stream<List<DocumentSnapshot>> getLettersStream() {
    final user = currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }
    return firestore
        .collection('users')
        //.doc(userId!.uid)
        .doc('21jPhIHrf7iBwVAh92ZW')
        .collection('letters')
        .orderBy('date', descending: true)
        .limit(fetchItemLimit)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<List<DocumentSnapshot>> fetchLetters() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }

    Query query = firestore
        .collection('users')
        //.doc(currentUser!.uid)
        .doc('21jPhIHrf7iBwVAh92ZW')
        .collection('letters')
        .orderBy('date', descending: true)
        .limit(fetchItemLimit);

    if (lastDocumentForLetter != null) {
      query = query.startAfterDocument(lastDocumentForLetter!);
    }

    QuerySnapshot querySnapshot = await query.get();

    // Update lastDocumentForLetter for the next fetch
    if (querySnapshot.docs.isNotEmpty) {
      lastDocumentForLetter = querySnapshot.docs.last;
    }

    return querySnapshot.docs;
  }

  Future<void> deleteLetter(String letterId) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }

    try {
      await firestore
          .collection('users')
          //.doc(currentUser!.uid)
          .doc('21jPhIHrf7iBwVAh92ZW')
          .collection('letters')
          .doc(letterId)
          .delete();
    } catch (e) {
      dev.log("Error deleting letter: $e");
    }
  }

  // Stream to fetch the first 10 likedDiaryId items and their corresponding documents from 'allDiary'
  Stream<List<DocumentSnapshot>> getLikedDiariesStream() async* {
    final user = currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }

    try {
      // Get the likedDiaryIds from the user's document
      DocumentSnapshot userDoc = await firestore
          .collection('users') //.doc(currentUser!.uid)
          .doc('21jPhIHrf7iBwVAh92ZW')
          .get();

      List<String> likedDiaryIds = List<String>.from(userDoc['likedDiaryId']);

      // First 10 likedDiaryIds
      List<String> firstLikedDiaryIds =
          likedDiaryIds.take(fetchItemLimit).toList();

      if (firstLikedDiaryIds.isNotEmpty) {
        Query query = firestore
            .collection('allDiary')
            .where(FieldPath.documentId, whereIn: firstLikedDiaryIds)
            .orderBy('createdAt', descending: true);

        QuerySnapshot querySnapshot = await query.get();
        // Update the lastDocument with the last fetched document
        if (querySnapshot.docs.isNotEmpty) {
          lastDocumentForlikedDiary = querySnapshot.docs.last;
        }

        yield querySnapshot.docs;
      } else {
        yield [];
      }
    } catch (e) {
      dev.log("Error fetching liked diaries: $e");
      yield [];
    }
  }

  Future<List<DocumentSnapshot>> fetchLikedDiaries() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }

    if (lastDocumentForlikedDiary == null) {
      return [];
    }

    DocumentSnapshot userDoc = await firestore
        .collection('users') //.doc(currentUser!.uid)
        .doc('21jPhIHrf7iBwVAh92ZW')
        .get();

    List<String> likedDiaryIds = List<String>.from(userDoc['likedDiaryId']);
    List<String> nextLikedDiaryIds =
        likedDiaryIds.skip(_lastFetchedIndex).take(fetchItemLimit).toList();

    Query query = firestore
        .collection('allDiary')
        .where(FieldPath.documentId, whereIn: nextLikedDiaryIds)
        .orderBy('createdAt', descending: true)
        .limit(fetchItemLimit);

    QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      lastDocumentForlikedDiary = querySnapshot.docs.last;
    }

    // Update index for the next fetch
    _lastFetchedIndex += fetchItemLimit;

    return querySnapshot.docs;
  }

  // Delete a single likedDiaryId array item
  Future<void> deleteLikedDiary(String diaryId) async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User is not logged in');
    }

    try {
      await firestore
          .collection('users') //.doc(currentUser!.uid)
          .doc('21jPhIHrf7iBwVAh92ZW')
          .update({
        'likedDiaryId': FieldValue.arrayRemove([diaryId]),
      });
    } catch (e) {
      dev.log("Error deleting liked diary: $e");
    }
  }
}
