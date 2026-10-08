import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/common.dart';
import '../../domain/project.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/location_dropdown_section.dart';
import '../../providers/operating_context_provider.dart';
import '../../providers/session_provider.dart';
import '../../data/repositories/consumer_project_repository.dart';
import '../../providers/consumer_projects_provider.dart';
import '../../shared/widgets/map_location_picker_modal.dart';
import 'package:mahakhanij_consumer/l10n/app_localizations.dart';


const List<Map<String, String>> kGovtDepartments = [
  {'value': 'Public Works Department (PWD)', 'label': 'Public Works Department (PWD)'},
  {'value': 'Water Resources Department (WRD / Irrigation)', 'label': 'Water Resources Department (WRD / Irrigation)'},
  {'value': 'Maharashtra State Road Development Corp (MSRDC)', 'label': 'MSRDC'},
  {'value': 'Zilla Parishad (ZP Infrastructure)', 'label': 'Zilla Parishad (ZP)'},
  {'value': 'CIDCO / MIDC', 'label': 'CIDCO / MIDC'},
  {'value': 'Maha-Metro / Railways', 'label': 'Maha-Metro / Railways'},
  {'value': 'National Highways Authority of India (NHAI)', 'label': 'NHAI'},
  {'value': 'Forest Department', 'label': 'Forest Department'},
  {'value': 'OTHER', 'label': 'Other Government Department'},
];

const Map<String, List<String>> kUrbanCitiesByDistrict = {
  'Pune': ['Pune City (PMC)', 'Pimpri-Chinchwad (PCMC)', 'Hinjawadi IT Corridor', 'Pune Cantonment', 'Khadki', 'Baramati Urban'],
  'Mumbai City': ['Mumbai City', 'Colaba', 'Nariman Point', 'Dadar', 'Worli', 'Fort'],
  'Mumbai Suburban': ['Mumbai Suburban', 'Andheri', 'Bandra', 'Kurla', 'Borivali', 'Malad', 'Powai'],
  'Thane': ['Thane City (TMC)', 'Navi Mumbai (NMMC)', 'Kalyan-Dombivli (KDMC)', 'Mira-Bhayandar', 'Ulhasnagar', 'Bhiwandi'],
  'Nagpur': ['Nagpur City (NMC)', 'Kamptee Urban', 'Hingna Industrial Hub', 'Nagpur West Urban', 'Katol Urban'],
  'Nashik': ['Nashik City (NMC)', 'Deolali Cantonment', 'Malegaon Urban', 'Sinnar Industrial Area', 'Ozar Urban'],
  'Chhatrapati Sambhajinagar': ['Chhatrapati Sambhajinagar City (CSMC)', 'Waluj MIDC Area', 'Shendra Industrial Town', 'Paithan Urban'],
  'Ahilyanagar': ['Ahilyanagar City (AMC)', 'Shirdi Urban Area', 'Sangamner City', 'Kopargaon Urban'],
};

const List<String> kDefaultUrbanCities = [
  'City Municipal Corporation',
  'Industrial Town / MIDC Hub',
  'Cantonment / Smart City Zone',
  'Suburban Town Council',
];

const Map<String, List<String>> kTalukasByDistrict = {
  'Pune': ['Haveli', 'Maval', 'Mulshi', 'Shirur', 'Khed', 'Baramati', 'Daund', 'Purandar'],
  'Mumbai City': ['Mumbai City'],
  'Mumbai Suburban': ['Andheri', 'Borivali', 'Kurla'],
  'Thane': ['Thane', 'Kalyan', 'Bhiwandi', 'Ulhasnagar', 'Ambernath'],
  'Nagpur': ['Nagpur Urban', 'Nagpur Rural', 'Kamptee', 'Hingna', 'Katol'],
  'Nashik': ['Nashik', 'Sinnar', 'Niphad', 'Dindori', 'Malegaon'],
  'Chhatrapati Sambhajinagar': ['Chhatrapati Sambhajinagar', 'Paithan', 'Gangapur', 'Vaijapur'],
  'Ahilyanagar': ['Nagar', 'Rahata', 'Sangamner', 'Kopargaon', 'Shrirampur'],
};

