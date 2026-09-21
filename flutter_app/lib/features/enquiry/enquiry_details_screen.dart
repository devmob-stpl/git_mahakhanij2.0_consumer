import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/enquiry.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/digitp_modal.dart';
import 'enquiries_screen.dart';

class EnquiryDetailsScreen extends ConsumerWidget {
  final Enquiry? enquiry;

  const EnquiryDetailsScreen({super.key, this.enquiry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allEnquiries = ref.watch(enquiriesProvider);
    final enq = enquiry ?? allEnquiries.first;

    Color badgeBg;
    Color badgeFg;

    if (enq.status == EnquiryStatus.actionRequired) {
      badgeBg = const Color(0xFFFFFBEB);
      badgeFg = const Color(0xFFD97706);
    } else if (enq.status == EnquiryStatus.digitpGenerated) {
      badgeBg = const Color(0xFFDCFCE7);
      badgeFg = const Color(0xFF16A34A);
    } else {
      badgeBg = const Color(0xFFEFF6FF);
      badgeFg = const Color(0xFF1D4ED8);
    }

    Widget? bottomAction;
    if (enq.status == EnquiryStatus.actionRequired || enq.status == EnquiryStatus.responded) {
      bottomAction = AppButton(
        label: 'Accept Quotation & Place Order',
        icon: const Icon(Icons.shopping_cart_outlined, size: 18),
        variant: AppButtonVariant.primary,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quotation accepted! Converted to formal statutory order.'),
              backgroundColor: Color(0xFF16A34A),
            ),
          );
          context.pop();
        },
      );
    } else if (enq.status == EnquiryStatus.digitpGenerated) {
      bottomAction = AppButton(
        label: 'View DigiTP Transit Pass',
        icon: const Icon(Icons.qr_code, size: 18),
        variant: AppButtonVariant.primary,
        onPressed: () {
          showDigiTpPassModal(
            context,
            digiTpNumber: 'ETP/2026/MH/0431188',
            destination: enq.packageName ?? 'Package A — Km 12 to Km 28',
          );
        },
      );
    }

    return AppScaffold(
      title: 'Mineral enquiry',
      subtitle: enq.enquiryNumber.isNotEmpty ? enq.enquiryNumber : 'ENQ/2026/009204',
      showBackButton: true,
      bottomActionButton: bottomAction,
      bottomNavigationBar: _buildBottomNavBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Summary Box
              Container(
                width: double.infinity,
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
                    // Badge on top left
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        enq.statusLabel,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: badgeFg,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Quantity
                    Text(
                      enq.requiredQuantity.formatted.isNotEmpty
                          ? enq.requiredQuantity.formatted
                          : '250 Brass',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Mineral Name
                    Text(
                      enq.mineralName.isNotEmpty ? enq.mineralName : 'Black Trap Metal',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Section Header: YOUR REQUIREMENT
              const Text(
                'YOUR REQUIREMENT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 10),

              // 3. Structured Requirement Table Card
              Container(
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTableRow('Enquiry number', enq.enquiryNumber.isNotEmpty ? enq.enquiryNumber : 'ENQ/2026/009204'),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildTableRow('Mineral place', enq.stockPointName.isNotEmpty ? enq.stockPointName : 'Kalyan Stock Point'),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildTableRow('Project', enq.projectName ?? 'Mumbai–Nashik Highway Widening'),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildTableRow('Package', enq.packageName ?? 'Package B — Km 28 to Km 41'),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildTableRow('Required by', enq.requiredByDate.isNotEmpty ? enq.requiredByDate : '1 Oct 2026'),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildTableRow('Raised on', enq.createdAt.isNotEmpty ? enq.createdAt : '16 Sept 2026'),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildTableRow('Last updated', enq.updatedAt.isNotEmpty ? enq.updatedAt : '16 Sept 2026', isLast: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(String label, String value, {bool isLast = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
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

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      padding: EdgeInsets.only(
        top: 6,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 8,
      ),
      child: Row(
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', false, () => context.go('/home')),
          _buildNavItem(Icons.layers_outlined, 'Projects', false, () => context.go('/organization/projects')),
          _buildNavItem(Icons.show_chart, 'Activity', true, () => context.go('/activity')),
          _buildNavItem(Icons.more_horiz, 'More', false, () => context.go('/more')),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 26,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFEEF4FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isActive ? const Color(0xFF1241A6) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? const Color(0xFF1241A6) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
