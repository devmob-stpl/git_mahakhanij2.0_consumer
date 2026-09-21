import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_button.dart';

class DigitpScanScreen extends StatefulWidget {
  final String? simulatedPayload;
  final Function(String)? onScanComplete;
  final String? error;

  const DigitpScanScreen({
    super.key,
    this.simulatedPayload,
    this.onScanComplete,
    this.error,
  });

  @override
  State<DigitpScanScreen> createState() => _DigitpScanScreenState();
}

class _DigitpScanScreenState extends State<DigitpScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final TextEditingController _manualController = TextEditingController();
  bool _hasScanned = false;
  bool _showManualInput = false;

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _hasScanned = true;
        _submitValue(barcode.rawValue!);
        break;
      }
    }
  }

  void _submitValue(String value) {
    if (widget.onScanComplete != null) {
      widget.onScanComplete!(value);
    } else {
      context.pop(value);
    }
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
        title: const Text('Scan DigiTP QR Code'),
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
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
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
                    'Point camera at the driver\'s QR code or printed DigiTP pass',
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
                    label: 'Simulate QR Scan (Test Pass)',
                    fullWidth: true,
                    size: AppButtonSize.medium,
                    icon: const Icon(Icons.qr_code, size: 18),
                    onPressed: () {
                      _submitValue(widget.simulatedPayload ?? 'MHKNJ:ETP:2026:MH:0436610');
                    },
                  ),
                  const SizedBox(height: 10),

                  if (_showManualInput) ...[
                    TextField(
                      controller: _manualController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: 'Enter e-TP Number or 6-Digit OTP',
                        hintText: 'e.g. 0436610 or ETP/2026/MH/0436610',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Verify Permit',
                      fullWidth: true,
                      size: AppButtonSize.medium,
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        if (_manualController.text.trim().isNotEmpty) {
                          _submitValue(_manualController.text.trim());
                        }
                      },
                    ),
                  ] else
                    TextButton(
                      onPressed: () => setState(() => _showManualInput = true),
                      child: const Text(
                        'Enter e-TP number manually',
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
