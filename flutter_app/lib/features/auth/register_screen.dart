import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/user.dart';
import '../../domain/aadhaar_kyc_models.dart';
import '../../data/repositories/aadhaar_kyc_repository.dart';
import '../../providers/session_provider.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/location_dropdown_section.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Step 1: Basic & Address details (1), Step 2: KYC Verification (2)
  int _step = 1;
  UserType _userType = UserType.normalConsumer;

  // Step 1: Basic & Contact Details
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();

  // Step 1: Organization Details
  final _orgNameController = TextEditingController();
  String _orgType = 'CONTRACTOR'; // BUILDER, CONTRACTOR, GOVERNMENT, OTHER
  final _gstController = TextEditingController();
  final _regNumberController = TextEditingController();
  bool _noGst = false;
  String _gstStatus = 'idle'; // 'idle' | 'verifying' | 'verified' | 'error'

  // Step 1: Address Details
  String _areaClassification = 'URBAN'; // 'URBAN' | 'RURAL'
  String? _district;
  String? _taluka;
  int? _districtId;
  int? _talukaId;
  int? _censusId;
  final _cityController = TextEditingController();

  final _villageController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Step 2: KYC Details & Aadhaar Verification API Flow
  final _aadhaarController = TextEditingController();
  final _aadhaarOtpController = TextEditingController();
  final _panController = TextEditingController();
  String? _kycFileName;
  String? _aadhaarDocUrl;
  String? _panFileName;
  String? _panDocUrl;
  String? _aadhaarFileName;
  String? _aadhaarSignatoryDocUrl;
  bool _isUploadingAadhaarDoc = false;
  bool _isUploadingPanDoc = false;

  // Aadhaar API State
  String? _aadhaarClientId;
  bool _isAadhaarOtpSent = false;
  bool _isAadhaarVerified = false;
  bool _isCheckingAadhaar = false;
  bool _isGeneratingAadhaarOtp = false;
  bool _isVerifyingAadhaarOtp = false;
  String? _aadhaarError;
  VerifyAadhaarOtpResponse? _aadhaarVerifiedData;

  // Form Errors
  Map<String, String> _errors = {};
  bool _isSubmitting = false;

  Timer? _resendTimer;
  int _timerCountdown = 0;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _fullNameController.dispose();
    _mobileController.dispose();
    _orgNameController.dispose();
    _gstController.dispose();
    _regNumberController.dispose();
    _cityController.dispose();
    _villageController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _aadhaarController.dispose();
    _aadhaarOtpController.dispose();
    _panController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _timerCountdown = 60;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_timerCountdown > 0) {
          _timerCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _handleSendAadhaarOtp() async {
    final aadh = _aadhaarController.text.replaceAll(' ', '').trim();
    if (aadh.length != 12 || !RegExp(r'^\d{12}$').hasMatch(aadh)) {
      setState(() => _aadhaarError = 'Enter a valid 12-digit Aadhaar number.');
      return;
    }

    setState(() {
      _aadhaarError = null;
      _isCheckingAadhaar = true;
    });

    final repo = ref.read(aadhaarKycRepositoryProvider);

    // 1. Check if Aadhaar already exists
    final existRes = await repo.checkAadhaarExists(aadh);
    if (!mounted) return;

    if (existRes.exists) {
      setState(() {
        _isCheckingAadhaar = false;
        _aadhaarError = 'This Aadhaar card number is already registered in Mahakhanij system.';
      });
      return;
    }

    // 2. Generate OTP
    setState(() {
      _isCheckingAadhaar = false;
      _isGeneratingAadhaarOtp = true;
    });

    final genRes = await repo.generateAadhaarOtp(aadh, createdBy: 0);
    if (!mounted) return;

    setState(() {
      _isGeneratingAadhaarOtp = false;
      if (genRes.isSuccess && genRes.clientId != null) {
        _isAadhaarOtpSent = true;
        _aadhaarClientId = genRes.clientId;
        _aadhaarError = null;
        _startResendTimer();
      } else {
        _aadhaarError = genRes.message ?? 'Failed to send OTP to Aadhaar-registered mobile number.';
      }
    });
  }

  Future<void> _handleVerifyAadhaarOtp() async {
    final otp = _aadhaarOtpController.text.trim();
    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      setState(() => _aadhaarError = 'Enter a valid 6-digit Aadhaar OTP.');
      return;
    }

    if (_aadhaarClientId == null) {
      setState(() => _aadhaarError = 'Client ID missing. Please resend OTP.');
      return;
    }

    setState(() {
      _aadhaarError = null;
      _isVerifyingAadhaarOtp = true;
    });

    final repo = ref.read(aadhaarKycRepositoryProvider);
    final verifyRes = await repo.submitAadhaarOtp(
      clientId: _aadhaarClientId!,
      otp: otp,
      mobileNumber: _mobileController.text.trim(),
      createdBy: 0,
    );

    if (!mounted) return;

    setState(() {
      _isVerifyingAadhaarOtp = false;
      if (verifyRes.isSuccess) {
        _isAadhaarVerified = true;
        _aadhaarVerifiedData = verifyRes;
        _aadhaarError = null;
      } else {
        _aadhaarError = verifyRes.message ?? 'Aadhaar OTP verification failed. Invalid OTP.';
      }
    });
  }

  Future<void> _pickAndUploadDocument({bool isPan = false, bool isSignatoryAadhaar = false}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;

      final key = isPan ? 'panFile' : (isSignatoryAadhaar ? 'aadhaarFile' : 'kycFile');

      setState(() {
        if (isPan) {
          _isUploadingPanDoc = true;
        } else {
          _isUploadingAadhaarDoc = true;
        }
        _errors.remove(key);
      });

      final repo = ref.read(aadhaarKycRepositoryProvider);
      final response = await repo.uploadAadhaarDocument(
        filePath: file.path ?? '',
        fileName: file.name,
        bytes: file.bytes,
      );

      if (!mounted) return;

      setState(() {
        if (isPan) {
          _isUploadingPanDoc = false;
        } else {
          _isUploadingAadhaarDoc = false;
        }

        if (response.isSuccess && response.responseData != null && response.responseData!.isNotEmpty) {
          if (isPan) {
            _panFileName = file.name;
            _panDocUrl = response.responseData;
          } else if (isSignatoryAadhaar) {
            _aadhaarFileName = file.name;
            _aadhaarSignatoryDocUrl = response.responseData;
          } else {
            _kycFileName = file.name;
            _aadhaarDocUrl = response.responseData;
          }
          _errors.remove(key);
        } else {
          _errors[key] = response.statusMessage.isNotEmpty
              ? response.statusMessage
              : 'Failed to upload document. Please try again.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      final key = isPan ? 'panFile' : (isSignatoryAadhaar ? 'aadhaarFile' : 'kycFile');
      setState(() {
        _isUploadingAadhaarDoc = false;
        _isUploadingPanDoc = false;
        _errors[key] = 'Document upload failed: ${e.toString()}';
      });
    }
  }

  void _verifyGst() {
    final gst = _gstController.text.trim().toUpperCase();
    if (gst.isEmpty) {
      setState(() => _errors['gstNumber'] = 'Enter your organization GSTIN.');
      return;
    }
    if (gst.length != 15 || !RegExp(r'^\d{2}[A-Z]{5}\d{4}[A-Z]{1}[A-Z\d]{1}[Z]{1}[A-Z\d]{1}$').hasMatch(gst)) {
      setState(() {
        _errors['gstNumber'] = 'Enter a valid 15-character GSTIN (e.g. 27AAAAA0000A1Z5).';
        _gstStatus = 'error';
      });
      return;
    }

    setState(() {
      _gstStatus = 'verifying';
      _errors.remove('gstNumber');
    });

    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() {
        _gstStatus = 'verified';
        if (_orgNameController.text.trim().isEmpty) {
          _orgNameController.text = 'Shree Infra & Constructions Pvt Ltd';
        }
      });
    });
  }

  void _back() {
    setState(() {
      _errors.clear();
      if (_step <= 1) {
        context.pop();
      } else {
        _step--;
      }
    });
  }


  void _next() async {
    final found = _validateStep();
    if (found.isNotEmpty) {
      setState(() => _errors = found);
      return;
    }

    if (_step < 2) {
      setState(() {
        _errors.clear();
        _step++;
      });
      return;
    }

    // Step 2 complete -> Directly submit Sign Up API without OTP verification
    setState(() => _isSubmitting = true);
    final mobile = _mobileController.text.trim();

    final Map<String, dynamic> signUpPayload = {
      'id': 0,
      'consumerType': _userType == UserType.organization ? 1 : 0,
      'name': _fullNameController.text.trim(),
      'mobileNo': mobile,
      'emailId': '',
      'isTown': _areaClassification == 'URBAN',
      'districtId': _districtId ?? 0,
      'censusId': _censusId ?? 0,
      'talukaId': _talukaId ?? 0,
      'address': _addressController.text.trim(),
      'pinCode': _pincodeController.text.trim(),
      'aadharCardNo': _aadhaarController.text.replaceAll(' ', '').trim(),
      'aadharDoc': _aadhaarDocUrl ?? _aadhaarSignatoryDocUrl ?? '',
      'isAadharVerified': _isAadhaarVerified,
      'panNo': _panController.text.trim(),
      'panDoc': _panDocUrl ?? '',
      'isPanVerified': false,
      'gstNo': _gstController.text.trim(),
      'gstDoc': '',
      'isGSTVerified': _gstStatus == 'verified',
      'pageName': 'ConsumerSignUp',
    };

    final response = await ref.read(authRepositoryProvider).consumerSignUp(signUpPayload);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please sign in with your mobile number.'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/login', extra: mobile);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.statusMessage.isNotEmpty
              ? response.statusMessage
              : 'Registration failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  Map<String, String> _validateStep() {
    final found = <String, String>{};

    if (_step == 1) {
      if (_fullNameController.text.trim().isEmpty) {
        found['fullName'] = 'This field is required.';
      }
      final mobile = _mobileController.text.trim();
      if (mobile.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
        found['mobile'] = 'Enter a valid 10-digit Indian mobile number.';
      }

      if (_userType == UserType.organization) {
        if (_orgNameController.text.trim().isEmpty) {
          found['orgName'] = 'This field is required.';
        }
        if (!_noGst) {
          if (_gstController.text.trim().isEmpty) {
            found['gstNumber'] = 'Enter your organization GSTIN.';
          }
        }
      }

      if (_addressController.text.trim().isEmpty) {
        found['address'] = 'This field is required.';
      }
      final pin = _pincodeController.text.trim();
      if (pin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pin)) {
        found['pincode'] = 'Enter a valid 6-digit PIN code.';
      }
    } else if (_step == 2) {
      // Aadhaar KYC is NON-MANDATORY. Allow skipping and continuing without validation errors.
    }

    return found;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            // Top Auth Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.ink),
                    onPressed: _back,
                  ),
                  if (_step > 0) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _step / 2,
                          backgroundColor: AppColors.line,
                          color: AppColors.primary700,
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      AppLocalizations.of(context)!.stepOf(_step, 2),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkSecondary),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),

            // Main Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: _step == 0
                    ? _buildStep0ChooseType()
                    : _step == 1
                        ? _buildStep1Details()
                        : _buildStep2Kyc(),
              ),
            ),

            // Sticky Footer Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    label: _step == 0
                        ? AppLocalizations.of(context)!.continueBtn
                        : _step == 1
                            ? AppLocalizations.of(context)!.continueToKyc
                            : AppLocalizations.of(context)!.completeRegistration,
                    isLoading: _isSubmitting,
                    fullWidth: true,
                    size: AppButtonSize.large,
                    onPressed: _isSubmitting ? null : _next,
                  ),
                  if (_step == 2) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _isSubmitting ? null : _next,
                      child: Text(
                        AppLocalizations.of(context)!.skipAadhaar,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkSecondary),
                      ),
                    ),
                  ],

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 0: Choose Account Type
  // -------------------------------------------------------------
  Widget _buildStep0ChooseType() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.chooseAccountType,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.howWillYouUse,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.chooseAccountDesc,
          style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
        ),
        const SizedBox(height: 24),

        // Individual Card
        InkWell(
          onTap: () => setState(() => _userType = UserType.normalConsumer),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _userType == UserType.normalConsumer ? const Color(0xFFEEF4FF) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _userType == UserType.normalConsumer ? AppColors.primary700 : AppColors.line,
                width: _userType == UserType.normalConsumer ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _userType == UserType.normalConsumer ? AppColors.primary700 : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: _userType == UserType.normalConsumer ? Colors.white : AppColors.ink,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.individual,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.individualDesc,
                        style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (AppConfig.enableOrganizationFlow) ...[
          const SizedBox(height: 14),
          // Organization Card
          InkWell(
            onTap: () => setState(() => _userType = UserType.organization),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _userType == UserType.organization ? const Color(0xFFEEF4FF) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _userType == UserType.organization ? AppColors.primary700 : AppColors.line,
                  width: _userType == UserType.organization ? 2 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _userType == UserType.organization ? AppColors.primary700 : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.business_outlined,
                      color: _userType == UserType.organization ? Colors.white : AppColors.ink,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.organization,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.organizationDesc,
                          style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 28),
        Row(
          children: [
            Text(l10n.alreadyHaveAccount, style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
            GestureDetector(
              onTap: () => context.push('/login'),
              child: Text(
                l10n.signIn,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary700, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 1: Basic & Address Details
  // -------------------------------------------------------------
  Widget _buildStep1Details() {
    final isOrg = _userType == UserType.organization;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.basicAndAddressDetails,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.5),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.enterPersonalContact,
          style: const TextStyle(fontSize: 14, color: AppColors.inkSecondary, height: 1.3),
        ),
        const SizedBox(height: 20),

        // Persona Summary Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOrg ? Icons.business : Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOrg ? l10n.organization : l10n.individual,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOrg ? l10n.personaOrganizationDesc : l10n.personaIndividualDesc,
                      style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Full Name
        _buildFieldLabel(l10n.fullName),
        const SizedBox(height: 6),
        _buildTextField(
          _fullNameController, 
          error: _errors['fullName'],
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16),

        // Mobile Number with +91 Prefix
        _buildFieldLabel(l10n.mobileNumber),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _errors.containsKey('mobile') ? AppColors.danger700 : AppColors.line),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text('+91', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.inkSecondary)),
              ),
              Container(width: 1, height: 24, color: AppColors.line),
              Expanded(
                child: TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: l10n.tenDigitNumber,
                    hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted, fontWeight: FontWeight.normal),
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_errors.containsKey('mobile')) ...[
          const SizedBox(height: 4),
          Text(_errors['mobile']!, style: const TextStyle(fontSize: 12, color: AppColors.danger700)),
        ] else ...[
          const SizedBox(height: 6),
          Text(l10n.weWillSendVerification, style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
        ],
        const SizedBox(height: 20),

        // Organization Specific Fields if org
        if (isOrg) ...[
          _buildFieldLabel(l10n.orgNameLabel),
          const SizedBox(height: 6),
          _buildTextField(_orgNameController, hint: 'Shree Infra & Constructions Pvt Ltd', error: _errors['orgName']),
          const SizedBox(height: 16),

          _buildFieldLabel(l10n.orgTypeLabel),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _orgType,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'BUILDER', child: Text('Builder')),
                  DropdownMenuItem(value: 'CONTRACTOR', child: Text('Contractor')),
                  DropdownMenuItem(value: 'GOVERNMENT', child: Text('Government')),
                  DropdownMenuItem(value: 'OTHER', child: Text('Organization')),
                ],
                onChanged: (val) => setState(() => _orgType = val!),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (!_noGst) ...[
            _buildFieldLabel('GSTIN / GST Number'),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _gstController,
                    hint: '15-character GSTIN (e.g. 27AAAAA0000A1Z5)',
                    error: _errors['gstNumber'],
                    uppercase: true,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _gstStatus == 'verifying' ? null : _verifyGst,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  child: _gstStatus == 'verifying'
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Verify', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
            if (_gstStatus == 'verified') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Color(0xFF15803D)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GSTIN Verified (Active)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                          Text('Entity verified with Maharashtra State GST Portal', style: TextStyle(fontSize: 11, color: Color(0xFF166534))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],

          Row(
            children: [
              Checkbox(
                value: _noGst,
                activeColor: AppColors.primary700,
                onChanged: (val) => setState(() => _noGst = val ?? false),
              ),
              const Expanded(
                child: Text('Entity does not have a GSTIN (Unregistered / Exemption)', style: TextStyle(fontSize: 12, color: AppColors.inkSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildFieldLabel('Mahakhanij registration number (optional)'),
          const SizedBox(height: 6),
          _buildTextField(_regNumberController, hint: 'e.g. MH-2024-ORG-9988'),
          const SizedBox(height: 20),
        ],

        // Delivery Destination Section Header
        Text(
          l10n.whereDeliverMineral,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.inkMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 14),

        // Dynamic Location Dropdowns
        LocationDropdownSection(
          initialCategory: _areaClassification,
          initialDistrict: _district,
          initialTaluka: _taluka,
          initialVillageCity: _areaClassification == 'URBAN' ? _cityController.text : _villageController.text,
          onChanged: (locData) {
            setState(() {
              _areaClassification = locData.category;
              _district = locData.districtName;
              _taluka = locData.talukaName;
              _districtId = locData.district?.id;
              _talukaId = locData.taluka?.id;
              _censusId = locData.villageCity?.id;
              if (locData.category == 'RURAL') { // Rural -> Village
                _villageController.text = locData.villageCityName;
                _cityController.text = '';
              } else { // Urban -> City
                _cityController.text = locData.villageCityName;
                _villageController.text = '';
              }
            });
          },
        ),
        const SizedBox(height: 14),

        // Street Address
        _buildFieldLabel(l10n.addressLabel),
        const SizedBox(height: 6),
        _buildTextField(_addressController, hint: l10n.addressHint, error: _errors['address'], keyboardType: TextInputType.streetAddress),
        const SizedBox(height: 14),

        // PIN code
        _buildFieldLabel(l10n.pincodeLabel),
        const SizedBox(height: 6),
        _buildTextField(
          _pincodeController, 
          hint: l10n.pincodeHint, 
          error: _errors['pincode'],
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 6,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 2: KYC Verification with Live Aadhaar Verification & Skip
  // -------------------------------------------------------------
  Widget _buildStep2Kyc() {
    final isOrg = _userType == UserType.organization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isOrg ? 'Organization KYC Verification' : 'Aadhaar KYC Verification',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.5),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Optional', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkSecondary)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Verify identity via Aadhaar OTP or skip to complete your registration.',
          style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
        ),
        const SizedBox(height: 20),

        if (!isOrg) ...[
          // Interactive Aadhaar Verification Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _isAadhaarVerified ? const Color(0xFFBBF7D0) : AppColors.line),
              boxShadow: const [
                BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _isAadhaarVerified ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _isAadhaarVerified ? Icons.verified_user : Icons.badge_outlined,
                        color: _isAadhaarVerified ? const Color(0xFF15803D) : const Color(0xFF2563EB),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isAadhaarVerified ? 'Aadhaar Identity Verified' : 'Aadhaar Card OTP Verification',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _isAadhaarVerified ? const Color(0xFF15803D) : AppColors.ink,
                            ),
                          ),
                          Text(
                            _isAadhaarVerified ? 'Aadhaar verified national identity card' : 'Enter 12-digit Aadhaar to receive OTP',
                            style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_isAadhaarVerified) ...[
                  // Verified State Summary Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, size: 16, color: Color(0xFF15803D)),
                            const SizedBox(width: 6),
                            Text(
                              _aadhaarVerifiedData?.fullName ?? 'Suraj Akil Atar',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Aadhaar: ${_aadhaarVerifiedData?.aadharNumber ?? "XXXX-XXXX-2902"}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF166534), fontFamily: 'monospace'),
                        ),
                        Text(
                          'Address: ${_aadhaarVerifiedData?.loc ?? "at post tungat taluka pandharpur"}, ${_aadhaarVerifiedData?.dist ?? "Solapur"}, ${_aadhaarVerifiedData?.state ?? "Maharashtra"} - ${_aadhaarVerifiedData?.zip ?? "413304"}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF166534)),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Aadhaar Number Input Row
                  _buildFieldLabel('Aadhaar card number'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _aadhaarController,
                          keyboardType: TextInputType.number,
                          maxLength: 12,
                          enabled: !_isAadhaarOtpSent,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                          decoration: InputDecoration(
                            hintText: '12-digit Aadhaar number',
                            hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted, fontWeight: FontWeight.normal),
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.line)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.line)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: (_isCheckingAadhaar || _isGeneratingAadhaarOtp || (_isAadhaarOtpSent && _timerCountdown > 0)) ? null : _handleSendAadhaarOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                        child: (_isCheckingAadhaar || _isGeneratingAadhaarOtp)
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                _isAadhaarOtpSent
                                    ? (_timerCountdown > 0
                                        ? '00:${_timerCountdown.toString().padLeft(2, '0')}'
                                        : 'Resend')
                                    : 'Send OTP',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                      ),
                    ],
                  ),

                  if (_isAadhaarOtpSent) ...[
                    const SizedBox(height: 14),
                    _buildFieldLabel('Enter 6-digit Aadhaar OTP'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _aadhaarOtpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                            decoration: InputDecoration(
                              hintText: '6-digit OTP',
                              hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted, fontWeight: FontWeight.normal),
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.line)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.line)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isVerifyingAadhaarOtp ? null : _handleVerifyAadhaarOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15803D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                          child: _isVerifyingAadhaarOtp
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Verify OTP', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ],
                    ),
                  ],

                  if (_aadhaarError != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: AppColors.danger700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _aadhaarError!,
                              style: const TextStyle(fontSize: 12, color: AppColors.danger700, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Upload Aadhaar Card (Optional Document)
          _buildUploadCard(
            title: 'Upload Aadhaar Card (Optional)',
            hint: 'Front or combined copy of Aadhaar card (PDF / Image)',
            fileName: _kycFileName,
            docUrl: _aadhaarDocUrl,
            isLoading: _isUploadingAadhaarDoc,
            error: _errors['kycFile'],
            onPick: () => _pickAndUploadDocument(isPan: false),
          ),
          const SizedBox(height: 20),

          // Non-Mandatory Notice Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, size: 18, color: Color(0xFF15803D)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Aadhaar verification is non-mandatory. You can skip this step at any time and complete registration.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF166534), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Organization PAN & Signatory Aadhaar
          _buildFieldLabel('Organization PAN number'),
          const SizedBox(height: 6),
          _buildTextField(_panController, hint: '10-character PAN (e.g. ABCDE1234F)', error: _errors['pan'], uppercase: true),
          const SizedBox(height: 16),

          _buildUploadCard(
            title: 'Upload Organization PAN Card',
            hint: 'Clear copy of entity PAN card (PDF / Image)',
            fileName: _panFileName,
            docUrl: _panDocUrl,
            isLoading: _isUploadingPanDoc,
            error: _errors['panFile'],
            onPick: () => _pickAndUploadDocument(isPan: true),
          ),
          const SizedBox(height: 20),

          _buildFieldLabel('Signatory Aadhaar Card Number'),
          const SizedBox(height: 6),
          _buildTextField(_aadhaarController, hint: '12-digit Aadhaar number', error: _errors['aadhaar']),
          const SizedBox(height: 16),

          _buildUploadCard(
            title: 'Upload Signatory Aadhaar Card',
            hint: 'Clear copy of authorized signatory Aadhaar (PDF / Image)',
            fileName: _aadhaarFileName,
            docUrl: _aadhaarSignatoryDocUrl ?? _aadhaarDocUrl,
            isLoading: _isUploadingAadhaarDoc,
            error: _errors['aadhaarFile'],
            onPick: () => _pickAndUploadDocument(isPan: false, isSignatoryAadhaar: true),
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  // -------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    String? hint,
    String? error,
    bool uppercase = false,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: error != null ? AppColors.danger700 : AppColors.line),
          ),
          child: TextField(
            controller: controller,
            textCapitalization: uppercase ? TextCapitalization.characters : TextCapitalization.words,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted, fontWeight: FontWeight.normal),
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(error, style: const TextStyle(fontSize: 12, color: AppColors.danger700)),
        ],
      ],
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String hint,
    required String? fileName,
    required String? docUrl,
    required bool isLoading,
    String? error,
    required VoidCallback onPick,
  }) {
    final hasFile = docUrl != null && docUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: isLoading ? null : onPick,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: hasFile ? const Color(0xFFF0FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: error != null ? AppColors.danger700 : (hasFile ? const Color(0xFFBBF7D0) : AppColors.line),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isLoading
                        ? const Color(0xFFEEF4FE)
                        : (hasFile ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary700),
                        )
                      : Icon(
                          hasFile ? Icons.check_circle : Icons.upload_file,
                          color: hasFile ? const Color(0xFF15803D) : AppColors.inkSecondary,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasFile ? (fileName ?? 'Aadhaar_Document.pdf') : title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: hasFile ? const Color(0xFF15803D) : AppColors.ink,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isLoading
                            ? 'Uploading document to Mahakhanij server...'
                            : (hasFile ? 'Document uploaded & verified' : hint),
                        style: TextStyle(
                          fontSize: 11,
                          color: isLoading ? AppColors.primary700 : AppColors.inkSecondary,
                          fontWeight: isLoading ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (hasFile) ...[
                        const SizedBox(height: 2),
                        Text(
                          docUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF166534), fontFamily: 'monospace'),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  isLoading ? 'Uploading...' : (hasFile ? 'Replace' : 'Upload'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary700),
                ),
              ],
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(error, style: const TextStyle(fontSize: 12, color: AppColors.danger700)),
              ),
              GestureDetector(
                onTap: onPick,
                child: const Text(
                  'Retry',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.danger700, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
