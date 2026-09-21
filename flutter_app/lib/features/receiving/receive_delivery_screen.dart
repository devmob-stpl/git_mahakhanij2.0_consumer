import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/delivery.dart';
import '../../rules/receiving_rules.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../data/repositories/delivery_repository.dart';

class ReceiveDeliveryScreen extends ConsumerStatefulWidget {
  final String? deliveryId;
  final Delivery? initialDelivery;

  const ReceiveDeliveryScreen({
    super.key,
    this.deliveryId,
    this.initialDelivery,
  });

  @override
  ConsumerState<ReceiveDeliveryScreen> createState() => _ReceiveDeliveryScreenState();
}

class _ReceiveDeliveryScreenState extends ConsumerState<ReceiveDeliveryScreen> {
  Delivery? _delivery;
  bool _isLoading = true;
  String? _scanError;

  // Discrepancy Editing State
  bool _isEditingQty = false;
  double? _receivedValue;
  final String _remarks = '';
  bool _isSubmitting = false;

  // Receipt Result State
  bool _isClosed = false;
  double _updatedSiteBalance = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialDelivery != null) {
      _delivery = widget.initialDelivery;
      _isLoading = false;
    } else {
      _loadDelivery(widget.deliveryId ?? 'del-003');
    }
  }

  Future<void> _loadDelivery(String id) async {
    setState(() => _isLoading = true);
    final repo = ref.read(deliveryRepositoryProvider);
    final d = await repo.getById(id);
    if (mounted) {
      setState(() {
        _delivery = d;
        _isLoading = false;
      });
    }
  }

  void _handleScan(String value) {
    if (_delivery == null) return;

    final payload = permitPayloadFor(value, _delivery!);
    final verified = verifyTransport(_delivery!, payload);

    if (!verified.results[0].passed) {
      setState(() {
        _scanError = 'That permit does not match this delivery. Check the DigiTP number and try again.';
      });
      return;
    }

    setState(() {
      _scanError = null;
      _receivedValue = _delivery!.transportPermit.permittedQuantity.value;
    });

    _showVerificationBottomSheet();
  }

  void _showVerificationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          final unit = _delivery!.transportPermit.permittedQuantity.unit;
          final manifestQty = _delivery!.transportPermit.permittedQuantity.value;
          final currentRecVal = _receivedValue ?? manifestQty;
          final diff = (manifestQty - currentRecVal).abs();
          final hasDiff = diff > 0.01;

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'DigiTP Verification & Pass Closure',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Verify pass details and confirm arrival to credit site inventory.',
                    style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Green Verified Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shield_outlined, size: 22, color: Color(0xFF15803D)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transit Pass Valid & Verified',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Authentic e-Permit issued by Mining Department, Maharashtra.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF15803D)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pass Details Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow('DigiTP Pass No:', _delivery!.transportPermit.etpNumber, isMonospace: true, isBold: true),
                        const SizedBox(height: 8),
                        _buildDetailRow('Vehicle Registration:', _delivery!.vehicle.registrationNumber, isMonospace: true, isBold: true),
                        const SizedBox(height: 8),
                        _buildDetailRow('Mineral & Grade:', 'Basalt Stone'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Quantity to Receive:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                            Text(
                              '${currentRecVal.toStringAsFixed(1)} $unit',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Discrepancy Adjustment Toggle
                  if (!_isEditingQty)
                    GestureDetector(
                      onTap: () {
                        setModalState(() => _isEditingQty = true);
                        setState(() => _isEditingQty = true);
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.primary700),
                          SizedBox(width: 4),
                          Text(
                            'Report shortage / weighment difference',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary700, decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Actual Weighed Quantity ($unit)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: currentRecVal.toString(),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (val) {
                                    final parsed = double.tryParse(val) ?? manifestQty;
                                    setModalState(() => _receivedValue = parsed);
                                    setState(() => _receivedValue = parsed);
                                  },
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(unit, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                            ],
                          ),
                          if (hasDiff) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Difference: ${diff.toStringAsFixed(1)} $unit (SHORTAGE)',
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFFB45309), fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Confirm Receipt Button
                  AppButton(
                    label: _isSubmitting ? 'Closing Transit Pass...' : 'Confirm Receipt & Close DigiTP',
                    fullWidth: true,
                    size: AppButtonSize.large,
                    variant: AppButtonVariant.primary,
                    icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
                    isLoading: _isSubmitting,
                    onPressed: () async {
                      setModalState(() => _isSubmitting = true);
                      setState(() => _isSubmitting = true);

                      final repo = ref.read(deliveryRepositoryProvider);
                      final updated = await repo.recordReceipt(
                        deliveryId: _delivery!.id,
                        receivedQuantity: currentRecVal,
                        remarks: _remarks.isNotEmpty ? _remarks : 'Verified at site gate',
                        userId: 'user-sup-001',
                      );

                      if (mounted) {
                        Navigator.of(modalContext).pop();
                        setState(() {
                          _delivery = updated;
                          _updatedSiteBalance = 47.5 + currentRecVal;
                          _isClosed = true;
                          _isSubmitting = false;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isMonospace = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontFamily: isMonospace ? 'monospace' : null,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppScaffold(
        title: 'Receive DigiTP Material',
        showBackButton: true,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_delivery == null) {
      return AppScaffold(
        title: 'Receive DigiTP Material',
        showBackButton: true,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Delivery not found'),
              const SizedBox(height: 12),
              AppButton(label: 'Go Back', onPressed: () => context.pop()),
            ],
          ),
        ),
      );
    }

    // 1. DONE & CLOSED STATE
    if (_isClosed) {
      final unit = _delivery!.transportPermit.permittedQuantity.unit;
      final recQty = _delivery!.discrepancyReport?.actualReceivedQuantity.value ?? _delivery!.transportPermit.permittedQuantity.value;
      final hasDiscrepancy = _delivery!.status == DeliveryStatus.receivedWithDiscrepancy;

      return AppScaffold(
        title: 'DigiTP Received & Closed',
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              // Success Icon
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 36, color: Color(0xFF15803D)),
              ),
              const SizedBox(height: 14),
              const Text(
                'Transit Pass Closed Successfully',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
              ),
              const SizedBox(height: 4),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                  children: [
                    const TextSpan(text: 'DigiTP '),
                    TextSpan(
                      text: _delivery!.transportPermit.etpNumber,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'monospace', color: AppColors.ink),
                    ),
                    const TextSpan(text: ' has been verified and marked as received.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Goods Inward Receipt Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'GOODS INWARD RECEIPT',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.5),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: hasDiscrepancy ? const Color(0xFFFEF2F2) : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                hasDiscrepancy ? Icons.warning_amber_rounded : Icons.assignment_turned_in_outlined,
                                size: 12,
                                color: hasDiscrepancy ? AppColors.danger700 : const Color(0xFF166534),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hasDiscrepancy ? 'Shortage Recorded' : 'Verified & Logged',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: hasDiscrepancy ? AppColors.danger700 : const Color(0xFF166534),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Material Received', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text('$recQty $unit', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
                                const Text('Basalt Stone', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Vehicle Number', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text(_delivery!.vehicle.registrationNumber, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: AppColors.ink)),
                                Text(_delivery!.vehicle.driverName, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Inventory Balance Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF4FE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFD5FB)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Updated Site Inventory', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF1241A6))),
                              Text('$_updatedSiteBalance $unit', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1241A6))),
                            ],
                          ),
                          const Text('Available Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1241A6))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              AppButton(
                label: 'Download Goods Inward Receipt',
                fullWidth: true,
                size: AppButtonSize.large,
                variant: AppButtonVariant.outline,
                icon: const Icon(Icons.download_outlined, size: 18),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Downloaded DigiTP_Receipt_${_delivery!.transportPermit.etpNumber}.txt'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Done & Return to Home',
                fullWidth: true,
                size: AppButtonSize.large,
                variant: AppButtonVariant.primary,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      );
    }

    // 2. ACTIVE RECEIVING SCREEN STATE
    return AppScaffold(
      title: 'Receive DigiTP Material',
      subtitle: _delivery!.vehicle.registrationNumber,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target Vehicle Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF4FE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.local_shipping, size: 18, color: Color(0xFF1241A6)),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _delivery!.vehicle.registrationNumber,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: AppColors.ink),
                              ),
                              Text(
                                'DigiTP: ${_delivery!.transportPermit.etpNumber}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Arrived at Gate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mineral Dispatched', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                            Text(_delivery!.transportPermit.permittedQuantity.formatted, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                            const Text('Basalt Stone', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Driver', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                            Text(_delivery!.vehicle.driverName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                            Text(_delivery!.vehicle.driverMobileNumber, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Scanner View Panel
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.qr_code_scanner, size: 48, color: Color(0xFF94A3B8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Scan DigiTP code',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Point camera at the QR code on the driver\'s permit',
                    style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  if (_scanError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Text(
                        _scanError!,
                        style: const TextStyle(fontSize: 12, color: AppColors.danger700, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  AppButton(
                    label: 'Scan QR code',
                    fullWidth: true,
                    size: AppButtonSize.large,
                    icon: const Icon(Icons.qr_code, size: 18),
                    onPressed: () {
                      _handleScan(_delivery!.transportPermit.qrPayload);
                    },
                  ),
                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: () {
                      _handleScan(_delivery!.transportPermit.etpNumber);
                    },
                    child: const Text(
                      'Enter e-TP number manually',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
