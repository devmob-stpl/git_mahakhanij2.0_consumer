import 'package:flutter/material.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/consumer_digitp_models.dart';
import '../../l10n/app_localizations.dart';

void showDigiTpPassModal(
  BuildContext context, {
  ConsumerDigiTpItem? item,
  String? digiTpNumber,
  String? vehicleNumber,
  String? driverName,
  String? driverMobile,
  String? ownerName,
  String? ownerMobile,
  String? plotName,
  String? destination,
  String? distance,
  String? createdAt,
  String? validity,
}) {
  final invoiceNoStr = item?.invoiceNo ?? digiTpNumber ?? 'N/A';
  final vehicleNoStr = item?.vehicleNo ?? vehicleNumber ?? 'N/A';
  final driverNameStr = item?.driverName ?? driverName ?? 'N/A';
  final driverMobStr = item?.driverMobNo ?? driverMobile ?? 'N/A';
  final ownerNameStr = item?.ownerName ?? ownerName ?? 'N/A';
  final ownerMobStr = item?.ownerMobileNo ?? ownerMobile ?? 'N/A';
  final plotNameStr = item?.plotName ?? item?.projectName ?? plotName ?? 'N/A';
  final destStr = item?.destination ?? destination ?? 'N/A';
  final distanceStr = item?.distance != null ? '${item!.distance} KM' : (distance ?? 'N/A');
  final createdAtStr = AppDateFormatter.formatDateTime(item?.timeStamp ?? item?.validityFrom ?? createdAt);
  final validityStr = AppDateFormatter.formatDateTime(item?.validityUpto ?? validity);
  final materialStr = item?.materialType;
  final qtyStr = item?.quantity != null ? '${item!.quantity} ${item.mineralUnit ?? "Brass"}' : null;
  final statusStr = item?.invoiceStatus ?? (item?.invoiceStatusId == 2 ? 'Delivered' : (item?.invoiceStatusId == 1 ? 'In Transit' : null));
  final receiveDateRaw = item?.receiveApprovedDate;
  final receiveDateStr = receiveDateRaw != null && receiveDateRaw.isNotEmpty ? AppDateFormatter.formatDateTime(receiveDateRaw) : null;
  final loc = AppLocalizations.of(context)!;
  
  String? localizedStatus;
  if (statusStr != null) {
    if (statusStr.toLowerCase() == 'delivered') {
      localizedStatus = loc.delivered;
    } else if (statusStr.toLowerCase() == 'in transit') {
      localizedStatus = loc.inTransit;
    } else {
      localizedStatus = statusStr;
    }
  }


  showDialog(
    context: context,
    builder: (dialogCtx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.assignment_outlined, color: Color(0xFF2563EB), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                                children: [
                                  TextSpan(
                                    text: '${loc.digiTpNo} : ',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  TextSpan(
                                    text: invoiceNoStr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Dynamic Details Table
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    children: [
                      _buildTableRow(loc.vehicleNumber, vehicleNoStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow(loc.vehicleDriverName, driverNameStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow(loc.driverMobileNumber, driverMobStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow(loc.ownerName, ownerNameStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow(loc.ownerMobileNumber, ownerMobStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow(loc.plotProjectName, plotNameStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      if (materialStr != null || qtyStr != null) ...[
                        _buildTableRow(loc.materialAndQuantity, '${materialStr ?? loc.mineral} (${qtyStr ?? ""})'),
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      ],
                      _buildTableRow(loc.destination, destStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow(loc.distanceKm, distanceStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      if (localizedStatus != null) ...[
                        _buildTableRow(loc.invoiceStatus, localizedStatus),
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      ],
                      _buildTableRow(loc.createdDateAndTimeOfDigiTp, createdAtStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow(loc.digiTpValidityDateAndTime, validityStr, isLast: receiveDateStr == null),
                      if (receiveDateStr != null && receiveDateStr.isNotEmpty) ...[
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                        _buildTableRow('Receive Approved Date', receiveDateStr, isLast: true),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),



              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildTableRow(String label, String value, {bool isLast = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
    ],
  );
}
