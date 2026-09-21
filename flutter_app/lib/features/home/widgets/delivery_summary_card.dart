import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DeliveryItemSummary {
  final String id;
  final String code;
  final String? digiTpNumber;
  final String? purchasedFrom;
  final String destination;
  final String mineralName;
  final String quantity;
  final String status;
  final VoidCallback? onClick;

  const DeliveryItemSummary({
    required this.id,
    required this.code,
    this.digiTpNumber,
    this.purchasedFrom,
    required this.destination,
    required this.mineralName,
    required this.quantity,
    required this.status,
    this.onClick,
  });
}

class DeliverySummaryCardWidget extends StatelessWidget {
  final DeliveryItemSummary item;

  const DeliverySummaryCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusBadge(item.status);
    final digiTpCode = item.digiTpNumber ?? item.code;

    return InkWell(
      onTap: item.onClick,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: DigiTP No & Status Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF4FE),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.assignment_turned_in_outlined, size: 14, color: Color(0xFF1241A6)),
                    ),
                    const SizedBox(width: 6),
                    Text.rich(
                      TextSpan(
                        text: 'DigiTP No: ',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1241A6),
                        ),
                        children: [
                          TextSpan(
                            text: digiTpCode,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusConfig.bg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusConfig.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusConfig.text,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Destination
            const Text(
              'Destination',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF737373)),
            ),
            const SizedBox(height: 2),
            Text(
              item.destination,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
            const SizedBox(height: 10),

            // Mineral & Quantity Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('Mineral: ', style: TextStyle(fontSize: 12, color: Color(0xFF737373))),
                      Text(
                        item.mineralName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Qty: ', style: TextStyle(fontSize: 12, color: Color(0xFF737373))),
                      Text(
                        item.quantity,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Bottom row: Purchased From + Chevron Right
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.store_outlined, size: 14, color: Color(0xFFA3A3A3)),
                      const SizedBox(width: 4),
                      Text(
                        'From: ${item.purchasedFrom ?? 'Authorized Quarry'}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF525252), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.chevron_right, size: 16, color: Color(0xFF737373)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StatusConfig _getStatusBadge(String status) {
    final normalized = status.toUpperCase();
    if (normalized.contains('TRANSIT') || normalized == 'DISPATCHED') {
      return _StatusConfig('In Transit', const Color(0xFFF7F0FD), const Color(0xFF7E22CE));
    }
    if (normalized.contains('ARRIV')) {
      return _StatusConfig('Arrived at Site', const Color(0xFFFEF3C7), const Color(0xFF92400E));
    }
    if (normalized.contains('PASS') || normalized.contains('APPROV')) {
      return _StatusConfig('Pass Issued', const Color(0xFFE0F2FE), const Color(0xFF0369A1));
    }
    if (normalized.contains('RECEIV') || normalized.contains('DELIVER')) {
      return _StatusConfig('Delivered & Verified', const Color(0xFFDCFCE7), const Color(0xFF15803D));
    }
    return _StatusConfig(status, const Color(0xFFF3F4F6), const Color(0xFF525252));
  }
}

class _StatusConfig {
  final String label;
  final Color bg;
  final Color text;

  _StatusConfig(this.label, this.bg, this.text);
}
