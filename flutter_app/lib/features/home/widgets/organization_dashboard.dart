import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/session_provider.dart';
import 'home_header.dart';
import 'delivery_summary_card.dart';

class OrganizationDashboard extends ConsumerWidget {
  const OrganizationDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).currentUser;
    final userName = user?.fullName ?? 'Rohit Sanghavi';

    final deliveries = [
      DeliveryItemSummary(
        id: 'del-org-1',
        code: 'DTP-2024-8842',
        digiTpNumber: 'DTP-2024-8842',
        purchasedFrom: 'Shree Ganesh Stone Quarry',
        status: 'IN_TRANSIT',
        destination: 'NH-48 Road Widening Site',
        mineralName: 'Basalt Stone',
        quantity: '500 Brass',
        onClick: () => context.push('/deliveries/del-001/live-tracking'),
      ),
      DeliveryItemSummary(
        id: 'del-org-2',
        code: 'DTP-2024-7931',
        digiTpNumber: 'DTP-2024-7931',
        purchasedFrom: 'Krishna River Sand Depo',
        status: 'PASS_ISSUED',
        destination: 'Coastal Highway Bridge Site',
        mineralName: 'River Sand',
        quantity: '200 Brass',
        onClick: () => context.push('/activity'),
      ),
      DeliveryItemSummary(
        id: 'del-org-3',
        code: 'DTP-2024-6420',
        digiTpNumber: 'DTP-2024-6420',
        purchasedFrom: 'Sahyadri Aggregate Hub',
        status: 'RECEIVED',
        destination: 'NH-48 Road Widening Site',
        mineralName: 'Stone Aggregate',
        quantity: '150 Brass',
        onClick: () => context.push('/activity'),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          HomeHeader(
            userName: userName,
            notificationCount: 3,
            onNotificationClick: () => _showAttentionSheet(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Stat Cards (3x2 grid = 6 cards)
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.15,
                    children: [
                      // Projects
                      _buildStatCard(
                        count: '03',
                        label: 'Projects',
                        bgColor: const Color(0xFFEEF5FD),
                        borderColor: const Color(0xFFD6E5F8),
                        textColor: const Color(0xFF134280),
                        onTap: () => context.push('/organization/projects'),
                      ),
                      // Pending Application
                      _buildStatCard(
                        count: '01',
                        label: 'Pending\nApplication',
                        bgColor: const Color(0xFFFEF9E7),
                        borderColor: const Color(0xFFFCE8B2),
                        textColor: const Color(0xFFB45309),
                        onTap: () => context.push('/excavation'),
                      ),
                      // Pending Demand note
                      _buildStatCard(
                        count: '01',
                        label: 'Pending\nDemand note',
                        bgColor: const Color(0xFFFDE8E8),
                        borderColor: const Color(0xFFFBCACA),
                        textColor: const Color(0xFFB91C1C),
                        onTap: () => context.push('/excavation'),
                      ),
                      // DigiTP Created
                      _buildStatCard(
                        count: '03',
                        label: 'DigiTP Created',
                        bgColor: const Color(0xFFEEF5FD),
                        borderColor: const Color(0xFFD6E5F8),
                        textColor: const Color(0xFF134280),
                        onTap: () => context.push('/activity'),
                      ),
                      // In Transit
                      _buildStatCard(
                        count: '01',
                        label: 'In Transit',
                        bgColor: const Color(0xFFF7F0FD),
                        borderColor: const Color(0xFFEBD9FB),
                        textColor: const Color(0xFF7E22CE),
                        onTap: () => context.push('/deliveries/del-001/live-tracking'),
                      ),
                      // Permits
                      _buildStatCard(
                        count: '02',
                        label: 'Permits',
                        bgColor: const Color(0xFFF7F0FD),
                        borderColor: const Color(0xFFEBD9FB),
                        textColor: const Color(0xFF7E22CE),
                        onTap: () => context.push('/excavation'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. Quick Services Header
                  const Text(
                    'QUICK SERVICES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Color(0xFF737373),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Quick Services Box (White card with 7 actions across 4 columns)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildQuickServiceItem(
                              icon: Icons.create_new_folder_outlined,
                              title: 'Register\nProject',
                              onTap: () => context.push('/organization/projects/create'),
                            ),
                            _buildQuickServiceItem(
                              icon: Icons.description_outlined,
                              title: 'Apply for\nPermits',
                              onTap: () => context.push('/excavation/new'),
                            ),
                            _buildQuickServiceItem(
                              icon: Icons.search,
                              title: 'Find Mineral\nPlaces',
                              onTap: () => context.push('/minerals/stock-points'),
                            ),
                            _buildQuickServiceItem(
                              icon: Icons.person_add_alt_1_outlined,
                              title: 'Register\nSupervisor',
                              onTap: () => context.push('/organization/supervisors'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildQuickServiceItem(
                              icon: Icons.local_shipping_outlined,
                              title: 'Track\nVehicle',
                              onTap: () => context.push('/deliveries/del-001/live-tracking'),
                            ),
                            _buildQuickServiceItem(
                              icon: Icons.qr_code_2,
                              title: 'Scan QR to\nReceive',
                              onTap: () => context.push('/receiving'),
                            ),
                            _buildQuickServiceItem(
                              icon: Icons.schedule_outlined,
                              title: 'Demand\nNotes',
                              onTap: () => context.push('/excavation'),
                            ),
                            const SizedBox(width: 70), // Spacer for balanced 4th column
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Recent Deliveries Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RECENT DELIVERIES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Color(0xFF737373),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/activity'),
                        child: const Row(
                          children: [
                            Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary700,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.arrow_forward, size: 13, color: AppColors.primary700),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Recent Deliveries Cards
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: deliveries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return DeliverySummaryCardWidget(item: deliveries[index]);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String count,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF525252),
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickServiceItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF4FE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF1241A6), size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF404040),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttentionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attention Required',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Deliveries, discrepancies, and application notices requiring your action.',
                  style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Demand Note Payment Due',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                            ),
                            const Text(
                              'DN-PLG-2024-0312 for ₹1,48,000 is awaiting statutory payment.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
                            ),
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
      },
    );
  }
}
