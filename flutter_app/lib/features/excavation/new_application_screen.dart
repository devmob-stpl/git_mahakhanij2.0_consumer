import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/common.dart';
import '../../domain/temporary_excavation.dart';
import '../../rules/excavation_rules.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../providers/excavation_provider.dart';
import '../../providers/session_provider.dart';
import 'widgets/application_step_widgets.dart';

class NewApplicationScreen extends ConsumerStatefulWidget {
  final TemporaryExcavationApplication? initialDraft;

  const NewApplicationScreen({super.key, this.initialDraft});

  @override
  ConsumerState<NewApplicationScreen> createState() => _NewApplicationScreenState();
}

class _NewApplicationScreenState extends ConsumerState<NewApplicationScreen> {
  int _currentStep = 0;
  bool _isSaving = false;

  // Step 1 Controllers (Applicant)
  late final TextEditingController _fullNameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _landlineController;
  late final TextEditingController _emailController;
  late final TextEditingController _districtController;
  late final TextEditingController _pincodeController;
  late final TextEditingController _addressController;
  late final TextEditingController _panController;
  late final TextEditingController _aadhaarController;
  late final TextEditingController _gstController;

  // Step 2 Controllers & State (Excavation)
  String _applicationType = 'QUARRY_TEMPORARY_PLOT';
  String _proposalLevel = 'DISTRICT_LEVEL';
  String _mineralId = 'min-3';
  String _mineralName = 'Stone Aggregate 20mm';
  late final TextEditingController _quantityController;
  late final TextEditingController _liftingPeriodController;
  late final TextEditingController _reasonController;

  // Self consumption project state
  String _projectType = 'GOVERNMENT';
  late final TextEditingController _departmentController;
  late final TextEditingController _officeController;
  late final TextEditingController _workOrderController;
  late final TextEditingController _projectCodeController;
  late final TextEditingController _projectNameController;
  late final TextEditingController _projectAddressController;
  late final TextEditingController _projectLatController;
  late final TextEditingController _projectLngController;
  String _zeroRoyaltyScheme = 'NO';

  // Step 3 Controllers & State (Location)
  String _category = 'RURAL';
  late final TextEditingController _plotLocationController;
  late final TextEditingController _locDistrictController;
  late final TextEditingController _locTalukaController;
  late final TextEditingController _locVillageController;
  late final TextEditingController _surveyInputController;
  List<SurveyEntry> _surveyEntries = [];
  late final TextEditingController _totalAreaController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  String _demandNoteOffice = 'DMO_PUNE';
  String _grasOfficeName = 'GRAS_PUNE';

  // Step 4 State (Documents)
  List<ApplicationDocument> _attachedDocs = [
    ApplicationDocument(
      id: 'doc-pan',
      kind: 'PAN_CARD',
      fileName: 'applicant-pan.pdf',
      documentType: 'PAN Card Document',
      uploadedAt: DateTime.now().toIso8601String(),
    ),
  ];

  // Step 5 State (Review)
  bool _declarationAccepted = false;
  Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    final d = widget.initialDraft;
    _currentStep = d?.lastStepIndex ?? 0;

    _fullNameController = TextEditingController(text: d?.applicant.fullName.isNotEmpty == true ? d!.applicant.fullName : 'Rohit Sanghavi');
    _mobileController = TextEditingController(text: d?.applicant.mobileNumber.isNotEmpty == true ? d!.applicant.mobileNumber : '9822014576');
    _landlineController = TextEditingController(text: d?.applicant.landlineNumber ?? '');
    _emailController = TextEditingController(text: d?.applicant.email ?? 'rohit.s@sanghaviinfra.in');
    _districtController = TextEditingController(text: d?.applicant.registeredAddress.district.isNotEmpty == true ? d!.applicant.registeredAddress.district : 'Mumbai Suburban');
    _pincodeController = TextEditingController(text: d?.applicant.registeredAddress.pincode.isNotEmpty == true ? d!.applicant.registeredAddress.pincode : '400070');
    _addressController = TextEditingController(text: d?.applicant.registeredAddress.line1.isNotEmpty == true ? d!.applicant.registeredAddress.line1 : '4th Floor, Sanghavi House, LBS Marg');
    _panController = TextEditingController(text: d?.applicant.panNumber.isNotEmpty == true ? d!.applicant.panNumber : 'AFZPS1234K');
    _aadhaarController = TextEditingController(text: d?.applicant.aadhaarNumber ?? '');
    _gstController = TextEditingController(text: d?.applicant.gstNumber ?? '27ANDPG4491M1Z4');

