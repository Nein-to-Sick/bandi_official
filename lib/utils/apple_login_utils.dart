import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Generate a random nonce with a given length (default is 32).
String generateNonce([int length = 32]) {
  final random = Random.secure();
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

/// Hash the nonce using SHA-256.
String hashNonce(String nonce) {
  final bytes = utf8.encode(nonce);
  final digest = sha256.convert(bytes);
  return digest.toString();
}