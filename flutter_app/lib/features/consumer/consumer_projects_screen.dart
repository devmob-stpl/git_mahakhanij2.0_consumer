import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/project.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';
import '../../providers/operating_context_provider.dart';

class ConsumerProjectsScreen extends ConsumerWidget {
  const ConsumerProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opState = ref.watch(operatingContextProvider);

    return AppScaffold(
      title: 'Projects',
      showBackButton: true,
      bottomActionButton: AppButton(
        label: '+ New project',
        onPressed: () => context.push('/consumer/projects/register'),
      ),
      body: opState.projects.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.business_outlined, size: 54, color: AppColors.inkMuted),
                    const SizedBox(height: 12),
                    const Text(
                      'No projects yet',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Create your first project to track the site and material requirements for sourcing.',
                      style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Register project',
                      onPressed: () => context.push('/consumer/projects/register'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: opState.projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final proj = opState.projects[index];
                return AppCard(
                  onTap: () => context.push('/consumer/projects/detail', extra: proj),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.business_outlined, size: 18, color: AppColors.primary700),
                              const SizedBox(width: 8),
                              Text(
                                proj.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                              ),
                            ],
                          ),
                          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${proj.location.taluka}, ${proj.location.district}',
                        style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        proj.code,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.inkMuted, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
