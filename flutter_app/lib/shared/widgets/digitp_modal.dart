import 'package:flutter/material.dart';

void showDigiTpPassModal(
  BuildContext context, {
  String digiTpNumber = 'ETP/2026/MH/0431188',
  String vehicleNumber = 'MH-04-GG-1234',
  String driverName = 'Suresh Patil',
  String driverMobile = '9820117453',
  String ownerName = 'A K',
  String ownerMobile = '6434234234',
  String plotName = 'Titwala Trap Quarry',
  String destination = 'Package A — Km 12 to Km 28',
  String distance = '10.0KM',
  String createdAt = '30/07/2026 02:33 PM',
  String validity = '09/09/2026, 07:10 am',
}) {
  showDialog(
    context: context,
    builder: (dialogCtx) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.assignment_turned_in_outlined,
                            color: Color(0xFF1D4ED8),
                            size: 20,
                          ),
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
                                color: Color(0xFF1D4ED8),
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
                                    text: digiTpNumber,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1D4ED8),
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

                // 2. Details Table
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    children: [
                      _buildTableRow('Vehicle Number', vehicleNumber),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('Vehicle Driver Name', driverName),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('Driver Mobile Number', driverMobile),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('Owner Name', ownerName),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('Owner Mobile Number', ownerMobile),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('Plot Name', plotName),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('Destination', destination),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('Distance (Km)', distance),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('Created date and time of DigiTP', createdAt),
                      const Divider(height: 16, color: Color(0xFFF1F5F9)),
                      _buildTableRow('DigiTP validity date and time', validity, isLast: true),
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
                            backgroundColor: const Color(0xFF1D4ED8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.pop(dialogCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Downloading $digiTpNumber.pdf...'),
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
                              color: Color(0xFF1D4ED8),
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
      Text(
        value,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
    ],
  );
}
