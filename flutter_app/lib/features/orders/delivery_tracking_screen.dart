import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/delivery.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_button.dart';

class DeliveryTrackingScreen extends StatelessWidget {
  final Delivery delivery;

  const DeliveryTrackingScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Live Delivery Tracking',
      showBackButton: true,
      bottomActionButton: AppButton(
        label: 'View DigiTP Electronic Transit Pass',
        icon: const Icon(Icons.qr_code, size: 18),
        onPressed: () => context.push('/orders/digitp', extra: delivery.transportPermit),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            AppCard(
              backgroundColor: AppColors.primary50.withOpacity(0.5),
              borderColor: AppColors.primary200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        delivery.deliveryNumber,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary700),
                      ),
                      const AppBadge(label: 'GPS Active', variant: AppBadgeVariant.success),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping, size: 36, color: AppColors.primary700),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              delivery.vehicle.registrationNumber,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink),
                            ),
                            Text(
                              'Driver: ${delivery.vehicle.driverName} (${delivery.vehicle.driverMobileNumber})',
                              style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Route & Transit Timeline
            const Text('Transit Route & Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRouteNode(
                    icon: Icons.storefront,
                    title: 'Source Quarry Loading Point',
                    subtitle: delivery.transportPermit.sourceQuarryName,
                    time: '08:15 AM',
                    isPassed: true,
                  ),
                  _buildRouteLine(),
                  _buildRouteNode(
                    icon: Icons.navigation,
                    title: 'In-Transit on Highway Corridor',
                    subtitle: 'Current Location: Thane-Bhiwandi Bypass (Speed: 42 km/h)',
                    time: 'ETA: ~35 mins',
                    isPassed: true,
                    isCurrent: true,
                  ),
                  _buildRouteLine(),
                  _buildRouteNode(
                    icon: Icons.pin_drop,
                    title: 'Authorized Offloading Destination',
                    subtitle: delivery.transportPermit.destinationLabel,
                    time: 'Expected: 11:30 AM',
                    isPassed: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sourcing Compliance Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.success700, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Statutory electronic transit permit ${delivery.transportPermit.etpNumber} actively matched to destination coordinates.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteNode({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required bool isPassed,
    bool isCurrent = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCurrent
                ? AppColors.primary700
                : (isPassed ? AppColors.primary50 : AppColors.neutral100),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isCurrent ? AppColors.neutral0 : (isPassed ? AppColors.primary700 : AppColors.inkMuted),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600)),
                  Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isCurrent ? AppColors.primary700 : AppColors.inkMuted)),
                ],
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteLine() {
    return Container(
      margin: const EdgeInsets.only(left: 15, top: 4, bottom: 4),
      width: 2,
      height: 28,
      color: AppColors.primary200,
    );
  }
}
