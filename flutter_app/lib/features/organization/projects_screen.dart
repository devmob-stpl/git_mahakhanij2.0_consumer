import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/project.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_button.dart';
import '../../providers/operating_context_provider.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opState = ref.watch(operatingContextProvider);
    final projects = opState.projects;

    return AppScaffold(
      title: 'Corporate Projects',
      showBackButton: Navigator.canPop(context),
      bottomActionButton: AppButton(
        label: '+ Register New Project',
        onPressed: () => context.push('/organization/projects/create'),
      ),
      body: opState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : projects.isEmpty
              ? const Center(child: Text('No projects registered.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: projects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final proj = projects[index];
                    final isActive = opState.activeProject?.id == proj.id;

                    return AppCard(
                      borderColor: isActive ? AppColors.primary700 : AppColors.line,
                      onTap: () {
                        ref.read(operatingContextProvider.notifier).selectProject(proj);
                        context.push('/organization/projects/detail', extra: proj);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                proj.code,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary700),
                              ),
                              AppBadge(label: proj.status, variant: AppBadgeVariant.success),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            proj.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                          ),
                          if (proj.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              proj.description!,
                              style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.inkMuted),
                              const SizedBox(width: 4),
                              Text(
                                '${proj.location.taluka}, ${proj.location.district}',
                                style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                              ),
                              const Spacer(),
                              if (isActive)
                                const Row(
                                  children: [
                                    Icon(Icons.check_circle, size: 14, color: AppColors.primary700),
                                    SizedBox(width: 4),
                                    Text(
                                      'Active Scope',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary700),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
