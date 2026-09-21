import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/enquiry.dart';
import '../enquiry/enquiries_screen.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/digitp_modal.dart';

enum ActivityChip { enquiries, live, delivered }

class ConsumerActivityScreen extends ConsumerStatefulWidget {
  final ActivityChip initialChip;

  const ConsumerActivityScreen({
    super.key,
    this.initialChip = ActivityChip.live,
  });

  @override
  ConsumerState<ConsumerActivityScreen> createState() => _ConsumerActivityScreenState();
}

class _ConsumerActivityScreenState extends ConsumerState<ConsumerActivityScreen> {
  late ActivityChip _activeChip;

  @override
  void initState() {
    super.initState();
    _activeChip = widget.initialChip;
  }

  void _showDigiTpModal(BuildContext context, String digiTpNumber, String vehicleNumber, String mineral, String qty) {
    showDigiTpPassModal(
      context,
      digiTpNumber: digiTpNumber.startsWith('ETP/') ? digiTpNumber : 'ETP/2026/MH/0431188',
      vehicleNumber: vehicleNumber.isNotEmpty ? vehicleNumber : 'MH-04-GG-1234',
    );
  }

  @override
  Widget build(BuildContext context) {
    final enquiries = ref.watch(enquiriesProvider);

    return AppScaffold(
      title: 'Activity',
      showBackButton: Navigator.canPop(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal Filter Chips Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChip(
                    chip: ActivityChip.enquiries,
                    icon: Icons.description_outlined,
                    label: 'Enquiries',
                    count: enquiries.length,
                  ),
                  const SizedBox(width: 8),
                  _buildChip(
                    chip: ActivityChip.live,
                    icon: Icons.local_shipping_outlined,
                    label: 'Live Deliveries',
                    count: 2,
                  ),
                  const SizedBox(width: 8),
                  _buildChip(
                    chip: ActivityChip.delivered,
                    icon: Icons.check_circle_outline,
                    label: 'Delivered',
                    count: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // CHIP 1: ENQUIRIES
            if (_activeChip == ActivityChip.enquiries) ...[
              ...enquiries.map((enq) => _buildEnquiryCard(context, enq)),
            ],

            // CHIP 2: LIVE DELIVERIES
            if (_activeChip == ActivityChip.live) ...[
              // Delivery 1: In Transit
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            const Text(
                              'DigiTP No: DTP-2024-8842',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1241A6),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F0FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'In Transit',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF7E22CE)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('Destination', style: TextStyle(fontSize: 11, color: Color(0xFF737373))),
                    const Text('NH-48 Road Widening Site', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mineral: River Sand', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
                          Text('Qty: 12 Brass', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: const Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Vehicle:', style: TextStyle(fontSize: 11, color: Color(0xFF737373))),
                              Text('MH-15-BN-4402', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink, fontFamily: 'monospace')),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Driver:', style: TextStyle(fontSize: 11, color: Color(0xFF737373))),
                              Text('Nitin Wagh (9689330214)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink)),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Quarry:', style: TextStyle(fontSize: 11, color: Color(0xFF737373))),
                              Text('Godavari Sand Ghat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Track Vehicle',
                            size: AppButtonSize.small,
                            icon: const Icon(Icons.navigation_outlined, size: 16),
                            onPressed: () => context.push('/deliveries/del-004/live-tracking'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            label: 'View DigiTP',
                            size: AppButtonSize.small,
                            variant: AppButtonVariant.secondary,
                            icon: const Icon(Icons.qr_code, size: 16),
                            onPressed: () => _showDigiTpModal(
                              context,
                              'DTP-2024-8842',
                              'MH-15-BN-4402',
                              'River Sand',
                              '12 Brass',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Delivery 2: Pass Issued
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            const Text(
                              'DigiTP No: DTP-2024-7931',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1241A6),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Pass Issued',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF0369A1)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('Destination', style: TextStyle(fontSize: 11, color: Color(0xFF737373))),
                    const Text('NH-48 Road Widening Site', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mineral: Basalt Stone', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
                          Text('Qty: 500 Brass', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: const Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Vehicle:', style: TextStyle(fontSize: 11, color: Color(0xFF737373))),
                              Text('MH-12-DE-9104', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.ink, fontFamily: 'monospace')),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Driver:', style: TextStyle(fontSize: 11, color: Color(0xFF737373))),
                              Text('Sachin Patil (9822451098)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink)),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Quarry:', style: TextStyle(fontSize: 11, color: Color(0xFF737373))),
                              Text('Shree Ganesh Stone Quarry', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Align(
                      alignment: Alignment.centerRight,
                      child: AppButton(
                        label: 'View DigiTP',
                        size: AppButtonSize.small,
                        variant: AppButtonVariant.secondary,
                        icon: const Icon(Icons.qr_code, size: 16),
                        onPressed: () => _showDigiTpModal(
                          context,
                          'DTP-2024-7931',
                          'MH-12-DE-9104',
                          'Basalt Stone',
                          '500 Brass',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // CHIP 3: DELIVERED
            if (_activeChip == ActivityChip.delivered) ...[
              _buildDeliveredCard(
                digiTpNo: 'DTP-2024-6420',
                title: 'Stone Aggregate · 150 Brass',
                site: 'Delivered at NH-48 Road Widening Site',
                date: 'Received 28 Aug 2024',
              ),
              const SizedBox(height: 10),
              _buildDeliveredCard(
                digiTpNo: 'DTP-2024-5119',
                title: 'Murum / Earth · 350 Brass',
                site: 'Delivered at NH-48 Road Widening Site',
                date: 'Received 24 Aug 2024',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required ActivityChip chip,
    required IconData icon,
    required String label,
    required int count,
  }) {
    final isSelected = _activeChip == chip;

    return InkWell(
      onTap: () => setState(() => _activeChip = chip),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1241A6) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF1241A6) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF525252)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF404040),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0x33FFFFFF) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF404040),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnquiryCard(BuildContext context, Enquiry enq) {
    Color badgeBg = const Color(0xFFEFF6FF);
    Color badgeFg = const Color(0xFF1D4ED8);
    if (enq.status == EnquiryStatus.actionRequired) {
      badgeBg = const Color(0xFFFFFBEB);
      badgeFg = const Color(0xFFD97706);
    } else if (enq.status == EnquiryStatus.digitpGenerated) {
      badgeBg = const Color(0xFFDCFCE7);
      badgeFg = const Color(0xFF16A34A);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/enquiries/detail', extra: enq),
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
                    enq.enquiryNumber,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1241A6), fontFamily: 'monospace'),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      enq.statusLabel,
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: badgeFg),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${enq.mineralName} · ${enq.requiredQuantity.formatted}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
              const SizedBox(height: 2),
              Text(enq.stockPointName, style: const TextStyle(fontSize: 12, color: Color(0xFF737373))),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(enq.createdAt, style: const TextStyle(fontSize: 11, color: Color(0xFF737373))),
                  const Row(
                    children: [
                      Text('View Enquiry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1241A6))),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 12, color: Color(0xFF1241A6)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveredCard({
    required String digiTpNo,
    required String title,
    required String site,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DigiTP No: $digiTpNo',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                    fontFamily: 'monospace',
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Delivered & Verified',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              site,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                InkWell(
                  onTap: () => _showDigiTpModal(context, digiTpNo, 'MH-04-GG-1234', title, ''),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: const Text(
                      'View DigiTP',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
