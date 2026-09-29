import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/consumer_project_models.dart';
import '../../providers/consumer_projects_provider.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_badge.dart';

class ConsumerProjectsScreen extends ConsumerWidget {
  const ConsumerProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(consumerProjectsProvider);

    return AppScaffold(
      title: 'Consumer Projects',
      showBackButton: true,
      bottomActionButton: AppButton(
        label: '+ New project',
        onPressed: () => context.push('/consumer/projects/register'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(consumerProjectsProvider.notifier).refresh(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.projects.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.business_outlined, size: 54, color: AppColors.inkMuted),
                              const SizedBox(height: 12),
                              const Text(
                                'No projects found',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Register your project to track minor mineral sourcing requirements.',
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
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.projects.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final proj = state.projects[index];
                      final category = proj.projectCategory ?? proj.projectType ?? 'Consumer Project';
                      final locationText = [
                        if (proj.village != null && proj.village!.isNotEmpty) proj.village,
                        if (proj.taluka != null && proj.taluka!.isNotEmpty) proj.taluka,
                        if (proj.district != null && proj.district!.isNotEmpty) proj.district,
                      ].join(', ');

                      return AppCard(
                        onTap: () => _showProjectDetailSheet(context, proj),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.business_outlined, size: 22, color: AppColors.primary700),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        proj.name.isNotEmpty ? proj.name : 'Project #${proj.id}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          AppBadge(
                                            label: category,
                                            variant: category.toLowerCase().contains('private')
                                                ? AppBadgeVariant.primary
                                                : AppBadgeVariant.neutral,
                                          ),
                                          if (proj.gutNo != null && proj.gutNo!.isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            AppBadge(
                                              label: 'Gut No: ${proj.gutNo}',
                                              variant: AppBadgeVariant.neutral,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, size: 20, color: Color(0xFF94A3B8)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: AppColors.line),
                            const SizedBox(height: 10),

                            if (locationText.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 15, color: AppColors.inkSecondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      locationText,
                                      style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                            ],

                            if (proj.contractorName.isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 15, color: AppColors.inkSecondary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Contractor: ${proj.contractorName} ${proj.contractorMobileNo.isNotEmpty ? "(${proj.contractorMobileNo})" : ""}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                            ],

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Est. Qty: ${proj.estimatedQuantityInTon.toStringAsFixed(1)} Ton',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary700),
                                ),
                                if (proj.getDocument.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.attach_file, size: 13, color: Color(0xFF475569)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${proj.getDocument.length} Doc',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  void _showProjectDetailSheet(BuildContext context, ConsumerProjectItem proj) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    proj.name.isNotEmpty ? proj.name : 'Project Details',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  if (proj.consumerName != null && proj.consumerName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      proj.consumerName!,
                      style: const TextStyle(fontSize: 13, color: AppColors.primary700, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.line),
                  const SizedBox(height: 16),

                  _buildDetailRow('Project ID', '#${proj.id}'),
                  _buildDetailRow('Category', proj.projectCategory ?? 'N/A'),
                  _buildDetailRow('Project Type', proj.projectType ?? 'N/A'),
                  _buildDetailRow('Department Project', proj.departmentProject ?? (proj.isDepartmentProject ? 'Yes' : 'No')),
                  if (proj.departmentName != null && proj.departmentName!.isNotEmpty)
                    _buildDetailRow('Department', proj.departmentName!),
                  if (proj.officeName != null && proj.officeName!.isNotEmpty)
                    _buildDetailRow('Office', proj.officeName!),
                  if (proj.gutNo != null && proj.gutNo!.isNotEmpty)
                    _buildDetailRow('Gut / Survey No.', proj.gutNo!),
                  _buildDetailRow('Estimated Quantity', '${proj.estimatedQuantityInTon.toStringAsFixed(2)} Ton'),
                  if (proj.approvedQuantity > 0)
                    _buildDetailRow('Approved Quantity', '${proj.approvedQuantity.toStringAsFixed(2)} Ton'),

                  const SizedBox(height: 12),
                  const Text('Location Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  const SizedBox(height: 8),
                  _buildDetailRow('State', proj.state ?? 'Maharashtra'),
                  _buildDetailRow('District', proj.district ?? 'N/A'),
                  _buildDetailRow('Taluka', proj.taluka ?? 'N/A'),
                  _buildDetailRow('Village / City', proj.village ?? 'N/A'),
                  if (proj.projectAddress.isNotEmpty)
                    _buildDetailRow('Address', proj.projectAddress),
                  if (proj.latitude != 0 || proj.longitude != 0)
                    _buildDetailRow('Coordinates', '${proj.latitude}, ${proj.longitude}'),

                  if (proj.contractorName.isNotEmpty || proj.contractorMobileNo.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Contractor Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
                    const SizedBox(height: 8),
                    if (proj.contractorName.isNotEmpty) _buildDetailRow('Contractor Name', proj.contractorName),
                    if (proj.contractorMobileNo.isNotEmpty) _buildDetailRow('Contact Mobile', '+91 ${proj.contractorMobileNo}'),
                  ],

                  if (proj.getDocument.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Attached Documents (${proj.getDocument.length})',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 8),
                    ...proj.getDocument.map((doc) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file_outlined, color: AppColors.primary700, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc.filename.isNotEmpty ? doc.filename : 'Document #${doc.id}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                                  ),
                                  if (doc.docNo.isNotEmpty)
                                    Text(
                                      'Doc No: ${doc.docNo}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary),
                                    ),
                                ],
                              ),
                            ),
                            if (doc.docPath.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.open_in_new, size: 20, color: AppColors.primary700),
                                onPressed: () async {
                                  final uri = Uri.parse(doc.docPath);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}
