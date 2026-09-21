import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/common.dart';
import '../../domain/project.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_button.dart';
import '../../providers/session_provider.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../providers/operating_context_provider.dart';

class ConsumerProjectRegistrationScreen extends ConsumerStatefulWidget {
  const ConsumerProjectRegistrationScreen({super.key});

  @override
  ConsumerState<ConsumerProjectRegistrationScreen> createState() => _ConsumerProjectRegistrationScreenState();
}

class _ConsumerProjectRegistrationScreenState extends ConsumerState<ConsumerProjectRegistrationScreen> {
  final _nameController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _pincodeController = TextEditingController(text: '411045');

  String _district = 'Pune';
  String _taluka = 'Haveli';
  String _category = 'RURAL'; // 'RURAL' | 'URBAN'
  String _villageOrCity = 'Baner';
  bool _isLoading = false;

  void _handleSubmit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter site name (e.g. My Residence Construction)')),
      );
      return;
    }
    if (_line1Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final orgRepo = ref.read(organizationRepositoryProvider);
    final opNotifier = ref.read(operatingContextProvider.notifier);

    final curUser = ref.read(sessionProvider).currentUser;
    final newProj = Project(
      id: 'cons-site-${DateTime.now().millisecondsSinceEpoch}',
      organizationId: curUser?.id ?? 'user-con-001',
      name: _nameController.text.trim(),
      code: 'SITE-${(1000 + DateTime.now().millisecond).toString()}',
      description: 'Private Consumer Delivery Site',
      status: 'ACTIVE',
      startDate: DateTime.now().toIso8601String().split('T')[0],
      location: Address(
        line1: _line1Controller.text.trim(),
        village: _villageOrCity,
        taluka: _taluka,
        district: _district,
        pincode: _pincodeController.text.trim(),
      ),
    );

    await orgRepo.createProject(newProj);
    opNotifier.selectProject(newProj);

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Private delivery site registered!')),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _line1Controller.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Register project',
      showBackButton: true,
      bottomActionButton: AppButton(
        label: 'Save and activate project',
        isLoading: _isLoading,
        onPressed: _handleSubmit,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Site Identification',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Site / Plot Name *',
              controller: _nameController,
              hint: 'e.g. Deshmukh Residence Villa',
              isRequired: true,
            ),
            const SizedBox(height: 16),
            const Text(
              'Location & Delivery Destination',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Plot Address / Landmark *',
              controller: _line1Controller,
              hint: 'e.g. Plot No. 42, Green Meadows',
              isRequired: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.my_location, color: AppColors.primary700),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coordinates marked on plot map.')),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('District *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _district,
                        decoration: const InputDecoration(),
                        items: const [
                          DropdownMenuItem(value: 'Pune', child: Text('Pune')),
                          DropdownMenuItem(value: 'Mumbai Suburban', child: Text('Mumbai Sub')),
                          DropdownMenuItem(value: 'Thane', child: Text('Thane')),
                          DropdownMenuItem(value: 'Nagpur', child: Text('Nagpur')),
                          DropdownMenuItem(value: 'Nashik', child: Text('Nashik')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _district = val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Taluka *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _taluka,
                        decoration: const InputDecoration(),
                        items: const [
                          DropdownMenuItem(value: 'Haveli', child: Text('Haveli')),
                          DropdownMenuItem(value: 'Maval', child: Text('Maval')),
                          DropdownMenuItem(value: 'Mulshi', child: Text('Mulshi')),
                          DropdownMenuItem(value: 'Thane', child: Text('Thane')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _taluka = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Rural (Village)'),
                    value: 'RURAL',
                    groupValue: _category,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _category = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Urban (City)'),
                    value: 'URBAN',
                    groupValue: _category,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _category = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AppTextField(
              label: _category == 'RURAL' ? 'Village Name *' : 'City Area *',
              initialValue: _villageOrCity,
              onChanged: (v) => _villageOrCity = v,
              isRequired: true,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'PIN Code *',
              controller: _pincodeController,
              keyboardType: TextInputType.number,
              isRequired: true,
            ),
          ],
        ),
      ),
    );
  }
}
