import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/project.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_button.dart';

class ConsumerProjectDetailsScreen extends StatelessWidget {
  final Project project;

  const ConsumerProjectDetailsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: project.name,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        project.code,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary700),
                      ),
                      const AppBadge(label: 'Verified Site', variant: AppBadgeVariant.success),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    project.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Delivery Site Address', style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                  const SizedBox(height: 2),
                  Text(
                    project.location.formattedAddress,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Procure Minerals for this Site',
              onPressed: () => context.push('/minerals'),
            ),
          ],
        ),
      ),
    );
  }
}
