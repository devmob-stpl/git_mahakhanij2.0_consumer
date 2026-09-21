import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/package.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_badge.dart';
import '../../providers/operating_context_provider.dart';

class SupervisorsScreen extends ConsumerStatefulWidget {
  const SupervisorsScreen({super.key});

  @override
  ConsumerState<SupervisorsScreen> createState() => _SupervisorsScreenState();
}

class _SupervisorsScreenState extends ConsumerState<SupervisorsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final orgRepo = ref.watch(organizationRepositoryProvider);

    return AppScaffold(
      title: 'Supervisors',
      showBackButton: true,
      bottomActionButton: AppButton(
        label: '+ Add Authorized Supervisor',
        onPressed: () async {
          await context.push('/organization/supervisors/create');
          setState(() {});
        },
      ),
      body: Column(
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.people_outline, color: AppColors.primary700, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Authorized Personnel',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      Text(
                        'Supervisors verify and approve mineral dispatches & DigiTP QR e-passes at site.',
                        style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search supervisor name or SUP code...',
                prefixIcon: Icon(Icons.search, size: 20, color: AppColors.inkMuted),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // List
          Expanded(
            child: FutureBuilder<List<SupervisorInfo>>(
              future: orgRepo.listSupervisors(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var list = snapshot.data!;
                if (_searchQuery.isNotEmpty) {
                  list = list.where((s) =>
                      s.name.toLowerCase().contains(_searchQuery) ||
                      s.employeeCode.toLowerCase().contains(_searchQuery) ||
                      s.mobileNumber.contains(_searchQuery)).toList();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final sup = list[index];
                    return AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.neutral100,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Center(
                              child: Icon(Icons.person, color: AppColors.inkSecondary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sup.name,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '+91 ${sup.mobileNumber}',
                                  style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                                ),
                                if (sup.assignedPackageName != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Site: ${sup.assignedPackageName}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.primary700, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          AppBadge(
                            label: sup.employeeCode,
                            variant: AppBadgeVariant.primary,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
