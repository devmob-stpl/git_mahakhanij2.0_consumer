import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/consumer_profile_models.dart';
import '../../data/repositories/aadhaar_kyc_repository.dart';
import '../../data/repositories/location_repository.dart';
import '../../providers/consumer_profile_provider.dart';
import '../../providers/session_provider.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/location_dropdown_section.dart';
import '../../l10n/app_localizations.dart';

enum KycStep { view, upload, success }

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Form controllers
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _designationController;
  late final TextEditingController _orgNameController;
  late final TextEditingController _line1Controller;
  late final TextEditingController _talukaController;
  late final TextEditingController _districtController;
  late final TextEditingController _cityVillageController;
  late final TextEditingController _pincodeController;

  bool _isTown = true;
  int? _selectedDistrictId;
  int? _selectedTalukaId;
  int? _selectedCensusId;

  // Live Aadhaar KYC & OTP Verification State (Profile)
  final _profileAadhaarController = TextEditingController();
  final _profileAadhaarOtpController = TextEditingController();
  String? _profileAadhaarClientId;
  bool _isProfileAadhaarOtpSent = false;
  bool _isProfileAadhaarChecking = false;
  bool _isProfileAadhaarGenerating = false;
  bool _isProfileAadhaarVerifying = false;
  String? _profileAadhaarError;

  String? _profileAadhaarDocUrl;
  String? _profileAadhaarDocError;
  bool _isProfileUploadingDoc = false;

  bool _isSaving = false;
  bool _showSaveToast = false;

  // Track populated profile ID to prevent overwriting user edits
  int? _lastLoadedProfileId;
  ConsumerProfileData? _activeProfileData;

  // KYC Modal State
  KycStep _kycStep = KycStep.view;
  String _uploadedDocName = '';

  @override
  void initState() {
    super.initState();
    final user = ref.read(sessionProvider).currentUser;

    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _mobileController = TextEditingController(text: user?.mobileNumber ?? '');
    _designationController = TextEditingController(text: user?.designation ?? '');
    _orgNameController = TextEditingController(text: user?.organizationId ?? '');
    _line1Controller = TextEditingController();
    _talukaController = TextEditingController();
    _districtController = TextEditingController();
    _cityVillageController = TextEditingController();
    _pincodeController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _designationController.dispose();
    _orgNameController.dispose();
    _line1Controller.dispose();
    _talukaController.dispose();
    _districtController.dispose();
    _cityVillageController.dispose();
    _pincodeController.dispose();
    _profileAadhaarController.dispose();
    _profileAadhaarOtpController.dispose();
    super.dispose();
  }

  void _populateProfileData(ConsumerProfileData profile) {
    if (_lastLoadedProfileId == profile.id) return;
    _lastLoadedProfileId = profile.id;
    _activeProfileData = profile;

    _nameController.text = profile.name.isNotEmpty ? profile.name : _nameController.text;
    _mobileController.text = profile.mobileNo.isNotEmpty ? profile.mobileNo : _mobileController.text;
    _emailController.text = profile.emailId ?? '';
    _line1Controller.text = profile.address ?? '';
    _pincodeController.text = profile.pinCode ?? '';
    _isTown = profile.isTown;
    _selectedDistrictId = profile.districtId;
    _selectedTalukaId = profile.talukaId;
    _selectedCensusId = profile.censusId;

    if (profile.aadharCardNo != null && profile.aadharCardNo!.isNotEmpty) {
      _profileAadhaarController.text = profile.aadharCardNo!;
    }

    if (profile.aadharDoc != null && profile.aadharDoc!.isNotEmpty) {
      _profileAadhaarDocUrl = profile.aadharDoc;
    }

    if (profile.districtName != null && profile.districtName!.isNotEmpty) {
      _districtController.text = profile.districtName!;
    }
    if (profile.talukaName != null && profile.talukaName!.isNotEmpty) {
      _talukaController.text = profile.talukaName!;
    }
    if (profile.cityName != null && profile.cityName!.isNotEmpty) {
      _cityVillageController.text = profile.cityName!;
    } else if (profile.villageName != null && profile.villageName!.isNotEmpty) {
      _cityVillageController.text = profile.villageName!;
    }

    // Resolve location names dynamically using District/Taluka/Census IDs
    if (profile.districtId != null || profile.talukaId != null || profile.censusId != null) {
      ref.read(locationRepositoryProvider).resolveLocationNames(
        districtId: profile.districtId,
        talukaId: profile.talukaId,
        censusId: profile.censusId,
        isTown: profile.isTown,
      ).then((names) {
        if (!mounted) return;
        setState(() {
          if (names.districtName.isNotEmpty) _districtController.text = names.districtName;
          if (names.talukaName.isNotEmpty) _talukaController.text = names.talukaName;
          if (names.villageName.isNotEmpty) _cityVillageController.text = names.villageName;
        });
      });
    }
  }

  Future<void> _handleProfileSendAadhaarOtp(StateSetter setModalState) async {
    final aadh = _profileAadhaarController.text.replaceAll(' ', '').trim();
    if (aadh.length != 12 || !RegExp(r'^\d{12}$').hasMatch(aadh)) {
      setModalState(() => _profileAadhaarError = 'Enter a valid 12-digit Aadhaar number.');
      return;
    }

    setModalState(() {
      _profileAadhaarError = null;
      _isProfileAadhaarChecking = true;
    });

    final repo = ref.read(aadhaarKycRepositoryProvider);
    final existRes = await repo.checkAadhaarExists(aadh);
    if (!mounted) return;

    if (existRes.exists) {
      setModalState(() {
        _isProfileAadhaarChecking = false;
        _profileAadhaarError = 'This Aadhaar card number is already registered in Mahakhanij system.';
      });
      return;
    }

    setModalState(() {
      _isProfileAadhaarChecking = false;
      _isProfileAadhaarGenerating = true;
    });

    final genRes = await repo.generateAadhaarOtp(aadh, createdBy: 0);
    if (!mounted) return;

    setModalState(() {
      _isProfileAadhaarGenerating = false;
      if (genRes.isSuccess && genRes.clientId != null) {
        _isProfileAadhaarOtpSent = true;
        _profileAadhaarClientId = genRes.clientId;
        _profileAadhaarError = null;
      } else {
        _profileAadhaarError = genRes.message ?? 'Failed to send OTP to Aadhaar-registered mobile number.';
      }
    });
  }

  Future<void> _handleProfileVerifyAadhaarOtp(StateSetter setModalState) async {
    final otp = _profileAadhaarOtpController.text.trim();
    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      setModalState(() => _profileAadhaarError = 'Enter a valid 6-digit Aadhaar OTP.');
      return;
    }

    if (_profileAadhaarClientId == null) {
      setModalState(() => _profileAadhaarError = 'Client session expired. Please resend OTP.');
      return;
    }

    setModalState(() {
      _profileAadhaarError = null;
      _isProfileAadhaarVerifying = true;
    });

    final repo = ref.read(aadhaarKycRepositoryProvider);
    final res = await repo.submitAadhaarOtp(
      clientId: _profileAadhaarClientId!,
      otp: otp,
      mobileNumber: _mobileController.text.trim(),
      createdBy: 0,
    );
    if (!mounted) return;

    setModalState(() {
      _isProfileAadhaarVerifying = false;
      if (res.isSuccess) {
        _kycStep = KycStep.success;
      } else {
        _profileAadhaarError = res.message ?? 'Invalid Aadhaar OTP. Please check and try again.';
      }
    });
  }

  Future<void> _handleProfileUploadAadhaarDoc(StateSetter setModalState) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) return;

      setModalState(() {
        _isProfileUploadingDoc = true;
        _profileAadhaarDocError = null;
        _uploadedDocName = file.name;
      });

      final repo = ref.read(aadhaarKycRepositoryProvider);
      final uploadRes = await repo.uploadAadhaarDocument(filePath: file.path!);
      if (!mounted) return;

      setModalState(() {
        _isProfileUploadingDoc = false;
        if (uploadRes.isSuccess && uploadRes.responseData != null && uploadRes.responseData!.isNotEmpty) {
          _profileAadhaarDocUrl = uploadRes.responseData;
          _profileAadhaarDocError = null;
        } else {
          _profileAadhaarDocError = uploadRes.statusMessage;
        }
      });
    } catch (e) {
      setModalState(() {
        _isProfileUploadingDoc = false;
        _profileAadhaarDocError = 'Upload failed: ${e.toString()}';
      });
    }
  }

  Future<void> _handleSaveProfile() async {
    final user = ref.read(sessionProvider).currentUser;
    final mobile = _mobileController.text.trim();

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final isAadhaarVerified = _activeProfileData?.isAadharVerified ?? false;

    final Map<String, dynamic> updatePayload = {
      'id': user!.consumerId,
      'consumerType': (user?.isOrganization ?? false) ? 1 : 0,
      'name': _nameController.text.trim(),
      'mobileNo': mobile,
      'emailId': _emailController.text.trim(),
      'isTown': _isTown,
      'districtId': _selectedDistrictId ?? 0,
      'talukaId': _selectedTalukaId ?? 0,
      'censusId': _selectedCensusId ?? 0,
      'address': _line1Controller.text.trim(),
      'pinCode': _pincodeController.text.trim(),
      'aadharCardNo': _profileAadhaarController.text.replaceAll(' ', '').trim(),
      'aadharDoc': _profileAadhaarDocUrl ?? '',
      'isAadharVerified': isAadhaarVerified,
      'pageName': 'ConsumerProfileUpdate',
    };

    try {
      final response = await ref.read(authRepositoryProvider).consumerSignUp(updatePayload);

      if (!mounted) return;

      setState(() => _isSaving = false);

      if (response.isSuccess) {
        ref.invalidate(consumerProfileProvider(mobile));
        setState(() => _showSaveToast = true);

        Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showSaveToast = false);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.statusMessage.isNotEmpty
                ? response.statusMessage
                : 'Failed to update consumer profile.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while updating profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openKycModal(KycStep initialStep) {
    final isAadhaarVerified = _activeProfileData?.isAadharVerified ?? false;
    if (isAadhaarVerified && initialStep == KycStep.upload) {
      initialStep = KycStep.view;
    }
    setState(() => _kycStep = initialStep);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),

                    if (_kycStep == KycStep.view) ...[
                      const Text(
                        'Aadhaar e-KYC Information',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),

                      const SizedBox(height: 16),

                      _buildKycDetailRow(
                        'Aadhaar Number',
                        _activeProfileData?.aadharCardNo != null && _activeProfileData!.aadharCardNo!.isNotEmpty
                            ? _activeProfileData!.aadharCardNo!
                            : 'N/A',
                      ),
                      const SizedBox(height: 10),
                      _buildKycDetailRow(
                        'Aadhaar Verification',
                        _activeProfileData?.isAadharVerified == true ? 'VERIFIED' : 'PENDING',
                      ),
                      const SizedBox(height: 10),
                      if (_profileAadhaarDocUrl != null) ...[
                        _buildKycDetailRow(
                          'Aadhaar Document URL',
                          _profileAadhaarDocUrl!.length > 25 ? '...${_profileAadhaarDocUrl!.substring(_profileAadhaarDocUrl!.length - 25)}' : _profileAadhaarDocUrl!,
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(modalContext),
                              child: const Text('Close'),
                            ),
                          ),
                          if (_activeProfileData?.isAadharVerified != true) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary700),
                                onPressed: () => setModalState(() => _kycStep = KycStep.upload),
                                child: const Text('Verify Aadhaar', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ] else if (_kycStep == KycStep.upload) ...[
                      const Text(
                        'Aadhaar Identity Verification',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Verify your Aadhaar OTP or upload document photo',
                        style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                      ),
                      const SizedBox(height: 16),

                      // Option 1: Live Aadhaar OTP
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Method 1: Live OTP Verification', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E40AF))),
                            const SizedBox(height: 8),
                            AppTextField(
                              label: '12-Digit Aadhaar Number *',
                              controller: _profileAadhaarController,
                              keyboardType: TextInputType.number,
                              hint: 'Enter 12 digit Aadhaar',
                              suffixIcon: _isProfileAadhaarOtpSent
                                  ? const Icon(Icons.check_circle, color: Color(0xFF15803D))
                                  : ElevatedButton(
                                      onPressed: (_isProfileAadhaarChecking || _isProfileAadhaarGenerating)
                                          ? null
                                          : () => _handleProfileSendAadhaarOtp(setModalState),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: (_isProfileAadhaarChecking || _isProfileAadhaarGenerating)
                                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : const Text('Send OTP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                    ),
                            ),
                            if (_isProfileAadhaarOtpSent) ...[
                              const SizedBox(height: 10),
                              AppTextField(
                                label: '6-Digit Aadhaar OTP *',
                                controller: _profileAadhaarOtpController,
                                keyboardType: TextInputType.number,
                                hint: 'Enter 6 digit OTP',
                                suffixIcon: ElevatedButton(
                                  onPressed: _isProfileAadhaarVerifying ? null : () => _handleProfileVerifyAadhaarOtp(setModalState),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF15803D),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: _isProfileAadhaarVerifying
                                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : const Text('Verify OTP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                            if (_profileAadhaarError != null) ...[
                              const SizedBox(height: 6),
                              Text(_profileAadhaarError!, style: const TextStyle(fontSize: 11, color: AppColors.danger700, fontWeight: FontWeight.w500)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Option 2: Live Document Upload API
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _profileAadhaarDocError != null
                                ? AppColors.danger700
                                : (_profileAadhaarDocUrl != null ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Method 2: Upload Aadhaar Card Document (PDF / Image)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Select document file to upload via Mahakhanij document server',
                              style: TextStyle(fontSize: 11, color: AppColors.inkSecondary),
                            ),
                            const SizedBox(height: 10),

                            InkWell(
                              onTap: _isProfileUploadingDoc ? null : () => _handleProfileUploadAadhaarDoc(setModalState),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: Row(
                                  children: [
                                    _isProfileUploadingDoc
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary700))
                                        : Icon(
                                            _profileAadhaarDocUrl != null ? Icons.check_circle : Icons.upload_file,
                                            color: _profileAadhaarDocUrl != null ? const Color(0xFF15803D) : AppColors.inkSecondary,
                                            size: 20,
                                          ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _uploadedDocName.isNotEmpty ? _uploadedDocName : 'Choose Aadhaar PDF or Image',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: _profileAadhaarDocUrl != null ? const Color(0xFF15803D) : AppColors.ink,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (_isProfileUploadingDoc) ...[
                                            const SizedBox(height: 2),
                                            const Text('Uploading to Mahakhanij server...', style: TextStyle(fontSize: 10.5, color: AppColors.primary700)),
                                          ],
                                          if (_profileAadhaarDocUrl != null) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              _profileAadhaarDocUrl!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 9.5, color: Color(0xFF166534), fontFamily: 'monospace'),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: _isProfileUploadingDoc ? null : () => _handleProfileUploadAadhaarDoc(setModalState),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        _isProfileUploadingDoc ? 'Uploading...' : (_profileAadhaarDocUrl != null ? 'Replace' : 'Upload'),
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if (_profileAadhaarDocError != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _profileAadhaarDocError!,
                                      style: const TextStyle(fontSize: 11, color: AppColors.danger700, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _handleProfileUploadAadhaarDoc(setModalState),
                                    child: const Text(
                                      'Retry',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.danger700, decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 44),
                                side: const BorderSide(color: AppColors.line),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () => Navigator.pop(modalContext),
                              child: const Text('Close', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkSecondary)),
                            ),
                          ),
                        ],
                      ),
                    ] else if (_kycStep == KycStep.success) ...[
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle, size: 36, color: Color(0xFF16A34A)),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Aadhaar Verification Completed!',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Aadhaar credentials verified successfully with Government of Maharashtra.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'Done',
                        fullWidth: true,
                        onPressed: () {
                          Navigator.pop(modalContext);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider).currentUser;
    final isOrg = user?.isOrganization ?? false;
    final mobileNo = user?.mobileNumber ?? '';
    final loc = AppLocalizations.of(context)!;

    final profileAsync = ref.watch(consumerProfileProvider(mobileNo));

    return AppScaffold(
      title: loc.profileScreenTitle,
      showBackButton: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.ink),
          onPressed: () => context.push('/settings'),
        ),
      ],
      body: profileAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 3),
              SizedBox(height: 12),
              Text(
                'Loading Consumer Profile...',
                style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
              ),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Color(0xFFDC2626)),
                const SizedBox(height: 12),
                const Text(
                  'Failed to fetch Consumer Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Retry Loading Profile',
                  size: AppButtonSize.small,
                  onPressed: () => ref.invalidate(consumerProfileProvider(mobileNo)),
                ),
              ],
            ),
          ),
        ),
        data: (response) {
          if (response.responseData != null) {
            _populateProfileData(response.responseData!);
          }

          final profile = response.responseData;
          final isAadhaarVerified = profile?.isAadharVerified ?? false;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1) Top Navy Identity Hero Card (#102d5e)
                    Container(
                      color: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                            ),
                            child: Center(
                              child: Text(
                                _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : 'C',
                                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _nameController.text.isNotEmpty ? _nameController.text : 'Consumer Account',
                                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isOrg ? 'Organization' : 'Consumer',
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '+91 ${_mobileController.text}',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontFamily: 'monospace'),
                                ),
                                Text(
                                  'Consumer ID: ${profile?.id ?? 412}',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11, fontFamily: 'monospace'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2) AADHAAR KYC VERIFICATION STATUS CARD
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isAadhaarVerified ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isAadhaarVerified ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: isAadhaarVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        isAadhaarVerified ? Icons.verified_user : Icons.warning_amber_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  isAadhaarVerified ? loc.aadhaarVerified : loc.aadhaarPending,
                                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isAadhaarVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: isAadhaarVerified ? const Color(0xFF86EFAC) : const Color(0xFFFCD34D),
                                                  ),
                                                ),
                                                child: Text(
                                                  isAadhaarVerified ? 'Approved' : 'Action Required',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: isAadhaarVerified ? const Color(0xFF15803D) : const Color(0xFFB45309),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Aadhaar Checklist Card
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildChecklistRow(
                                        icon: Icons.person_outline,
                                        label: 'Aadhaar Authentication',
                                        isVerified: isAadhaarVerified,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(double.infinity, 40),
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () => _openKycModal(KycStep.view),
                                        child: Text(loc.viewDocument, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
                                      ),
                                    ),
                                    if (!isAadhaarVerified) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(double.infinity, 40),
                                            backgroundColor: AppColors.primary700,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: () => _openKycModal(KycStep.upload),
                                          child: Text('${loc.verifyAadhaar} →', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // 3) Personal & Account Details Form
                          Text(
                            loc.personalDetails,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Column(
                              children: [
                                AppTextField(
                                  label: '${loc.profileName} *',
                                  controller: _nameController,
                                  prefixIcon: const Icon(Icons.person_outline, size: 18),
                                ),
                                const SizedBox(height: 12),
                                AppTextField(
                                  label: '${loc.profileMobile} *',
                                  controller: _mobileController,
                                  enabled: false,
                                  prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                                  helperText: 'Verified via Government OTP (Locked)',
                                ),
                                const SizedBox(height: 12),
                                AppTextField(
                                  label: '${loc.profileEmail} *',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: const Icon(Icons.mail_outline, size: 18),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // 4) Address & Location Details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                loc.residentialDetails,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _isTown ? const Color(0xFFEFF6FF) : const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _isTown ? const Color(0xFFBFDBFE) : const Color(0xFFA7F3D0),
                                  ),
                                ),
                                child: Text(
                                  _isTown ? loc.urban.toUpperCase() : loc.rural.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _isTown ? const Color(0xFF2563EB) : const Color(0xFF047857),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.line),
                            ),
                            child: Column(
                              children: [
                                AppTextField(
                                  label: '${loc.profileAddress} *',
                                  controller: _line1Controller,
                                  prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                                ),
                                const SizedBox(height: 14),
                                LocationDropdownSection(
                                  key: const ValueKey('loc____'),
                                  initialCategory: _isTown ? 'URBAN' : 'RURAL',
                                  initialDistrictId: _selectedDistrictId,
                                  initialTalukaId: _selectedTalukaId,
                                  initialCensusId: _selectedCensusId,
                                  initialDistrict: _districtController.text,
                                  initialTaluka: _talukaController.text,
                                  initialVillageCity: _cityVillageController.text,
                                  showCategorySelector: true,
                                  onChanged: (data) {
                                    setState(() {
                                      _selectedDistrictId = data.districtId;
                                      _selectedTalukaId = data.talukaId;
                                      _selectedCensusId = data.censusId;
                                      _districtController.text = data.districtName;
                                      _talukaController.text = data.talukaName;
                                      _cityVillageController.text = data.villageCityName;
                                      _isTown = data.isTown;
                                                                          });
                                  },
                                ),
                                const SizedBox(height: 14),
                                AppTextField(
                                  label: '${loc.profilePincode} *',
                                  controller: _pincodeController,
                                  keyboardType: TextInputType.number,
                                  prefixIcon: const Icon(Icons.pin_drop_outlined, size: 18),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Save Button
                          AppButton(
                            label: _isSaving ? 'Saving Changes...' : loc.saveChanges,
                            fullWidth: true,
                            size: AppButtonSize.large,
                            onPressed: _isSaving ? null : _handleSaveProfile,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Floating Save Toast
              if (_showSaveToast)
                Positioned(
                  top: 16,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF047857),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Profile details updated successfully!',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChecklistRow({required IconData icon, required String label, required bool isVerified}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, size: 16, color: isVerified ? const Color(0xFF059669) : AppColors.inkMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.ink),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVerified ? Icons.check : Icons.access_time,
              size: 14,
              color: isVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
            ),
            const SizedBox(width: 4),
            Text(
              isVerified ? 'Verified' : 'Pending',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKycDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: AppColors.ink),
          ),
        ),
      ],
    );
  }
}