    if (d != null) {
      _applicationType = d.applicationType;
      _proposalLevel = d.proposalLevel;
      _mineralId = d.mineralId.isNotEmpty ? d.mineralId : _mineralId;
      _mineralName = d.mineralName.isNotEmpty ? d.mineralName : _mineralName;
      _projectType = d.projectType;
      _zeroRoyaltyScheme = d.zeroRoyaltyScheme;
      _category = d.category;
      _demandNoteOffice = d.demandNoteOffice;
      _grasOfficeName = d.grasOfficeName;
      _declarationAccepted = d.declarationAccepted;
      if (d.documents.isNotEmpty) {
        _attachedDocs = List.from(d.documents);
      }
      if (d.surveyEntries.isNotEmpty) {
        _surveyEntries = List.from(d.surveyEntries);
      }
    } else {
      _surveyEntries = [
        const SurveyEntry(
          id: 'survey-1',
          surveyNumber: '42/1B',
          areaInHectares: 0.75,
          sevenTwelveAttached: true,
        ),
      ];
    }

    _quantityController = TextEditingController(text: d != null && d.estimatedQuantity.value > 0 ? d.estimatedQuantity.value.toInt().toString() : '22');
    _liftingPeriodController = TextEditingController(text: d?.liftingPeriodDays.toString() ?? '60');
    _reasonController = TextEditingController(
      text: d?.purpose.isNotEmpty == true
          ? d!.purpose
          : 'Commercial minor mineral extraction from temporary allocated plot for infrastructure project work.',
    );

    _departmentController = TextEditingController(text: d?.departmentName ?? 'Public Works Department');
    _officeController = TextEditingController(text: d?.officeName ?? 'Executive Engineer Pune Division');
    _workOrderController = TextEditingController(text: d?.workOrderNumber ?? 'WO/PWD/2026/894');
    _projectCodeController = TextEditingController(text: d?.projectCode ?? 'PRJ-MUM-NSK-01');
    _projectNameController = TextEditingController(text: d?.projectName ?? 'Mumbai–Nashik Highway Widening');
    _projectAddressController = TextEditingController(text: d?.projectAddress ?? 'Km 12 to Km 48 Highway Stretch');
    _projectLatController = TextEditingController(text: d?.projectLatitude ?? '19.2012');
    _projectLngController = TextEditingController(text: d?.projectLongitude ?? '73.1145');

    _plotLocationController = TextEditingController(text: d?.plotLocationType.isNotEmpty == true ? d!.plotLocationType : '');
    _locDistrictController = TextEditingController(text: d?.siteAddress.district.isNotEmpty == true ? d!.siteAddress.district : 'Mumbai Suburban');
    _locTalukaController = TextEditingController(text: d?.siteAddress.taluka.isNotEmpty == true ? d!.siteAddress.taluka : 'Haveli');
    _locVillageController = TextEditingController(text: d?.village.isNotEmpty == true ? d!.village : 'Wagholi');
    _surveyInputController = TextEditingController(text: d?.surveyNumber.isNotEmpty == true ? d!.surveyNumber : '42/1B');
    _totalAreaController = TextEditingController(text: d?.totalPlotAreaHectare.toString() ?? '0.75');
    _latController = TextEditingController(text: d?.siteGeo.latitude.toString() ?? '18.57900');
    _lngController = TextEditingController(text: d?.siteGeo.longitude.toString() ?? '73.98100');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _landlineController.dispose();
    _emailController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _panController.dispose();
    _aadhaarController.dispose();
    _gstController.dispose();
    _quantityController.dispose();
    _liftingPeriodController.dispose();
    _reasonController.dispose();
    _departmentController.dispose();
    _officeController.dispose();
    _workOrderController.dispose();
    _projectCodeController.dispose();
    _projectNameController.dispose();
    _projectAddressController.dispose();
    _projectLatController.dispose();
    _projectLngController.dispose();
    _plotLocationController.dispose();
    _locDistrictController.dispose();
    _locTalukaController.dispose();
    _locVillageController.dispose();
    _surveyInputController.dispose();
    _totalAreaController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  double get _currentQuantityBrass => double.tryParse(_quantityController.text) ?? 22.0;

