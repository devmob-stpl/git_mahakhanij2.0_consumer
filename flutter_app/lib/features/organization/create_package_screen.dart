import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/project.dart';
import '../../domain/package.dart';
import '../../domain/common.dart';
import '../../domain/organization.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../providers/operating_context_provider.dart';

class CreatePackageScreen extends ConsumerStatefulWidget {
  final Project? project;

  const CreatePackageScreen({super.key, this.project});

  @override
  ConsumerState<CreatePackageScreen> createState() => _CreatePackageScreenState();
}

class _CreatePackageScreenState extends ConsumerState<CreatePackageScreen> {
  final _nameController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _talukaController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();

  String _category = 'RURAL';
  String? _selectedSupervisorCode;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _talukaController.text = widget.project!.location.taluka;
      _districtController.text = widget.project!.location.district;
      _pincodeController.text = widget.project!.location.pincode;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _line1Controller.dispose();
    _cityController.dispose();
    _talukaController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a package name')),
      );
      return;
    }

    final opState = ref.read(operatingContextProvider);
    final targetProject = widget.project ?? opState.activeProject ?? opState.projects.first;

    final supervisors = opState.supervisors;
    SupervisorInfo? chosenSupervisor;
    if (_selectedSupervisorCode != null) {
      try {
        chosenSupervisor = supervisors.firstWhere((s) => s.employeeCode == _selectedSupervisorCode);
      } catch (_) {}
    }

    final newPkg = Package(
      id: 'pkg-${DateTime.now().millisecondsSinceEpoch}',
      projectId: targetProject.id,
      organizationId: targetProject.organizationId,
      code: 'PKG-${targetProject.id.replaceAll('proj-', '')}-${(100 + DateTime.now().millisecond)}',
      name: _nameController.text.trim(),
      siteAddress: Address(
        line1: _line1Controller.text.trim().isNotEmpty ? _line1Controller.text.trim() : 'Project Site Works',
        taluka: _talukaController.text.trim().isNotEmpty ? _talukaController.text.trim() : targetProject.location.taluka,
        district: _districtController.text.trim().isNotEmpty ? _districtController.text.trim() : targetProject.location.district,
        state: 'Maharashtra',
        pincode: _pincodeController.text.trim().isNotEmpty ? _pincodeController.text.trim() : '411001',
      ),
      siteGeo: targetProject.geo ?? const GeoPoint(latitude: 18.5204, longitude: 73.8567),
      status: 'ACTIVE',
      startDate: DateTime.now().toIso8601String().split('T')[0],
      supervisor: chosenSupervisor,
    );

    ref.read(organizationRepositoryProvider).createPackage(newPkg);
    ref.read(operatingContextProvider.notifier).refresh();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Package "${newPkg.name}" created successfully!')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final opState = ref.watch(operatingContextProvider);
    final supervisors = opState.supervisors;

    return AppScaffold(
      title: 'Create Package',
      showBackButton: true,
      bottomActionButton: AppButton(
        label: 'Save Package',
        onPressed: _handleSubmit,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary700, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Package Work Site', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                        SizedBox(height: 2),
                        Text('Assign supervisor and specify site jurisdiction for material gate receipts.', style: TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            AppTextField(
              label: 'Package Name *',
              controller: _nameController,
              hint: 'e.g. Package A - North Viaduct & Earthworks',
            ),
            const SizedBox(height: 14),

            // Jurisdiction Area Classification
            const Text('Area Classification', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _category = 'RURAL'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _category == 'RURAL' ? const Color(0xFFEFF6FF) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _category == 'RURAL' ? AppColors.primary700 : AppColors.line),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.landscape_outlined, size: 18, color: _category == 'RURAL' ? AppColors.primary700 : AppColors.inkSecondary),
                          const SizedBox(width: 6),
                          Text('Rural (Gram Panchayat)', style: TextStyle(fontSize: 12, fontWeight: _category == 'RURAL' ? FontWeight.w700 : FontWeight.w500, color: _category == 'RURAL' ? AppColors.primary700 : AppColors.ink)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _category = 'URBAN'),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _category == 'URBAN' ? const Color(0xFFEFF6FF) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _category == 'URBAN' ? AppColors.primary700 : AppColors.line),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_city, size: 18, color: _category == 'URBAN' ? AppColors.primary700 : AppColors.inkSecondary),
                          const SizedBox(width: 6),
                          Text('Urban (Municipal Corp)', style: TextStyle(fontSize: 12, fontWeight: _category == 'URBAN' ? FontWeight.w700 : FontWeight.w500, color: _category == 'URBAN' ? AppColors.primary700 : AppColors.ink)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            AppTextField(
              label: 'District *',
              controller: _districtController,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: _category == 'URBAN' ? 'City / Corporation' : 'Taluka *',
                    controller: _talukaController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: _category == 'URBAN' ? 'Zone / Division' : 'Village Name',
                    controller: _cityController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            AppTextField(
              label: 'Site Address / Highway Chainage (KM) *',
              controller: _line1Controller,
              hint: 'e.g. Chainage KM 42+200 to 58+400',
            ),
            const SizedBox(height: 14),

            AppTextField(
              label: 'PIN Code *',
              controller: _pincodeController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Assign Supervisor
            const Text('Assign Site Supervisor', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedSupervisorCode,
              decoration: const InputDecoration(
                hintText: 'Choose an authorized supervisor',
              ),
              items: supervisors.map<DropdownMenuItem<String>>((s) {
                return DropdownMenuItem<String>(
                  value: s.employeeCode.toString(),
                  child: Text('${s.name} (${s.mobileNumber})'),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedSupervisorCode = v),
            ),
          ],
        ),
      ),
    );
  }
}
