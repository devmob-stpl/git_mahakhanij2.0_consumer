import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../providers/session_provider.dart';

class SupervisorDashboard extends ConsumerWidget {
  const SupervisorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Supervisor ID Badge Card
          AppCard(
            backgroundColor: AppColors.surface,
            borderColor: AppColors.primary700,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user?.fullName ?? 'Field Supervisor',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const AppBadge(label: 'SUP-4417', variant: AppBadgeVariant.primary),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Assigned: Package 02 - Viaduct Casting Yard',
                  style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                ),
                const SizedBox(height: 14),
                AppButton(
                  label: 'Launch DigiTP Gate Scanner',
                  icon: const Icon(Icons.qr_code_scanner, size: 18),
                  onPressed: () => context.push('/receiving'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Quick Operations',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(height: 10),

          AppCard(
            onTap: () => context.push('/inventory'),
            child: const Row(
              children: [
                Icon(Icons.draw_outlined, color: AppColors.primary700, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Log Material Drawdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text('Record on-site consumption drawdowns against received balance', style: TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.inkMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
