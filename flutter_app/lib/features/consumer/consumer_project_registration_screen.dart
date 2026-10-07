import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/common.dart';
import '../../domain/project.dart';
import '../../providers/consumer_projects_provider.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_button.dart';
import '../../providers/session_provider.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/location_dropdown_section.dart';
import '../../providers/operating_context_provider.dart';
import '../../data/repositories/consumer_project_repository.dart';
import '../../shared/widgets/map_location_picker_modal.dart';

class ConsumerProjectRegistrationScreen extends ConsumerStatefulWidget {
  final Project? existingProject;

  const ConsumerProjectRegistrationScreen({
    super.key,
    this.existingProject,
  });

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

  int? _districtId;
  int? _talukaId;
  int? _censusId;

  double? _latitude;
  double? _longitude;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingProject != null) {
      _nameController.text = widget.existingProject!.name;
      _line1Controller.text = widget.existingProject!.location?.line1 ?? '';
      _pincodeController.text = widget.existingProject!.location?.pincode ?? '411045';
      if (widget.existingProject!.geo != null) {
        _latitude = widget.existingProject!.geo!.latitude;
        _longitude = widget.existingProject!.geo!.longitude;
      }
    }
  }

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
    final consumerProjectRepo = ref.read(consumerProjectRepositoryProvider);
    final opNotifier = ref.read(operatingContextProvider.notifier);

    final curUser = ref.read(sessionProvider).currentUser;
    final userId = curUser?.id != null ? (int.tryParse(curUser!.id) ?? 44434) : 44434;
    final generatedCode = widget.existingProject?.code ?? 'SITE-${(1000 + DateTime.now().millisecond).toString()}';
    final int projectIdToSave = widget.existingProject != null
        ? (int.tryParse(widget.existingProject!.id) ?? 0)
        : 0;
    final bool isTown = _category == 'URBAN';

    final Map<String, dynamic> payload = {
      'id': projectIdToSave,
      'projectCode': generatedCode,
      'projectName': _nameController.text.trim(),
      'projectAddress': _line1Controller.text.trim(),
      'latitude': _latitude ?? 0.0,
      'longitude': _longitude ?? 0.0,
      'stateId': 1,
      'divisionId': 0,
      'districtId': _districtId ?? 0,
      'talukaId': _talukaId ?? 0,
      'censusId': _censusId ?? 0,
      'projectType': 0,
      'isTown': isTown,
      'consumerId': userId,
    };



    final response = await consumerProjectRepo.saveUpdateProject(payload);

    if (!mounted) return;

    if (response.isSuccess) {
      final newProj = Project(
        id: 'cons-site-${DateTime.now().millisecondsSinceEpoch}',
        organizationId: curUser?.id ?? 'user-con-001',
        name: _nameController.text.trim(),
        code: generatedCode,
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
        geo: (_latitude != null && _longitude != null)
            ? GeoPoint(latitude: _latitude!, longitude: _longitude!)
            : null,
      );

      await orgRepo.createProject(newProj);
      opNotifier.selectProject(newProj);
      ref.read(consumerProjectsProvider.notifier).refresh();

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.statusMessage.isNotEmpty ? response.statusMessage : 'Private delivery site registered!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.statusMessage.isNotEmpty ? response.statusMessage : 'Failed to register site.'),
          backgroundColor: Colors.red,
        ),
      );
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
              label: 'Site / Plot Name',
              controller: _nameController,
              hint: 'e.g. Deshmukh Residence Villa',
              isRequired: true,
            ),
            const SizedBox(height: 16),
            const Text(
              'Location & Delivery Destination',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),

            const SizedBox(height: 14),
            LocationDropdownSection(
              initialCategory: _category,
              initialDistrict: _district,
              initialTaluka: _taluka,
              initialVillageCity: _villageOrCity,
              showCategorySelector: true,
              onChanged: (data) {
                setState(() {
                  _district = data.districtName;
                  _taluka = data.talukaName;
                  _category = data.category ?? 'URBAN';
                  _villageOrCity = data.villageCityName;
                  _districtId = data.district?.id;
                  _talukaId = data.taluka?.id;
                  _censusId = data.villageCity?.id;
                });
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Plot Address / Landmark',
              controller: _line1Controller,
              hint: 'e.g. Plot No. 42, Green Meadows',
              isRequired: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.map_outlined, color: AppColors.primary700, size: 22),
                tooltip: 'Select on Google Maps',
                onPressed: () async {
                  final result = await MapLocationPickerModal.show(
                    context,
                    initialLat: _latitude ?? 18.520430,
                    initialLng: _longitude ?? 73.856740,
                    initialAddress: _line1Controller.text.trim(),
                    district: _district,
                    taluka: _taluka,
                    village: _villageOrCity,
                  );

                  if (result != null) {
                    if (!context.mounted) return;
                    setState(() {
                      _latitude = result.latitude;
                      _longitude = result.longitude;
                      _line1Controller.text = result.address;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Coordinates selected: (${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)})'),
                      ),
                    );
                  }

                },
              ),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'PIN Code',
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
