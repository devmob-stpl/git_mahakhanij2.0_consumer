import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/location_service.dart';
import '../../core/services/scan_processing_service.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/consumer_digitp_models.dart';
import '../../domain/scan_result.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/consumer_dashboard_count_provider.dart';
import '../../providers/consumer_digitp_provider.dart';
import '../../providers/session_provider.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_scaffold.dart';
import 'digitp_scan_screen.dart';

enum _ReceiveStep {
  initial,   // Step 1: Scan QR Code / Barcode option
  loading,   // Step 2: Fetching DigiTP Details loading state
  scanned,   // Step 3: Display Details + Confirm & Receive
  completed, // Step 4: Successfully Received
}

class ReceiveScreen extends ConsumerStatefulWidget {
  final String? initialInvoiceNo;

  const ReceiveScreen({
    super.key,
    this.initialInvoiceNo,
  });

  @override
  ConsumerState<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends ConsumerState<ReceiveScreen> {
  final ScanProcessingService _scanProcessingService = const ScanProcessingService();

  _ReceiveStep _step = _ReceiveStep.initial;
  ConsumerDigiTpItem? _scannedItem;
  bool _isSubmitting = false;
  bool _alreadyReceived = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialInvoiceNo != null && widget.initialInvoiceNo!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final scanResult = ScanResult(
            rawContent: widget.initialInvoiceNo!.trim(),
            format: 'qrCode',
            isQrCode: false,
          );
          _processScanResult(scanResult);
        }
      });
    }
  }

  /// Process Scan Result (QR or Barcode) and fetch Invoice Details
  Future<void> _processScanResult(ScanResult result) async {
    if (!mounted) return;

    setState(() {
      _step = _ReceiveStep.loading;
      _alreadyReceived = false;
      _statusMessage = null;
    });

    try {
      debugPrint('Processing ScanResult');
      debugPrint('Format: ${result.format}');
      debugPrint('Is QR: ${result.isQrCode}');
      debugPrint('Raw: ${result.rawContent}');

      final invoiceNo = _scanProcessingService.process(result);

      debugPrint('FINAL DigiTP NUMBER: $invoiceNo');

      if (!mounted) return;

      final repo = ref.read(consumerDigiTpRepositoryProvider);
      final user = ref.read(sessionProvider).currentUser;
      int resolvedConsumerId = user?.consumerId ?? 0;

      final response = await repo.getConsumerInvoiceDetails(
        invoiceNo: invoiceNo,
        consumerId: resolvedConsumerId,
      );

      if (!mounted) return;

      if (response.isAlreadyReceived) {
        setState(() {
          _alreadyReceived = true;
          _statusMessage = response.statusMessage.isNotEmpty
              ? response.statusMessage
              : 'Invoice is already received.';
          _scannedItem = response.responseData ?? ConsumerDigiTpItem(invoiceNo: invoiceNo);
          _step = _ReceiveStep.scanned;
        });
        return;
      }

      if (response.isSuccess && response.responseData != null) {
        final item = response.responseData!;
        final isItemReceived = item.invoiceStatusId == 1 ||
            (item.invoiceStatus != null && item.invoiceStatus!.toLowerCase() == 'received');

        setState(() {
          _scannedItem = item;
          _alreadyReceived = isItemReceived;
          _statusMessage = isItemReceived
              ? 'Invoice is already received.'
              : (response.statusMessage.isNotEmpty ? response.statusMessage : null);
          _step = _ReceiveStep.scanned;
        });
        return;
      }

      throw Exception(
        response.statusMessage.isNotEmpty
            ? response.statusMessage
            : 'Unable to fetch DigiTP details.',
      );
    } catch (e, stackTrace) {
      debugPrint('Process scan failed: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        _step = _ReceiveStep.initial;
      });

      await _showErrorDialog(
        e is FormatException ? e.message : e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> _openCameraScanner() async {
    try {
      final result = await Navigator.of(context).push<ScanResult>(
        MaterialPageRoute(
          builder: (context) => const DigitpScanScreen(),
        ),
      );

      debugPrint('Returned ScanResult: $result');

      if (!mounted || result == null) {
        debugPrint('ScanResult is null or widget not mounted.');
        return;
      }

      await _processScanResult(result);
    } catch (e) {
      debugPrint('Scanner navigation error: $e');

      if (!mounted) return;

      await _showErrorDialog(e.toString());
    }
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.enterDigiTpNumber, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.enterDigiTpNumberHint,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty || !RegExp(r'^\d+$').hasMatch(text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid numeric DigiTP Number.')),
                );
                return;
              }
              Navigator.of(ctx).pop();
              if (text.isNotEmpty) {
                final result = ScanResult(
                  rawContent: text,
                  format: 'manual',
                  isQrCode: false,
                );
                _processScanResult(result);
              }
            },
            child: Text(AppLocalizations.of(context)!.fetchDetails),
          ),
        ],
      ),
    );
  }

  /// Confirm & Receive Action with dynamic location capture
  Future<void> _confirmAndReceive() async {
    if (_scannedItem == null || _alreadyReceived || _isSubmitting) return;

    if (!mounted) return;
    setState(() => _isSubmitting = true);

    // Get device current latitude and longitude
    final locationRes = await LocationService.getCurrentLocation();

    if (!mounted) return;

    if (!locationRes.isSuccess || locationRes.latitude == 0.0 || locationRes.longitude == 0.0) {
      setState(() => _isSubmitting = false);
      await _showErrorDialog(
        locationRes.errorMessage ?? 'Device GPS Location is required to confirm material receipt. Please enable location services.',
      );
      return;
    }

    final session = ref.read(sessionProvider);
    final user = session.currentUser;
    int resolvedConsumerId = user?.consumerId ?? 0; // Fallback to 0 if null
    
    // Attempt fallback from profile if needed (similar to dashboard)
    if (resolvedConsumerId <= 0) {
      if (user != null && user.id.isNotEmpty) {
        final parsed = int.tryParse(user.id);
        if (parsed != null && parsed > 0) {
          resolvedConsumerId = parsed;
        }
      }
    }

    final repo = ref.read(consumerDigiTpRepositoryProvider);
    final request = ReceiveInvoiceRequest(
      invoiceNo: _scannedItem!.invoiceNo,
      consumerId: resolvedConsumerId,
      rVehicleLat: locationRes.latitude,
      rVehicleLong: locationRes.longitude,
    );

    final response = await repo.receiveInvoice(request: request);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (response.isSuccess) {
      // HTTP 200 Success
      setState(() {
        _alreadyReceived = true;
        _scannedItem = ConsumerDigiTpItem(
          invoiceNo: _scannedItem!.invoiceNo,
          plotId: _scannedItem!.plotId,
          plotName: _scannedItem!.plotName,
          ownerId: _scannedItem!.ownerId,
          ownerName: _scannedItem!.ownerName,
          ownerMobileNo: _scannedItem!.ownerMobileNo,
          vehicleId: _scannedItem!.vehicleId,
          vehicleNo: _scannedItem!.vehicleNo,
          validityFrom: _scannedItem!.validityFrom,
          validityUpto: _scannedItem!.validityUpto,
          distance: _scannedItem!.distance,
          destination: _scannedItem!.destination,
          timeStamp: _scannedItem!.timeStamp,
          userId: _scannedItem!.userId,
          quantity: _scannedItem!.quantity,
          createdBy: _scannedItem!.createdBy,
          materialId: _scannedItem!.materialId,
          materialType: _scannedItem!.materialType,
          mineralUnit: _scannedItem!.mineralUnit,
          projectId: _scannedItem!.projectId,
          projectName: _scannedItem!.projectName,
          driverMobNo: _scannedItem!.driverMobNo,
          driverName: _scannedItem!.driverName,
          consumerId: _scannedItem!.consumerId,
          invoiceStatusId: 1,
          invoiceStatus: 'Received',
        );
        _step = _ReceiveStep.completed;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.statusMessage.isNotEmpty
              ? response.statusMessage
              : 'Invoice received successfully.'),
          backgroundColor: const Color(0xFF15803D),
        ),
      );

      // Invalidate DigiTP lists & dashboard count providers
      ref.invalidate(consumerDigiTpListProvider(2));
      ref.invalidate(consumerDigiTpListProvider(3));
      ref.invalidate(consumerDashboardCountProvider);
    } else if (response.isAlreadyReceived) {
      // HTTP 409 Conflict: Already Received
      setState(() {
        _alreadyReceived = true;
        _statusMessage = 'DigiTP is already received.';
      });
      await _showErrorDialog('DigiTP is already received.');
    } else {
      await _showErrorDialog(
        response.statusMessage.isNotEmpty
            ? response.statusMessage
            : 'Failed to receive DigiTP. Please try again.',
      );
    }
  }

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.receiveMaterialError, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetToInitial() {
    if (!mounted) return;
    setState(() {
      _step = _ReceiveStep.initial;
      _scannedItem = null;
      _isSubmitting = false;
      _alreadyReceived = false;
      _statusMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppScaffold(
      title: l10n.receiveMaterial,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STEP 1: INITIAL STATE (SHOW ONLY SCAN QR CODE OPTION)
            if (_step == _ReceiveStep.initial) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD6E5F8)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF4FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        size: 48,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.scanDigiTp,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.pointCameraDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.inkSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: l10n.openCameraScanner,
                      size: AppButtonSize.large,
                      icon: const Icon(Icons.camera_alt, size: 20),
                      onPressed: _openCameraScanner,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _showManualEntryDialog,
                      child: Text(
                        l10n.enterInvoiceManually,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // STEP 2: LOADING STATE
            if (_step == _ReceiveStep.loading) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF2563EB)),
                    const SizedBox(height: 16),
                    Text(
                      l10n.processingScan,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.decodingPermit,
                      style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                    ),
                  ],
                ),
              ),
            ],

            // STEP 3: DISPLAY SCANNED DETAILS + CONFIRM & RECEIVE
            if (_step == _ReceiveStep.scanned && _scannedItem != null) ...[
              if (_alreadyReceived || _statusMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _statusMessage ?? 'Invoice is already received.',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Invoice Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.eTransitPassDetails,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${l10n.invoiceHash}: ${_scannedItem!.invoiceNo}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    _buildDetailRow(
                      label: l10n.vehicleNumber,
                      value: _scannedItem!.vehicleNo ?? 'N/A',
                      isBold: true,
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      label: l10n.ownerName,
                      value: _scannedItem!.ownerName ?? 'N/A',
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      label: l10n.ownerMobile,
                      value: _scannedItem!.ownerMobileNo ?? 'N/A',
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      label: l10n.driverDetails,
                      value: _scannedItem!.driverName != null && _scannedItem!.driverName!.isNotEmpty
                          ? '${_scannedItem!.driverName}${_scannedItem!.driverMobNo != null ? ' (${_scannedItem!.driverMobNo})' : ''}'
                          : 'N/A',
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      label: l10n.materialAndQuantity,
                      value: '${_scannedItem!.materialType ?? "Mineral"} (${_scannedItem!.quantity ?? 0} ${_scannedItem!.mineralUnit ?? "Brass"})',
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      label: l10n.destination,
                      value: _scannedItem!.destination ?? 'N/A',
                    ),
                    if (_scannedItem!.distance != null) ...[
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        label: l10n.distanceKm,
                        value: '${_scannedItem!.distance} KM',
                      ),
                    ],
                    if (_scannedItem!.validityFrom != null) ...[
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        label: l10n.validityFrom,
                        value: AppDateFormatter.formatDateTime(_scannedItem!.validityFrom),
                      ),
                    ],
                    if (_scannedItem!.validityUpto != null) ...[
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        label: l10n.validityUpto,
                        value: AppDateFormatter.formatDateTime(_scannedItem!.validityUpto),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Confirm & Receive Action Button
              if (!_alreadyReceived) ...[
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _confirmAndReceive,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline, size: 20),
                    label: Text(
                      _isSubmitting ? l10n.confirmingReceipt : l10n.confirmAndReceiveMaterial,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _resetToInitial,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.scanAnotherCode),
                ),
              ),
            ],

            // STEP 4: COMPLETED STATE
            if (_step == _ReceiveStep.completed) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle, size: 54, color: Color(0xFF15803D)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.materialReceivedSuccess,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'DigiTP #${_scannedItem?.invoiceNo} has been verified and marked as Received on Mahakhanij Portal.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: l10n.scanAnotherCode,
                      fullWidth: true,
                      onPressed: _resetToInitial,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => context.go('/activity'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(l10n.viewAllReceivedDeliveries),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}
