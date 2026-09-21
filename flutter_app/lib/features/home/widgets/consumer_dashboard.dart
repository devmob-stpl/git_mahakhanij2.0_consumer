import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/session_provider.dart';
import 'home_header.dart';
import 'delivery_summary_card.dart';

class ConsumerDashboard extends ConsumerWidget {
  const ConsumerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).currentUser;
    final userName = user?.fullName ?? 'Aniket Deshmukh';

    final deliveries = [
      DeliveryItemSummary(
        id: 'del-demo-1',
        code: 'DTP-2024-8842',
        digiTpNumber: 'DTP-2024-8842',
        purchasedFrom: 'Shree Ganesh Stone Quarry',
        status: 'IN_TRANSIT',
        destination: 'NH-48 Road Widening Site',
        mineralName: 'Basalt Stone',
        quantity: '500 Brass',
        onClick: () => context.push('/deliveries/del-004/live-tracking'),
      ),
      DeliveryItemSummary(
        id: 'del-demo-2',
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
        id: 'del-demo-3',
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
            notificationCount: 4,
            onNotificationClick: () {},
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Stat Cards (3 columns)
                  Row(
                    children: [
                      // Projects
                      Expanded(
                        child: _buildStatCard(
                          count: '01',
                          label: 'Projects',
                          bgColor: const Color(0xFFEEF5FD),
                          borderColor: const Color(0xFFD6E5F8),
                          textColor: const Color(0xFF134280),
                          onTap: () => context.push('/consumer/projects'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // DigiTP Created
                      Expanded(
                        child: _buildStatCard(
                          count: '02',
                          label: 'DigiTP Created',
                          bgColor: const Color(0xFFEEF5FD),
                          borderColor: const Color(0xFFD6E5F8),
                          textColor: const Color(0xFF134280),
                          onTap: () => context.push('/activity'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // In Transit Vehicle
                      Expanded(
                        child: _buildStatCard(
                          count: '01',
                          label: 'In Transit\nVehicle',
                          bgColor: const Color(0xFFF7F0FD),
                          borderColor: const Color(0xFFEBD9FB),
                          textColor: const Color(0xFF7E22CE),
                          onTap: () => context.push('/deliveries/del-004/live-tracking'),
                        ),
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

                  // Quick Services Box (White card with 4 rounded actions)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuickServiceItem(
                          icon: Icons.qr_code_2,
                          title: 'Receive\nMaterial',
                          onTap: () => context.push('/receive'),
                        ),
                        _buildQuickServiceItem(
                          icon: Icons.local_shipping_outlined,
                          title: 'Track\nVehicle',
                          onTap: () => context.push('/deliveries/del-004/live-tracking'),
                        ),
                        _buildQuickServiceItem(
                          icon: Icons.search,
                          title: 'Find Mineral\nPlaces',
                          onTap: () => context.push('/minerals/stock-points'),
                        ),
                        _buildQuickServiceItem(
                          icon: Icons.create_new_folder_outlined,
                          title: 'Register\nProject',
                          onTap: () => context.push('/consumer/projects/register'),
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
        height: 86,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
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
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
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
}
