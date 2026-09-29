import 'package:flutter/material.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/consumer_digitp_models.dart';

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
                            const Text(
                              'E-TRANSIT PASS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                                children: [
                                  const TextSpan(
                                    text: 'DigiTP No : ',
                                    style: TextStyle(fontWeight: FontWeight.w500),
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
                      _buildTableRow('Vehicle Number', vehicleNoStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('Vehicle Driver Name', driverNameStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('Driver Mobile Number', driverMobStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('Owner Name', ownerNameStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('Owner Mobile Number', ownerMobStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('Plot / Project Name', plotNameStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      if (materialStr != null || qtyStr != null) ...[
                        _buildTableRow('Material & Quantity', '${materialStr ?? "Mineral"} (${qtyStr ?? ""})'),
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      ],
                      _buildTableRow('Destination', destStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('Distance (Km)', distanceStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      if (statusStr != null) ...[
                        _buildTableRow('Invoice Status', statusStr),
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      ],
                      _buildTableRow('Created date and time of DigiTP', createdAtStr),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('DigiTP validity date and time', validityStr, isLast: receiveDateStr == null),
                      if (receiveDateStr != null && receiveDateStr.isNotEmpty) ...[
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                        _buildTableRow('Receive Approved Date', receiveDateStr, isLast: true),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Department Verified Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_outlined, size: 16, color: Color(0xFF0F172A)),
                      SizedBox(width: 6),
                      Text(
                        'Department of Mines & Geology Verified',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Action Buttons (Download & Cancel)
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.pop(dialogCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Downloading DigiTP_$invoiceNoStr.pdf...'),
                                backgroundColor: const Color(0xFF16A34A),
                              ),
                            );
                          },
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text(
                            'Download',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.pop(dialogCtx),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
