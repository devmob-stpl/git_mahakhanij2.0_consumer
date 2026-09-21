import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_button.dart';

class ConsumerReportsScreen extends StatelessWidget {
  const ConsumerReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Reports & Statements',
      showBackButton: Navigator.canPop(context),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildReportTile(
            context,
            title: 'DigiTP Transit Pass Ledger',
            subtitle: 'Complete list of statutory e-passes for site audits',
            icon: Icons.receipt_long,
          ),
          const SizedBox(height: 12),
          _buildReportTile(
            context,
            title: 'Monthly Sourcing & Consumption Reconciliation',
            subtitle: 'Balance drawdowns vs received volumes by package',
            icon: Icons.bar_chart,
          ),
          const SizedBox(height: 12),
          _buildReportTile(
            context,
            title: 'Royalty & Cess Tax Invoices',
            subtitle: 'GST, District Mineral Foundation (DMF) & TCS receipts',
            icon: Icons.description,
          ),
        ],
      ),
    );
  }

  Widget _buildReportTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary700, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.primary700),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading $title (PDF)...')),
              );
            },
          ),
        ],
      ),
    );
  }
}