const Map<String, List<String>> kVillagesByTaluka = {
  'Haveli': ['Wagholi', 'Kesnand', 'Loni Kalbhor', 'Uruli Kanchan', 'Manjari', 'Shivane'],
  'Maval': ['Talegaon Dabhade', 'Lonavala Rural', 'Kamshet', 'Vadgaon Maval'],
  'Mulshi': ['Pirangut', 'Paud', 'Hinjawadi Gram Panchayat', 'Lavale'],
  'Khed': ['Chakan', 'Rajgurunagar', 'Alandi Rural', 'Mahalunge'],
  'Nagar': ['Vilad', 'Bhalawani', 'Kedgaon Gram Panchayat', 'Nimbodi'],
  'Rahata': ['Shirdi Rural', 'Sakori', 'Pimplas', 'Babhaleshwar'],
};

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _nameController = TextEditingController();
  final _customDepartmentController = TextEditingController();
  final _officeNameController = TextEditingController();
  final _workOrderNoController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _pincodeController = TextEditingController(text: '411001');

  String _projectType = 'PRIVATE'; // 'PRIVATE' | 'GOVERNMENT'
  String _department = 'Public Works Department (PWD)';
  String _category = 'RURAL'; // 'URBAN' | 'RURAL'
  String _district = '';
  String _taluka = '';
  String _city = '';
  String _village = '';

  int? _districtId;
  int? _talukaId;
  int? _censusId;

  double? _latitude;
  double? _longitude;

  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _customDepartmentController.dispose();
    _officeNameController.dispose();
    _workOrderNoController.dispose();
    _line1Controller.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _handleQuickFill() {
    setState(() {
      _nameController.text = 'Maha-Metro Line 3 Interchange Site';
      _projectType = 'GOVERNMENT';
      _department = 'Maha-Metro / Railways';
      _officeNameController.text = 'Pune Metro Rail Project Division (Shivajinagar)';
      _workOrderNoController.text = 'MMRCL/PUN/LINE3/2024-884';
      _line1Controller.text = 'Plot No. 12, Civil Court Metro Interchange, Shivajinagar';
      _district = 'Pune';
      _category = 'URBAN';
      _taluka = 'Haveli';
      _city = 'Pune City (PMC)';
      _pincodeController.text = '411005';
    });
  }

  void _handleSubmit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errEnterProjectName)),
      );
      return;
    }
    if (_projectType == 'GOVERNMENT') {
      final activeDept = _department == 'OTHER' ? _customDepartmentController.text.trim() : _department;
      if (activeDept.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errSelectGovDept)),
        );
        return;
      }
      if (_officeNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errEnterOfficeName)),
        );
        return;
      }
    }
    if (_workOrderNoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errEnterWorkOrder)),
      );
      return;
    }
    if (_line1Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errEnterSiteAddress)),
      );
      return;
    }

    setState(() => _submitting = true);
    final opNotifier = ref.read(operatingContextProvider.notifier);
    final orgRepo = ref.read(organizationRepositoryProvider);
    final consumerProjectRepo = ref.read(consumerProjectRepositoryProvider);
    final user = ref.read(sessionProvider).currentUser;

    final userId = user?.id != null ? (int.tryParse(user!.id) ?? 44434) : 44434;

    final bool isTown = _category == 'URBAN';
    final Map<String, dynamic> payload = {
      'id': 0,
      'projectCode': _workOrderNoController.text.trim(),
      'projectName': _nameController.text.trim(),
      'projectAddress': _line1Controller.text.trim(),
      'latitude': _latitude ?? 0.0,
      'longitude': _longitude ?? 0.0,
      'stateId': 1,
      'divisionId': 0,
      'districtId': _districtId ?? 0,
      'talukaId': _talukaId ?? 0,
      'censusId': _censusId ?? 0,
      'projectType': _projectType == 'GOVERNMENT' ? 1 : 0,
      'isTown': isTown,
      'consumerId': userId,
    };



    final response = await consumerProjectRepo.saveUpdateProject(payload);

    if (!mounted) return;

    if (response.isSuccess) {
      final effectiveDept = _projectType == 'GOVERNMENT'
          ? (_department == 'OTHER' ? _customDepartmentController.text.trim() : _department)
          : null;

      final newProj = Project(
        id: 'proj-${DateTime.now().millisecondsSinceEpoch}',
        organizationId: user?.organizationId ?? 'org-001',
        name: _nameController.text.trim(),
        code: _workOrderNoController.text.trim(),
        description: _projectType == 'GOVERNMENT' ? 'Govt Project ($effectiveDept) · WO: ${_workOrderNoController.text.trim()}' : 'Private Infrastructure Project',
        projectType: _projectType,
        department: effectiveDept,
        officeName: _projectType == 'GOVERNMENT' ? _officeNameController.text.trim() : null,
        workOrderNumber: _workOrderNoController.text.trim(),
        category: _category,
        city: _category == 'URBAN' ? _city : null,
        village: _category == 'RURAL' ? _village : null,
        status: 'ACTIVE',
        startDate: DateTime.now().toIso8601String().split('T')[0],
        location: Address(
          line1: _line1Controller.text.trim(),
          village: _category == 'RURAL' ? _village : _city,
          taluka: _taluka,
          district: _district,
          state: 'Maharashtra',
          pincode: _pincodeController.text.trim(),
        ),
        geo: (_latitude != null && _longitude != null)
            ? GeoPoint(latitude: _latitude!, longitude: _longitude!)
            : const GeoPoint(latitude: 18.5204, longitude: 73.8567),
      );

      await orgRepo.createProject(newProj);
      opNotifier.selectProject(newProj);
      ref.read(consumerProjectsProvider.notifier).refresh();

      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.statusMessage.isNotEmpty ? response.statusMessage : 'Project registered successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.statusMessage.isNotEmpty ? response.statusMessage : 'Failed to register project.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create project',
      showBackButton: true,
      bottomActionButton: AppButton(
        label: 'Create project',
        isLoading: _submitting,
        onPressed: _handleSubmit,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner (Identical to React prototype)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.line),
                  bottom: BorderSide(color: AppColors.line),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.business, color: AppColors.primary700, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PROJECT REGISTRATION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.inkMuted,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Create project',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Register your project to group packages, order minerals, and track work orders seamlessly.',
                          style: TextStyle(fontSize: 13, color: AppColors.inkSecondary, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Form Container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.line),
                  bottom: BorderSide(color: AppColors.line),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1) Project Name
                  AppTextField(
                    label: 'Project name *',
                    controller: _nameController,
                    hint: 'e.g. Patel Quarry Site / Highway Package 2',
                  ),
                  const SizedBox(height: 16),

                  // 2) Project Type: Private vs Government
                  const Text('Project type *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _projectType = 'PRIVATE'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: _projectType == 'PRIVATE' ? const Color(0xFFEFF6FF) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _projectType == 'PRIVATE' ? AppColors.primary700 : AppColors.line,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.business, size: 16, color: _projectType == 'PRIVATE' ? AppColors.primary700 : AppColors.inkSecondary),
                                const SizedBox(width: 8),
                                Text(
                                  'Private',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _projectType == 'PRIVATE' ? FontWeight.w700 : FontWeight.w600,
                                    color: _projectType == 'PRIVATE' ? AppColors.primary700 : AppColors.inkSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _projectType = 'GOVERNMENT'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: _projectType == 'GOVERNMENT' ? const Color(0xFFEFF6FF) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _projectType == 'GOVERNMENT' ? AppColors.primary700 : AppColors.line,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.account_balance, size: 16, color: _projectType == 'GOVERNMENT' ? AppColors.primary700 : AppColors.inkSecondary),
                                const SizedBox(width: 8),
                                Text(
                                  'Government',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _projectType == 'GOVERNMENT' ? FontWeight.w700 : FontWeight.w600,
                                    color: _projectType == 'GOVERNMENT' ? AppColors.primary700 : AppColors.inkSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 3) Department (Only if Government is chosen)
                  if (_projectType == 'GOVERNMENT') ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Department *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _department,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            items: kGovtDepartments.map((dept) {
                              return DropdownMenuItem(
                                value: dept['value']!,
                                child: Text(dept['label']!, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _department = v);
                            },
                          ),
                          if (_department == 'OTHER') ...[
                            const SizedBox(height: 12),
                            AppTextField(
                              label: 'Specify Department Name *',
                              controller: _customDepartmentController,
                              hint: 'e.g. Maharashtra Metro Rail Corporation',
                            ),
                          ],
                          const SizedBox(height: 12),
                          AppTextField(
                            label: 'Office name *',
                            controller: _officeNameController,
                            hint: 'e.g. Pune Metro Project Division / PWD Executive Office',
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  // 4) Work Order No
                  AppTextField(
                    label: 'Work order no *',
                    controller: _workOrderNoController,
                    hint: 'e.g. CE/PWD/2026/WO-4819',
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppColors.line),
                  const SizedBox(height: 16),

                  // Location & Jurisdiction Section
                  const Text(
                    'SITE LOCATION & JURISDICTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 12),

                  LocationDropdownSection(
                    initialCategory: _category,
                    initialDistrict: _district,
                    initialTaluka: _taluka,
                    initialVillageCity: _category == 'URBAN' ? _city : _village,
                    showCategorySelector: true,
                    onChanged: (data) {
                      setState(() {
                        _district = data.districtName;
                        _taluka = data.talukaName;
                        _category = data.category ?? 'URBAN';
                        _districtId = data.district?.id;
                        _talukaId = data.taluka?.id;
                        _censusId = data.villageCity?.id;
                        if (data.category == 'URBAN') {
                          _city = data.villageCityName;
                        } else {
                          _village = data.villageCityName;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  // Site Address with Location Map Pin Icon
                  AppTextField(
                    label: 'Site address / Landmark *',
                    controller: _line1Controller,
                    hint: 'Plot No., Survey No., corridor chainage or street address',
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
                          village: _category == 'URBAN' ? _city : _village,
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
                  const SizedBox(height: 14),

                  // PIN Code
                  AppTextField(
                    label: 'PIN code *',
                    controller: _pincodeController,
                    keyboardType: TextInputType.number,
                    hint: '411001',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
