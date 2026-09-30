import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/consumer_digitp_models.dart';
import '../../../shared/widgets/digitp_modal.dart';
import '../../../l10n/app_localizations.dart';

class DeliveryItemSummary {
  final String id;
  final String code;
  final String? digiTpNumber;
  final String? vehicleNo;
  final String? purchasedFrom;
  final String destination;
  final String mineralName;
  final String quantity;
  final String status;
  final ConsumerDigiTpItem? rawItem;
  final VoidCallback? onClick;
  final VoidCallback? onTrackVehicle;
  final VoidCallback? onViewDigiTp;

  const DeliveryItemSummary({
    required this.id,
    required this.code,
    this.digiTpNumber,
    this.vehicleNo,
    this.purchasedFrom,
    required this.destination,
    required this.mineralName,
    required this.quantity,
    required this.status,
    this.rawItem,
    this.onClick,
    this.onTrackVehicle,
    this.onViewDigiTp,
  });

  bool get isInTransit {
    final s = status.toUpperCase();
    return s.contains('TRANSIT') || s == 'DISPATCHED' || s == '1';
  }

  bool get isDelivered {
    final s = status.toUpperCase();
    return s.contains('RECEIV') || s.contains('DELIVER') || s == '2';
  }
}

class DeliverySummaryCardWidget extends StatelessWidget {
  final DeliveryItemSummary item;

  const DeliverySummaryCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final statusConfig = _getStatusBadge(item.status, loc);
    final digiTpCode = item.digiTpNumber ?? item.code;
    final vehicleStr = item.vehicleNo ?? item.rawItem?.vehicleNo;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 1),
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
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.assignment_turned_in_outlined, size: 15, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 8),
                  Text.rich(
                    TextSpan(
                      text: '${loc.digiTpNo}: ',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                      children: [
                        TextSpan(
                          text: digiTpCode,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusConfig.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusConfig.borderColor),
                ),
                child: Text(
                  statusConfig.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusConfig.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Vehicle Number line (if available)
          if (vehicleStr != null && vehicleStr.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.directions_car_outlined, size: 14, color: AppColors.inkSecondary),
                const SizedBox(width: 4),
                Text(
                  '${loc.vehicle}: $vehicleStr',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: AppColors.ink),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],

          // Destination
          Text(
            loc.destination,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: Color(0xFF737373)),
          ),
          const SizedBox(height: 2),
          Text(
            item.destination,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(height: 10),

          // Mineral & Quantity Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('${loc.mineral}: ', style: const TextStyle(fontSize: 11.5, color: Color(0xFF737373))),
                    Text(
                      item.mineralName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('${loc.qty}: ', style: const TextStyle(fontSize: 11.5, color: Color(0xFF737373))),
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

          // Source Quarry line
          Row(
            children: [
              const Icon(Icons.store_outlined, size: 14, color: Color(0xFFA3A3A3)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${loc.source}: ${item.purchasedFrom ?? 'Authorized Quarry'}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF525252), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Dynamic Status-Based Action Button
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (item.isInTransit) {
      // In-Transit DigiTP → Show both "View DigiTP" & "Track Vehicle" buttons
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 38,
              child: OutlinedButton.icon(
                onPressed: () {
                  if (item.onViewDigiTp != null) {
                    item.onViewDigiTp!();
                  } else if (item.rawItem != null) {
                    showDigiTpPassModal(context, item: item.rawItem);
                  } else {
                    showDigiTpPassModal(
                      context,
                      digiTpNumber: item.digiTpNumber ?? item.code,
                      vehicleNumber: item.vehicleNo,
                      destination: item.destination,
                      ownerName: item.purchasedFrom,
                    );
                  }
                },
                icon: const Icon(Icons.assignment_outlined, size: 15),
                label: Text(loc.viewDigiTp, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (item.onTrackVehicle != null) {
                    item.onTrackVehicle!();
                  } else if (item.onClick != null) {
                    item.onClick!();
                  } else {
                    final targetVeh = item.vehicleNo ?? item.rawItem?.vehicleNo ?? item.digiTpNumber ?? item.code;
                    context.push('/deliveries/${item.digiTpNumber ?? item.code}/live-tracking?vehicleNo=$targetVeh');
                  }
                },
                icon: const Icon(Icons.navigation_outlined, size: 15),
                label: Text(loc.trackVehicle.replaceAll('\n', ' '), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), // Purple theme for in-transit tracking
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Delivered / Pass Issued DigiTP → Show "View DigiTP" button
      return SizedBox(
        width: double.infinity,
        height: 38,
        child: OutlinedButton.icon(
          onPressed: () {
            if (item.onViewDigiTp != null) {
              item.onViewDigiTp!();
            } else if (item.rawItem != null) {
              showDigiTpPassModal(context, item: item.rawItem);
            } else if (item.onClick != null) {
              item.onClick!();
            } else {
              showDigiTpPassModal(
                context,
                digiTpNumber: item.digiTpNumber ?? item.code,
                vehicleNumber: item.vehicleNo,
                destination: item.destination,
                ownerName: item.purchasedFrom,
              );
            }
          },
          icon: const Icon(Icons.assignment_outlined, size: 16),
          label: Text(loc.viewDigiTp, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2563EB),
            side: const BorderSide(color: Color(0xFF2563EB), width: 1.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
    }
  }


  _StatusConfig _getStatusBadge(String status, AppLocalizations loc) {
    final normalized = status.toUpperCase();
    if (normalized.contains('TRANSIT') || normalized == 'DISPATCHED' || normalized == '1') {
      return _StatusConfig(loc.inTransit, const Color(0xFFF7F0FD), const Color(0xFFEBD9FB), const Color(0xFF7E22CE));
    }
    if (normalized.contains('ARRIV')) {
      return _StatusConfig('Arrived at Site', const Color(0xFFFEF3C7), const Color(0xFFFDE68A), const Color(0xFF92400E));
    }
    if (normalized.contains('PASS') || normalized.contains('APPROV')) {
      return _StatusConfig('Pass Issued', const Color(0xFFE0F2FE), const Color(0xFFBAE6FD), const Color(0xFF0369A1));
    }
    if (normalized.contains('RECEIV') || normalized.contains('DELIVER') || normalized == '2') {
      return _StatusConfig(loc.delivered, const Color(0xFFDCFCE7), const Color(0xFFBBF7D0), const Color(0xFF15803D));
    }
    return _StatusConfig(status, const Color(0xFFF3F4F6), const Color(0xFFE5E7EB), const Color(0xFF525252));
  }
}

class _StatusConfig {
  final String label;
  final Color bg;
  final Color borderColor;
  final Color text;

  _StatusConfig(this.label, this.bg, this.borderColor, this.text);
}
