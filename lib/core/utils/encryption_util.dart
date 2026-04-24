import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

abstract final class EncryptionUtil {
  static final encrypt.Key _key = encrypt.Key.fromUtf8(
    'jogjasplorasi-key-32-bytes-long!',
  );
  static final encrypt.IV _iv = encrypt.IV.fromUtf8('liquidglass12345');

  static String hashPassword(String rawPassword) {
    return sha256.convert(utf8.encode(rawPassword)).toString();
  }

  static String encryptText(String plainText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    return encrypter.encrypt(plainText, iv: _iv).base64;
  }

  static String decryptText(String encryptedText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    return encrypter.decrypt64(encryptedText, iv: _iv);
  }
}
