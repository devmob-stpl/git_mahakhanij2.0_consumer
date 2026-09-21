import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/delivery.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_badge.dart';

class DigitpPassScreen extends StatelessWidget {
  final TransportPermit permit;

  const DigitpPassScreen({super.key, required this.permit});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'DigiTP Electronic Transit Pass',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // E-TP Certificate Container
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.line, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Pass Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.primary700,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'GOVERNMENT OF MAHARASHTRA',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.neutral100, letterSpacing: 0.5),
                            ),
                            AppBadge(label: 'VERIFIED e-TP', variant: AppBadgeVariant.success),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          permit.etpNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neutral0,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Electronic Transit Pass for Minor Minerals',
                          style: TextStyle(fontSize: 12, color: AppColors.primary100),
                        ),
                      ],
                    ),
                  ),

                  // QR Code Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: QrImageView(
                            data: permit.qrPayload,
                            version: QrVersions.auto,
                            size: 180,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Scan at package delivery site to authorize receipt',
                          style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Detailed Verification Attributes
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildRow('Vehicle Number', permit.vehicleNumber, isEmphasized: true),
                        const SizedBox(height: 10),
                        _buildRow('Permitted Volume', permit.permittedQuantity.formatted, isEmphasized: true),
                        const SizedBox(height: 10),
                        _buildRow('Source Quarry', permit.sourceQuarryName),
                        const SizedBox(height: 10),
                        _buildRow('Authorized Destination', permit.destinationLabel),
                        const SizedBox(height: 10),
                        _buildRow('Pass Validity', 'Valid until 18:00 hrs today'),
                      ],
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

  Widget _buildRow(String label, String value, {bool isEmphasized = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isEmphasized ? FontWeight.w700 : FontWeight.w500,
            color: isEmphasized ? AppColors.ink : AppColors.inkSecondary,
          ),
        ),
      ],
    );
  }
}
