import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/inventory.dart';
import '../../rules/inventory_rules.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../providers/inventory_provider.dart';

class RecordConsumptionDialog extends ConsumerStatefulWidget {
  final InventoryBalance balance;

  const RecordConsumptionDialog({super.key, required this.balance});

  @override
  ConsumerState<RecordConsumptionDialog> createState() => _RecordConsumptionDialogState();
}

class _RecordConsumptionDialogState extends ConsumerState<RecordConsumptionDialog> {
  final _qtyController = TextEditingController();
  final _purposeController = TextEditingController();
  bool _isLoading = false;

  void _handleSubmit() async {
    final qty = double.tryParse(_qtyController.text) ?? 0.0;
    final check = InventoryRules.canRecordConsumption(
      balance: widget.balance,
      requestedValue: qty,
    );

    if (!check.isAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(check.reason ?? 'Invalid quantity requested')),
      );
      return;
    }

    if (_purposeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please state the engineering purpose for drawdown')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await ref.read(inventoryProvider.notifier).recordConsumption(
      balanceId: widget.balance.id,
      packageId: widget.balance.packageId,
      quantityValue: qty,
      purpose: _purposeController.text.trim(),
      userId: 'user-sup-1',
      userName: 'S. R. Pawar (Supervisor)',
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Statutory on-site consumption drawdown logged successfully!')),
        );
      }
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record Consumption — ${widget.balance.mineralName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
            const SizedBox(height: 4),
            Text(
              'Available on-site balance: ${widget.balance.currentAvailableBalance.formatted}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary700),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Drawdown Volume (${widget.balance.currentAvailableBalance.unit}) *',
              controller: _qtyController,
              keyboardType: TextInputType.number,
              hint: 'e.g. 5.0',
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Engineering Purpose / Structure Activity *',
              controller: _purposeController,
              maxLines: 2,
              hint: 'e.g. Concrete mix batching for Pier P14',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Record',
                    isLoading: _isLoading,
                    onPressed: _handleSubmit,
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
