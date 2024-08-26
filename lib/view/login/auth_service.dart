import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  // signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleSignInAccount =
  //         await googleSignIn.signIn();

  //     if (googleSignInAccount != null) {
  //       final GoogleSignInAuthentication googleSignInAuthentication =
  //           await googleSignInAccount.authentication;
  //       final AuthCredential authCredential = GoogleAuthProvider.credential(
  //           accessToken: googleSignInAuthentication.accessToken,
  //           idToken: googleSignInAuthentication.idToken);
  //       await auth.signInWithCredential(authCredential);
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     log(e.toString());
  //   }
  // }

  Future signInWithGoogle() async {
    //begin interactive sign in process
    GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount? gUser = await _googleSignIn.signIn();

    if (gUser == null) {
      return null;
    }

    //obtain auth details from request
    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    //create a new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // final userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);

    final userCollection = FirebaseFirestore.instance.collection("users");

    String? userId = FirebaseAuth.instance.currentUser?.uid;
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    final docRef = userCollection.doc(userId);
    DocumentSnapshot snapshot = await docRef.get();

    if (snapshot.exists) {
    } else {
      await docRef.set({
        "created_at": FieldValue.serverTimestamp(),
        "email": userEmail,
        "nickname": "",
        "likedDiaryId": [], // Empty string array
        "myDiaryId": [], // Empty string array
        "socialLoginProvider": "google",
        "updatedAt": FieldValue.serverTimestamp(),
        "userId": userId,
      });
    }

    final dateDocRef = docRef.collection("mailBox").doc("");
    //finally, lets sign in

    return FirebaseAuth.instance.currentUser;
  }
}