  TemporaryExcavationApplication _buildDraftObject() {
    final feeBreakdown = ExcavationRules.calculateApplicationFeeBreakdown(_currentQuantityBrass);
    final lat = double.tryParse(_latController.text) ?? 18.57900;
    final lng = double.tryParse(_lngController.text) ?? 73.98100;
    final areaHa = double.tryParse(_totalAreaController.text) ?? 0.75;
    final liftingDays = int.tryParse(_liftingPeriodController.text) ?? 60;

    return TemporaryExcavationApplication(
      id: widget.initialDraft?.id ?? 'draft-${DateTime.now().millisecondsSinceEpoch}',
      applicationNumber: widget.initialDraft?.applicationNumber ?? 'DRAFT-IN-PROGRESS',
      organizationId: ref.read(sessionProvider).currentUser?.organizationId ?? 'org-001',
      applicant: ApplicantDetails(
        fullName: _fullNameController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        landlineNumber: _landlineController.text.trim().isNotEmpty ? _landlineController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        panNumber: _panController.text.trim(),
        aadhaarNumber: _aadhaarController.text.trim().isNotEmpty ? _aadhaarController.text.trim() : null,
        gstNumber: _gstController.text.trim().isNotEmpty ? _gstController.text.trim() : null,
        registeredAddress: Address(
          line1: _addressController.text.trim(),
          taluka: _locTalukaController.text.trim(),
          district: _districtController.text.trim(),
          pincode: _pincodeController.text.trim(),
        ),
      ),
      applicationType: _applicationType,
      proposalLevel: _proposalLevel,
      mineralId: _mineralId,
      mineralName: _mineralName,
      estimatedQuantity: Quantity(value: _currentQuantityBrass, unit: 'BRASS'),
      liftingPeriodDays: liftingDays,
      reasonForApplying: _reasonController.text.trim(),
      purpose: _reasonController.text.trim(),
      projectType: _projectType,
      departmentName: _departmentController.text.trim(),
      officeName: _officeController.text.trim(),
      workOrderNumber: _workOrderController.text.trim(),
      projectCode: _projectCodeController.text.trim(),
      projectName: _projectNameController.text.trim(),
      projectAddress: _projectAddressController.text.trim(),
      projectLatitude: _projectLatController.text.trim(),
      projectLongitude: _projectLngController.text.trim(),
      zeroRoyaltyScheme: _zeroRoyaltyScheme,
      category: _category,
      plotLocationType: _plotLocationController.text.trim(),
      districtCode: _locDistrictController.text.trim(),
      districtName: _locDistrictController.text.trim(),
      talukaCode: _locTalukaController.text.trim(),
      talukaName: _locTalukaController.text.trim(),
      villageCode: _locVillageController.text.trim(),
      villageName: _locVillageController.text.trim(),
      siteAddress: Address(
        line1: 'Survey ${_surveyInputController.text}, ${_locVillageController.text}',
        village: _locVillageController.text.trim(),
        taluka: _locTalukaController.text.trim(),
        district: _locDistrictController.text.trim(),
        pincode: _pincodeController.text.trim(),
      ),
      siteGeo: GeoPoint(latitude: lat, longitude: lng),
      village: _locVillageController.text.trim(),
      surveyNumber: _surveyInputController.text.trim(),
      surveyEntries: _surveyEntries,
      totalPlotAreaHectare: areaHa,
      areaInSqm: areaHa * 10000,
      demandNoteOffice: _demandNoteOffice,
      grasOfficeName: _grasOfficeName,
      fromDate: DateTime.now().toIso8601String().substring(0, 10),
      toDate: DateTime.now().add(Duration(days: liftingDays)).toIso8601String().substring(0, 10),
      applicationFee: feeBreakdown.totalFee,
      declarationAccepted: _declarationAccepted,
      status: TemporaryExcavationStatus.draft,
      lastStepIndex: _currentStep,
      statusUpdatedAt: DateTime.now().toIso8601String(),
      documents: _attachedDocs,
    );
  }

  void _autoSave() async {
    final draft = _buildDraftObject();
    await ref.read(excavationRepositoryProvider).saveDraft(draft);
  }

