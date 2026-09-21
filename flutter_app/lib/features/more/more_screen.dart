import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/user.dart';
import '../../rules/access_control.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_badge.dart';
import '../../providers/session_provider.dart';
import '../../providers/operating_context_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionProvider);
    final user = sessionState.currentUser;
    final opState = ref.watch(operatingContextProvider);

    if (user == null) {
      return const Center(child: Text('Not signed in'));
    }

    final canExcavate = AccessControl.userCan(user, Capability.temporaryExcavation);
    final isOrg = user.userType == UserType.organization;

    return AppScaffold(
      title: 'More',
      showBackButton: false,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Profile Card (Clickable to open Profile & KYC)
            InkWell(
              onTap: () => context.push('/profile'),
              child: Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.surface,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primary200),
                      ),
                      child: const Center(
                        child: Icon(Icons.person, color: AppColors.primary700, size: 26),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                user.fullName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                              ),
                              const SizedBox(width: 8),
                              AppBadge(
                                label: isOrg ? 'Organization' : 'Individual',
                                variant: isOrg ? AppBadgeVariant.primary : AppBadgeVariant.neutral,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+91 ${user.mobileNumber}',
                            style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                          ),
                          if (opState.organization != null && isOrg) ...[
                            const SizedBox(height: 4),
                            Text(
                              opState.organization!.legalName,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary700),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary200),
                      ),
                      child: const Row(
                        children: [
                          Text('Edit & KYC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary700)),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right, size: 14, color: AppColors.primary700),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // Organization Management
            if (isOrg) ...[
              _buildSectionHeader('Organization Management'),
              if (canExcavate)
                _buildMenuItem(
                  icon: Icons.landslide_outlined,
                  title: 'Temporary Excavation Application',
                  subtitle: 'Applications and status',
                  onTap: () => context.push('/excavation'),
                ),
              _buildMenuItem(
                icon: Icons.badge_outlined,
                title: 'Supervisors',
                subtitle: '6 registered supervisors',
                onTap: () => context.push('/organization/supervisors'),
              ),
              _buildMenuItem(
                icon: Icons.business_outlined,
                title: 'Projects',
                subtitle: 'Manage projects and packages',
                onTap: () => context.push('/organization/projects'),
              ),
            ],

            _buildSectionHeader('Operations'),
            _buildMenuItem(
              icon: Icons.warehouse_outlined,
              title: 'Inventory',
              subtitle: 'Received, consumed and available quantity',
              onTap: () => context.push('/inventory'),
            ),
            _buildMenuItem(
              icon: Icons.swap_calls_outlined,
              title: 'Mineral Transfers & e-TP',
              subtitle: 'Surplus relocation, inter-site passes and returns',
              onTap: () => context.push('/transfers'),
            ),
            if (!isOrg)
              _buildMenuItem(
                icon: Icons.home_work_outlined,
                title: 'Projects',
                subtitle: 'Create and manage your registered sites',
                onTap: () => context.push('/consumer/projects'),
              ),
            _buildMenuItem(
              icon: Icons.assignment_outlined,
              title: 'Enquiries',
              subtitle: 'Mineral quote requests you have raised',
              onTap: () => context.push('/enquiries'),
            ),
            _buildMenuItem(
              icon: Icons.bar_chart_outlined,
              title: 'Report',
              subtitle: 'DigiTP transit pass logs and compliance records',
              onTap: () => context.push('/reports'),
            ),
            _buildMenuItem(
              icon: Icons.qr_code_scanner,
              title: 'Receive mineral',
              subtitle: 'Scan incoming truck QR and confirm receipt',
              onTap: () => context.push('/receiving'),
            ),
            _buildMenuItem(
              icon: Icons.explore_outlined,
              title: 'Find mineral place',
              subtitle: 'Find quarries and stockyards',
              onTap: () => context.push('/minerals/stock-points'),
            ),

            _buildSectionHeader('Session'),
            _buildMenuItem(
              icon: Icons.swap_horiz,
              title: 'Switch persona',
              subtitle: 'Switch between Consumer, Organization, and Supervisor',
              onTap: () => context.push('/persona-switch'),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger600,
                  side: const BorderSide(color: AppColors.danger200),
                  minimumSize: const Size(double.infinity, 44),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sign out'),
                onPressed: () {
                  ref.read(sessionProvider.notifier).logout();
                  context.go('/welcome');
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: AppColors.canvas,
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF737373),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.inkSecondary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}
