import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';

class AesUtils {
  static const String _key = '8080808080808080';

  static const String _iv = '8080808080808080';

  static String utf8Parse(String input) {
    final bytes = utf8.encode(input);

    return utf8.decode(bytes).replaceAll('\n', '');
  }

  static String decryptStringAES(String cipherText) {
    try {
      String normalized = cipherText
          .replaceAll('\r', '')
          .replaceAll('\n', '')
          .trim();

      if (normalized.isEmpty) {
        throw const FormatException(
          'Encrypted QR content is empty.',
        );
      }

      // Handle URL-encoding (%2B, %2F, %3D) and spaces
      try {
        normalized = Uri.decodeComponent(normalized);
      } catch (_) {}
      normalized = normalized.replaceAll(' ', '+');

      // Add missing Base64 padding if needed
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }

      debugPrint(
        'Encrypted QR normalized length: ${normalized.length}',
      );

      final keyBytes = Uint8List.fromList(
        utf8.encode(_key),
      );

      final ivBytes = Uint8List.fromList(
        utf8.encode(_iv),
      );

      final encryptedBytes = base64Decode(normalized);

      final cipher = PaddedBlockCipher(
        'AES/CBC/PKCS7',
      );

      final params = PaddedBlockCipherParameters<
          ParametersWithIV<KeyParameter>,
          Null>(
        ParametersWithIV<KeyParameter>(
          KeyParameter(keyBytes),
          ivBytes,
        ),
        null,
      );

      cipher.init(
        false,
        params,
      );

      final decryptedBytes = cipher.process(
        encryptedBytes,
      );

      final result = utf8.decode(decryptedBytes).trim();

      debugPrint(
        'Decrypted QR value: $result',
      );

      return result;
    } catch (e, stackTrace) {
      debugPrint(
        'AES QR decryption failed: $e',
      );

      debugPrint(
        '$stackTrace',
      );

      throw const FormatException(
        'Unable to decrypt QR code.',
      );
    }
  }
}
