import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/temporary_excavation.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/filter_pill.dart';
import '../../providers/excavation_provider.dart';
import 'widgets/resume_draft_dialog.dart';

class TemporaryExcavationScreen extends ConsumerWidget {
  const TemporaryExcavationScreen({super.key});

  void _handleNewApplication(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(excavationRepositoryProvider);
    final cachedDraft = await repo.getCachedDraft('org-001');

    if (context.mounted) {
      if (cachedDraft != null) {
        showDialog(
          context: context,
          builder: (_) => ResumeDraftDialog(
            draft: cachedDraft,
            onResume: () {
              context.push('/excavation/new', extra: cachedDraft);
            },
            onStartFresh: () {
              context.push('/excavation/new');
            },
          ),
        );
      } else {
        context.push('/excavation/new');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final excavationState = ref.watch(excavationProvider);
    final notifier = ref.read(excavationProvider.notifier);
    final list = excavationState.filteredApplications;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP HEADER BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.ink),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Temporary Excavation',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),

            // 2. SCROLLABLE BODY CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    // 4 METRIC CARDS GRID
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              count: excavationState.pendingCount.toString().padLeft(2, '0'),
                              label: 'Pending',
                              countColor: const Color(0xFFEA580C),
                              isSelected: excavationState.selectedStageFilter == TemporaryExcavationStatus.underReview,
                              onTap: () => notifier.toggleStageFilter(TemporaryExcavationStatus.underReview),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: MetricCard(
                              count: excavationState.paymentDueCount.toString().padLeft(2, '0'),
                              label: 'Payment Due',
                              countColor: const Color(0xFF0284C7),
                              isSelected: excavationState.selectedStageFilter == TemporaryExcavationStatus.demandNoteIssued,
                              onTap: () => notifier.toggleStageFilter(TemporaryExcavationStatus.demandNoteIssued),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: MetricCard(
                              count: excavationState.permitReadyCount.toString().padLeft(2, '0'),
                              label: 'Permit Ready',
                              countColor: const Color(0xFF16A34A),
                              isSelected: excavationState.selectedStageFilter == TemporaryExcavationStatus.orderIssued,
                              onTap: () => notifier.toggleStageFilter(TemporaryExcavationStatus.orderIssued),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: MetricCard(
                              count: excavationState.rejectedCount.toString().padLeft(2, '0'),
                              label: 'Rejected',
                              countColor: const Color(0xFFDC2626),
                              isSelected: excavationState.selectedStageFilter == TemporaryExcavationStatus.rejected,
                              onTap: () => notifier.toggleStageFilter(TemporaryExcavationStatus.rejected),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3 FILTER PILLS ROW
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          FilterPill(
                            label: '📄 All (${excavationState.allCount})',
                            isSelected: excavationState.activeTab == ExcavationFilterTab.all,
                            onTap: () => notifier.setFilterTab(ExcavationFilterTab.all),
                          ),
                          const SizedBox(width: 8),
                          FilterPill(
                            label: '✏️ Drafts (${excavationState.draftsCount})',
                            isSelected: excavationState.activeTab == ExcavationFilterTab.drafts,
                            onTap: () => notifier.setFilterTab(ExcavationFilterTab.drafts),
                          ),
                          const SizedBox(width: 8),
                          FilterPill(
                            label: '⚠️ Action Required (${excavationState.actionRequiredCount})',
                            isSelected: excavationState.activeTab == ExcavationFilterTab.actionRequired,
                            onTap: () => notifier.setFilterTab(ExcavationFilterTab.actionRequired),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // SEARCH BAR
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: TextField(
                          onChanged: notifier.setSearchQuery,
                          style: const TextStyle(fontSize: 13, color: AppColors.ink),
                          decoration: const InputDecoration(
                            hintText: 'Search by application no, survey no, mineral, village...',
                            hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // APPLICATIONS LIST
                    if (excavationState.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (list.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No excavation applications found.',
                          style: TextStyle(fontSize: 14, color: AppColors.inkSecondary),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final app = list[index];
                          return _buildApplicationCard(context, ref, app);
                        },
                      ),
                  ],
                ),
              ),
            ),

            // 3. FIXED BOTTOM BUTTON (+ New application)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _handleNewApplication(context, ref),
                  child: const Text(
                    '+ New application',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),

            // 4. BOTTOM NAVIGATION BAR
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFDDE3EE), width: 1)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  _buildBottomNavItem(Icons.home_outlined, 'Home', false, () => context.go('/home')),
                  _buildBottomNavItem(Icons.layers_outlined, 'Projects', false, () => context.go('/organization/projects')),
                  _buildBottomNavItem(Icons.show_chart, 'Activity', false, () => context.go('/activity')),
                  _buildBottomNavItem(Icons.more_horiz, 'More', false, () => context.go('/more')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, WidgetRef ref, TemporaryExcavationApplication app) {
    if (app.isDraft) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 18, color: Color(0xFF1D4ED8)),
                    const SizedBox(width: 8),
                    Text(
                      app.applicationNumber,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Draft',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Mineral: ${app.mineralName.isNotEmpty ? app.mineralName : "Pending"}',
                  style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                ),
                const Spacer(),
                Text(
                  'Volume: ${app.estimatedQuantity.formatted}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Survey No: ${app.surveyNumber.isNotEmpty ? app.surveyNumber : "—"}, ${app.village.isNotEmpty ? app.village : "Pending"}',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT STAGE    Draft Saved',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Step ${(app.lastStepIndex ?? 0) + 1} of 5 completed. Click to resume draft.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Updated: Recently', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                TextButton(
                  onPressed: () => context.push('/excavation/new', extra: app),
                  child: const Text('Resume Application →', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8))),
                ),
              ],
            ),
          ],
        ),
      );
    }

    String statusText;
    Color statusBgColor;
    Color statusTextColor;
    String stageHeader;
    String stageTitle;
    Color stageTitleColor;
    String stageDescription;
    Color stageBgColor;
    Color stageBorderColor;
    Widget actionWidget;

    switch (app.status) {
      case TemporaryExcavationStatus.queryRaised:
        statusText = 'Query raised';
        statusBgColor = const Color(0xFFFEF3C7);
        statusTextColor = const Color(0xFFB45309);
        stageHeader = 'CURRENT STAGE';
        stageTitle = 'Stage 2: Action Required';
        stageTitleColor = const Color(0xFFB45309);
        stageDescription = app.purpose.isNotEmpty
            ? app.purpose
            : 'Revised site plan required with clear demarcation of excavation boundary.';
        stageBgColor = const Color(0xFFFFFBEB);
        stageBorderColor = const Color(0xFFFDE68A);
        actionWidget = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFEF3C7),
            foregroundColor: const Color(0xFFB45309),
            elevation: 0,
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => context.push('/excavation/detail', extra: app.id),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.warning_amber_rounded, size: 15),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Respond to Query',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
        break;

      case TemporaryExcavationStatus.demandNoteIssued:
        statusText = 'Payment Due';
        statusBgColor = const Color(0xFFFEF3C7);
        statusTextColor = const Color(0xFFB45309);
        stageHeader = 'CURRENT STAGE';
        stageTitle = 'Stage 3: Demand Note Issued';
        stageTitleColor = const Color(0xFF059669);
        stageDescription = app.purpose.isNotEmpty
            ? app.purpose
            : 'Royalty calculation complete. Challan payment of ₹2,68,000 due.';
        stageBgColor = const Color(0xFFF0FDF4);
        stageBorderColor = const Color(0xFFBBF7D0);
        final amountText = app.demandNote != null ? app.demandNote!.totalAmount.formatted : '₹2,68,000';
        actionWidget = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF15803D),
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => context.push('/excavation/pay', extra: {
            'title': 'Demand Note Payment',
            'amount': amountText,
            'applicationId': app.applicationNumber,
            'applicantName': app.applicant.fullName,
            'proposedQuantity': app.estimatedQuantity.formatted,
            'applicationFee': amountText,
            'stampDuty': '₹0',
          }),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.credit_card_outlined, size: 15),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Pay Demand Note ($amountText)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
        break;

      case TemporaryExcavationStatus.rejected:
        statusText = 'Rejected';
        statusBgColor = const Color(0xFFFEE2E2);
        statusTextColor = const Color(0xFFDC2626);
        stageHeader = 'REJECTION REASON';
        stageTitle = 'Application Rejected';
        stageTitleColor = const Color(0xFFDC2626);
        stageDescription = '"${app.purpose.isNotEmpty ? app.purpose : 'Proposed excavation site falls within 100m restricted river buffer zone. Tehsil environmental NOC rejected.'}"';
        stageBgColor = const Color(0xFFFEF2F2);
        stageBorderColor = const Color(0xFFFECACA);
        actionWidget = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => context.push('/excavation/new', extra: app),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.edit_outlined, size: 15),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Edit & Re-submit Proposal →',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
        break;

      case TemporaryExcavationStatus.orderIssued:
        statusText = 'Order issued';
        statusBgColor = const Color(0xFFDCFCE7);
        statusTextColor = const Color(0xFF16A34A);
        stageHeader = 'CURRENT STAGE';
        stageTitle = 'Stage 4: Permit Granted';
        stageTitleColor = const Color(0xFF16A34A);
        stageDescription = app.purpose.isNotEmpty
            ? app.purpose
            : 'Official excavation order issued. Transport permits & DigiTP authorized.';
        stageBgColor = const Color(0xFFF0FDF4);
        stageBorderColor = const Color(0xFFBBF7D0);
        final orderNo = app.excavationOrder != null ? app.excavationOrder!.orderNumber : 'OrderNo-04/08/2026-1';
        actionWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.description_outlined, size: 14, color: Color(0xFF16A34A)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Permit Ready ($orderNo)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF16A34A)),
                ),
              ),
            ],
          ),
        );
        break;

      case TemporaryExcavationStatus.submitted:
        statusText = 'Submitted';
        statusBgColor = const Color(0xFFEFF6FF);
        statusTextColor = const Color(0xFF1D4ED8);
        stageHeader = 'CURRENT STAGE';
        stageTitle = 'Stage 1: Application Submitted';
        stageTitleColor = const Color(0xFF1D4ED8);
        stageDescription = app.purpose.isNotEmpty
            ? app.purpose
            : 'Application fee of ₹520 paid. Ready for departmental review.';
        stageBgColor = const Color(0xFFF8FAFC);
        stageBorderColor = const Color(0xFFE2E8F0);
        actionWidget = GestureDetector(
          onTap: () => context.push('/excavation/detail', extra: app.id),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'View Details',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8)),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16, color: Color(0xFF1D4ED8)),
            ],
          ),
        );
        break;

      case TemporaryExcavationStatus.underReview:
      default:
        statusText = 'Under review';
        statusBgColor = const Color(0xFFEFF6FF);
        statusTextColor = const Color(0xFF1D4ED8);
        stageHeader = 'CURRENT STAGE';
        stageTitle = 'Stage 2: Under Department Review';
        stageTitleColor = const Color(0xFF1D4ED8);
        stageDescription = app.purpose.isNotEmpty
            ? app.purpose
            : 'Site boundary inspection and verification in progress by Revenue Officer.';
        stageBgColor = const Color(0xFFF8FAFC);
        stageBorderColor = const Color(0xFFE2E8F0);
        actionWidget = GestureDetector(
          onTap: () => context.push('/excavation/detail', extra: app.id),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'View Details',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8)),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16, color: Color(0xFF1D4ED8)),
            ],
          ),
        );
        break;
    }

    return InkWell(
      onTap: () => context.push('/excavation/detail', extra: app.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.description_outlined, size: 18, color: Color(0xFF1D4ED8)),
                  const SizedBox(width: 8),
                  Text(
                    app.applicationNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Mineral: ', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    TextSpan(text: app.mineralName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  ],
                ),
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Volume: ', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                    TextSpan(text: app.estimatedQuantity.formatted, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Survey No: ${app.surveyNumber}, ${app.village}',
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: stageBgColor,
              border: Border.all(color: stageBorderColor, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stageHeader,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      stageTitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: stageTitleColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  stageDescription,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: app.status == TemporaryExcavationStatus.rejected
                        ? const Color(0xFF991B1B)
                        : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Updated: 18/9/2026',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: actionWidget,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFEEF4FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isActive ? const Color(0xFF1241A6) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? const Color(0xFF1241A6) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
