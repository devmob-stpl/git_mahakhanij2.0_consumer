import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/consumer_digitp_provider.dart';
import '../../../providers/consumer_dashboard_count_provider.dart';
import '../../../providers/session_provider.dart';
import '../../../shared/widgets/digitp_modal.dart';
import 'home_header.dart';
import 'delivery_summary_card.dart';


class ConsumerDashboard extends ConsumerWidget {
  const ConsumerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).currentUser;
    final userName = user?.fullName ?? '';

    final dashboardCountAsync = ref.watch(consumerDashboardCountProvider);
    final inTransitAsync = ref.watch(consumerDigiTpListProvider(1));
    final deliveredAsync = ref.watch(consumerDigiTpListProvider(2));

    final inTransitItems = inTransitAsync.valueOrNull?.items ?? [];
    final deliveredItems = deliveredAsync.valueOrNull?.items ?? [];

    final countData = dashboardCountAsync.valueOrNull?.responseData;
    final inTransitCount = countData?.inTransitCount ?? inTransitItems.length;
    final deliveredCount = countData?.deliveredCount ?? deliveredItems.length;
    final totalCount = countData?.totalCount ?? (inTransitCount + deliveredCount);

    // Convert live items to DeliveryItemSummary for recent deliveries
    final List<DeliveryItemSummary> recentDeliveries = [];

    for (final item in inTransitItems) {
      recentDeliveries.add(
        DeliveryItemSummary(
          id: item.invoiceNo,
          code: item.invoiceNo,
          digiTpNumber: item.invoiceNo,
          vehicleNo: item.vehicleNo,
          purchasedFrom: item.plotName ?? 'Quarry / Stockyard',
          status: item.invoiceStatus ?? 'IN_TRANSIT',
          destination: item.destination ?? 'Destination Site',
          mineralName: item.materialType ?? 'Mineral',
          quantity: '${item.quantity ?? 0} ${item.mineralUnit ?? 'Brass'}',
          onTrackVehicle: () => context.push('/deliveries/${item.invoiceNo}/live-tracking?vehicleNo=${item.vehicleNo ?? item.invoiceNo}'),
          onViewDigiTp: () => showDigiTpPassModal(context, item: item),
        ),
      );
    }


    for (final item in deliveredItems) {
      recentDeliveries.add(
        DeliveryItemSummary(
          id: item.invoiceNo,
          code: item.invoiceNo,
          digiTpNumber: item.invoiceNo,
          vehicleNo: item.vehicleNo,
          purchasedFrom: item.ownerName ?? 'Quarry / Stockyard',
          status: item.invoiceStatus ?? 'RECEIVED',
          destination: item.destination ?? 'Destination Site',
          mineralName: item.materialType ?? 'Mineral',
          quantity: '${item.quantity ?? 0} ${item.mineralUnit ?? 'Brass'}',
          rawItem: item,
          onViewDigiTp: () => showDigiTpPassModal(context, item: item),
        ),
      );
    }



    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          HomeHeader(
            userName: userName,
            notificationCount: inTransitCount > 0 ? inTransitCount : 0,
            onNotificationClick: () {},
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary700,
              onRefresh: () async {
                ref.invalidate(consumerDashboardCountProvider);
                ref.invalidate(consumerDigiTpListProvider(1));
                ref.invalidate(consumerDigiTpListProvider(2));
                await Future.wait([
                  ref.refresh(consumerDashboardCountProvider.future),
                  ref.refresh(consumerDigiTpListProvider(1).future),
                  ref.refresh(consumerDigiTpListProvider(2).future),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                  // 1. Core Module Stat Cards (3 columns - summary display only)
                  Row(
                    children: [
                      // DigiTP Deliveries (totalCount)
                      Expanded(
                        child: _buildStatCard(
                          count: dashboardCountAsync.isLoading ? '...' : totalCount.toString().padLeft(2, '0'),
                          label: 'DigiTP\nDeliveries',
                          bgColor: const Color(0xFFEEF5FD),
                          borderColor: const Color(0xFFD6E5F8),
                          textColor: const Color(0xFF134280),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Received Material (deliveredCount)
                      Expanded(
                        child: _buildStatCard(
                          count: dashboardCountAsync.isLoading ? '...' : deliveredCount.toString().padLeft(2, '0'),
                          label: 'Received\nMaterial',
                          bgColor: const Color(0xFFF0FDF4),
                          borderColor: const Color(0xFFBBF7D0),
                          textColor: const Color(0xFF15803D),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // In Transit Vehicles (inTransitCount)
                      Expanded(
                        child: _buildStatCard(
                          count: dashboardCountAsync.isLoading ? '...' : inTransitCount.toString().padLeft(2, '0'),
                          label: 'In Transit\nVehicles',
                          bgColor: const Color(0xFFF7F0FD),
                          borderColor: const Color(0xFFEBD9FB),
                          textColor: const Color(0xFF7E22CE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. Core Actions Header
                  const Text(
                    'CORE SERVICES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Color(0xFF737373),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Core Actions Box
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQuickServiceItem(
                          icon: Icons.assignment_turned_in_outlined,
                          title: 'DigiTP\nPasses',
                          onTap: () => context.go('/activity'),
                        ),
                        _buildQuickServiceItem(
                          icon: Icons.qr_code_2,
                          title: 'Receive\nMaterial',
                          onTap: () => context.push('/receive'),
                        ),
                        _buildQuickServiceItem(
                          icon: Icons.local_shipping_outlined,
                          title: 'Track\nVehicle',
                          onTap: () => context.push('/deliveries/in-transit'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Recent DigiTP Deliveries Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'DIGITP & MINERAL DELIVERIES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Color(0xFF737373),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/activity'),
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
                  if (recentDeliveries.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Text(
                        'No recent DigiTP deliveries found.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentDeliveries.length > 3 ? 3 : recentDeliveries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return DeliverySummaryCardWidget(item: recentDeliveries[index]);
                      },
                    ),
                  const SizedBox(height: 24),
                ],
              ),
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
  }) {
    return Container(
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
        width: 76,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF4FE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
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
