import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/user.dart';
import '../../domain/aadhaar_kyc_models.dart';
import '../../data/repositories/aadhaar_kyc_repository.dart';
import '../../providers/session_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/location_dropdown_section.dart';
import '../../core/utils/pan_input_formatter.dart';
import '../../core/utils/document_permission_helper.dart';
import '../../core/utils/api_error_localizer.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Step 0: Choose Account Type, Step 1: Basic & Address details (1), Step 2: KYC Verification (2)
  int _step = 0;
  UserType _userType = UserType.normalConsumer;
  int _locationResetKey = 0;

  // Step 1: Basic & Contact Details
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  // Step 1: Organization Details
  final _orgNameController = TextEditingController();
  final _contactPersonController = TextEditingController();

  // Step 1: Address Details
  String _areaClassification = 'URBAN'; // 'URBAN' | 'RURAL'
  int? _stateId = 1;
  String? _district;
  String? _taluka;
  int? _districtId;
  int? _talukaId;
  int? _censusId;
  final _cityController = TextEditingController();

  final _villageController = TextEditingController();
  final _addressController = TextEditingController();

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

  String? _localAadhaarPath;
  String? _localAadhaarName;
  Uint8List? _localAadhaarBytes;

  String? _localPanPath;
  String? _localPanName;
  Uint8List? _localPanBytes;

  String? _localSignatoryAadhaarPath;
  String? _localSignatoryAadhaarName;
  Uint8List? _localSignatoryAadhaarBytes;

  // Aadhaar API State
  String? _aadhaarClientId;
  bool _isAadhaarOtpSent = false;
  bool _isAadhaarVerified = false;
  bool _isCheckingAadhaar = false;
  bool _isGeneratingAadhaarOtp = false;
  bool _isVerifyingAadhaarOtp = false;
  String? _aadhaarError;
  String? _aadhaarOtpError;
  VerifyAadhaarOtpResponse? _aadhaarVerifiedData;

  // PAN Verification State
  bool _isCheckingPan = false;
  bool _isVerifyingPan = false;
  bool _isPanVerified = false;
  String? _panClientId;
  String? _panClientName;
  String? _panError;

  // Form Errors
  Map<String, String> _errors = {};
  bool _isSubmitting = false;

  Timer? _resendTimer;
  int _timerCountdown = 0;

  bool _declarationConfirmed = false;



  void _onConsumerTypeChanged(UserType newType) {
    if (_userType == newType) return;
    setState(() {
      _userType = newType;
      _resetForm();
    });
  }

  void _resetForm() {
    _fullNameController.clear();
    _mobileController.clear();
    _emailController.clear();
    _orgNameController.clear();
    _contactPersonController.clear();
    _cityController.clear();
    _villageController.clear();
    _addressController.clear();
    _aadhaarController.clear();
    _aadhaarOtpController.clear();
    _panController.clear();

    _areaClassification = 'URBAN';
    _stateId = 1;
    _district = null;
    _taluka = null;
    _districtId = null;
    _talukaId = null;
    _censusId = null;

    _kycFileName = null;
    _aadhaarDocUrl = null;
    _panFileName = null;
    _panDocUrl = null;
    _aadhaarFileName = null;
    _aadhaarSignatoryDocUrl = null;
    _isUploadingAadhaarDoc = false;
    _isUploadingPanDoc = false;

    _localAadhaarPath = null;
    _localAadhaarName = null;
    _localAadhaarBytes = null;
    _localPanPath = null;
    _localPanName = null;
    _localPanBytes = null;
    _localSignatoryAadhaarPath = null;
    _localSignatoryAadhaarName = null;
    _localSignatoryAadhaarBytes = null;

    _aadhaarClientId = null;
    _isAadhaarOtpSent = false;
    _isAadhaarVerified = false;
    _isCheckingAadhaar = false;
    _isGeneratingAadhaarOtp = false;
    _isVerifyingAadhaarOtp = false;
    _aadhaarError = null;
    _aadhaarOtpError = null;
    _aadhaarVerifiedData = null;

    _isCheckingPan = false;
    _isVerifyingPan = false;
    _isPanVerified = false;
    _panClientId = null;
    _panClientName = null;
    _panError = null;

    _resendTimer?.cancel();
    _resendTimer = null;
    _timerCountdown = 0;

    _declarationConfirmed = false;
    _errors.clear();
    _isSubmitting = false;

    _locationResetKey++;
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _orgNameController.dispose();
    _contactPersonController.dispose();
    _cityController.dispose();
    _villageController.dispose();
    _addressController.dispose();
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
    final l10n = AppLocalizations.of(context)!;
    final aadh = _aadhaarController.text.replaceAll(' ', '').trim();
    if (aadh.length != 12 || !RegExp(r'^\d{12}$').hasMatch(aadh)) {
      setState(() => _aadhaarError = l10n.enterValidAadhaarNumber);
      return;
    }
    
    if (aadh.startsWith('0') || aadh.startsWith('1')) {
      setState(() => _aadhaarError = l10n.aadhaarCannotStartWithZeroOrOne);
      return;
    }

    setState(() {
      _aadhaarError = null;
      _aadhaarOtpError = null;
      _isCheckingAadhaar = true;
    });

    final repo = ref.read(aadhaarKycRepositoryProvider);

    // 1. Check if Aadhaar already exists
    final mobileNo = _mobileController.text.trim();
    final existRes = await repo.checkAadhaarExists(aadh, mobileNo: mobileNo);
    if (!mounted) return;

    final existStatusCode = existRes.statusCode.trim();
    final existStatusMsg = existRes.statusMessage.toLowerCase();

    if (existStatusCode == '408' ||
        existStatusCode == '504' ||
        existStatusCode == '500' ||
        existStatusCode == '502' ||
        existStatusCode == '503' ||
        existStatusCode == '0' ||
        existStatusMsg.contains('aadhaar server error') ||
        existStatusMsg.contains('timeout') ||
        existStatusMsg.contains('timed out') ||
        existStatusMsg.contains('server error') ||
        existStatusMsg.contains('unexpected') ||
        existStatusMsg.contains('network error')) {
      setState(() {
        _isCheckingAadhaar = false;
        _aadhaarError = l10n.aadhaarServerError;
      });
      return;
    }

    if (existRes.exists) {
      setState(() {
        _isCheckingAadhaar = false;
        _aadhaarError = l10n.aadhaarAlreadyRegistered;
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
        _aadhaarOtpError = null;
        _startResendTimer();
      } else {
        final genStatusCode = genRes.statusCode.trim();
        final genRawMsg = genRes.message?.trim() ?? '';

        final isServerErrorOrTimeout =
            genStatusCode == '408' ||
            genStatusCode == '504' ||
            genStatusCode == '500' ||
            genStatusCode == '502' ||
            genStatusCode == '503' ||
            genStatusCode == '0' ||
            genRawMsg.isEmpty;

         if (isServerErrorOrTimeout || genStatusCode == '429') {
          _aadhaarError = l10n.aadhaarServerError;
        } else if (genStatusCode == '422') {
          _aadhaarError = l10n.invalidAadhaarNumber;
        }
      }
    });
  }

  Future<void> _handleVerifyAadhaarOtp() async {
    final l10n = AppLocalizations.of(context)!;
    final otp = _aadhaarOtpController.text.trim();
    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      setState(() => _aadhaarOtpError = l10n.enterValidAadhaarOtp);
      return;
    }

    if (_aadhaarClientId == null) {
      setState(() => _aadhaarOtpError = l10n.aadhaarSendOtpError);
      return;
    }

    setState(() {
      _aadhaarError = null;
      _aadhaarOtpError = null;
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
        _aadhaarOtpError = null;
        _aadhaarError = null;
        if (_errors.containsKey('aadhaar')) _errors.remove('aadhaar');

        final verifiedName = verifyRes.fullName;
        if (verifiedName != null && verifiedName.trim().isNotEmpty) {
          try {
            final mobile = _mobileController.text.trim();
            final aadh = _aadhaarController.text.replaceAll(' ', '').trim();
            SharedPreferences.getInstance().then((prefs) {
              if (mobile.isNotEmpty) prefs.setString('aadhaar_verified_name_$mobile', verifiedName.trim());
              if (aadh.isNotEmpty) prefs.setString('aadhaar_verified_name_$aadh', verifiedName.trim());
              prefs.setString('aadhaar_verified_name_last', verifiedName.trim());
            });
          } catch (_) {}
        }
      } else {
        final statusCode = verifyRes.statusCode.trim();
        final rawMsg = verifyRes.message?.trim() ?? '';

        final isServerErrorOrTimeout =
            statusCode == '408' ||
            statusCode == '504' ||
            statusCode == '500' ||
            statusCode == '502' ||
            statusCode == '503' ||
            statusCode == '0' ||
            rawMsg.isEmpty;

        final isExplicitInvalidOtp = !isServerErrorOrTimeout && (statusCode == '422');

        if (isExplicitInvalidOtp) {
          _aadhaarOtpError = l10n.invalidOtpServer;
        } else {
          _aadhaarOtpError = l10n.aadhaarServerError;
        }
      }
    });
  }

  Future<void> _pickAndUploadDocument({bool isPan = false, bool isSignatoryAadhaar = false}) async {
    final l10n = AppLocalizations.of(context)!;
    final docType = isPan ? 'PAN Card' : 'Aadhaar Card';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bottomSheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(l10n.cameraBtn),
                onTap: () async {
                  Navigator.pop(bottomSheetCtx);
                  final hasPerm = await DocumentPermissionHelper.requestUploadPermission(
                    context: context,
                    source: DocumentUploadSource.camera,
                    documentType: docType,
                  );
                  if (!hasPerm) return;
                  _processPickImage(ImageSource.camera, isPan: isPan, isSignatoryAadhaar: isSignatoryAadhaar);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.galleryBtn),
                onTap: () async {
                  Navigator.pop(bottomSheetCtx);
                  final hasPerm = await DocumentPermissionHelper.requestUploadPermission(
                    context: context,
                    source: DocumentUploadSource.gallery,
                    documentType: docType,
                  );
                  if (!hasPerm) return;
                  _processPickImage(ImageSource.gallery, isPan: isPan, isSignatoryAadhaar: isSignatoryAadhaar);
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(l10n.fileDocumentBtn),
                onTap: () async {
                  Navigator.pop(bottomSheetCtx);
                  final hasPerm = await DocumentPermissionHelper.requestUploadPermission(
                    context: context,
                    source: DocumentUploadSource.file,
                    documentType: docType,
                  );
                  if (!hasPerm) return;
                  _processPickFile(isPan: isPan, isSignatoryAadhaar: isSignatoryAadhaar);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processPickImage(ImageSource source, {bool isPan = false, bool isSignatoryAadhaar = false}) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) return;
      final bytes = await pickedFile.readAsBytes();
      await _setLocalDocumentFile(pickedFile.path, pickedFile.name, bytes, isPan: isPan, isSignatoryAadhaar: isSignatoryAadhaar);
    } catch (e) {
      if (DocumentPermissionHelper.isPermissionException(e)) {
        if (!mounted) return;
        setState(() {
          _isUploadingAadhaarDoc = false;
          _isUploadingPanDoc = false;
        });
        await DocumentPermissionHelper.handlePermissionException(
          context: context,
          source: source == ImageSource.camera ? DocumentUploadSource.camera : DocumentUploadSource.gallery,
          documentType: isPan ? 'PAN Card' : 'Aadhaar Card',
          error: e,
        );
        return;
      }
      if (e.toString().contains('access_denied')) {
        if (!mounted) return;
        setState(() {
          _isUploadingAadhaarDoc = false;
          _isUploadingPanDoc = false;
        });
        return;
      }
      if (!mounted) return;
      final key = isPan ? 'panFile' : (isSignatoryAadhaar ? 'aadhaarFile' : 'kycFile');
      String errorMessage = e.toString();
      if (errorMessage.contains('413')) {
        errorMessage = 'File size is too large. Please select a smaller file (under 5MB).';
      } else if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      } else if (errorMessage.contains('DioException')) {
        errorMessage = 'Network error occurred during upload. Please try again.';
      }
      setState(() {
        _isUploadingAadhaarDoc = false;
        _isUploadingPanDoc = false;
        _errors[key] = errorMessage;
      });
    }
  }

  Future<void> _processPickFile({bool isPan = false, bool isSignatoryAadhaar = false}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final ext = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : '';
      if (!['pdf', 'jpg', 'jpeg', 'png'].contains(ext)) {
        final key = isPan ? 'panFile' : (isSignatoryAadhaar ? 'aadhaarFile' : 'kycFile');
        setState(() {
          _errors[key] = l10n.unsupportedFileFormat;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.unsupportedFileFormat),
            backgroundColor: AppColors.danger700,
          ),
        );
        return;
      }
      await _setLocalDocumentFile(file.path ?? '', file.name, file.bytes, isPan: isPan, isSignatoryAadhaar: isSignatoryAadhaar);
    } catch (e) {
      if (DocumentPermissionHelper.isPermissionException(e)) {
        if (!mounted) return;
        setState(() {
          _isUploadingAadhaarDoc = false;
          _isUploadingPanDoc = false;
        });
        await DocumentPermissionHelper.handlePermissionException(
          context: context,
          source: DocumentUploadSource.file,
          documentType: isPan ? 'PAN Card' : 'Aadhaar Card',
          error: e,
        );
        return;
      }
      if (e.toString().contains('access_denied')) {
        if (!mounted) return;
        setState(() {
          _isUploadingAadhaarDoc = false;
          _isUploadingPanDoc = false;
        });
        return;
      }
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final key = isPan ? 'panFile' : (isSignatoryAadhaar ? 'aadhaarFile' : 'kycFile');
      String errorMessage = e.toString();
      if (errorMessage.contains('413') ||
          errorMessage.contains('415') ||
          errorMessage.toLowerCase().contains('unsupported file format')) {
        errorMessage = l10n.unsupportedFileFormat;
      } else if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      } else if (errorMessage.contains('DioException')) {
        errorMessage = 'Network error occurred during upload. Please try again.';
      }
      setState(() {
        _isUploadingAadhaarDoc = false;
        _isUploadingPanDoc = false;
        _errors[key] = errorMessage;
      });
    }
  }

  Future<void> _setLocalDocumentFile(String path, String name, Uint8List? bytes, {bool isPan = false, bool isSignatoryAadhaar = false}) async {
    final key = isPan ? 'panFile' : (isSignatoryAadhaar ? 'aadhaarFile' : 'kycFile');

    setState(() {
      if (isPan) {
        _localPanPath = path;
        _localPanName = name;
        _localPanBytes = bytes;
        _panFileName = name;
        _panDocUrl = null;
      } else if (isSignatoryAadhaar) {
        _localSignatoryAadhaarPath = path;
        _localSignatoryAadhaarName = name;
        _localSignatoryAadhaarBytes = bytes;
        _aadhaarFileName = name;
        _aadhaarSignatoryDocUrl = null;
      } else {
        _localAadhaarPath = path;
        _localAadhaarName = name;
        _localAadhaarBytes = bytes;
        _kycFileName = name;
        _aadhaarDocUrl = null;
      }
      _errors.remove(key);
    });
  }

  Future<void> _handleVerifyPan() async {
    final l10n = AppLocalizations.of(context)!;
    final pan = _panController.text.trim().toUpperCase();
    if (pan.isEmpty) {
      setState(() => _panError = l10n.orgPanRequired);
      return;
    }
    if (pan.length != 10 || !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(pan)) {
      setState(() => _panError = l10n.validPanRequired);
      return;
    }

    final mobile = _mobileController.text.trim();
    if (mobile.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      setState(() => _panError = l10n.validMobileRequired);
      return;
    }

    setState(() {
      _panError = null;
      _isCheckingPan = true;
    });

    final authRepo = ref.read(authRepositoryProvider);

    // Step 1: Duplicate check via check-pan-exists-VehicleOwner
    final checkRes = await authRepo.checkPanExists(
      panNo: pan,
      mobileNo: mobile,
      id: 0,
      userCategory: 2,
    );

    if (!mounted) return;

    if (checkRes.exists) {
      setState(() {
        _isCheckingPan = false;
        _isPanVerified = false;
        _panError = ApiErrorLocalizer.localize(
          context,
          checkRes.statusMessage,
          defaultMessage: l10n.panAlreadyRegistered,
        );
      });
      return;
    }

    // Step 2: Verify PAN number via pan-verification_v1
    setState(() {
      _isCheckingPan = false;
      _isVerifyingPan = true;
    });

    final verifyRes = await authRepo.verifyPan(panNo: pan, userId: 0);

    if (!mounted) return;

    setState(() {
      _isVerifyingPan = false;
      if (verifyRes.isSuccess) {
        _isPanVerified = true;
        _panClientId = verifyRes.clientId;
        _panClientName = verifyRes.clientName;
        _panError = null;
        if (_errors.containsKey('pan')) _errors.remove('pan');
      } else {
        _isPanVerified = false;
        final rawMsg = verifyRes.statusMessage.trim();
        _panError = ApiErrorLocalizer.localize(
          context,
          rawMsg,
          defaultMessage: l10n.invalidPanNumber,
        );
      }
    });
  }

  void _back() {
    setState(() {
      _errors.clear();
      _aadhaarError = null;
      _panError = null;
      _aadhaarOtpError = null;
      if (_step <= 0) {
        context.pop();
      } else {
        _step--;
      }
    });
  }


  void _next() async {
    final found = _validateStep();
    if (found.isNotEmpty) {
      setState(() {
        _errors = found;
        _aadhaarError = found['aadhaar'];
        _panError = found['pan'];
      });
      return;
    }

    if (_step < 2) {
      setState(() {
        _errors.clear();
        _aadhaarError = null;
        _panError = null;
        _aadhaarOtpError = null;
        _aadhaarController.text = _aadhaarController.text.replaceAll(' ', '').trim();
        _step++;
      });
      return;
    }

    // Step 2 complete -> Directly submit Sign Up API without OTP verification
    setState(() => _isSubmitting = true);
    final mobile = _mobileController.text.trim();
    final l10n = AppLocalizations.of(context)!;

    final repo = ref.read(aadhaarKycRepositoryProvider);
    Future<String?> uploadLocal(String? path, String? name, Uint8List? bytes) async {
      if (path == null) return null;
      final res = await repo.uploadAadhaarDocument(filePath: path, fileName: name ?? 'doc', bytes: bytes);
      if (res.isSuccess && res.responseData != null) return res.responseData;
      if (res.statusCode == '413' ||
          res.statusCode == '415' ||
          res.statusMessage.toLowerCase().contains('unsupported file format') ||
          res.statusMessage.toLowerCase().contains('valid pdf or image')) {
        throw Exception(l10n.unsupportedFileFormat);
      }
      throw Exception(
        res.statusMessage.isNotEmpty
            ? ApiErrorLocalizer.localizeWithL10n(l10n, res.statusMessage, defaultMessage: l10n.docUploadFailed)
            : l10n.docUploadFailed,
      );
    }

    try {
      if (_localAadhaarPath != null) {
        final resUrl = await uploadLocal(_localAadhaarPath, _localAadhaarName, _localAadhaarBytes);
        if (resUrl != null) _aadhaarDocUrl = resUrl;
      }
      if (_localPanPath != null) {
        final resUrl = await uploadLocal(_localPanPath, _localPanName, _localPanBytes);
        if (resUrl != null) _panDocUrl = resUrl;
      }
      if (_localSignatoryAadhaarPath != null) {
        final resUrl = await uploadLocal(_localSignatoryAadhaarPath, _localSignatoryAadhaarName, _localSignatoryAadhaarBytes);
        if (resUrl != null) _aadhaarSignatoryDocUrl = resUrl;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      String errorMsg = e.toString();
      if (errorMsg.startsWith('Exception: ')) {
        errorMsg = errorMsg.substring(11);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
      return;
    }

    final isOrg = _userType == UserType.organization;

    final Map<String, dynamic> signUpPayload = {
      'id': 0,
      'name': isOrg ? _orgNameController.text.trim() : _fullNameController.text.trim(),
      'mobileNo': mobile,
      'aadharCardNo': _aadhaarController.text.replaceAll(' ', '').trim(),
      'emailId': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'stateId': _stateId ?? 1,
      'districtId': _districtId ?? 0,
      'talukaId': _talukaId ?? 0,
      'isTown': _areaClassification == 'URBAN',
      'censusId': _censusId ?? 0,
      'createdBy': 0,
      'flag': 'i',
      'panNo': isOrg ? _panController.text.trim().toUpperCase() : '',
      'gstNo': '',
      'consumerType': isOrg ? CONSUMER_TYPE_ORGANISATION : CONSUMER_TYPE_INDIVIDUAL,
      'rationCardId': '',
      'aadharDoc': isOrg ? (_aadhaarSignatoryDocUrl ?? _aadhaarDocUrl ?? '') : (_aadhaarDocUrl ?? ''),
      'panDoc': isOrg ? (_panDocUrl ?? '') : '',
      'rcDoc': '',
      'pinCode': '',
      'gstDoc': '',
      'isAadharVerified': _isAadhaarVerified,
      'aadharVerifiedName': _isAadhaarVerified ? (_aadhaarVerifiedData?.fullName ?? '') : '',
      'aadharClientId': _isAadhaarVerified ? (_aadhaarClientId ?? '') : '',
      'panClientId': (isOrg && _isPanVerified) ? (_panClientId ?? '') : '',
      'isPanVerified': isOrg ? _isPanVerified : false,
      'isCompulsoryVerification': false,
      'otp': '',
      'pageName': 'ConsumerReg',
      'contactPersonName': isOrg ? _contactPersonController.text.trim() : '',
      'insertDocuments': <Map<String, dynamic>>[],
    };

    final response = await ref.read(authRepositoryProvider).consumerSignUp(signUpPayload);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (response.isSuccess) {
      final verifiedName = _aadhaarVerifiedData?.fullName;
      if (verifiedName != null && verifiedName.trim().isNotEmpty) {
        try {
          final aadh = _aadhaarController.text.replaceAll(' ', '').trim();
          final prefs = await SharedPreferences.getInstance();
          if (mobile.isNotEmpty) await prefs.setString('aadhaar_verified_name_$mobile', verifiedName.trim());
          if (aadh.isNotEmpty) await prefs.setString('aadhaar_verified_name_$aadh', verifiedName.trim());
          await prefs.setString('aadhaar_verified_name_last', verifiedName.trim());
        } catch (_) {}
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.registrationSuccess),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/login', extra: mobile);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiErrorLocalizer.localize(
            context,
            response.statusMessage,
            defaultMessage: AppLocalizations.of(context)!.registrationFailed,
          )),
          backgroundColor: const Color(0xFF2563EB),
        ),
      );
    }
  }



  Map<String, String> _validateStep() {
    final found = <String, String>{};

    final l10n = AppLocalizations.of(context)!;
    if (_step == 1) {
      if (_userType == UserType.normalConsumer) {
        if (_fullNameController.text.trim().isEmpty) {
          found['fullName'] = l10n.fullNameRequired;
        }
        final mobile = _mobileController.text.trim();
        if (mobile.isEmpty) {
          found['mobile'] = l10n.mobileRequired;
        } else if (mobile.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
          found['mobile'] = l10n.validMobileRequired;
        }
        if (_addressController.text.trim().isEmpty) {
          found['address'] = l10n.addressRequired;
        } else if (RegExp(r'[\u0900-\u097F\uA8E0-\uA8FF]').hasMatch(_addressController.text)) {
          found['address'] = l10n.marathiNotAcceptedInAddress;
        }
        if (_emailController.text.trim().isNotEmpty) {
          final email = _emailController.text.trim();
          if (RegExp(r'[\u0900-\u097F\uA8E0-\uA8FF]').hasMatch(email)) {
            found['email'] = l10n.marathiNotAcceptedInEmail;
          } else if (email.startsWith('.') || email.contains('..')) {
            found['email'] = l10n.emailConsecutiveDots;
          } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
            found['email'] = l10n.validEmailRequired;
          }
        }
        if (_districtId == null) {
          found['district'] = l10n.districtRequired;
        }
        if (_talukaId == null && _areaClassification != 'URBAN') {
          found['taluka'] = l10n.talukaRequired;
        }
        if (_censusId == null) {
          found['villageCity'] = _areaClassification == 'URBAN'
              ? l10n.cityCorpRequired
              : l10n.villageRequired;
        }
      } else {
        // Organisation registration Step 1 validation
        if (_orgNameController.text.trim().isEmpty) {
          found['orgName'] = l10n.orgNameRequired;
        } else if (RegExp(r'[0-9\u0966-\u096F]').hasMatch(_orgNameController.text)) {
          found['orgName'] = l10n.orgNameCannotContainNumbers;
        }
        final email = _emailController.text.trim();
        if (email.isEmpty) {
          found['email'] = l10n.emailRequired;
        } else if (RegExp(r'[\u0900-\u097F\uA8E0-\uA8FF]').hasMatch(email)) {
          found['email'] = l10n.marathiNotAcceptedInEmail;
        } else if (email.startsWith('.') || email.contains('..')) {
          found['email'] = l10n.emailConsecutiveDots;
        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
          found['email'] = l10n.validEmailRequired;
        }
        if (_addressController.text.trim().isEmpty) {
          found['address'] = l10n.addressRequired;
        } else if (RegExp(r'[\u0900-\u097F\uA8E0-\uA8FF]').hasMatch(_addressController.text)) {
          found['address'] = l10n.marathiNotAcceptedInAddress;
        }
        if (_districtId == null) {
          found['district'] = l10n.districtRequired;
        }
        if (_talukaId == null && _areaClassification != 'URBAN') {
          found['taluka'] = l10n.talukaRequired;
        }
        if (_censusId == null) {
          found['villageCity'] = _areaClassification == 'URBAN'
              ? l10n.cityCorpRequired
              : l10n.villageRequired;
        }
        if (_contactPersonController.text.trim().isEmpty) {
          found['contactPersonName'] = l10n.contactPersonNameRequired;
        }
        final mobile = _mobileController.text.trim();
        if (mobile.isEmpty) {
          found['mobile'] = l10n.mobileRequired;
        } else if (mobile.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
          found['mobile'] = l10n.validMobileRequired;
        }
        final aadh = _aadhaarController.text.replaceAll(' ', '').trim();
        if (aadh.isNotEmpty) {
          if (aadh.length != 12 || !RegExp(r'^\d{12}$').hasMatch(aadh)) {
            found['aadhaar'] = l10n.enterValidAadhaarNumber;
          } else if (aadh.startsWith('0') || aadh.startsWith('1')) {
            found['aadhaar'] = l10n.aadhaarCannotStartWithZeroOrOne;
          }
        }
      }
    } else if (_step == 2) {
      if (!_declarationConfirmed) {
        found['declaration'] = l10n.confirmDeclarationRequired;
      }

      if (_userType == UserType.normalConsumer) {
        final aadh = _aadhaarController.text.replaceAll(' ', '').trim();
        final hasAadhaarDoc = _localAadhaarPath != null || _aadhaarDocUrl != null;
        final hasAadhaarInput = aadh.isNotEmpty || hasAadhaarDoc;

        if (hasAadhaarInput) {
          if (aadh.isEmpty || aadh.length != 12 || !RegExp(r'^\d{12}$').hasMatch(aadh)) {
            found['aadhaar'] = l10n.enterValidAadhaarNumber;
          } else if (aadh.startsWith('0') || aadh.startsWith('1')) {
            found['aadhaar'] = l10n.aadhaarCannotStartWithZeroOrOne;
          } else if (!_isAadhaarVerified) {
            found['aadhaar'] = l10n.aadhaarVerificationRequired;
          }
        }
      } else {
        // Organisation registration Step 2 validation

        final pan = _panController.text.trim().toUpperCase();
        final hasPanDoc = _localPanPath != null || _panDocUrl != null;
        final hasPanInput = pan.isNotEmpty || hasPanDoc;

        if (hasPanInput) {
          if (pan.isEmpty) {
            found['pan'] = l10n.orgPanRequired;
          } else if (pan.length != 10 || !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(pan)) {
            found['pan'] = l10n.validPanRequired;
          } else if (!_isPanVerified) {
            found['pan'] = l10n.verifyOrgPanBeforeRegistration;
          }
        }

        final aadh = _aadhaarController.text.replaceAll(' ', '').trim();
        final hasAadhaarDoc = _localSignatoryAadhaarPath != null || _aadhaarSignatoryDocUrl != null || _localAadhaarPath != null || _aadhaarDocUrl != null;
        final hasAadhaarInput = aadh.isNotEmpty || hasAadhaarDoc;

        if (hasAadhaarInput) {
          if (aadh.isEmpty) {
            found['aadhaar'] = l10n.enterValidAadhaarNumber;
          } else if (aadh.length != 12 || !RegExp(r'^\d{12}$').hasMatch(aadh)) {
            found['aadhaar'] = l10n.enterValidAadhaarNumber;
          } else if (aadh.startsWith('0') || aadh.startsWith('1')) {
            found['aadhaar'] = l10n.aadhaarCannotStartWithZeroOrOne;
          } else if (!_isAadhaarVerified) {
            found['aadhaar'] = l10n.aadhaarVerificationRequired;
          }
        }
      }
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
                            ? (_userType == UserType.organization ? AppLocalizations.of(context)!.continueBtn : AppLocalizations.of(context)!.continueToKyc)
                            : AppLocalizations.of(context)!.completeRegistration,
                    isLoading: _isSubmitting,
                    fullWidth: true,
                    size: AppButtonSize.large,
                    onPressed: _isSubmitting ? null : _next,
                  ),
                  // skipAadhaar button removed per user request
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.5),
        ),

        const SizedBox(height: 24),

        // Individual Card
        InkWell(
          onTap: () => _onConsumerTypeChanged(UserType.normalConsumer),
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  child: Text(
                    l10n.individual,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Organization Card
        InkWell(
          onTap: () => _onConsumerTypeChanged(UserType.organization),
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  child: Text(
                    l10n.organization,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),
        Row(
          children: [
            Text(l10n.alreadyHaveAccount.trim(), style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
            const SizedBox(width: 4),
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
    if (_userType == UserType.organization) {
      return _buildOrgStep1Details();
    }
    return _buildIndividualStep1Details();
  }

  // -------------------------------------------------------------
  // STEP 1: Organisation Details (Matches Reference Screenshot 1)
  // -------------------------------------------------------------
  Widget _buildOrgStep1Details() {
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
                child: const Icon(
                  Icons.business,
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
                      l10n.organization,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.personaOrganizationDesc,
                      style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _step = 0),
                child: Text(l10n.changeBtn, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 1. ORGANISATION DETAILS SECTION
        _buildSectionHeader(Icons.domain_outlined, l10n.organisationDetailsHeader),
        const SizedBox(height: 14),

        _buildOrgFieldLabel(l10n.orgNameRequiredLabel),
        const SizedBox(height: 6),
        _buildOrgTextField(
          controller: _orgNameController,
          hint: l10n.enterOrgNameHint,
          error: _errors['orgName'],
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-Z ]'),
            ),
          ],
          onChanged: (val) {
            if (val.isNotEmpty && _errors.containsKey('orgName')) {
              setState(() => _errors.remove('orgName'));
            }
          },
        ),
        const SizedBox(height: 14),

        _buildOrgFieldLabel(l10n.emailIdRequiredLabel),
        const SizedBox(height: 6),
        _buildOrgTextField(
          controller: _emailController,
          hint: l10n.enterEmailHint,
          keyboardType: TextInputType.emailAddress,
          error: _errors['email'],
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'[\u0900-\u097F\uA8E0-\uA8FF\s]')),
          ],
          onChanged: (val) {
            if (val.isNotEmpty && _errors.containsKey('email')) {
              setState(() => _errors.remove('email'));
            }
          },
        ),
        const SizedBox(height: 14),

        _buildOrgFieldLabel(l10n.addressRequiredLabel),
        const SizedBox(height: 6),
        _buildOrgTextField(
          controller: _addressController,
          hint: l10n.registeredOfficeAddressHint,
          error: _errors['address'],
          minLines: 2,
          maxLines: 3,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'[\u0900-\u097F\uA8E0-\uA8FF]')),
          ],
          onChanged: (val) {
            if (val.isNotEmpty && _errors.containsKey('address')) {
              setState(() => _errors.remove('address'));
            }
          },
        ),
        const SizedBox(height: 22),

        // 2. LOCATION DETAILS SECTION
        _buildSectionHeader(Icons.location_on, l10n.locationDetailsHeader),
        const SizedBox(height: 14),

        LocationDropdownSection(
          key: ValueKey('loc_section_${_userType}_$_locationResetKey'),
          initialCategory: _areaClassification,
          initialDistrict: _district,
          initialTaluka: _taluka,
          initialVillageCity: _areaClassification == 'URBAN' ? _cityController.text : _villageController.text,
          districtError: _errors['district'],
          talukaError: _errors['taluka'],
          villageCityError: _errors['villageCity'],
          onChanged: (locData) {
            setState(() {
              _areaClassification = locData.category ?? 'URBAN';
              _district = locData.districtName;
              _taluka = locData.talukaName;
              _stateId = locData.stateId ?? 1;
              _districtId = locData.district?.id;
              _talukaId = locData.taluka?.id;
              _censusId = locData.villageCity?.id;

              if (_districtId != null) _errors.remove('district');
              if (_talukaId != null) _errors.remove('taluka');
              if (_censusId != null) _errors.remove('villageCity');

              if (locData.category == 'RURAL') {
                _villageController.text = locData.villageCityName;
                _cityController.text = '';
              } else {
                _cityController.text = locData.villageCityName;
                _villageController.text = '';
              }
            });
          },
        ),
        const SizedBox(height: 22),

        // 3. CONTACT PERSON DETAILS SECTION
        _buildSectionHeader(Icons.person, l10n.contactPersonDetailsHeader),
        const SizedBox(height: 14),

        _buildOrgFieldLabel(l10n.contactPersonNameRequiredLabel),
        const SizedBox(height: 6),
        _buildOrgTextField(
          controller: _contactPersonController,
          hint: l10n.enterContactPersonNameHint,
          error: _errors['contactPersonName'],
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
          onChanged: (val) {
            if (val.isNotEmpty && _errors.containsKey('contactPersonName')) {
              setState(() => _errors.remove('contactPersonName'));
            }
          },
        ),
        const SizedBox(height: 14),

        // Mobile No. *
        _buildOrgFieldLabel(l10n.mobileNumberRequiredLabel),
        const SizedBox(height: 6),
        TextField(
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            hintText: l10n.enterTenDigitMobileHint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted, fontWeight: FontWeight.normal),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _errors.containsKey('mobile') ? AppColors.danger600 : AppColors.lineStrong),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _errors.containsKey('mobile') ? AppColors.danger600 : AppColors.lineStrong),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _errors.containsKey('mobile') ? AppColors.danger600 : AppColors.primary700, width: 1.5),
            ),
          ),
          onChanged: (val) {
            if (val.isNotEmpty && _errors.containsKey('mobile')) {
              setState(() => _errors.remove('mobile'));
            }
          },
        ),
        if (_errors.containsKey('mobile')) ...[
          const SizedBox(height: 4),
          Text(_errors['mobile']!, style: const TextStyle(fontSize: 11, color: AppColors.danger700)),
        ],
        const SizedBox(height: 14),

        // Contact Person Aadhaar No. (optional)
        _buildOrgFieldLabel(l10n.contactPersonAadhaarOptionalLabel),
        const SizedBox(height: 6),
        TextField(
          controller: _aadhaarController,
          keyboardType: TextInputType.number,
          maxLength: 12,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            hintText: l10n.twelveDigitAadhaarHint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted, fontWeight: FontWeight.normal),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _errors.containsKey('aadhaar') ? AppColors.danger600 : AppColors.lineStrong),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _errors.containsKey('aadhaar') ? AppColors.danger600 : AppColors.lineStrong),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _errors.containsKey('aadhaar') ? AppColors.danger600 : AppColors.primary700, width: 1.5),
            ),
          ),
          onChanged: (val) {
            setState(() {
              if (_errors.containsKey('aadhaar')) _errors.remove('aadhaar');
              _aadhaarError = null;
            });
          },
        ),
        if (_errors.containsKey('aadhaar')) ...[
          const SizedBox(height: 4),
          Text(_errors['aadhaar']!, style: const TextStyle(fontSize: 11, color: AppColors.danger700)),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 1: Individual Registration Details (Unchanged)
  // -------------------------------------------------------------
  Widget _buildIndividualStep1Details() {
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
                child: const Icon(
                  Icons.person,
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
                      l10n.individual,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.personaIndividualDesc,
                      style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _step = 0),
                child: Text(l10n.changeBtn, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
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
          hint: l10n.enterFullName,
          onChanged: (val) {
            if (val.isNotEmpty && _errors.containsKey('fullName')) {
              setState(() => _errors.remove('fullName'));
            }
          },
        ),
        const SizedBox(height: 16),

        // Mobile Number
        _buildFieldLabel(l10n.mobileNumber),
        const SizedBox(height: 6),
        TextField(
          controller: _mobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (val) {
            if (val.isNotEmpty && _errors.containsKey('mobile')) {
              setState(() => _errors.remove('mobile'));
            }
          },
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            hintText: l10n.tenDigitNumber,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted, fontWeight: FontWeight.normal),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _errors.containsKey('mobile') ? AppColors.danger600 : AppColors.lineStrong),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _errors.containsKey('mobile') ? AppColors.danger600 : AppColors.lineStrong),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _errors.containsKey('mobile') ? AppColors.danger600 : AppColors.primary700, width: 1.5),
            ),
          ),
        ),
        if (_errors.containsKey('mobile')) ...[
          const SizedBox(height: 4),
          Text(_errors['mobile']!, style: const TextStyle(fontSize: 12, color: AppColors.danger700)),
        ],
        const SizedBox(height: 16),

        _buildFieldLabel(l10n.emailOptional),
        const SizedBox(height: 6),
        _buildTextField(
          _emailController,
          hint: l10n.enterEmail,
          keyboardType: TextInputType.emailAddress,
          error: _errors['email'],
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'[\u0900-\u097F\uA8E0-\uA8FF\s]')),
          ],
          onChanged: (val) {
            if (val.isNotEmpty && _errors.containsKey('email')) {
              setState(() => _errors.remove('email'));
            }
          },
        ),
        const SizedBox(height: 20),

        // Dynamic Location Dropdowns
        LocationDropdownSection(
          key: ValueKey('loc_section_${_userType}_$_locationResetKey'),
          initialCategory: _areaClassification,
          initialDistrict: _district,
          initialTaluka: _taluka,
          initialVillageCity: _areaClassification == 'URBAN' ? _cityController.text : _villageController.text,
          districtError: _errors['district'],
          talukaError: _errors['taluka'],
          villageCityError: _errors['villageCity'],
          onChanged: (locData) {
            setState(() {
              _areaClassification = locData.category ?? 'URBAN';
              _district = locData.districtName;
              _taluka = locData.talukaName;
              _stateId = locData.stateId ?? 1;
              _districtId = locData.district?.id;
              _talukaId = locData.taluka?.id;
              _censusId = locData.villageCity?.id;

              if (_districtId != null) _errors.remove('district');
              if (_talukaId != null) _errors.remove('taluka');
              if (_censusId != null) _errors.remove('villageCity');

              if (locData.category == 'RURAL') {
                _villageController.text = locData.villageCityName;
                _cityController.text = '';
              } else {
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
        _buildTextField(
          _addressController,
          hint: l10n.addressHint,
          error: _errors['address'],
          keyboardType: TextInputType.streetAddress,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'[\u0900-\u097F\uA8E0-\uA8FF]')),
          ],
          onChanged: (val) {
            if (val.isNotEmpty && _errors.containsKey('address')) {
              setState(() => _errors.remove('address'));
            }
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 2: KYC Verification Dispatcher
  // -------------------------------------------------------------
  Widget _buildStep2Kyc() {
    if (_userType == UserType.organization) {
      return _buildOrgStep2Kyc();
    }
    return _buildIndividualStep2Kyc();
  }

  // -------------------------------------------------------------
  // STEP 2: Organisation KYC (Matches Reference Screenshot 2)
  // -------------------------------------------------------------
  Widget _buildOrgStep2Kyc() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.orgKycVerification,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.5),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Card 1: Contact Person Aadhaar Verification (Same functionality as Individual)
        _buildAadhaarVerificationCard(isOrg: true),
        const SizedBox(height: 16),

        // Upload Contact Person Aadhaar Document (Optional Document)
        _buildUploadCard(
          title: l10n.uploadAadhaarDocOptional,
          hint: l10n.chooseAadhaarCardPhotoPdf,
          fileName: _localSignatoryAadhaarName ?? _localAadhaarName ?? _aadhaarFileName,
          docUrl: _aadhaarSignatoryDocUrl ?? _aadhaarDocUrl,
          localPath: _localSignatoryAadhaarPath ?? _localAadhaarPath,
          isLoading: _isUploadingAadhaarDoc,
          error: _errors['aadhaarFile'],
          onPick: () => _pickAndUploadDocument(isPan: false, isSignatoryAadhaar: true),
          onRemove: () {
            setState(() {
              _localSignatoryAadhaarPath = null;
              _localSignatoryAadhaarName = null;
              _localSignatoryAadhaarBytes = null;
              _aadhaarFileName = null;
              _aadhaarSignatoryDocUrl = null;
              _localAadhaarPath = null;
              _localAadhaarName = null;
              _localAadhaarBytes = null;
              _aadhaarDocUrl = null;
              if (_errors.containsKey('aadhaarFile')) _errors.remove('aadhaarFile');
            });
          },
        ),
        const SizedBox(height: 16),

        // Card 2: Organisation PAN Verification
        _buildOrgPanVerificationCard(),
        const SizedBox(height: 16),

        // Confirmation Checkbox (Declaration)
        _buildDeclarationCheckbox(),
        const SizedBox(height: 24),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 2: Individual KYC
  // -------------------------------------------------------------
  Widget _buildIndividualStep2Kyc() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.aadhaarKyc,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.5),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Interactive Aadhaar Verification Box
        _buildAadhaarVerificationCard(isOrg: false),
        const SizedBox(height: 16),

        // Upload Aadhaar Card (Optional Document)
        _buildUploadCard(
          title: l10n.uploadAadhaarCardOptional,
          hint: l10n.frontOrCombinedAadhaar,
          fileName: _kycFileName,
          docUrl: _aadhaarDocUrl,
          localPath: _localAadhaarPath,
          isLoading: _isUploadingAadhaarDoc,
          error: _errors['kycFile'],
          onPick: () => _pickAndUploadDocument(isPan: false),
          onRemove: () {
            setState(() {
              _localAadhaarPath = null;
              _localAadhaarBytes = null;
              _kycFileName = null;
              _aadhaarDocUrl = null;
            });
          },
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined, size: 18, color: Color(0xFF15803D)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.aadhaarNonMandatoryNotice,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF166534), height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Confirmation Checkbox (Declaration)
        _buildDeclarationCheckbox(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDeclarationCheckbox() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _declarationConfirmed,
                activeColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                side: const BorderSide(color: Color(0xFF64748B), width: 1.5),
                onChanged: (val) {
                  setState(() {
                    _declarationConfirmed = val ?? false;
                    if (_declarationConfirmed) _errors.remove('declaration');
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _declarationConfirmed = !_declarationConfirmed;
                    if (_declarationConfirmed) _errors.remove('declaration');
                  });
                },
                child: Text(
                  l10n.orgDeclarationText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_errors.containsKey('declaration')) ...[
          const SizedBox(height: 6),
          Text(
            _errors['declaration']!,
            style: const TextStyle(fontSize: 12, color: AppColors.danger700),
          ),
        ],
      ],
    );
  }

  // -------------------------------------------------------------
  // Organisation KYC Cards
  // -------------------------------------------------------------


  Widget _buildOrgPanVerificationCard() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isPanVerified ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF2563EB), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.orgPanVerificationTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isPanVerified ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isPanVerified ? l10n.verifiedStatus : l10n.notVerifiedStatus,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _isPanVerified ? const Color(0xFF15803D) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Field: PAN No. (optional)
          _buildOrgFieldLabel(l10n.panNoOptionalLabel),
          const SizedBox(height: 6),
          TextField(
            controller: _panController,
            keyboardType: TextInputType.visiblePassword,
            maxLength: 10,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: const [
              PanInputFormatter(),
            ],
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.badge, color: Colors.white, size: 16),
                ),
              ),
              hintText: l10n.enterTenDigitPan,
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted, fontWeight: FontWeight.normal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: !_isPanVerified && (_panError != null || _errors.containsKey('pan')) ? AppColors.danger600 : AppColors.lineStrong,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: !_isPanVerified && (_panError != null || _errors.containsKey('pan')) ? AppColors.danger600 : AppColors.lineStrong,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: !_isPanVerified && (_panError != null || _errors.containsKey('pan')) ? AppColors.danger600 : AppColors.primary700,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (val) {
              if (_panError != null) setState(() => _panError = null);
              if (_errors.containsKey('pan')) setState(() => _errors.remove('pan'));
              if (_isPanVerified) setState(() => _isPanVerified = false);
            },
          ),
          if (!_isPanVerified && (_panError != null || _errors.containsKey('pan'))) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, size: 14, color: AppColors.danger700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _panError ?? _errors['pan'] ?? '',
                    style: const TextStyle(fontSize: 12, color: AppColors.danger700, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),

          // Upload PAN Document (with View, Change, Delete actions)
          _buildUploadCard(
            title: l10n.uploadPanDocOptional,
            hint: l10n.choosePanCardPhotoPdf,
            fileName: _localPanName ?? _panFileName,
            docUrl: _panDocUrl,
            localPath: _localPanPath,
            isLoading: _isUploadingPanDoc,
            error: _errors['panFile'],
            onPick: () => _pickAndUploadDocument(isPan: true),
            onRemove: () {
              setState(() {
                _localPanPath = null;
                _localPanName = null;
                _localPanBytes = null;
                _panFileName = null;
                _panDocUrl = null;
                if (_errors.containsKey('panFile')) _errors.remove('panFile');
              });
            },
          ),
          const SizedBox(height: 14),

          // Action: Verify PAN button
          if (!_isPanVerified) ...[
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: (_isCheckingPan || _isVerifyingPan) ? null : _handleVerifyPan,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary700, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: (_isCheckingPan || _isVerifyingPan)
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary700))
                    : Text(
                        l10n.verifyPanBtn,
                        style: const TextStyle(color: AppColors.primary700, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Color(0xFF15803D)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _panClientName ?? _orgNameController.text.trim(),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16, color: Color(0xFF15803D)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      setState(() {
                        _isPanVerified = false;
                        _panClientId = null;
                        _panClientName = null;
                        _panError = null;
                        if (_errors.containsKey('pan')) _errors.remove('pan');
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }



  // -------------------------------------------------------------
  // Section Headers & Field Helpers
  // -------------------------------------------------------------
  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.inkSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.inkSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOrgFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    );
  }

  Widget _buildOrgTextField({
    required TextEditingController controller,
    String? hint,
    String? error,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? minLines,
    int? maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          inputFormatters: [
            FilteringTextInputFormatter.deny(
              RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]|[\u2700-\u27bf])'),
            ),
            ...?inputFormatters,
          ],
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted, fontWeight: FontWeight.normal),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: error != null ? AppColors.danger600 : AppColors.lineStrong,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: error != null ? AppColors.danger600 : AppColors.lineStrong,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: error != null ? AppColors.danger600 : AppColors.primary700,
                width: 1.5,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(error, style: const TextStyle(fontSize: 12, color: AppColors.danger700)),
        ],
      ],
    );
  }

  Widget _buildAadhaarVerificationCard({required bool isOrg}) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
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
                      _isAadhaarVerified
                          ? (isOrg ? l10n.contactPersonAadhaarVerified : l10n.aadhaarIdentityVerified)
                          : (isOrg ? l10n.contactPersonAadhaarVerificationTitle : l10n.aadhaarCardOtpVerification),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _isAadhaarVerified ? const Color(0xFF15803D) : AppColors.ink,
                      ),
                    ),
                    if (!_isAadhaarVerified) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.enterTwelveDigitAadhaarToReceiveOtp,
                        style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isAadhaarVerified) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, size: 16, color: Color(0xFF15803D)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _aadhaarVerifiedData?.fullName ?? (isOrg ? _contactPersonController.text.trim() : _fullNameController.text.trim()),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.aadhaarLabel}: ${_aadhaarVerifiedData?.aadharNumber ?? "XXXX-XXXX-${_aadhaarController.text.replaceAll(' ', '').trim().length >= 4 ? _aadhaarController.text.replaceAll(' ', '').trim().substring(_aadhaarController.text.replaceAll(' ', '').trim().length - 4) : 'XXXX'}"}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF166534), fontFamily: 'monospace'),
                        ),
                        if (_aadhaarVerifiedData?.loc != null || _aadhaarVerifiedData?.dist != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${l10n.profileAddress}: ${_aadhaarVerifiedData?.loc ?? ""}, ${_aadhaarVerifiedData?.dist ?? ""}, ${_aadhaarVerifiedData?.state ?? ""} - ${_aadhaarVerifiedData?.zip ?? ""}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF166534)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Color(0xFF15803D)),
                    onPressed: () {
                      setState(() {
                        _isAadhaarVerified = false;
                        _aadhaarVerifiedData = null;
                        _isAadhaarOtpSent = false;
                        _aadhaarOtpController.clear();
                        _aadhaarController.clear();
                        _aadhaarError = null;
                        _aadhaarOtpError = null;
                        _aadhaarClientId = null;
                        _resendTimer?.cancel();
                        _timerCountdown = 60;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildFieldLabel(isOrg ? l10n.contactPersonAadhaarOptionalLabel : l10n.aadhaarCardNumberLabel),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _aadhaarController,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (val) {
                      if (_aadhaarError != null) setState(() => _aadhaarError = null);
                      if (_aadhaarOtpError != null) setState(() => _aadhaarOtpError = null);
                      if (_errors.containsKey('aadhaar')) setState(() => _errors.remove('aadhaar'));
                      if (_isAadhaarOtpSent) {
                        setState(() {
                          _isAadhaarOtpSent = false;
                          _aadhaarOtpController.clear();
                        });
                      }
                    },
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                    decoration: InputDecoration(
                      hintText: l10n.twelveDigitAadhaarHint,
                      hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted, fontWeight: FontWeight.normal),
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _aadhaarError != null || _errors.containsKey('aadhaar') ? AppColors.danger600 : AppColors.line)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _aadhaarError != null || _errors.containsKey('aadhaar') ? AppColors.danger600 : AppColors.line)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _aadhaarError != null || _errors.containsKey('aadhaar') ? AppColors.danger600 : AppColors.primary700, width: 1.5)),
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
                                  : l10n.resendBtn)
                              : l10n.sendOtpBtn,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                ),
              ],
            ),

            if (_aadhaarError != null || _errors.containsKey('aadhaar')) ...[
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
                        _aadhaarError ?? _errors['aadhaar'] ?? '',
                        style: const TextStyle(fontSize: 12, color: AppColors.danger700, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_isAadhaarOtpSent) ...[
              const SizedBox(height: 14),
              _buildFieldLabel(l10n.enterSixDigitAadhaarOtpLabel),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _aadhaarOtpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      onChanged: (val) {
                        if (_aadhaarOtpError != null) {
                          setState(() => _aadhaarOtpError = null);
                        }
                      },
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                      decoration: InputDecoration(
                        hintText: l10n.sixDigitOtpHint,
                        hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted, fontWeight: FontWeight.normal),
                        counterText: '',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _aadhaarOtpError != null ? AppColors.danger600 : AppColors.line)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _aadhaarOtpError != null ? AppColors.danger600 : AppColors.line)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _aadhaarOtpError != null ? AppColors.danger600 : AppColors.primary700, width: 1.5)),
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
                        : Text(l10n.verifyOtpBtn, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ],
              ),
              if (_aadhaarOtpError != null) ...[
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
                          _aadhaarOtpError!,
                          style: const TextStyle(fontSize: 12, color: AppColors.danger700, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
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
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          textCapitalization: uppercase ? TextCapitalization.characters : TextCapitalization.words,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
          inputFormatters: [
            FilteringTextInputFormatter.deny(
              RegExp(r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff]|[\u2700-\u27bf])'),
            ),
            ...?inputFormatters,
          ],
          keyboardType: keyboardType,
          maxLength: maxLength,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted, fontWeight: FontWeight.normal),
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: error != null ? AppColors.danger600 : AppColors.lineStrong),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: error != null ? AppColors.danger600 : AppColors.lineStrong),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: error != null ? AppColors.danger600 : AppColors.primary700, width: 1.5),
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
    String? localPath,
    required bool isLoading,
    String? error,
    required VoidCallback onPick,
    VoidCallback? onRemove,
  }) {
    final hasFile = fileName != null && fileName.isNotEmpty;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: isLoading
              ? null
              : (hasFile
                  ? () async {
                      if (docUrl != null) {
                        final url = Uri.tryParse(docUrl);
                        if (url != null) {
                          try {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } catch (_) {}
                        }
                      } else if (localPath != null) {
                        try {
                          await OpenFile.open(localPath);
                        } catch (_) {}
                      }
                    }
                  : onPick),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasFile ? fileName : title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: hasFile ? const Color(0xFF15803D) : AppColors.ink,
                          height: 1.25,
                        ),
                        maxLines: hasFile ? 1 : null,
                        softWrap: true,
                        overflow: hasFile ? TextOverflow.ellipsis : TextOverflow.clip,
                      ),
                      if (isLoading || !hasFile) ...[
                        const SizedBox(height: 2),
                        Text(
                          isLoading ? l10n.uploadingToMahakhanijServer : hint,
                          style: TextStyle(
                            fontSize: 11,
                            color: isLoading ? AppColors.primary700 : AppColors.inkSecondary,
                            fontWeight: isLoading ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasFile) ...[
                  GestureDetector(
                    onTap: !isLoading ? onPick : null,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      child: Icon(Icons.edit, color: AppColors.primary700, size: 20),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (docUrl != null) {
                        final url = Uri.tryParse(docUrl);
                        if (url != null) {
                          try {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } catch (_) {}
                        }
                      } else if (localPath != null) {
                        try {
                          await OpenFile.open(localPath);
                        } catch (_) {}
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                      child: Icon(Icons.visibility, color: AppColors.primary700, size: 20),
                    ),
                  ),
                  if (onRemove != null)
                    GestureDetector(
                      onTap: !isLoading ? onRemove : null,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: Icon(Icons.delete_outline, color: AppColors.danger700, size: 20),
                      ),
                    ),
                ] else ...[
                  GestureDetector(
                    onTap: !isLoading ? onPick : null,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                      child: Text(
                        isLoading ? '${l10n.uploadBtn}...' : l10n.uploadBtn,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary700),
                      ),
                    ),
                  ),
                ],
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
                child: Text(
                  l10n.retryBtn,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.danger700, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
