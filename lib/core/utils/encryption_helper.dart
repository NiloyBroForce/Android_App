import 'dart:convert';

class EncryptionHelper {
  static const String _secretKey = "RentalAppSecretKey2026";

  static String encrypt(String plainText) {
    if (plainText.isEmpty) return plainText;
    final textBytes = utf8.encode(plainText);
    final keyBytes = utf8.encode(_secretKey);
    final encryptedBytes = List<int>.generate(
      textBytes.length,
      (i) => textBytes[i] ^ keyBytes[i % keyBytes.length],
    );
    return base64.encode(encryptedBytes);
  }

  static String decrypt(String cipherText) {
    if (cipherText.isEmpty) return cipherText;
    try {
      final encryptedBytes = base64.decode(cipherText);
      final keyBytes = utf8.encode(_secretKey);
      final decryptedBytes = List<int>.generate(
        encryptedBytes.length,
        (i) => encryptedBytes[i] ^ keyBytes[i % keyBytes.length],
      );
      return utf8.decode(decryptedBytes);
    } catch (_) {
      return cipherText;
    }
  }
}
