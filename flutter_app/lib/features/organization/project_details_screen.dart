import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/project.dart';
import '../../domain/package.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_button.dart';
import '../../providers/operating_context_provider.dart';

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  ConsumerState<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  bool _showWorkOrderDetails = false;

  @override
  Widget build(BuildContext context) {
    final opState = ref.watch(operatingContextProvider);
    final isSelected = opState.activeProject?.id == widget.project.id;
    final packages = opState.packages.where((p) => p.projectId == widget.project.id).toList();

    final isLinear = widget.project.location.line1.toLowerCase().contains('km') ||
        widget.project.location.line1.toLowerCase().contains('corridor') ||
        widget.project.location.line1.toLowerCase().contains('highway') ||
        widget.project.name.toLowerCase().contains('highway') ||
        widget.project.name.toLowerCase().contains('line');

    return AppScaffold(
      title: widget.project.name,
      showBackButton: true,
      bottomActionButton: AppButton(
        label: '+ Add Package to Project',
        onPressed: () => context.push(
          '/organization/packages/create',
          extra: widget.project,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Classification Header
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.project.code,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary700),
                      ),
                      AppBadge(
                        label: widget.project.status,
                        variant: AppBadgeVariant.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.project.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          widget.project.projectType == 'GOVERNMENT' ? 'Govt Project' : 'Private',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1D4ED8)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(
                          isLinear ? 'Linear Corridor' : 'Stationary Site',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                        ),
                      ),
                    ],
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.project.location.line1,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                            ),
                            Text(
                              '${widget.project.location.taluka}, ${widget.project.location.district}, ${widget.project.location.state} — ${widget.project.location.pincode}',
                              style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Active context button
                  InkWell(
                    onTap: () {
                      ref.read(operatingContextProvider.notifier).selectProject(widget.project);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Active operating scope set to: ${widget.project.name}')),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? const Color(0xFF86EFAC) : AppColors.line),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            size: 16,
                            color: isSelected ? const Color(0xFF16A34A) : AppColors.inkMuted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isSelected ? 'Currently Active Operating Scope' : 'Set as Active Operating Scope',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? const Color(0xFF15803D) : AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Collapsible Work Order / Department Section
            if (widget.project.department != null || widget.project.workOrderNumber != null) ...[
              InkWell(
                onTap: () => setState(() => _showWorkOrderDetails = !_showWorkOrderDetails),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.description_outlined, size: 16, color: AppColors.primary700),
                          const SizedBox(width: 8),
                          Text(
                            widget.project.workOrderNumber != null
                                ? 'Work Order: ${widget.project.workOrderNumber}'
                                : 'Authority Details',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                          ),
                        ],
                      ),
                      Icon(
                        _showWorkOrderDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 20,
                        color: AppColors.inkMuted,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showWorkOrderDetails) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      if (widget.project.department != null)
                        _buildInfoRow('Department / Authority', widget.project.department!),
                      if (widget.project.officeName != null)
                        _buildInfoRow('Office Division', widget.project.officeName!),
                      if (widget.project.workOrderNumber != null)
                        _buildInfoRow('Work Order Number', widget.project.workOrderNumber!),
                      if (widget.project.workOrderDate != null)
                        _buildInfoRow('Work Order Date', widget.project.workOrderDate!),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],

            // Packages Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Project Packages',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${packages.length}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary700),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.push(
                    '/organization/packages/create',
                    extra: widget.project,
                  ),
                  child: const Text('+ Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (packages.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('No packages added to this project yet.'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: packages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final pkg = packages[index];

                  return AppCard(
                    onTap: () => context.push('/organization/packages/detail', extra: pkg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pkg.code,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary700),
                            ),
                            AppBadge(
                              label: pkg.status,
                              variant: pkg.status == 'ACTIVE' ? AppBadgeVariant.success : AppBadgeVariant.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          pkg.name,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pkg.siteAddress.formattedAddress,
                          style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                        ),
                        if (pkg.supervisor != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: AppColors.inkMuted),
                              const SizedBox(width: 4),
                              Text(
                                'Supervisor: ${pkg.supervisor!.name} (${pkg.supervisor!.mobileNumber})',
                                style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                              ),
                            ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
        ],
      ),
    );
  }
}
