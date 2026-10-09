import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool? _isTown;
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
  Timer? _profileAadhaarResendTimer;
  int _profileAadhaarTimerCountdown = 60;

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
  
  String? _localProfileAadhaarPath;
  String? _localProfileAadhaarName;
  Uint8List? _localProfileAadhaarBytes;
  
  bool? _tempIsAadharVerified;
  String? _tempAadharCardNo;
  String? _tempAadharName;

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
    _profileAadhaarController.dispose();
    _profileAadhaarOtpController.dispose();
    _profileAadhaarResendTimer?.cancel();
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
    if (profile.districtId == null || profile.districtId == 0) {
      _isTown = null;
    } else {
      _isTown = profile.isTown;
    }
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
    
    if (aadh.startsWith('0') || aadh.startsWith('1')) {
      setModalState(() => _profileAadhaarError = 'Aadhaar number cannot start with 0 or 1.');
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
        
        _profileAadhaarTimerCountdown = 60;
        _profileAadhaarResendTimer?.cancel();
        _profileAadhaarResendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          setModalState(() {
            if (_profileAadhaarTimerCountdown > 0) {
              _profileAadhaarTimerCountdown--;
            } else {
              timer.cancel();
            }
          });
        });
      } else {
        String msg = genRes.message ?? 'Failed to send OTP to Aadhaar-registered mobile number.';
        if (msg.trim().toLowerCase() == 'verification_failed') {
          msg = 'Invalid Aadhaar number entered. Please verify and try again.';
        }
        _profileAadhaarError = msg;
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
        if (_activeProfileData != null) {
          final newName = (res.fullName != null && res.fullName!.trim().isNotEmpty) ? res.fullName! : _activeProfileData!.name;
          _tempIsAadharVerified = true;
          _tempAadharCardNo = _profileAadhaarController.text.replaceAll(' ', '').trim();
          _tempAadharName = newName;
        }
        setState(() {});
      } else {
        String msg = res.message ?? 'Invalid Aadhaar OTP. Please check and try again.';
        if (msg.toLowerCase() == 'verification_failed' || msg.toLowerCase().contains('invalid')) {
          msg = 'Invalid OTP entered. Please try again.';
        }
        _profileAadhaarError = msg;
      }
    });
  }

  Future<void> _handleProfileUploadAadhaarDoc(StateSetter setModalState) async {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(loc.cameraBtn),
                onTap: () {
                  Navigator.pop(context);
                  _processProfilePickImage(ImageSource.camera, setModalState);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(loc.galleryBtn),
                onTap: () {
                  Navigator.pop(context);
                  _processProfilePickImage(ImageSource.gallery, setModalState);
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(loc.fileDocumentBtn),
                onTap: () {
                  Navigator.pop(context);
                  _processProfilePickFile(setModalState);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processProfilePickImage(ImageSource source, StateSetter setModalState) async {
    try {

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) return;
      
      final bytes = await pickedFile.readAsBytes();
      await _uploadProfileDocument(pickedFile.path, pickedFile.name, bytes, setModalState);
    } catch (e) {
      if (e.toString().contains('access_denied')) {
        setModalState(() {
          _isProfileUploadingDoc = false;
        });
        return;
      }
      setModalState(() {
        _isProfileUploadingDoc = false;
        _profileAadhaarDocError = 'Upload failed: ${e.toString()}';
      });
    }
  }

  Future<void> _processProfilePickFile(StateSetter setModalState) async {
    try {

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.path == null) return;

      await _uploadProfileDocument(file.path!, file.name, file.bytes, setModalState);
    } catch (e) {
      if (e.toString().contains('access_denied')) {
        setModalState(() {
          _isProfileUploadingDoc = false;
        });
        return;
      }
      setModalState(() {
        _isProfileUploadingDoc = false;
        _profileAadhaarDocError = 'Upload failed: ${e.toString()}';
      });
    }
  }

  Future<void> _uploadProfileDocument(String path, String name, Uint8List? bytes, StateSetter setModalState) async {
    setModalState(() {
      _localProfileAadhaarPath = path;
      _localProfileAadhaarName = name;
      _localProfileAadhaarBytes = bytes;
      _profileAadhaarDocUrl = null;
      _profileAadhaarDocError = null;
      _uploadedDocName = name;
      setState(() {});
    });
  }

  Future<bool> _handleSaveProfile() async {
    final user = ref.read(sessionProvider).currentUser;
    final mobile = _mobileController.text.trim();
    final l10n = AppLocalizations.of(context)!;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterFullName)),
      );
      return false;
    }

    if (_emailController.text.trim().isNotEmpty) {
      final emailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim());
      if (!emailValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pleaseEnterValidEmail)),
        );
        return false;
      }
    }

    setState(() => _isSaving = true);

    if (_tempIsAadharVerified != null && _activeProfileData != null) {
      _activeProfileData = _activeProfileData!.copyWith(
        name: _tempAadharName ?? _activeProfileData!.name,
        isAadharVerified: _tempIsAadharVerified,
        aadharCardNo: _tempAadharCardNo ?? _activeProfileData!.aadharCardNo,
      );
      if (_tempAadharName != null) {
        _nameController.text = _tempAadharName!;
      }
      _tempIsAadharVerified = null;
      _tempAadharCardNo = null;
      _tempAadharName = null;
    }

    if (_localProfileAadhaarPath != null) {
      final repo = ref.read(aadhaarKycRepositoryProvider);
      final uploadRes = await repo.uploadAadhaarDocument(
        filePath: _localProfileAadhaarPath!,
        fileName: _localProfileAadhaarName ?? 'doc',
        bytes: _localProfileAadhaarBytes,
      );
      if (uploadRes.isSuccess && uploadRes.responseData != null) {
        _profileAadhaarDocUrl = uploadRes.responseData;
        if (_activeProfileData != null) {
          _activeProfileData = _activeProfileData!.copyWith(aadharDoc: _profileAadhaarDocUrl);
        }
      } else {
        if (!mounted) return false;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(uploadRes.statusMessage ?? 'Document upload failed. Please try again.'),
            backgroundColor: AppColors.danger700,
          ),
        );
        return false;
      }
    }

    final isAadhaarVerified = _activeProfileData?.isAadharVerified ?? false;

    final Map<String, dynamic> updatePayload = {
      'id': user!.consumerId,
      'consumerType': (user.isOrganization) ? 1 : 0,
      'name': _nameController.text.trim(),
      'mobileNo': mobile,
      'emailId': _emailController.text.trim(),
      'isTown': _isTown,
      'districtId': _selectedDistrictId ?? 0,
      'talukaId': _selectedTalukaId ?? 0,
      'censusId': _selectedCensusId ?? 0,
      'address': _line1Controller.text.trim(),
      'pinCode': '',
      'aadharCardNo': _profileAadhaarController.text.replaceAll(' ', '').trim(),
      'aadharDoc': _profileAadhaarDocUrl ?? '',
      'isAadharVerified': isAadhaarVerified,
      'pageName': 'ConsumerProfileUpdate',
    };

    try {
      final response = await ref.read(authRepositoryProvider).consumerProfileUpdate(updatePayload);

      if (!mounted) return false;

      setState(() => _isSaving = false);

      if (response.isSuccess) {
        ref.invalidate(consumerProfileProvider(mobile));
        setState(() => _showSaveToast = true);

        Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showSaveToast = false);
        });
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.statusMessage.isNotEmpty
                ? response.statusMessage
                : 'Failed to update consumer profile.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while updating profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  void _openKycModal(KycStep initialStep) {
    final loc = AppLocalizations.of(context)!;
    final mobileNo = ref.read(sessionProvider).currentUser?.mobileNumber ?? '';
    final isServerVerified = ref.read(consumerProfileProvider(mobileNo)).value?.responseData?.isAadharVerified == true;
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
                      Text(
                        loc.aadhaarEkycInfoTitle,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),

                      const SizedBox(height: 16),

                      _buildKycDetailRow(
                        loc.aadhaarNumberLabel,
                        (_tempAadharCardNo != null && _tempAadharCardNo!.isNotEmpty)
                            ? _tempAadharCardNo!
                            : (_activeProfileData?.aadharCardNo != null && _activeProfileData!.aadharCardNo!.isNotEmpty)
                                ? _activeProfileData!.aadharCardNo!
                                : 'N/A',
                      ),
                      const SizedBox(height: 10),
                      _buildKycDetailRow(
                        loc.aadhaarVerificationLabel,
                        (_tempIsAadharVerified ?? _activeProfileData?.isAadharVerified == true) ? 'VERIFIED' : 'PENDING',
                      ),
                      const SizedBox(height: 10),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(modalContext),
                              child: Text(loc.closeBtn),
                            ),
                          ),
                          if (!(_tempIsAadharVerified ?? _activeProfileData?.isAadharVerified == true)) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary700),
                                onPressed: () => setModalState(() => _kycStep = KycStep.upload),
                                child: Text(loc.verifyAadhaarBtn, style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ] else if (_kycStep == KycStep.upload) ...[
                      Text(
                        loc.aadhaarIdentityVerificationTitle,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.aadhaarIdentityVerificationDesc,
                        style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                      ),
                      const SizedBox(height: 16),

                      // Option 1: Live Aadhaar OTP
                      if (_tempIsAadharVerified ?? _activeProfileData?.isAadharVerified == true) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loc.method1LiveOtp, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Color(0xFF15803D), size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_profileAadhaarController.text.isNotEmpty ? _profileAadhaarController.text : (_tempAadharCardNo ?? _activeProfileData?.aadharCardNo ?? 'Aadhaar OTP Verified'), style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.w600)),
                                        if ((_tempAadharName ?? _activeProfileData?.name)?.isNotEmpty == true) ...[
                                          const SizedBox(height: 2),
                                          Text((_tempAadharName ?? _activeProfileData!.name), style: const TextStyle(color: Color(0xFF15803D), fontSize: 12, fontWeight: FontWeight.w500)),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (!isServerVerified)
                                    GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          if (_activeProfileData != null) {
                                            _activeProfileData = _activeProfileData!.copyWith(isAadharVerified: false, aadharCardNo: '');
                                          }
                                          _tempIsAadharVerified = null;
                                          _tempAadharCardNo = null;
                                          _tempAadharName = null;
                                          _profileAadhaarController.clear();
                                          _profileAadhaarOtpController.clear();
                                          _isProfileAadhaarOtpSent = false;
                                          _profileAadhaarError = null;
                                          _profileAadhaarDocUrl = null;
                                        });
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                        child: Icon(Icons.edit, color: AppColors.primary700, size: 20),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
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
                              Text(loc.method1LiveOtp, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E40AF))),
                              const SizedBox(height: 8),
                            AppTextField(
                              label: loc.twelveDigitAadhaarNumber,
                              controller: _profileAadhaarController,
                              keyboardType: TextInputType.number,
                              maxLength: 12,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              hint: loc.enterTwelveDigitAadhaar,
                              readOnly: _isProfileAadhaarOtpSent,
                              suffixIcon: _isProfileAadhaarOtpSent
                                  ? IconButton(
                                      icon: const Icon(Icons.edit, color: Color(0xFF15803D)),
                                      onPressed: () {
                                        setModalState(() {
                                          _isProfileAadhaarOtpSent = false;
                                          _profileAadhaarOtpController.clear();
                                          _profileAadhaarError = null;
                                        });
                                      },
                                    )
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
                                          : Text(loc.sendOtpBtn, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                    ),
                            ),
                            if (_isProfileAadhaarOtpSent) ...[
                              const SizedBox(height: 10),
                              AppTextField(
                                label: loc.sixDigitAadhaarOtp,
                                controller: _profileAadhaarOtpController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                hint: loc.enterSixDigitOtp,
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
                                      : Text(loc.verifyOtpBtn, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ),
                              if (_profileAadhaarTimerCountdown > 0) ...[
                                const SizedBox(height: 6),
                                Text('Resend OTP in 00:${_profileAadhaarTimerCountdown.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary)),
                              ] else ...[
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: _isProfileAadhaarGenerating ? null : () => _handleProfileSendAadhaarOtp(setModalState),
                                  child: Text(
                                    loc.resendBtn,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB)),
                                  ),
                                ),
                              ],
                            ],
                            if (_profileAadhaarError != null) ...[
                              const SizedBox(height: 6),
                              Text(_profileAadhaarError!, style: const TextStyle(fontSize: 11, color: AppColors.danger700, fontWeight: FontWeight.w500)),
                            ],
                          ],
                        ),
                        ),
                      ],
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
                            Text(
                              loc.method2UploadAadhaar,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
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
                                            (_profileAadhaarDocUrl != null || _localProfileAadhaarPath != null) ? Icons.check_circle : Icons.upload_file,
                                            color: (_profileAadhaarDocUrl != null || _localProfileAadhaarPath != null) ? const Color(0xFF15803D) : AppColors.inkSecondary,
                                            size: 20,
                                          ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _uploadedDocName.isNotEmpty ? _uploadedDocName : loc.chooseAadhaarPdfOrImage,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: (_profileAadhaarDocUrl != null || _localProfileAadhaarPath != null) ? const Color(0xFF15803D) : AppColors.ink,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (_isProfileUploadingDoc) ...[
                                            const SizedBox(height: 2),
                                            Text(loc.uploadingToMahakhanijServer, style: TextStyle(fontSize: 10.5, color: AppColors.primary700)),
                                          ],

                                        ],
                                      ),
                                    ),
                                    if ((_profileAadhaarDocUrl != null || _localProfileAadhaarPath != null) && !_isProfileUploadingDoc) ...[
                                      GestureDetector(
                                        onTap: () => _handleProfileUploadAadhaarDoc(setModalState),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          child: Icon(Icons.edit, color: AppColors.primary700, size: 20),
                                        ),
                                      ),
                                      if (_profileAadhaarDocUrl != null || _localProfileAadhaarPath != null) ...[
                                        GestureDetector(
                                          onTap: () async {
                                            if (_profileAadhaarDocUrl != null) {
                                              final url = Uri.tryParse(_profileAadhaarDocUrl!);
                                              if (url != null) {
                                                try {
                                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                                } catch (_) {}
                                              }
                                            } else if (_localProfileAadhaarPath != null) {
                                              try {
                                                await OpenFile.open(_localProfileAadhaarPath!);
                                              } catch (_) {}
                                            }
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                            child: Icon(Icons.visibility, color: AppColors.primary700, size: 20),
                                          ),
                                        ),
                                      ],
                                      GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            _localProfileAadhaarPath = null;
                                            _localProfileAadhaarBytes = null;
                                            _localProfileAadhaarName = null;
                                            _profileAadhaarDocUrl = null;
                                            _uploadedDocName = '';
                                            setState(() {});
                                          });
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          child: Icon(Icons.delete_outline, color: AppColors.danger700, size: 20),
                                        ),
                                      ),
                                    ] else ...[
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
                                          _isProfileUploadingDoc ? 'Uploading...' : loc.uploadBtn,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
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
                                    child: Text(
                                      loc.retryBtn,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.danger700, decoration: TextDecoration.underline),
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
                              child: Text(loc.closeBtn, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkSecondary)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 44),
                                backgroundColor: AppColors.primary700,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _isSaving ? null : () async {
                                final isVerified = _tempIsAadharVerified == true || _activeProfileData?.isAadharVerified == true;
                                if (!isVerified) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(loc.aadhaarVerificationRequired),
                                      backgroundColor: AppColors.danger700,
                                    ),
                                  );
                                  return;
                                }
                                setModalState(() => _isSaving = true);
                                final success = await _handleSaveProfile();
                                if (mounted) {
                                  setModalState(() => _isSaving = false);
                                  if (success) {
                                    Navigator.pop(modalContext);
                                  }
                                }
                              },
                              child: _isSaving 
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(loc.saveBtn, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                      Text(
                        loc.aadhaarVerificationCompleted,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.aadhaarVerificationSuccessDesc,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        label: loc.doneBtn,
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
      title: loc.aadhaarKyc,
      showBackButton: false,
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
          final isAadhaarVerified = _activeProfileData?.isAadharVerified ?? profile?.isAadharVerified ?? false;
          final displayAadhaarNo = _tempAadharCardNo ?? _activeProfileData?.aadharCardNo ?? profile?.aadharCardNo ?? '';
          final displayAadhaarName = _tempAadharName ?? _activeProfileData?.name ?? profile?.name ?? '';

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                                  isAadhaarVerified ? loc.aadhaarVerified : loc.actionRequiredLabel,
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
                                        label: loc.aadhaarAuthenticationLabel,
                                        subtitle: isAadhaarVerified ? '${displayAadhaarNo.isNotEmpty ? displayAadhaarNo : 'N/A'}\n${displayAadhaarName.isNotEmpty ? displayAadhaarName : 'N/A'}' : null,
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
                                        onPressed: (profile?.aadharDoc == null || profile!.aadharDoc!.isEmpty)
                                            ? null
                                            : () async {
                                                final url = Uri.tryParse(profile!.aadharDoc!);
                                                if (url != null) {
                                                  try {
                                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                                  } catch (_) {}
                                                }
                                              },
                                        child: Text(loc.viewDocument, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: (profile?.aadharDoc != null && profile!.aadharDoc!.isNotEmpty) ? AppColors.ink : Colors.grey)),
                                      ),
                                    ),
                                    if (!isAadhaarVerified || profile?.aadharDoc == null || profile!.aadharDoc!.isEmpty) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: const Size(double.infinity, 40),
                                            backgroundColor: AppColors.primary700,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: () => _openKycModal(KycStep.upload),
                                          child: Text(isAadhaarVerified ? 'Upload Document' : '${loc.verifyAadhaar} →', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          loc.aadhaarDetailsSavedSuccessfully,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
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

  Widget _buildChecklistRow({required IconData icon, required String label, String? subtitle, required bool isVerified}) {
    final loc = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, size: 16, color: isVerified ? const Color(0xFF059669) : AppColors.inkMuted),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.ink),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary, fontFamily: 'monospace'),
                      ),
                    ],
                  ],
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
              isVerified ? loc.aadhaarVerified : loc.aadhaarPending,
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