  void _handleSaveAndExit() async {
    setState(() => _isSaving = true);
    _autoSave();
    await ref.read(excavationProvider.notifier).loadApplications('org-001');
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved successfully.')),
      );
      context.pop();
    }
  }

  void _handleNext() async {
    setState(() => _errors = {});

    // Validate Step 0 (Applicant)
    if (_currentStep == 0) {
      final errors = ExcavationRules.validateApplicantStep(
        fullName: _fullNameController.text,
        mobileNumber: _mobileController.text,
        panNumber: _panController.text,
        addressLine: _addressController.text,
        district: _districtController.text,
        pincode: _pincodeController.text,
        email: _emailController.text,
      );
      if (errors.isNotEmpty) {
        setState(() => _errors = errors);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errors.values.first)),
        );
        return;
      }
    } else if (_currentStep == 1) {
      final errors = ExcavationRules.validateExcavationStep(
        applicationType: _applicationType,
        mineralId: _mineralId,
        quantityBrass: _currentQuantityBrass,
        liftingPeriodDays: int.tryParse(_liftingPeriodController.text),
        reasonForApplying: _reasonController.text,
      );
      if (errors.isNotEmpty) {
        setState(() => _errors = errors);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errors.values.first)),
        );
        return;
      }
    } else if (_currentStep == 2) {
      final errors = ExcavationRules.validateLocationStep(
        district: _locDistrictController.text,
        taluka: _locTalukaController.text,
        village: _locVillageController.text,
        surveyNumber: _surveyInputController.text,
        totalPlotAreaHectare: double.tryParse(_totalAreaController.text),
      );
      if (errors.isNotEmpty) {
        setState(() => _errors = errors);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errors.values.first)),
        );
        return;
      }
    } else if (_currentStep == 3) {
      final attachedKinds = _attachedDocs.map((d) => d.kind).toList();
      final missing = ExcavationRules.missingRequiredDocuments(attachedKinds);
      if (missing.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload all mandatory documents (*) before proceeding.')),
        );
        return;
      }
    } else if (_currentStep == 4) {
      if (!_declarationAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept statutory minor minerals declaration.')),
        );
        return;
      }
      final draft = _buildDraftObject();
      final paid = await context.push<bool>('/excavation/pay', extra: {
        'title': 'Application Fee Payment',
        'amount': '₹520',
        'applicationId': draft.applicationNumber.isNotEmpty ? draft.applicationNumber : 'TEA/2026/DRAFT-001410',
        'applicantName': draft.applicant.fullName.isNotEmpty ? draft.applicant.fullName : 'Rohit Sanghavi',
        'proposedQuantity': '${draft.estimatedQuantity.value > 0 ? draft.estimatedQuantity.value.toInt() : 22} Brass',
      });

      if (paid == true) {
        setState(() => _isSaving = true);
        await ref.read(excavationRepositoryProvider).submitApplication(draft);
        await ref.read(excavationProvider.notifier).loadApplications('org-001');
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application successfully submitted with fee paid!')),
          );
          context.pop();
        }
      }
      return;
    }

    setState(() {
      _currentStep++;
      _autoSave();
    });
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _autoSave();
      });
    } else {
      context.pop();
    }
  }

  void _addSurvey() {
    final text = _surveyInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _surveyEntries.add(SurveyEntry(
        id: 'survey-${DateTime.now().millisecondsSinceEpoch}',
        surveyNumber: text,
        areaInHectares: double.tryParse(_totalAreaController.text) ?? 0.75,
        sevenTwelveAttached: true,
      ));
    });
    _autoSave();
  }

  void _removeSurvey(String id) {
    setState(() {
      _surveyEntries.removeWhere((s) => s.id == id);
    });
    _autoSave();
  }

  void _uploadDoc(String kind, String fileName, String docType, String? docNum) {
    setState(() {
      _attachedDocs.removeWhere((d) => d.kind == kind);
      _attachedDocs.add(ApplicationDocument(
        id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
        kind: kind,
        fileName: fileName,
        documentType: docType,
        documentNumber: docNum,
        uploadedAt: DateTime.now().toIso8601String(),
      ));
    });
    _autoSave();
  }

  void _removeDoc(String kind) {
    setState(() {
      _attachedDocs.removeWhere((d) => d.kind == kind);
    });
    _autoSave();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBackButton: false,
      body: Column(
        children: [
          // 1. TOP HEADER BAR
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.ink),
                      onPressed: _handleBack,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'New application',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                // Save & Exit Soft Blue Pill Button
                GestureDetector(
                  onTap: _handleSaveAndExit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4FE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Save & Exit',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. BREADCRUMB BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                top: BorderSide(color: AppColors.line, width: 1),
                bottom: BorderSide(color: AppColors.line, width: 1),
              ),
            ),
            child: Row(
              children: const [
                Icon(Icons.layers_outlined, size: 16, color: AppColors.primary700),
                SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Mumbai–Nashik Highway Wide ',
                          style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                        ),
                        TextSpan(
                          text: '> ',
                          style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                        ),
                        TextSpan(
                          text: 'Package A — Km 12 to Kn',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // 3. STEP PROGRESS BAR ROW
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // 5 Segmented Progress Bars
                Expanded(
                  child: Row(
                    children: List.generate(5, (index) {
                      final isFilled = index <= _currentStep;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: index < 4 ? 6 : 0),
                          decoration: BoxDecoration(
                            color: isFilled ? AppColors.primary700 : const Color(0xFFEFF2F7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Step ${_currentStep + 1} of 5',
                  style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                ),
                const SizedBox(width: 8),

                // Auto-saved Badge Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.inkMuted, width: 1),
                  ),
                  child: const Text(
                    'Auto-saved ✓',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.line),

          // 4. STEP BODY CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(),
            ),
          ),

          // 5. BOTTOM ACTIONS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.line, width: 1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary700,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isSaving ? null : _handleNext,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : Text(
                            _currentStep == 4 ? 'Pay Fee & Submit Application' : 'Continue',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _handleSaveAndExit,
                  child: const Text(
                    'Save as draft and exit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return ApplicantStepWidget(
          nameController: _fullNameController,
          mobileController: _mobileController,
          landlineController: _landlineController,
          emailController: _emailController,
          districtController: _districtController,
          pincodeController: _pincodeController,
          addressController: _addressController,
          panController: _panController,
          aadhaarController: _aadhaarController,
          gstController: _gstController,
          errors: _errors,
          onChanged: _autoSave,
        );
      case 1:
        return ExcavationStepWidget(
          applicationType: _applicationType,
          onApplicationTypeChanged: (val) => setState(() => _applicationType = val),
          proposalLevel: _proposalLevel,
          onProposalLevelChanged: (val) => setState(() => _proposalLevel = val),
          mineralId: _mineralId,
          onMineralChanged: (val) {
            setState(() {
              _mineralId = val;
              if (val == 'min-3') _mineralName = 'Stone Aggregate 20mm';
              if (val == 'min-1') _mineralName = 'Natural River Sand';
              if (val == 'min-2') _mineralName = 'Manufactured Sand (M-Sand)';
              if (val == 'min-4') _mineralName = 'Murrum / Soil Filling';
            });
          },
          quantityController: _quantityController,
          liftingPeriodController: _liftingPeriodController,
          reasonController: _reasonController,
          projectType: _projectType,
          onProjectTypeChanged: (val) => setState(() => _projectType = val),
          departmentController: _departmentController,
          officeController: _officeController,
          workOrderController: _workOrderController,
          projectCodeController: _projectCodeController,
          projectNameController: _projectNameController,
          projectAddressController: _projectAddressController,
          latController: _projectLatController,
          lngController: _projectLngController,
          zeroRoyaltyScheme: _zeroRoyaltyScheme,
          onZeroRoyaltyChanged: (val) => setState(() => _zeroRoyaltyScheme = val),
          errors: _errors,
          onChanged: _autoSave,
        );
      case 2:
        return LocationStepWidget(
          category: _category,
          onCategoryChanged: (val) => setState(() => _category = val),
          plotLocationController: _plotLocationController,
          districtController: _locDistrictController,
          talukaController: _locTalukaController,
          villageController: _locVillageController,
          surveyInputController: _surveyInputController,
          surveyEntries: _surveyEntries,
          onAddSurvey: _addSurvey,
          onRemoveSurvey: _removeSurvey,
          totalAreaController: _totalAreaController,
          latController: _latController,
          lngController: _lngController,
          onPinOnMap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pin map overlay opened. Location set.')),
            );
          },
          demandNoteOffice: _demandNoteOffice,
          onDemandNoteOfficeChanged: (val) => setState(() => _demandNoteOffice = val),
          grasOfficeName: _grasOfficeName,
          onGrasOfficeChanged: (val) => setState(() => _grasOfficeName = val),
          onApplySuggestion: () {
            setState(() {
              _locVillageController.text = 'Wagholi';
              _locTalukaController.text = 'Haveli';
              _locDistrictController.text = 'Pune';
            });
            _autoSave();
          },
          errors: _errors,
          onChanged: _autoSave,
        );
      case 3:
        return DocumentsStepWidget(
          attachedDocs: _attachedDocs,
          onUploadDoc: _uploadDoc,
          onRemoveDoc: _removeDoc,
          errors: _errors,
        );
      case 4:
      default:
        final draftApp = _buildDraftObject();
        return ReviewStepWidget(
          application: draftApp,
          declarationAccepted: _declarationAccepted,
          onDeclarationChanged: (val) {
            setState(() => _declarationAccepted = val);
            _autoSave();
          },
          onEditStep: (stepIdx) {
            setState(() => _currentStep = stepIdx);
          },
        );
    }
  }
}
