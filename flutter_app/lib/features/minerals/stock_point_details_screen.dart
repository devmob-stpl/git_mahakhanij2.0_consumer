import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/mineral.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_button.dart';

class StockPointDetailsScreen extends ConsumerWidget {
  final StockPoint stockPoint;

  const StockPointDetailsScreen({super.key, required this.stockPoint});

  Future<void> _callOperator(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: stockPoint.name,
      showBackButton: true,
      bottomActionButton: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Raise Mineral Enquiry',
              onPressed: () => context.push('/enquiries/create'),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 48),
              side: const BorderSide(color: AppColors.primary700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _callOperator(stockPoint.contactPhone),
            child: const Icon(Icons.phone, color: AppColors.primary700, size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        stockPoint.code,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary700),
                      ),
                      const AppBadge(label: 'Approved Quarry Depot', variant: AppBadgeVariant.success),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stockPoint.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Operator: ${stockPoint.operatorName}',
                    style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.line),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColors.inkMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          stockPoint.address.formattedAddress,
                          style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                        ),
                      ),
                      Text(
                        '${stockPoint.distanceKm} km away',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.inkMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Operating Hours: ${stockPoint.operatingHours}',
                        style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: AppColors.inkMuted),
                      const SizedBox(width: 6),
                      Text(
                        '${stockPoint.operatorName} · ${stockPoint.contactPhone}',
                        style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Available minerals section
            const Text(
              'Available Minerals & Royalty Stock',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (stockPoint.availableMineralIds.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No minerals listed for this stock point.'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stockPoint.availableMineralIds.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final minId = stockPoint.availableMineralIds[index];

                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primary50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.terrain, color: AppColors.primary700, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                minId.toUpperCase().replaceAll('-', ' '),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Available: 500 BRASS',
                                style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                              ),
                            ],
                          ),
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹400',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary700),
                            ),
                            Text(
                              'per BRASS',
                              style: TextStyle(fontSize: 11, color: AppColors.inkMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
