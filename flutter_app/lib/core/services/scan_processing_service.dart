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

    final processedContent = AesUtils.utf8Parse(rawContent);

    if (processedContent.isEmpty) {
      throw const FormatException(
        'Invalid QR code or barcode.',
      );
    }

    debugPrint('========== SCAN PROCESSING SERVICE ==========');
    debugPrint('Raw Content: $rawContent');
    debugPrint('Processed Content: $processedContent');
    debugPrint('Is QR: ${result.isQrCode}');

    String candidateString = processedContent;

    // 1. Direct check: if payload is already pure digits (e.g. "491" or "0436610"), use directly
    if (RegExp(r'^\d+$').hasMatch(processedContent)) {
      debugPrint('Payload is direct numeric invoice number: $processedContent');
      return int.parse(processedContent).toString();
    }

    // 2. Attempt AES decryption if marked as QR code or payload length looks like Base64
    if (result.isQrCode || processedContent.length >= 12) {
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

    // 3. Extract numeric digits from candidate string (e.g. "491" from "491" or "Invoice: 491")
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
