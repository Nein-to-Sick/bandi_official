import 'package:cloud_firestore/cloud_firestore.dart';

class AgreementRepository {
  final FirebaseFirestore firestore;

  AgreementRepository({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      firestore.collection('users');

  Future<void> markAgreed({
    required String userId,
  }) async {
    await _users.doc(userId).update({
      "isAgreed": true,
      "last_agreed_at": DateTime.now(),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
}
