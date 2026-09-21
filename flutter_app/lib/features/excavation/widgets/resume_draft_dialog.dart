import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/temporary_excavation.dart';
import '../../../shared/widgets/app_button.dart';

class ResumeDraftDialog extends StatelessWidget {
  final TemporaryExcavationApplication draft;
  final VoidCallback onResume;
  final VoidCallback onStartFresh;

  const ResumeDraftDialog({
    super.key,
    required this.draft,
    required this.onResume,
    required this.onStartFresh,
  });

  @override
  Widget build(BuildContext context) {
    final stepNames = [
      'Applicant Details',
      'Excavation Details',
      'Quarry & Location',
      'Compliance Documents',
      'Review & Payment',
    ];
    final stepIndex = draft.lastStepIndex ?? 0;
    final stepName = stepIndex < stepNames.length ? stepNames[stepIndex] : 'In-Progress';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.history_edu, color: AppColors.primary700, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Unfinished Draft Found',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'You have an incomplete statutory application saved at Step ${stepIndex + 1}: $stepName.',
              style: const TextStyle(fontSize: 14, color: AppColors.inkSecondary, height: 1.4),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSunken,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mineral: ${draft.mineralName.isNotEmpty ? draft.mineralName : "Not specified"}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Location: ${draft.village.isNotEmpty ? "${draft.village}, ${draft.surveyNumber}" : "Not filled yet"}',
                    style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Start Fresh',
                    variant: AppButtonVariant.outline,
                    onPressed: () {
                      Navigator.pop(context);
                      onStartFresh();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Resume Draft →',
                    onPressed: () {
                      Navigator.pop(context);
                      onResume();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
