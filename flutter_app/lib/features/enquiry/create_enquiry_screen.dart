import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/enquiry.dart';
import '../../domain/common.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import 'enquiries_screen.dart';

class CreateEnquiryScreen extends ConsumerStatefulWidget {
  const CreateEnquiryScreen({super.key});

  @override
  ConsumerState<CreateEnquiryScreen> createState() => _CreateEnquiryScreenState();
}

class _CreateEnquiryScreenState extends ConsumerState<CreateEnquiryScreen> {
  final _qtyController = TextEditingController(text: '50');
  final _contactController = TextEditingController(text: 'Rohit Sanghavi');
  final _phoneController = TextEditingController(text: '9822014576');
  final _remarksController = TextEditingController();

  String _mineralId = 'min-3';
  String _mineralName = 'Stone Aggregate 20mm';
  final String _stockPointName = 'Talegaon Government Minor Mineral Depot';

  @override
  void dispose() {
    _qtyController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final qty = double.tryParse(_qtyController.text) ?? 50.0;
    final newEnq = Enquiry(
      id: 'enq-${DateTime.now().millisecondsSinceEpoch}',
      enquiryNumber: 'ENQ-2024-${(1000 + DateTime.now().millisecond).toString()}',
      raisedByUserId: 'user-org-001',
      organizationId: 'org-001',
      stockPointId: 'sp-1',
      stockPointName: _stockPointName,
      mineralId: _mineralId,
      mineralName: _mineralName,
      requiredQuantity: Quantity(value: qty, unit: 'BRASS'),
      requiredByDate: DateTime.now().add(const Duration(days: 14)).toIso8601String().split('T')[0],
      contactName: _contactController.text.trim(),
      contactMobileNumber: _phoneController.text.trim(),
      remarks: _remarksController.text.trim(),
      status: EnquiryStatus.submitted,
      createdAt: DateTime.now().toIso8601String(),
    );

    ref.read(enquiriesProvider.notifier).update((state) => [newEnq, ...state]);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enquiry submitted to quarry operator!')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Raise Mineral Enquiry',
      showBackButton: true,
      bottomActionButton: AppButton(
        label: 'Submit Enquiry for Quotation',
        onPressed: _handleSubmit,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mineral Specification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _mineralId,
              decoration: const InputDecoration(labelText: 'Mineral Type *'),
              items: const [
                DropdownMenuItem(value: 'min-3', child: Text('Stone Aggregate 20mm')),
                DropdownMenuItem(value: 'min-1', child: Text('Natural River Sand')),
                DropdownMenuItem(value: 'min-2', child: Text('Manufactured Sand (M-Sand)')),
                DropdownMenuItem(value: 'min-4', child: Text('Murrum / Soil Filling')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _mineralId = v;
                    if (v == 'min-3') _mineralName = 'Stone Aggregate 20mm';
                    if (v == 'min-1') _mineralName = 'Natural River Sand';
                    if (v == 'min-2') _mineralName = 'Manufactured Sand (M-Sand)';
                    if (v == 'min-4') _mineralName = 'Murrum / Soil Filling';
                  });
                }
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Required Quantity (Brass) *',
              controller: _qtyController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Contact Person Name *',
              controller: _contactController,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Mobile Number *',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Delivery Site Requirements / Remarks',
              controller: _remarksController,
              maxLines: 2,
              hint: 'e.g. Need delivery via 10-wheeler tipper trucks',
            ),
          ],
        ),
      ),
    );
  }
}
