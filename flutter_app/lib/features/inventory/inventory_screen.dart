import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';
import '../../providers/inventory_provider.dart';
import 'record_consumption_dialog.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryState = ref.watch(inventoryProvider);

    return AppScaffold(
      title: 'Materials & Stock Ledger',
      showBackButton: true,
      body: inventoryState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statutory Provenance Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Color(0xFF15803D), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Verified 100% legal sourcing under Maharashtra minor mineral regulations (e-TP).',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Active Material Balances',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 10),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: inventoryState.balances.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final balance = inventoryState.balances[index];
                      return AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  balance.mineralName,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Avail: ${balance.currentAvailableBalance.formatted}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Sourced: ${balance.receivedBalance.formatted}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                                ),
                                Text(
                                  'Utilized: ${balance.consumedBalance.formatted}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              label: 'Record consumption',
                              variant: AppButtonVariant.outline,
                              height: 40,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => RecordConsumptionDialog(balance: balance),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Recent Drawdown Audit Log',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 10),

                  if (inventoryState.history.isEmpty)
                    const Text('No consumption drawdowns recorded yet.', style: TextStyle(color: AppColors.inkMuted))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: inventoryState.history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entry = inventoryState.history[index];
                        return AppCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.action,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
                                  ),
                                  Text(
                                    '-${entry.quantity.formatted}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.danger700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${entry.mineralName} • ${entry.timestamp}',
                                style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                              ),
                              if (entry.remarks != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Purpose: ${entry.remarks}',
                                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.inkMuted),
                                ),
                              ],
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
