import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/enquiry.dart';
import '../../domain/common.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_button.dart';

// In-memory mock enquiries state matching prototype
final enquiriesProvider = StateProvider<List<Enquiry>>((ref) {
  return const [
    Enquiry(
      id: 'enq-9204',
      enquiryNumber: 'ENQ/2026/009204',
      raisedByUserId: 'user-org-001',
      organizationId: 'org-001',
      stockPointId: 'sp-kalyan',
      stockPointName: 'Kalyan Stock Point',
      mineralId: 'min-1',
      mineralName: 'Black Trap Metal',
      requiredQuantity: Quantity(value: 250.0, unit: 'BRASS'),
      requiredByDate: '1 Oct 2026',
      contactName: 'Rohit Sanghavi',
      contactMobileNumber: '9822014576',
      status: EnquiryStatus.submitted,
      statusLabel: 'Enquiry Sent',
      createdAt: '16 Sept 2026',
      updatedAt: '16 Sept 2026',
      projectName: 'Mumbai–Nashik Highway Widening',
      packageName: 'Package B — Km 28 to Km 41',
    ),
    Enquiry(
      id: 'enq-9231',
      enquiryNumber: 'ENQ/2026/009231',
      raisedByUserId: 'user-org-001',
      organizationId: 'org-001',
      stockPointId: 'sp-nashik',
      stockPointName: 'Nashik Road Stock Point',
      mineralId: 'min-2',
      mineralName: 'Crushed Stone Grit 20mm',
      requiredQuantity: Quantity(value: 8.0, unit: 'BRASS'),
      requiredByDate: '28 Sept 2026',
      contactName: 'Rohit Sanghavi',
      contactMobileNumber: '9822014576',
      status: EnquiryStatus.submitted,
      statusLabel: 'Enquiry Sent',
      createdAt: '16 Sept 2026',
      updatedAt: '16 Sept 2026',
      projectName: 'Mumbai–Nashik Highway Widening',
      packageName: 'Package B — Km 28 to Km 41',
    ),
    Enquiry(
      id: 'enq-9003',
      enquiryNumber: 'ENQ/2026/009003',
      raisedByUserId: 'user-org-001',
      organizationId: 'org-001',
      stockPointId: 'sp-bhiwandi',
      stockPointName: 'Bhiwandi Mineral Depot',
      mineralId: 'min-3',
      mineralName: 'River Sand',
      requiredQuantity: Quantity(value: 300.0, unit: 'BRASS'),
      requiredByDate: '25 Sept 2026',
      contactName: 'Rohit Sanghavi',
      contactMobileNumber: '9822014576',
      status: EnquiryStatus.actionRequired,
      statusLabel: 'Action Required',
      createdAt: '12 Sept 2026',
      updatedAt: '14 Sept 2026',
      projectName: 'Thane-Kalyan Expressway Project',
      packageName: 'Package 1 — Km 0 to Km 15',
    ),
    Enquiry(
      id: 'enq-9088',
      enquiryNumber: 'ENQ/2026/009088',
      raisedByUserId: 'user-org-001',
      organizationId: 'org-001',
      stockPointId: 'sp-nashik',
      stockPointName: 'Nashik Road Stock Point',
      mineralId: 'min-3',
      mineralName: 'River Sand',
      requiredQuantity: Quantity(value: 12.0, unit: 'BRASS'),
      requiredByDate: '18 Sept 2026',
      contactName: 'Rohit Sanghavi',
      contactMobileNumber: '9822014576',
      status: EnquiryStatus.digitpGenerated,
      statusLabel: 'DigiTP Generated',
      createdAt: '11 Sept 2026',
      updatedAt: '12 Sept 2026',
      projectName: 'Mumbai–Nashik Highway Widening',
      packageName: 'Package A — Km 12 to Km 28',
    ),
    Enquiry(
      id: 'enq-9117',
      enquiryNumber: 'ENQ/2026/009117',
      raisedByUserId: 'user-org-001',
      organizationId: 'org-001',
      stockPointId: 'sp-wagholi',
      stockPointName: 'Wagholi Stock Point',
      mineralId: 'min-4',
      mineralName: 'Murum',
      requiredQuantity: Quantity(value: 800.0, unit: 'BRASS'),
      requiredByDate: '20 Sept 2026',
      contactName: 'Rohit Sanghavi',
      contactMobileNumber: '9822014576',
      status: EnquiryStatus.digitpGenerated,
      statusLabel: 'DigiTP Generated',
      createdAt: '9 Sept 2026',
      updatedAt: '10 Sept 2026',
      projectName: 'Pune-Solapur Highway Expansion',
      packageName: 'Package C — Km 42 to Km 65',
    ),
    Enquiry(
      id: 'enq-8841',
      enquiryNumber: 'ENQ/2026/008841',
      raisedByUserId: 'user-org-001',
      organizationId: 'org-001',
      stockPointId: 'sp-kalyan',
      stockPointName: 'Kalyan Stock Point',
      mineralId: 'min-2',
      mineralName: 'Crushed Stone Grit 20mm',
      requiredQuantity: Quantity(value: 500.0, unit: 'BRASS'),
      requiredByDate: '15 Sept 2026',
      contactName: 'Rohit Sanghavi',
      contactMobileNumber: '9822014576',
      status: EnquiryStatus.digitpGenerated,
      statusLabel: 'DigiTP Generated',
      createdAt: '5 Sept 2026',
      updatedAt: '6 Sept 2026',
      projectName: 'Mumbai–Nashik Highway Widening',
      packageName: 'Package A — Km 12 to Km 28',
    ),
  ];
});

class EnquiriesScreen extends ConsumerWidget {
  const EnquiriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enquiries = ref.watch(enquiriesProvider);

    return AppScaffold(
      title: 'Mineral Enquiries',
      showBackButton: true,
      bottomActionButton: AppButton(
        label: '+ Raise Mineral Enquiry',
        onPressed: () => context.push('/enquiries/create'),
      ),
      body: enquiries.isEmpty
          ? const Center(child: Text('No enquiries raised.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: enquiries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final enq = enquiries[index];

                return AppCard(
                  onTap: () => context.push('/enquiries/detail', extra: enq),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            enq.enquiryNumber,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary700),
                          ),
                          AppBadge(
                            label: enq.status == EnquiryStatus.responded ? 'Quote Ready' : enq.status.value,
                            variant: enq.status == EnquiryStatus.responded ? AppBadgeVariant.success : AppBadgeVariant.warning,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        enq.mineralName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 4),
                      Text('Quarry: ${enq.stockPointName}', style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quantity: ${enq.requiredQuantity.formatted}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                          ),
                          Text(
                            'Req by: ${enq.requiredByDate}',
                            style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
