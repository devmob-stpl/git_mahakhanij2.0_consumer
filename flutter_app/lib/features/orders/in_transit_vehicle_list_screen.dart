import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/consumer_digitp_models.dart';
import '../../providers/consumer_digitp_provider.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_scaffold.dart';

class InTransitVehicleListScreen extends ConsumerWidget {
  const InTransitVehicleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Status 1 = In Transit vehicles/deliveries
    final inTransitAsync = ref.watch(consumerDigiTpListProvider(1));

    return AppScaffold(
      title: 'In-Transit Vehicles',
      showBackButton: true,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(consumerDigiTpListProvider(1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F0FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEBD9FB)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.near_me_outlined, size: 22, color: Color(0xFF7E22CE)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Vehicle Tracking',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF581C87),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Select an in-transit vehicle to monitor real-time GPS location and ETA.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF7E22CE),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // In-Transit Vehicle List Content
              inTransitAsync.when(
                loading: () => Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(strokeWidth: 3),
                        SizedBox(height: 12),
                        Text(
                          'Loading In-Transit vehicles...',
                          style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (err, stack) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 36, color: Color(0xFFDC2626)),
                      const SizedBox(height: 8),
                      const Text(
                        'Failed to load In-Transit vehicles',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF991B1B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        err.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF7F1D1D)),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Retry Fetching',
                        size: AppButtonSize.small,
                        variant: AppButtonVariant.primary,
                        onPressed: () => ref.invalidate(consumerDigiTpListProvider(1)),
                      ),
                    ],
                  ),
                ),
                data: (response) {
                  final items = response.items;

                  if (items.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(28),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_shipping_outlined,
                              size: 38,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No Vehicles In-Transit',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'There are currently no active mineral vehicles in-transit for your account.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.5, color: AppColors.inkSecondary),
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            label: 'Refresh List',
                            size: AppButtonSize.small,
                            variant: AppButtonVariant.secondary,
                            icon: const Icon(Icons.refresh, size: 16),
                            onPressed: () => ref.invalidate(consumerDigiTpListProvider(1)),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildVehicleCard(context, item);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, ConsumerDigiTpItem item) {
    final vehicleNoStr = item.vehicleNo ?? 'Vehicle N/A';
    final digiTpNoStr = item.invoiceNo;
    final qtyStr = '${item.quantity ?? 0} ${item.mineralUnit ?? 'Brass'}';
    final mineralStr = item.materialType ?? 'Mineral';
    final destStr = item.destination ?? 'Destination N/A';
    final distanceStr = item.distance != null ? '~${item.distance} km away' : 'GPS Active';
    final driverStr = item.driverName != null && item.driverName!.isNotEmpty
        ? '${item.driverName}${item.driverMobNo != null ? ' (${item.driverMobNo})' : ''}'
        : 'N/A';

    return Container(
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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.local_shipping, size: 18, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicleNoStr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'DigiTP: $digiTpNoStr',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.inkSecondary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F0FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEBD9FB)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 6, color: Color(0xFF7E22CE)),
                    SizedBox(width: 4),
                    Text(
                      'In Transit',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF7E22CE)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF3F4F6)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mineral & Qty:', style: TextStyle(fontSize: 11, color: Color(0xFF737373))),
                    Text('$mineralStr · $qtyStr', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Destination:', style: TextStyle(fontSize: 11, color: Color(0xFF737373))),
                    Expanded(
                      child: Text(
                        destStr,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Distance / Speed:', style: TextStyle(fontSize: 11, color: Color(0xFF737373))),
                    Text(distanceStr, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Driver:', style: TextStyle(fontSize: 11, color: Color(0xFF737373))),
                    Text(driverStr, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          AppButton(
            label: 'Select Vehicle & Track Live',
            size: AppButtonSize.small,
            icon: const Icon(Icons.navigation_outlined, size: 16),
            onPressed: () => context.push('/deliveries/$digiTpNoStr/live-tracking?vehicleNo=${item.vehicleNo ?? vehicleNoStr}'),
          ),
        ],
      ),
    );
  }
}
