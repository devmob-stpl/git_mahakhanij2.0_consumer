import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/order.dart';
import '../../data/repositories/order_repository.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_badge.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl();
});

final ordersListProvider = FutureProvider<List<Order>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.listOrders();
});

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersListProvider);

    return AppScaffold(
      title: 'Orders & Dispatches',
      showBackButton: false,
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No orders placed yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];

              AppBadgeVariant statusVariant = AppBadgeVariant.neutral;
              String statusLabel = order.status.value;
              if (order.status == OrderStatus.completed) {
                statusVariant = AppBadgeVariant.success;
                statusLabel = 'Delivered';
              } else if (order.status == OrderStatus.partiallyDelivered) {
                statusVariant = AppBadgeVariant.warning;
                statusLabel = 'In Transit / Partial';
              }

              return AppCard(
                onTap: () => context.push('/orders/detail', extra: order),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.orderNumber,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary700),
                        ),
                        AppBadge(label: statusLabel, variant: statusVariant),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.mineralName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Source: ${order.stockPointName}',
                      style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivered: ${order.deliveredQuantity.formatted} / ${order.orderedQuantity.formatted}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
                        ),
                        Text(
                          order.totalAmount.formatted,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
