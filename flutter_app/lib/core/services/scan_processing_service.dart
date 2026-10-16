import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../domain/scan_result.dart';
import '../utils/aes_utils.dart';

class ScanProcessingService {
  const ScanProcessingService();

  String process(ScanResult result) {
    final rawContent = result.rawContent.trim();

    if (rawContent.isEmpty) {
      throw const FormatException(
        'QR code or barcode is empty.',
      );
    }

    String candidateString = '';

    // Handle Barcode Scans
    if (!result.isQrCode && result.format != 'manual') {
      debugPrint('Processing Barcode: Decoding Base64...');
      try {
        final decodedBytes = base64.decode(rawContent);
        candidateString = utf8.decode(decodedBytes);
        debugPrint('Base64 Decoded Barcode Payload: $candidateString');
      } catch (e) {
        debugPrint('Base64 Decoding failed for Barcode, falling back to raw payload: $e');
        candidateString = rawContent;
      }
    } 
    // Handle QR Codes and Manual Fallback
    else {
      final processedContent = AesUtils.utf8Parse(rawContent);
      if (processedContent.isEmpty) {
        throw const FormatException(
          'Invalid QR code or manual input.',
        );
      }

      candidateString = processedContent;

      if (RegExp(r'^\d+$').hasMatch(processedContent)) {
        debugPrint('Payload is direct numeric invoice number: $processedContent');
        return int.parse(processedContent).toString();
      }

      try {
        final decrypted = AesUtils.decryptStringAES(processedContent);
        if (decrypted.trim().isNotEmpty) {
          candidateString = decrypted;
          debugPrint('Decrypted AES Payload: $candidateString');
        }
      } catch (e) {
        debugPrint('AES Decryption attempt failed, falling back to raw payload: $e');
        candidateString = processedContent;
      }
    }

    final cleanedValue = candidateString
        .replaceAll('\r', '')
        .replaceAll('\n', '')
        .trim();

    final match = RegExp(r'\d+').firstMatch(cleanedValue);
    final String digitsOnly = match != null ? match.group(0)! : cleanedValue;

    final invoiceNo = int.tryParse(digitsOnly);

    if (invoiceNo == null || invoiceNo <= 0) {
      throw FormatException(
        'Invalid invoice number in scanned code: "$cleanedValue"',
      );
    }

    debugPrint('EXTRACTED INVOICE NUMBER: $invoiceNo');
    return invoiceNo.toString();
  }
}
