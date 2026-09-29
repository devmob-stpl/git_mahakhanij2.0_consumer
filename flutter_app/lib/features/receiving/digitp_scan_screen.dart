import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/scan_result.dart';
import '../../shared/widgets/app_button.dart';

class DigitpScanScreen extends StatefulWidget {
  final String? simulatedPayload;
  final String? error;

  const DigitpScanScreen({
    super.key,
    this.simulatedPayload,
    this.error,
  });

  @override
  State<DigitpScanScreen> createState() => _DigitpScanScreenState();
}

class _DigitpScanScreenState extends State<DigitpScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final TextEditingController _manualController = TextEditingController();
  bool _isProcessingScan = false;
  bool _showManualInput = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessingScan) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue?.trim();

      if (rawValue == null || rawValue.isEmpty) {
        continue;
      }

      _isProcessingScan = true;

      final isQrCode = barcode.format == BarcodeFormat.qrCode;

      final scanResult = ScanResult(
        rawContent: rawValue,
        format: barcode.format.name,
        isQrCode: isQrCode,
      );

      debugPrint('========== SCAN ==========');
      debugPrint('Format: ${barcode.format.name}');
      debugPrint('Is QR: $isQrCode');
      debugPrint('Raw Content: $rawValue');
      debugPrint('Raw Length: ${rawValue.length}');
      debugPrint('==========================');

      try {
        _controller.stop();
      } catch (e) {
        debugPrint('Error stopping mobile scanner: $e');
      }

      if (!mounted) {
        return;
      }

      debugPrint('Popping ScanResult to caller: $scanResult');
      Navigator.of(context).pop(scanResult);
      return;
    }
  }

  void _submitManualValue(String value) {
    if (_isProcessingScan) return;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;

    _isProcessingScan = true;

    final result = ScanResult(
      rawContent: trimmed,
      format: 'qrCode',
      isQrCode: false,
    );

    if (!mounted) return;
    debugPrint('Popping Manual ScanResult to caller: $result');
    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    _controller.dispose();
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan DigiTP QR Code / Barcode'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Live camera scanner
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Reticle and overlay
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary500, width: 2.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.qr_code_scanner, size: 64, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Point camera at the driver\'s QR code or barcode',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Error banner if any
          if (widget.error != null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.danger600, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.error!,
                        style: const TextStyle(color: AppColors.danger700, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Action Panel
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    label: 'Simulate Test Scan (Invoice 491)',
                    fullWidth: true,
                    size: AppButtonSize.medium,
                    icon: const Icon(Icons.qr_code, size: 18),
                    onPressed: () {
                      _submitManualValue(widget.simulatedPayload ?? '491');
                    },
                  ),
                  const SizedBox(height: 10),

                  if (_showManualInput) ...[
                    TextField(
                      controller: _manualController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Enter Invoice Number',
                        hintText: 'e.g. 491',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Verify Invoice',
                      fullWidth: true,
                      size: AppButtonSize.medium,
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        if (_manualController.text.trim().isNotEmpty) {
                          _submitManualValue(_manualController.text.trim());
                        }
                      },
                    ),
                  ] else
                    TextButton(
                      onPressed: () => setState(() => _showManualInput = true),
                      child: const Text(
                        'Enter invoice number manually',
                        style: TextStyle(color: AppColors.primary700, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
