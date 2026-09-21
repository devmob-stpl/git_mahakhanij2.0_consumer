import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/order.dart';
import '../../domain/delivery.dart';
import '../../data/repositories/delivery_repository.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryRepo = ref.watch(deliveryRepositoryProvider);

    return AppScaffold(
      title: order.orderNumber,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Overview Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.mineralName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 4),
                  Text('Dispatched from ${order.stockPointName}', style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Value', style: TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
                      Text(order.totalAmount.formatted, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Ordered', style: TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
                      Text(order.orderedQuantity.formatted, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Associated DigiTP Truck Dispatches',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
            const SizedBox(height: 10),

            FutureBuilder<List<Delivery>>(
              future: deliveryRepo.listDeliveries(activeOnly: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final deliveries = snapshot.data!;
                if (deliveries.isEmpty) {
                  return const Text('No deliveries recorded.');
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: deliveries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final del = deliveries[index];
                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                del.deliveryNumber,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary700),
                              ),
                              Text(
                                del.vehicle.registrationNumber,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Driver: ${del.vehicle.driverName} (${del.vehicle.driverMobileNumber})', style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 12),
                          AppButton(
                            label: 'View DigiTP Electronic Pass (QR)',
                            variant: AppButtonVariant.secondary,
                            height: 40,
                            onPressed: () {
                              context.push('/orders/digitp', extra: del.transportPermit);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
