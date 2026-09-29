class ScanResult {
  final String rawContent;
  final String format;
  final bool isQrCode;

  const ScanResult({
    required this.rawContent,
    required this.format,
    required this.isQrCode,
  });

  @override
  String toString() {
    return 'ScanResult('
        'format: $format, '
        'isQrCode: $isQrCode, '
        'rawContent: $rawContent'
        ')';
  }
}
