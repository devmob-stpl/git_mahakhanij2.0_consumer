import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_button.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  int _activeTab = 0; // 0 = ALL, 1 = ACTIVE, 2 = COMPLETED

  final List<Map<String, dynamic>> _transfers = [
    {
      'id': 'trf-001',
      'etpNumber': 'MH-ETP-2026-9041',
      'transferNumber': 'TRF-2026-0041',
      'mineralName': 'Natural River Sand',
      'quantity': '12.0 Brass',
      'status': 'IN_TRANSIT',
      'statusLabel': 'In Transit',
      'vehicleNumber': 'MH-12-RN-8842',
      'driverName': 'Suresh Shinde',
      'driverPhone': '9822199882',
      'origin': 'Package 02 (Viaduct & Station Site)',
      'destination': 'Package 03 (Underground Station Box)',
      'createdAt': 'Today, 10:15 AM',
      'validUntil': 'Today, 06:00 PM',
    },
    {
      'id': 'trf-002',
      'etpNumber': 'MH-ETP-2026-8812',
      'transferNumber': 'TRF-2026-0038',
      'mineralName': 'Stone Aggregate (20mm)',
      'quantity': '8.0 Brass',
      'status': 'PERMIT_ISSUED',
      'statusLabel': 'Permit Issued',
      'vehicleNumber': 'MH-14-BT-3321',
      'driverName': 'Pravin Pawar',
      'driverPhone': '9730112233',
      'origin': 'Package 01 (Casting Yard)',
      'destination': 'Package 02 (Viaduct & Station Site)',
      'createdAt': 'Today, 08:30 AM',
      'validUntil': 'Today, 04:30 PM',
    },
    {
      'id': 'trf-003',
      'etpNumber': 'MH-ETP-2026-7204',
      'transferNumber': 'TRF-2026-0025',
      'mineralName': 'Murum / Filling Soil',
      'quantity': '15.0 Brass',
      'status': 'RECEIVED',
      'statusLabel': 'Completed',
      'vehicleNumber': 'MH-12-PQ-9910',
      'driverName': 'Ramesh Jadhav',
      'driverPhone': '9822001144',
      'origin': 'Package 03 (Underground Station Box)',
      'destination': 'Wagholi Storage Yard (Return)',
      'createdAt': 'Yesterday, 03:00 PM',
      'validUntil': 'Yesterday, 09:00 PM',
    },
  ];

  void _showCreateTransferSheet(BuildContext context) {
    final qtyController = TextEditingController(text: '5.0');
    final vehController = TextEditingController(text: 'MH-12-AB-5544');
    final driverController = TextEditingController(text: 'Mahesh Bhosale');
    final phoneController = TextEditingController(text: '9822055667');
    String selectedMineral = 'River Sand';
    String selectedDest = 'Package 03 (Underground Station Box)';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Issue Transfer e-TP Pass', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Generate a verified statutory e-TP to legally move mineral surplus to another package or site.', style: TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
              const SizedBox(height: 16),

              const Text('Select Mineral', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedMineral,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: const [
                  DropdownMenuItem(value: 'River Sand', child: Text('River Sand (Available: 7.0 Brass)')),
                  DropdownMenuItem(value: 'Stone Aggregate', child: Text('Stone Aggregate (Available: 5.0 Brass)')),
                  DropdownMenuItem(value: 'Murum / Soil', child: Text('Murum / Soil (Available: 4.0 Brass)')),
                ],
                onChanged: (val) => selectedMineral = val!,
              ),
              const SizedBox(height: 14),

              const Text('Destination Project / Site', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedDest,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Package 03 (Underground Station Box)', child: Text('Package 03 (Underground Station Box)')),
                  DropdownMenuItem(value: 'Package 01 (Casting Yard)', child: Text('Package 01 (Casting Yard)')),
                  DropdownMenuItem(value: 'Return to Mineral Place', child: Text('Return to Mineral Place')),
                ],
                onChanged: (val) => selectedDest = val!,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Transfer Qty (Brass)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Vehicle Reg Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: vehController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Driver Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: driverController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Driver Phone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              AppButton(
                label: 'Issue Transfer e-TP',
                fullWidth: true,
                size: AppButtonSize.large,
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _transfers.insert(0, {
                      'id': 'trf-new-${DateTime.now().millisecondsSinceEpoch}',
                      'etpNumber': 'MH-ETP-2026-${(1000 + DateTime.now().millisecond).toString()}',
                      'transferNumber': 'TRF-2026-0045',
                      'mineralName': selectedMineral,
                      'quantity': '${qtyController.text} Brass',
                      'status': 'PERMIT_ISSUED',
                      'statusLabel': 'Permit Issued',
                      'vehicleNumber': vehController.text,
                      'driverName': driverController.text,
                      'driverPhone': phoneController.text,
                      'origin': 'Package 02 (Viaduct & Station Site)',
                      'destination': selectedDest,
                      'createdAt': 'Just now',
                      'validUntil': 'Today, 08:00 PM',
                    });
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transfer e-TP generated successfully! Pass is ready for driver handover.')),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showPermitDetailsModal(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Transit Permit (Transfer e-TP)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: QrImageView(
                  data: 'MH-TRANSFER-ETP|${item['etpNumber']}|${item['vehicleNumber']}|${item['quantity']}',
                  size: 140,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    _modalRow('Pass Number', item['etpNumber']),
                    const SizedBox(height: 6),
                    _modalRow('Mineral', item['mineralName']),
                    const SizedBox(height: 6),
                    _modalRow('Quantity', item['quantity']),
                    const SizedBox(height: 6),
                    _modalRow('Vehicle', item['vehicleNumber']),
                    const SizedBox(height: 6),
                    _modalRow('From', item['origin']),
                    const SizedBox(height: 6),
                    _modalRow('To', item['destination']),
                    const SizedBox(height: 6),
                    _modalRow('Driver', '${item['driverName']} (${item['driverPhone']})'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('WhatsApp'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transit pass link shared on WhatsApp!')));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary700, foregroundColor: Colors.white),
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Gate Pass'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gate pass ready to print / download.')));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _transfers.where((t) {
      if (_activeTab == 1) return t['status'] == 'IN_TRANSIT' || t['status'] == 'PERMIT_ISSUED';
      if (_activeTab == 2) return t['status'] == 'RECEIVED';
      return true;
    }).toList();

    return AppScaffold(
      title: 'Mineral Transfers & e-TP',
      showBackButton: true,
      bottomActionButton: AppButton(
        label: '+ Issue Transfer e-TP Pass',
        onPressed: () => _showCreateTransferSheet(context),
      ),
      body: Column(
        children: [
          // Filter Tabs (All, Active e-TPs, Completed)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _tabButton(0, 'All (${_transfers.length})'),
                _tabButton(1, 'Active e-TPs (2)'),
                _tabButton(2, 'Completed (1)'),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filtered[index];
                final isDelivered = item['status'] == 'RECEIVED';

                return AppCard(
                  onTap: () => _showPermitDetailsModal(context, item),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['etpNumber'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary700, fontFamily: 'monospace')),
                          AppBadge(
                            label: item['statusLabel'],
                            variant: isDelivered ? AppBadgeVariant.success : AppBadgeVariant.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${item['mineralName']} (${item['quantity']})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
                      const SizedBox(height: 4),
                      Text('To: ${item['destination']}', style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
                      const SizedBox(height: 2),
                      Text('Vehicle: ${item['vehicleNumber']} • Driver: ${item['driverName']}', style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['createdAt'], style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                          const Row(
                            children: [
                              Text('View e-TP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary700)),
                              SizedBox(width: 4),
                              Icon(Icons.chevron_right, size: 14, color: AppColors.primary700),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(int index, String label) {
    final active = _activeTab == index;

    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.primary700 : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.primary700 : AppColors.inkSecondary,
          ),
        ),
      ),
    );
  }
}
