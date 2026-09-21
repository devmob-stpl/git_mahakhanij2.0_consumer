import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/mineral.dart';
import '../../data/repositories/mineral_repository.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_badge.dart';

final mineralRepositoryProvider = Provider<MineralRepository>((ref) {
  return MineralRepositoryImpl();
});

class MineralCatalogScreen extends ConsumerWidget {
  const MineralCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mineralRepo = ref.watch(mineralRepositoryProvider);

    return AppScaffold(
      title: 'Mineral Catalog',
      showBackButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.map_outlined, size: 22),
          onPressed: () => context.push('/minerals/stock-points'),
        ),
      ],
      body: FutureBuilder<List<Mineral>>(
        future: mineralRepo.listMinerals(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final minerals = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: minerals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final min = minerals[index];

              return AppCard(
                onTap: () {
                  // Direct to stock points or quote request
                  context.push('/minerals/stock-points');
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          min.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                        const AppBadge(label: '100% Legal', variant: AppBadgeVariant.success),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      min.description,
                      style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Category: ${min.category}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.inkMuted),
                        ),
                        Text(
                          '₹${min.defaultRatePerUnit.toStringAsFixed(0)} / ${min.standardUnit}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary700),
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
