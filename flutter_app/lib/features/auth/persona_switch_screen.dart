import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/user.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_badge.dart';
import '../../providers/session_provider.dart';

class PersonaSwitchScreen extends ConsumerWidget {
  const PersonaSwitchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);
    final currentUser = sessionState.currentUser;
    final authRepo = ref.watch(authRepositoryProvider);

    return AppScaffold(
      title: 'Persona Switcher (Prototype)',
      showBackButton: true,
      body: FutureBuilder<List<User>>(
        future: authRepo.getAllUsersForPersonaSwitch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              final isCurrent = currentUser?.id == user.id;

              String roleDesc;
              AppBadgeVariant badgeVariant;
              switch (user.userType) {
                case UserType.organization:
                  roleDesc = 'Full corporate access: Multi-package hierarchy, Temporary Excavation permits, inventory drawdowns';
                  badgeVariant = AppBadgeVariant.primary;
                  break;
                case UserType.normalConsumer:
                  roleDesc = 'Individual citizen: Browse minerals, quote requests, DigiTP delivery verification';
                  badgeVariant = AppBadgeVariant.success;
                  break;
                case UserType.supervisor:
                  roleDesc = 'Field staff: DigiTP QR scanning, delivery discrepancy reports, stock audits';
                  badgeVariant = AppBadgeVariant.warning;
                  break;
              }

              return AppCard(
                borderColor: isCurrent ? AppColors.primary700 : AppColors.line,
                backgroundColor: isCurrent ? AppColors.primary50.withOpacity(0.5) : AppColors.surface,
                onTap: () async {
                  await ref.read(sessionProvider.notifier).switchPersona(user);
                  if (context.mounted) {
                    context.go('/home');
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        AppBadge(
                          label: user.userType.value,
                          variant: badgeVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mobile: +91 ${user.mobileNumber}',
                      style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      roleDesc,
                      style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(Icons.check_circle, size: 16, color: AppColors.primary700),
                          SizedBox(width: 6),
                          Text(
                            'Active Persona in Current Session',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary700,
                            ),
                          ),
                        ],
                      ),
                    ],
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
