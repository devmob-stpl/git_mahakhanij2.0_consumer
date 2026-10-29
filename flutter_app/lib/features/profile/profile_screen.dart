import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/consumer_profile_models.dart';
import '../../data/repositories/aadhaar_kyc_repository.dart';
import '../../data/repositories/location_repository.dart';
import '../../providers/consumer_profile_provider.dart';
import '../../providers/session_provider.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import '../../core/utils/pan_input_formatter.dart';
import '../../core/utils/document_permission_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isProfileAadhaarResending = false;
  bool _isProfileAadhaarVerifying = false;
  String? _profileAadhaarError;
  Timer? _profileAadhaarResendTimer;
  int _profileAadhaarTimerCountdown = 60;
  DateTime? _profileAadhaarOtpTargetTime;
  StateSetter? _activeAadhaarModalState;

  int get _profileAadhaarRemainingSeconds {
    if (_profileAadhaarOtpTargetTime == null) return 0;
    final diffMs = _profileAadhaarOtpTargetTime!.difference(DateTime.now()).inMilliseconds;
    final remaining = (diffMs / 1000).ceil();
    return remaining > 60 ? 60 : (remaining > 0 ? remaining : 0);
  }

  void _startProfileAadhaarTimer({int? seconds}) {
    if (seconds != null) {
      _profileAadhaarOtpTargetTime = DateTime.now().add(Duration(seconds: seconds));
      _profileAadhaarTimerCountdown = seconds;
    } else {
      _profileAadhaarTimerCountdown = _profileAadhaarRemainingSeconds;
    }

    if (_profileAadhaarRemainingSeconds <= 0) {
      _profileAadhaarTimerCountdown = 0;
      _profileAadhaarOtpTargetTime = null;
      _profileAadhaarResendTimer?.cancel();
      _profileAadhaarResendTimer = null;
      return;
    }

    if (_profileAadhaarResendTimer != null && _profileAadhaarResendTimer!.isActive) {
      return;
    }

    _profileAadhaarResendTimer?.cancel();
    _profileAadhaarResendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = _profileAadhaarRemainingSeconds;
      _profileAadhaarTimerCountdown = remaining;

      if (_activeAadhaarModalState != null) {
        try {
          _activeAadhaarModalState!(() {});
        } catch (_) {
          _activeAadhaarModalState = null;
        }
      }

      if (remaining <= 0) {
        timer.cancel();
        _profileAadhaarResendTimer = null;
        _profileAadhaarOtpTargetTime = null;
        _profileAadhaarTimerCountdown = 0;
        if (_activeAadhaarModalState != null) {
          try {
            _activeAadhaarModalState!(() {});
          } catch (_) {
            _activeAadhaarModalState = null;
          }
        }
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  void _safeSetModalState(void Function() fn) {
    if (_activeAadhaarModalState != null) {
      try {
        _activeAadhaarModalState!(fn);
        return;
      } catch (_) {
        _activeAadhaarModalState = null;
      }
    }
    fn();
    if (mounted) {
      setState(() {});
    }
  }

  String? _profileAadhaarDocUrl;
  String? _profileAadhaarDocError;
  bool _isProfileUploadingDoc = false;

  // Live PAN Verification State (Profile)
  final _profilePanController = TextEditingController();
  bool _isProfilePanVerifying = false;
  String? _profilePanError;
  String? _profilePanDocUrl;
  String? _profilePanDocError;
  bool _isProfileUploadingPanDoc = false;
  String? _localProfilePanPath;
  String? _localProfilePanName;
  Uint8List? _localProfilePanBytes;
  bool? _tempIsPanVerified;
  String? _tempPanNo;
  String? _tempPanClientName;
  String? _tempPanClientId;

  bool _isSaving = false;
  bool _showSaveToast = false;

  // Track populated profile ID to prevent overwriting user edits
  int? _lastLoadedProfileId;
  ConsumerProfileData? _activeProfileData;

  // KYC Modal State
  KycStep _kycStep = KycStep.view;
  String _uploadedDocName = '';
  KycStep _panKycStep = KycStep.view;
  String _uploadedPanDocName = '';
  
  String? _localProfileAadhaarPath;
  String? _localProfileAadhaarName;
  Uint8List? _localProfileAadhaarBytes;
  
  bool? _tempIsAadharVerified;
  String? _tempAadharCardNo;
  String? _tempAadharName;
  String? _cachedAadhaarVerifiedName;

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

    final mobile = user?.mobileNumber ?? '';
    SharedPreferences.getInstance().then((prefs) {
      final name = (mobile.isNotEmpty ? prefs.getString('aadhaar_verified_name_$mobile') : null) ??
          prefs.getString('aadhaar_verified_name_last');
      if (name != null && name.isNotEmpty && mounted) {
        setState(() {
          _cachedAadhaarVerifiedName = name;
        });
      }
    });
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
    _profilePanController.dispose();
    _profileAadhaarResendTimer?.cancel();
    _profileAadhaarResendTimer = null;
    _activeAadhaarModalState = null;
    _profileAadhaarOtpTargetTime = null;
    super.dispose();
  }

  void _populateProfileData(ConsumerProfileData profile) {
    if (_lastLoadedProfileId == profile.id) return;
    _lastLoadedProfileId = profile.id;
    _activeProfileData = profile;

    final aadh = profile.aadharCardNo?.replaceAll(' ', '').trim() ?? '';
    final mob = profile.mobileNo.trim();
    SharedPreferences.getInstance().then((prefs) {
      final name = (profile.aadharVerifiedName != null && profile.aadharVerifiedName!.isNotEmpty)
          ? profile.aadharVerifiedName
          : ((aadh.isNotEmpty ? prefs.getString('aadhaar_verified_name_$aadh') : null) ??
              (mob.isNotEmpty ? prefs.getString('aadhaar_verified_name_$mob') : null) ??
              prefs.getString('aadhaar_verified_name_last'));
      if (name != null && name.isNotEmpty && mounted && _cachedAadhaarVerifiedName == null) {
        setState(() {
          _cachedAadhaarVerifiedName = name;
        });
      }
    });

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
      _uploadedDocName = profile.aadharDoc!.split('/').last;
    }

    if (profile.panNo != null && profile.panNo!.isNotEmpty) {
      _profilePanController.text = profile.panNo!;
    }

    if (profile.panDoc != null && profile.panDoc!.isNotEmpty) {
      _profilePanDocUrl = profile.panDoc;
      _uploadedPanDocName = profile.panDoc!.split('/').last;
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
    } else if (profile.censusName != null && profile.censusName!.isNotEmpty) {
      _cityVillageController.text = profile.censusName!;
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
    _activeAadhaarModalState = setModalState;
    final loc = AppLocalizations.of(context)!;
    final aadh = _profileAadhaarController.text.replaceAll(' ', '').trim();
    if (aadh.length != 12 || !RegExp(r'^\d{12}$').hasMatch(aadh)) {
      _safeSetModalState(() => _profileAadhaarError = loc.enterValidAadhaarNumber);
      return;
    }
    
    if (aadh.startsWith('0') || aadh.startsWith('1')) {
      _safeSetModalState(() => _profileAadhaarError = loc.aadhaarCannotStartWithZeroOrOne);
      return;
    }

    final isResend = _isProfileAadhaarOtpSent;

    _safeSetModalState(() {
      _profileAadhaarError = null;
      if (isResend) {
        _isProfileAadhaarResending = true;
      } else {
        _isProfileAadhaarChecking = true;
      }
    });

    final repo = ref.read(aadhaarKycRepositoryProvider);

    if (!isResend) {
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
        _safeSetModalState(() {
          _isProfileAadhaarChecking = false;
          _profileAadhaarError = loc.aadhaarServerError;
        });
        return;
      }

      if (existRes.exists) {
        _safeSetModalState(() {
          _isProfileAadhaarChecking = false;
          _profileAadhaarError = loc.aadhaarAlreadyRegistered;
        });
        return;
      }
    }

    _safeSetModalState(() {
      _isProfileAadhaarChecking = false;
      _isProfileAadhaarGenerating = true;
    });

    try {
      final genRes = await repo.generateAadhaarOtp(aadh, createdBy: 0);
      if (!mounted) return;

      _safeSetModalState(() {
        _isProfileAadhaarGenerating = false;
        _isProfileAadhaarResending = false;

        final genStatusCode = genRes.statusCode.trim();
        final genRawMsg = genRes.message?.trim() ?? '';
        final genStatusMsg = genRes.statusMessage.trim();
        final genCombined = '${genRawMsg.toLowerCase()} ${genStatusMsg.toLowerCase()}';

        final isServerErrorOrTimeout =
            genStatusCode == '408' ||
            genStatusCode == '504' ||
            genStatusCode == '500' ||
            genStatusCode == '502' ||
            genStatusCode == '503' ||
            genStatusCode == '0' ||
            genRawMsg.isEmpty ||
            genCombined.contains('aadhaar server error') ||
            genCombined.contains('timeout') ||
            genCombined.contains('timed out') ||
            genCombined.contains('server error') ||
            genCombined.contains('internal') ||
            genCombined.contains('gateway') ||
            genCombined.contains('service unavailable') ||
            genCombined.contains('unexpected');

        if (genRes.isSuccess && genRes.clientId != null) {
          _isProfileAadhaarOtpSent = true;
          _profileAadhaarClientId = genRes.clientId;
          _profileAadhaarError = null;

          // Start OTP countdown timer only after the API call succeeds!
          _startProfileAadhaarTimer(seconds: 60);
        } else if (genCombined.contains('already exists') || genCombined.contains('already registered')) {
          _profileAadhaarError = loc.aadhaarAlreadyRegistered;
        } else if (isServerErrorOrTimeout) {
          _profileAadhaarError = loc.aadhaarServerError;
        } else if (genRawMsg.toLowerCase().contains('verification_failed')) {
          _profileAadhaarError = loc.invalidAadhaarNumber;
        } else {
          _profileAadhaarError = loc.aadhaarServerError;
        }
      });
    } catch (_) {
      if (!mounted) return;
      _safeSetModalState(() {
        _isProfileAadhaarGenerating = false;
        _isProfileAadhaarResending = false;
        _profileAadhaarError = loc.aadhaarServerError;
      });
    }
  }

  Future<void> _handleProfileVerifyAadhaarOtp(StateSetter setModalState) async {
    _activeAadhaarModalState = setModalState;
    final loc = AppLocalizations.of(context)!;
    final otp = _profileAadhaarOtpController.text.trim();
    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      _safeSetModalState(() => _profileAadhaarError = loc.enterValidAadhaarOtp);
      return;
    }

    if (_profileAadhaarClientId == null) {
      _safeSetModalState(() => _profileAadhaarError = loc.clientSessionExpired);
      return;
    }

    _safeSetModalState(() {
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

    _safeSetModalState(() {
      _isProfileAadhaarVerifying = false;
      if (res.isSuccess) {
        _profileAadhaarResendTimer?.cancel();
        _profileAadhaarResendTimer = null;
        _profileAadhaarOtpTargetTime = null;
        _profileAadhaarTimerCountdown = 60;
        _profileAadhaarError = null;
        if (_activeProfileData != null) {
          final newName = (res.fullName != null && res.fullName!.trim().isNotEmpty)
              ? res.fullName!
              : (_activeProfileData!.aadharVerifiedName ?? _activeProfileData!.name);
          _tempIsAadharVerified = true;
          _tempAadharCardNo = _profileAadhaarController.text.replaceAll(' ', '').trim();
          _tempAadharName = newName;
          _cachedAadhaarVerifiedName = newName;
          try {
            final mobile = _mobileController.text.trim();
            final aadh = _profileAadhaarController.text.replaceAll(' ', '').trim();
            SharedPreferences.getInstance().then((prefs) {
              if (mobile.isNotEmpty) prefs.setString('aadhaar_verified_name_$mobile', newName);
              if (aadh.isNotEmpty) prefs.setString('aadhaar_verified_name_$aadh', newName);
              prefs.setString('aadhaar_verified_name_last', newName);
            });
          } catch (_) {}
        }
        setState(() {});
      } else {
        final statusCode = res.statusCode.trim();
        final rawMsg = res.message?.trim() ?? '';
        final statusMsg = res.statusMessage.trim();
        final combined = '${rawMsg.toLowerCase()} ${statusMsg.toLowerCase()}';

        final isServerErrorOrTimeout =
            statusCode == '408' ||
            statusCode == '504' ||
            statusCode == '500' ||
            statusCode == '502' ||
            statusCode == '503' ||
            statusCode == '0' ||
            rawMsg.isEmpty ||
            combined.contains('aadhaar server error') ||
            combined.contains('timeout') ||
            combined.contains('timed out') ||
            combined.contains('server error') ||
            combined.contains('internal') ||
            combined.contains('gateway') ||
            combined.contains('service unavailable') ||
            combined.contains('unexpected');

        final isExplicitInvalidOtp = !isServerErrorOrTimeout &&
            (combined.contains('invalid otp') ||
             combined.contains('incorrect otp') ||
             combined.contains('otp does not match') ||
             combined.contains('wrong otp') ||
             combined.contains('otp mismatch') ||
             combined.contains('invalid_otp'));

        if (isExplicitInvalidOtp) {
          _profileAadhaarError = loc.invalidOtpServer;
        } else {
          _profileAadhaarError = loc.aadhaarServerError;
        }
      }
    });
  }

  Future<void> _handleProfileUploadAadhaarDoc(StateSetter setModalState) async {
    final loc = AppLocalizations.of(context)!;
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
                title: Text(loc.cameraBtn),
                onTap: () async {
                  Navigator.pop(bottomSheetCtx);
                  final hasPerm = await DocumentPermissionHelper.requestUploadPermission(
                    context: context,
                    source: DocumentUploadSource.camera,
                    documentType: 'Aadhaar Card',
                  );
                  if (!hasPerm) return;
                  _processProfilePickImage(ImageSource.camera, setModalState);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(loc.galleryBtn),
                onTap: () async {
                  Navigator.pop(bottomSheetCtx);
                  final hasPerm = await DocumentPermissionHelper.requestUploadPermission(
                    context: context,
                    source: DocumentUploadSource.gallery,
                    documentType: 'Aadhaar Card',
                  );
                  if (!hasPerm) return;
                  _processProfilePickImage(ImageSource.gallery, setModalState);
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(loc.fileDocumentBtn),
                onTap: () async {
                  Navigator.pop(bottomSheetCtx);
                  final hasPerm = await DocumentPermissionHelper.requestUploadPermission(
                    context: context,
                    source: DocumentUploadSource.file,
                    documentType: 'Aadhaar Card',
                  );
                  if (!hasPerm) return;
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
    final loc = AppLocalizations.of(context)!;
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) return;
      
      final bytes = await pickedFile.readAsBytes();
      await _uploadProfileDocument(pickedFile.path, pickedFile.name, bytes, setModalState);
    } catch (e) {
      if (DocumentPermissionHelper.isPermissionException(e)) {
        setModalState(() {
          _isProfileUploadingDoc = false;
        });
        if (mounted) {
          await DocumentPermissionHelper.handlePermissionException(
            context: context,
            source: source == ImageSource.camera ? DocumentUploadSource.camera : DocumentUploadSource.gallery,
            documentType: 'Aadhaar Card',
            error: e,
          );
        }
        return;
      }
      if (e.toString().contains('access_denied')) {
        setModalState(() {
          _isProfileUploadingDoc = false;
        });
        return;
      }
      setModalState(() {
        _isProfileUploadingDoc = false;
        _profileAadhaarDocError = '${loc.uploadFailedWithReason}${e.toString()}';
      });
    }
  }

  Future<void> _processProfilePickFile(StateSetter setModalState) async {
    final loc = AppLocalizations.of(context)!;
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
      if (DocumentPermissionHelper.isPermissionException(e)) {
        setModalState(() {
          _isProfileUploadingDoc = false;
        });
        if (mounted) {
          await DocumentPermissionHelper.handlePermissionException(
            context: context,
            source: DocumentUploadSource.file,
            documentType: 'Aadhaar Card',
            error: e,
          );
        }
        return;
      }
      if (e.toString().contains('access_denied')) {
        setModalState(() {
          _isProfileUploadingDoc = false;
        });
        return;
      }
      setModalState(() {
        _isProfileUploadingDoc = false;
        _profileAadhaarDocError = '${loc.uploadFailedWithReason}${e.toString()}';
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

  Future<void> _handleProfileVerifyPan(StateSetter setModalState) async {
    final loc = AppLocalizations.of(context)!;
    final pan = _profilePanController.text.trim().toUpperCase();
    if (pan.isEmpty) {
      setModalState(() => _profilePanError = loc.orgPanRequired);
      return;
    }
    if (pan.length != 10 || !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(pan)) {
      setModalState(() => _profilePanError = loc.validPanRequired);
      return;
    }

    final mobile = _mobileController.text.trim();
    if (mobile.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      setModalState(() => _profilePanError = loc.validMobileRequired);
      return;
    }

    setModalState(() {
      _profilePanError = null;
      _isProfilePanVerifying = true;
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
      setModalState(() {
        _isProfilePanVerifying = false;
        _profilePanError = checkRes.statusMessage.isNotEmpty
            ? checkRes.statusMessage
            : loc.panAlreadyRegistered;
      });
      return;
    }

    // Step 2: Verify PAN via verifyPan
    final verifyRes = await authRepo.verifyPan(panNo: pan, userId: 0);

    if (!mounted) return;

    setModalState(() {
      _isProfilePanVerifying = false;
      if (verifyRes.isSuccess) {
        _tempIsPanVerified = true;
        _tempPanNo = pan;
        _tempPanClientName = verifyRes.clientName;
        _tempPanClientId = verifyRes.clientId;
        _profilePanError = null;
      } else {
        final rawMsg = verifyRes.statusMessage.trim();
        final lower = rawMsg.toLowerCase();
        final isGenericOk = lower.isEmpty || lower == 'ok.' || lower == 'ok' || lower == 'success' || lower == '200';

        String displayMsg;
        if (isGenericOk ||
            lower.contains('invalid pan') ||
            lower.contains('invalid') ||
            lower.contains('not found') ||
            lower.contains('record_not_found') ||
            lower.contains('does not exist')) {
          displayMsg = loc.invalidPanNumber;
        } else {
          displayMsg = rawMsg;
        }
        _profilePanError = displayMsg;
      }
    });
  }

  Future<void> _handleProfileUploadPanDoc(StateSetter setModalState) async {
    final loc = AppLocalizations.of(context)!;
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
                title: Text(loc.cameraBtn),
                onTap: () async {
                  Navigator.pop(bottomSheetCtx);
                  final hasPerm = await DocumentPermissionHelper.requestUploadPermission(
                    context: context,
                    source: DocumentUploadSource.camera,
                    documentType: 'PAN Card',
                  );
                  if (!hasPerm) return;
                  _processProfilePickPanImage(ImageSource.camera, setModalState);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(loc.galleryBtn),
                onTap: () async {
                  Navigator.pop(bottomSheetCtx);
                  final hasPerm = await DocumentPermissionHelper.requestUploadPermission(
                    context: context,
                    source: DocumentUploadSource.gallery,
                    documentType: 'PAN Card',
                  );
                  if (!hasPerm) return;
                  _processProfilePickPanImage(ImageSource.gallery, setModalState);
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(loc.fileDocumentBtn),
                onTap: () async {
                  Navigator.pop(bottomSheetCtx);
                  final hasPerm = await DocumentPermissionHelper.requestUploadPermission(
                    context: context,
                    source: DocumentUploadSource.file,
                    documentType: 'PAN Card',
                  );
                  if (!hasPerm) return;
                  _processProfilePickPanFile(setModalState);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processProfilePickPanImage(ImageSource source, StateSetter setModalState) async {
    final loc = AppLocalizations.of(context)!;
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      setModalState(() {
        _localProfilePanPath = pickedFile.path;
        _localProfilePanName = pickedFile.name;
        _localProfilePanBytes = bytes;
        _profilePanDocUrl = null;
        _profilePanDocError = null;
        _uploadedPanDocName = pickedFile.name;
        setState(() {});
      });
    } catch (e) {
      if (DocumentPermissionHelper.isPermissionException(e)) {
        setModalState(() {
          _isProfileUploadingPanDoc = false;
        });
        if (mounted) {
          await DocumentPermissionHelper.handlePermissionException(
            context: context,
            source: source == ImageSource.camera ? DocumentUploadSource.camera : DocumentUploadSource.gallery,
            documentType: 'PAN Card',
            error: e,
          );
        }
        return;
      }
      setModalState(() {
        _isProfileUploadingPanDoc = false;
        _profilePanDocError = '${loc.uploadFailedWithReason}${e.toString()}';
      });
    }
  }

  Future<void> _processProfilePickPanFile(StateSetter setModalState) async {
    final loc = AppLocalizations.of(context)!;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.path == null) return;

      setModalState(() {
        _localProfilePanPath = file.path!;
        _localProfilePanName = file.name;
        _localProfilePanBytes = file.bytes;
        _profilePanDocUrl = null;
        _profilePanDocError = null;
        _uploadedPanDocName = file.name;
        setState(() {});
      });
    } catch (e) {
      if (DocumentPermissionHelper.isPermissionException(e)) {
        setModalState(() {
          _isProfileUploadingPanDoc = false;
        });
        if (mounted) {
          await DocumentPermissionHelper.handlePermissionException(
            context: context,
            source: DocumentUploadSource.file,
            documentType: 'PAN Card',
            error: e,
          );
        }
        return;
      }
      setModalState(() {
        _isProfileUploadingPanDoc = false;
        _profilePanDocError = '${loc.uploadFailedWithReason}${e.toString()}';
      });
    }
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

    final isOrg = (user?.isOrganization ?? false) || (_activeProfileData?.isOrganization ?? false);

    // Retain previous verification status and profile state before any API calls
    final previousProfileData = _activeProfileData;
    final previousIsAadhaarVerified = _activeProfileData?.isAadharVerified ?? false;
    final previousIsPanVerified = _activeProfileData?.isPanVerified ?? false;
    final previousAadhaarCardNo = _activeProfileData?.aadharCardNo ?? '';
    final previousPanNo = _activeProfileData?.panNo ?? '';
    final previousAadhaarName = _activeProfileData?.aadharVerifiedName ?? '';
    final previousPanClientName = _activeProfileData?.panClientName ?? '';
    final previousAadhaarDoc = _activeProfileData?.aadharDoc ?? '';
    final previousPanDoc = _activeProfileData?.panDoc ?? '';

    // Determine target verification parameters to submit
    final targetIsAadhaarVerified = _tempIsAadharVerified ?? previousIsAadhaarVerified;
    // Consumer-Type-Based Verification:
    // Individual Consumer: Allow updates only to Aadhaar verification details.
    // Organisation Consumer: Allow updates to both Aadhaar and PAN verification details.
    final targetIsPanVerified = isOrg ? (_tempIsPanVerified ?? previousIsPanVerified) : previousIsPanVerified;

    final targetAadhaarNo = (_tempAadharCardNo != null && _tempAadharCardNo!.isNotEmpty)
        ? _tempAadharCardNo!
        : (_profileAadhaarController.text.replaceAll(' ', '').trim().isNotEmpty
            ? _profileAadhaarController.text.replaceAll(' ', '').trim()
            : previousAadhaarCardNo);

    final targetPanNo = isOrg
        ? ((_tempPanNo != null && _tempPanNo!.isNotEmpty)
            ? _tempPanNo!
            : (_profilePanController.text.replaceAll(' ', '').trim().toUpperCase().isNotEmpty
                ? _profilePanController.text.replaceAll(' ', '').trim().toUpperCase()
                : previousPanNo))
        : previousPanNo;

    final targetAadhaarName = (_tempAadharName != null && _tempAadharName!.trim().isNotEmpty)
        ? _tempAadharName!.trim()
        : ((_cachedAadhaarVerifiedName != null && _cachedAadhaarVerifiedName!.trim().isNotEmpty)
            ? _cachedAadhaarVerifiedName!.trim()
            : previousAadhaarName);

    final targetPanClientName = isOrg
        ? ((_tempPanClientName != null && _tempPanClientName!.trim().isNotEmpty)
            ? _tempPanClientName!.trim()
            : previousPanClientName)
        : previousPanClientName;

    // Upload documents if needed
    if (_localProfileAadhaarPath != null) {
      final repo = ref.read(aadhaarKycRepositoryProvider);
      final uploadRes = await repo.uploadAadhaarDocument(
        filePath: _localProfileAadhaarPath!,
        fileName: _localProfileAadhaarName ?? 'doc',
        bytes: _localProfileAadhaarBytes,
      );
      if (uploadRes.isSuccess && uploadRes.responseData != null) {
        _profileAadhaarDocUrl = uploadRes.responseData;
      } else {
        if (!mounted) return false;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(uploadRes.statusMessage.isNotEmpty ? uploadRes.statusMessage : l10n.docUploadFailed),
            backgroundColor: AppColors.danger700,
          ),
        );
        return false;
      }
    }

    if (isOrg && _localProfilePanPath != null) {
      final repo = ref.read(aadhaarKycRepositoryProvider);
      final uploadRes = await repo.uploadAadhaarDocument(
        filePath: _localProfilePanPath!,
        fileName: _localProfilePanName ?? 'pan_doc',
        bytes: _localProfilePanBytes,
      );
      if (uploadRes.isSuccess && uploadRes.responseData != null) {
        _profilePanDocUrl = uploadRes.responseData;
      } else {
        if (!mounted) return false;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(uploadRes.statusMessage.isNotEmpty ? uploadRes.statusMessage : l10n.panDocUploadFailed),
            backgroundColor: AppColors.danger700,
          ),
        );
        return false;
      }
    }

    final targetAadhaarDoc = _profileAadhaarDocUrl ?? previousAadhaarDoc;
    final targetPanDoc = isOrg ? (_profilePanDocUrl ?? previousPanDoc) : previousPanDoc;

    // Resolve consumerId: pass consumerId in id parameter
    final activeId = _activeProfileData?.id ?? 0;
    final userConsumerId = user?.consumerId ?? 0;
    final int consumerId = activeId > 0
        ? activeId
        : (userConsumerId > 0 ? userConsumerId : (int.tryParse(user?.id ?? '0') ?? 0));

    final targetPanClientId = isOrg
        ? (_tempPanClientId ?? _activeProfileData?.panClientId ?? '')
        : (_activeProfileData?.panClientId ?? '');

    final Map<String, dynamic> updatePayload = {
      'id': consumerId,
      'flag': 'u',
      'consumerType': isOrg ? CONSUMER_TYPE_ORGANISATION : CONSUMER_TYPE_INDIVIDUAL,
      'name': (!isOrg && targetAadhaarName.isNotEmpty)
          ? targetAadhaarName
          : (_nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : (_activeProfileData?.name ?? '')),
      'mobileNo': mobile.isNotEmpty ? mobile : (_activeProfileData?.mobileNo ?? ''),
      'emailId': _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : (_activeProfileData?.emailId ?? ''),
      'address': _line1Controller.text.trim().isNotEmpty
          ? _line1Controller.text.trim()
          : (_activeProfileData?.address ?? ''),
      'stateId': _activeProfileData?.stateId ?? 1,
      'districtId': (_selectedDistrictId != null && _selectedDistrictId != 0)
          ? _selectedDistrictId!
          : (_activeProfileData?.districtId ?? 0),
      'talukaId': (_selectedTalukaId != null && _selectedTalukaId != 0)
          ? _selectedTalukaId!
          : (_activeProfileData?.talukaId ?? 0),
      'isTown': _isTown ?? _activeProfileData?.isTown ?? false,
      'censusId': (_selectedCensusId != null && _selectedCensusId != 0)
          ? _selectedCensusId!
          : (_activeProfileData?.censusId ?? 0),
      'createdBy': _activeProfileData?.createdBy ?? consumerId,
      'panNo': isOrg ? targetPanNo : (_activeProfileData?.panNo ?? ''),
      'gstNo': _activeProfileData?.gstNo ?? '',
      'rationCardId': _activeProfileData?.rationCardId ?? '',
      'aadharCardNo': targetAadhaarNo.isNotEmpty
          ? targetAadhaarNo
          : (_activeProfileData?.aadharCardNo ?? ''),
      'aadharDoc': targetAadhaarDoc.isNotEmpty
          ? targetAadhaarDoc
          : (_activeProfileData?.aadharDoc ?? ''),
      'panDoc': isOrg
          ? (targetPanDoc.isNotEmpty ? targetPanDoc : (_activeProfileData?.panDoc ?? ''))
          : (_activeProfileData?.panDoc ?? ''),
      'rcDoc': _activeProfileData?.rcDoc ?? '',
      'pinCode': _activeProfileData?.pinCode ?? '',
      'gstDoc': _activeProfileData?.gstDoc ?? '',
      'isAadharVerified': targetIsAadhaarVerified,
      'aadharVerifiedName': targetAadhaarName.isNotEmpty
          ? targetAadhaarName
          : (_activeProfileData?.aadharVerifiedName ?? ''),
      'aadharClientId': _profileAadhaarClientId ?? _activeProfileData?.aadharClientId ?? '',
      'panClientId': targetPanClientId,
      'isPanVerified': isOrg ? targetIsPanVerified : (_activeProfileData?.isPanVerified ?? false),
      'isCompulsoryVerification': _activeProfileData?.isCompulsoryVerification ?? false,
      'otp': '',
      'pageName': 'ConsumerReg',
      'contactPersonName': isOrg
          ? (targetAadhaarName.isNotEmpty
              ? targetAadhaarName
              : (_activeProfileData?.contactPersonName?.trim().isNotEmpty == true
                  ? _activeProfileData!.contactPersonName!.trim()
                  : (_nameController.text.trim().isNotEmpty
                      ? _nameController.text.trim()
                      : (_activeProfileData?.name ?? ''))))
          : (_activeProfileData?.contactPersonName ?? ''),
      'insertDocuments': <Map<String, dynamic>>[],
    };

    try {
      final response = await ref.read(authRepositoryProvider).saveUpdateConsumerDetails(updatePayload);

      if (!mounted) return false;

      setState(() => _isSaving = false);

      if (response.isSuccess) {
        // Update the verification status ONLY after the API call succeeds
        if (_activeProfileData != null) {
          _activeProfileData = _activeProfileData!.copyWith(
            name: (!isOrg && targetAadhaarName.isNotEmpty)
                ? targetAadhaarName
                : (_nameController.text.trim().isNotEmpty ? _nameController.text.trim() : _activeProfileData!.name),
            isAadharVerified: targetIsAadhaarVerified,
            aadharCardNo: targetAadhaarNo,
            aadharVerifiedName: targetAadhaarName,
            aadharDoc: targetAadhaarDoc,
            aadharClientId: _profileAadhaarClientId ?? _activeProfileData!.aadharClientId,
            isPanVerified: isOrg ? targetIsPanVerified : _activeProfileData!.isPanVerified,
            panNo: isOrg ? targetPanNo : _activeProfileData!.panNo,
            panDoc: isOrg ? targetPanDoc : _activeProfileData!.panDoc,
            panClientName: isOrg ? targetPanClientName : _activeProfileData!.panClientName,
            panClientId: isOrg ? targetPanClientId : _activeProfileData!.panClientId,
            contactPersonName: isOrg
                ? (targetAadhaarName.isNotEmpty ? targetAadhaarName : _activeProfileData!.contactPersonName)
                : _activeProfileData!.contactPersonName,
          );
        }
        if (!isOrg && targetAadhaarName.isNotEmpty) {
          _nameController.text = targetAadhaarName;
        }

        _tempIsAadharVerified = null;
        _tempAadharCardNo = null;
        _tempAadharName = null;
        _tempIsPanVerified = null;
        _tempPanNo = null;
        _tempPanClientName = null;
        _tempPanClientId = null;

        _localProfileAadhaarPath = null;
        _localProfileAadhaarName = null;
        _localProfileAadhaarBytes = null;
        _localProfilePanPath = null;
        _localProfilePanName = null;
        _localProfilePanBytes = null;

        ref.invalidate(consumerProfileProvider(mobile));
        setState(() => _showSaveToast = true);

        Timer(const Duration(seconds: 3), () {
          if (mounted) setState(() => _showSaveToast = false);
        });
        return true;
      } else {
        // If the API call fails, retain the previous verification status without making any changes
        _activeProfileData = previousProfileData;
        _tempIsAadharVerified = null;
        _tempAadharCardNo = null;
        _tempAadharName = null;
        _tempIsPanVerified = null;
        _tempPanNo = null;
        _tempPanClientName = null;
        _tempPanClientId = null;

        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.statusMessage.isNotEmpty
                ? response.statusMessage
                : l10n.failedToUpdateProfile),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _isSaving = false;
        // Retain the previous verification status without making any changes
        _activeProfileData = previousProfileData;
        _tempIsAadharVerified = null;
        _tempAadharCardNo = null;
        _tempAadharName = null;
        _tempIsPanVerified = null;
        _tempPanNo = null;
        _tempPanClientName = null;
        _tempPanClientId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.errorUpdatingProfile}${e.toString()}'),
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

    _profileAadhaarTimerCountdown = _profileAadhaarRemainingSeconds;
    if (_profileAadhaarRemainingSeconds > 0 && (_profileAadhaarResendTimer == null || !_profileAadhaarResendTimer!.isActive)) {
      _startProfileAadhaarTimer();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            _activeAadhaarModalState = setModalState;
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
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
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
                        (_tempIsAadharVerified ?? _activeProfileData?.isAadharVerified == true) ? loc.verifiedUpper : loc.pendingUpper,
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
                                child: Text(loc.verifyAadhaarBtn, style: const TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ] else if (_kycStep == KycStep.upload) ...[
                      Text(
                        loc.aadhaarIdentityVerificationTitle,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.aadhaarIdentityVerificationDesc,
                        style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
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
                                        _profileAadhaarResendTimer?.cancel();
                                        _profileAadhaarResendTimer = null;
                                        _profileAadhaarOtpTargetTime = null;
                                        _profileAadhaarTimerCountdown = 60;
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
                              Text(loc.method1LiveOtp, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E40AF))),
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
                                        _profileAadhaarResendTimer?.cancel();
                                        _profileAadhaarResendTimer = null;
                                        _profileAadhaarOtpTargetTime = null;
                                        _profileAadhaarTimerCountdown = 60;
                                        setModalState(() {
                                          _isProfileAadhaarOtpSent = false;
                                          _isProfileAadhaarResending = false;
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
                                          : Text(loc.sendOtpBtn, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
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
                                      : Text(loc.verifyOtpBtn, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ),
                              if (_isProfileAadhaarResending) ...[
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      loc.resendBtn,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else if (_profileAadhaarTimerCountdown > 0) ...[
                                const SizedBox(height: 6),
                                Text(loc.resendInSeconds(_profileAadhaarTimerCountdown.toString().padLeft(2, '0')), style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary)),
                              ] else ...[
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: (_isProfileAadhaarResending || _isProfileAadhaarGenerating || _isProfileAadhaarChecking)
                                      ? null
                                      : () => _handleProfileSendAadhaarOtp(setModalState),
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
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
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
                                            Text(loc.uploadingToMahakhanijServer, style: const TextStyle(fontSize: 10.5, color: AppColors.primary700)),
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
                              child: Text(loc.closeBtn, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkSecondary)),
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
                                  if (success && modalContext.mounted) {
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
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.aadhaarVerificationSuccessDesc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
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
    ).whenComplete(() {
      _activeAadhaarModalState = null;
    }).then((_) {
      if (mounted) {
        setState(() {
          _tempIsAadharVerified = null;
          _tempAadharCardNo = null;
          _tempAadharName = null;
        });
      }
    });
  }

  void _openPanModal(KycStep initialStep) {
    final loc = AppLocalizations.of(context)!;
    final mobileNo = ref.read(sessionProvider).currentUser?.mobileNumber ?? '';
    final isServerVerified = ref.read(consumerProfileProvider(mobileNo)).value?.responseData?.isPanVerified == true;
    setState(() => _panKycStep = initialStep);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isPanVerified = _tempIsPanVerified ?? _activeProfileData?.isPanVerified == true;
            final panNo = (_tempPanNo != null && _tempPanNo!.isNotEmpty)
                ? _tempPanNo!
                : (_activeProfileData?.panNo != null && _activeProfileData!.panNo!.isNotEmpty)
                    ? _activeProfileData!.panNo!
                    : '';
            final orgName = _tempPanClientName ?? _orgNameController.text.trim();

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

                    if (_panKycStep == KycStep.view) ...[
                      Text(
                        loc.orgPanInfoTitle,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 16),
                      _buildKycDetailRow(
                        loc.panNumberLabel,
                        panNo.isNotEmpty ? panNo : 'N/A',
                      ),
                      const SizedBox(height: 10),
                      _buildKycDetailRow(
                        loc.panVerificationLabel,
                        isPanVerified ? loc.verifiedUpper : loc.pendingUpper,
                      ),
                      if (orgName.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _buildKycDetailRow(
                          loc.orgNameLabel,
                          orgName,
                        ),
                      ],
                      const SizedBox(height: 20),
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
                              child: Text(loc.closeBtn, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkSecondary)),
                            ),
                          ),
                          if (!isPanVerified) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary700,
                                  minimumSize: const Size(double.infinity, 44),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => setModalState(() => _panKycStep = KycStep.upload),
                                child: Text(loc.verifyPanBtn, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ] else if (_panKycStep == KycStep.upload) ...[
                      Text(
                        loc.orgPanVerificationTitle,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.verifyOrgPanDesc,
                        style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                      ),
                      const SizedBox(height: 16),

                      // Method 1: Live PAN Verification
                      if (isPanVerified) ...[
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
                              Text(loc.method1LivePanVerification, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Color(0xFF15803D), size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _profilePanController.text.isNotEmpty ? _profilePanController.text : panNo,
                                          style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.w700),
                                        ),
                                        if (orgName.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            orgName,
                                            style: const TextStyle(color: Color(0xFF15803D), fontSize: 12, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (!isServerVerified)
                                    GestureDetector(
                                      onTap: () {
                                        setModalState(() {
                                          _tempIsPanVerified = null;
                                          _tempPanNo = null;
                                          _tempPanClientName = null;
                                          _tempPanClientId = null;
                                          _profilePanController.clear();
                                          _profilePanError = null;
                                          _profilePanDocUrl = null;
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
                              Text(loc.method1LivePanVerification, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E40AF))),
                              const SizedBox(height: 8),
                              AppTextField(
                                label: loc.orgPanNumberRequired,
                                controller: _profilePanController,
                                keyboardType: TextInputType.visiblePassword,
                                maxLength: 10,
                                inputFormatters: const [
                                  PanInputFormatter(),
                                ],
                                hint: 'ABCDE1234F',
                                suffixIcon: ElevatedButton(
                                  onPressed: _isProfilePanVerifying ? null : () => _handleProfileVerifyPan(setModalState),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: _isProfilePanVerifying
                                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : Text(loc.verifyPanBtn, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ),
                              if (_profilePanError != null) ...[
                                const SizedBox(height: 6),
                                Text(_profilePanError!, style: const TextStyle(fontSize: 11, color: AppColors.danger700, fontWeight: FontWeight.w500)),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // Method 2: Live PAN Document Upload
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _profilePanDocError != null
                                ? AppColors.danger700
                                : (_profilePanDocUrl != null || _localProfilePanPath != null ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.method2UploadPanCard,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: _isProfileUploadingPanDoc ? null : () => _handleProfileUploadPanDoc(setModalState),
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
                                    _isProfileUploadingPanDoc
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary700))
                                        : Icon(
                                            (_profilePanDocUrl != null || _localProfilePanPath != null) ? Icons.check_circle : Icons.upload_file,
                                            color: (_profilePanDocUrl != null || _localProfilePanPath != null) ? const Color(0xFF15803D) : AppColors.inkSecondary,
                                            size: 20,
                                          ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _uploadedPanDocName.isNotEmpty ? _uploadedPanDocName : loc.choosePanPdfOrImage,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: (_profilePanDocUrl != null || _localProfilePanPath != null) ? const Color(0xFF15803D) : AppColors.ink,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if ((_profilePanDocUrl != null || _localProfilePanPath != null) && !_isProfileUploadingPanDoc) ...[
                                      GestureDetector(
                                        onTap: () => _handleProfileUploadPanDoc(setModalState),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          child: Icon(Icons.edit, color: AppColors.primary700, size: 20),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          if (_profilePanDocUrl != null) {
                                            final url = Uri.tryParse(_profilePanDocUrl!);
                                            if (url != null) {
                                              try {
                                                await launchUrl(url, mode: LaunchMode.externalApplication);
                                              } catch (_) {}
                                            }
                                          } else if (_localProfilePanPath != null) {
                                            try {
                                              await OpenFile.open(_localProfilePanPath!);
                                            } catch (_) {}
                                          }
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          child: Icon(Icons.visibility, color: AppColors.primary700, size: 20),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            _localProfilePanPath = null;
                                            _localProfilePanBytes = null;
                                            _localProfilePanName = null;
                                            _profilePanDocUrl = null;
                                            _uploadedPanDocName = '';
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
                                        onPressed: _isProfileUploadingPanDoc ? null : () => _handleProfileUploadPanDoc(setModalState),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary700,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          _isProfileUploadingPanDoc ? loc.uploadingDots : loc.uploadBtn,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            if (_profilePanDocError != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _profilePanDocError!,
                                      style: const TextStyle(fontSize: 11, color: AppColors.danger700, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _handleProfileUploadPanDoc(setModalState),
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
                              child: Text(loc.closeBtn, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkSecondary)),
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
                                final isVerified = _tempIsPanVerified == true || _activeProfileData?.isPanVerified == true;
                                if (!isVerified) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(loc.verifyOrgPanBeforeSaving),
                                      backgroundColor: AppColors.danger700,
                                    ),
                                  );
                                  return;
                                }
                                setModalState(() => _isSaving = true);
                                final success = await _handleSaveProfile();
                                if (mounted) {
                                  setModalState(() => _isSaving = false);
                                  if (success && modalContext.mounted) {
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
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          _tempIsPanVerified = null;
          _tempPanNo = null;
          _tempPanClientName = null;
          _tempPanClientId = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider).currentUser;
    final mobileNo = user?.mobileNumber ?? '';
    final loc = AppLocalizations.of(context)!;

    final profileAsync = ref.watch(consumerProfileProvider(mobileNo));
    final cachedProfile = profileAsync.value?.responseData ?? _activeProfileData;
    final isOrgHeader = (cachedProfile?.isOrganization ?? false) || (user?.isOrganization ?? false);

    return AppScaffold(
      title: isOrgHeader ? loc.orgKycVerification : loc.kycVerification,
      showBackButton: false,
      body: profileAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(strokeWidth: 3),
              const SizedBox(height: 12),
              Text(
                loc.loadingConsumerProfile,
                style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
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
                Text(
                  loc.failedToFetchConsumerProfile,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                ),
                const SizedBox(height: 6),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: loc.retryLoadingProfile,
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
          final isOrg = (profile?.isOrganization ?? false) || (user?.isOrganization ?? false) || (_activeProfileData?.isOrganization ?? false);
          final isAadhaarVerified = _activeProfileData?.isAadharVerified ?? profile?.isAadharVerified ?? false;
          final isPanVerified = _activeProfileData?.isPanVerified ?? profile?.isPanVerified ?? false;
          final displayAadhaarNo = _activeProfileData?.aadharCardNo ?? profile?.aadharCardNo ?? '';
          final activeProfileAadhaarName = _activeProfileData?.aadharVerifiedName?.trim();
          final directProfileAadhaarName = profile?.aadharVerifiedName?.trim();
          final cachedAadhaarName = _cachedAadhaarVerifiedName?.trim();

          String displayAadhaarName;
          if (activeProfileAadhaarName != null && activeProfileAadhaarName.isNotEmpty) {
            displayAadhaarName = activeProfileAadhaarName;
          } else if (directProfileAadhaarName != null && directProfileAadhaarName.isNotEmpty) {
            displayAadhaarName = directProfileAadhaarName;
          } else if (cachedAadhaarName != null && cachedAadhaarName.isNotEmpty) {
            displayAadhaarName = cachedAadhaarName;
          } else if (isOrg) {
            final contactName = _activeProfileData?.contactPersonName ?? profile?.contactPersonName ?? '';
            displayAadhaarName = contactName.trim();
          } else {
            displayAadhaarName = (_activeProfileData?.name ?? profile?.name ?? '').trim();
          }
          final displayPanNo = _activeProfileData?.panNo ?? profile?.panNo ?? '';
          final displayPanName = _activeProfileData?.panClientName ?? profile?.panClientName ?? _orgNameController.text.trim();

          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1) Dynamic Consumer Type Header Banner
                      _buildConsumerTypeHeader(
                        isOrg: isOrg,
                        isAadhaarVerified: isAadhaarVerified,
                        isPanVerified: isPanVerified,
                      ),
                      const SizedBox(height: 16),

                      // 2) Document 1: Aadhaar Verification Card
                      _buildAadhaarCard(
                        isOrg: isOrg,
                        isAadhaarVerified: isAadhaarVerified,
                        displayAadhaarNo: displayAadhaarNo,
                        displayAadhaarName: displayAadhaarName,
                        profile: profile,
                      ),

                      // 3) Document 2: Organisation PAN Verification Card (Shown only for Organisation)
                      if (isOrg) ...[
                        const SizedBox(height: 16),
                        _buildPanCard(
                          isPanVerified: isPanVerified,
                          displayPanNo: displayPanNo,
                          displayPanName: displayPanName,
                          profile: profile,
                        ),
                      ],
                    ],
                  ),
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
                          isOrg ? loc.kycDetailsSavedSuccessfully : loc.aadhaarDetailsSavedSuccessfully,
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

  Widget _buildConsumerTypeHeader({
    required bool isOrg,
    required bool isAadhaarVerified,
    required bool isPanVerified,
  }) {
    final loc = AppLocalizations.of(context)!;
    final totalDocs = isOrg ? 2 : 1;
    final verifiedCount = (isAadhaarVerified ? 1 : 0) + (isOrg && isPanVerified ? 1 : 0);
    final allVerified = verifiedCount == totalDocs;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isOrg ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOrg ? const Color(0xFFBFDBFE) : const Color(0xFFBBF7D0),
              ),
            ),
            child: Icon(
              isOrg ? Icons.business_outlined : Icons.person_outline,
              color: isOrg ? const Color(0xFF1D4ED8) : const Color(0xFF15803D),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOrg ? loc.organisationConsumer : loc.individualConsumer,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isOrg
                      ? loc.requiresOrgKycSubtitle
                      : loc.requiresIndividualKycSubtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: allVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: allVerified ? const Color(0xFF86EFAC) : const Color(0xFFFCD34D),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  allVerified ? Icons.check_circle : Icons.pending_actions,
                  size: 13,
                  color: allVerified ? const Color(0xFF15803D) : const Color(0xFFB45309),
                ),
                const SizedBox(width: 4),
                Text(
                  isOrg ? loc.verifiedCountSummary(verifiedCount.toString(), totalDocs.toString()) : (allVerified ? loc.aadhaarVerified : loc.pendingBadge),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: allVerified ? const Color(0xFF15803D) : const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAadhaarCard({
    required bool isOrg,
    required bool isAadhaarVerified,
    required String displayAadhaarNo,
    required String displayAadhaarName,
    required ConsumerProfileData? profile,
  }) {
    final loc = AppLocalizations.of(context)!;
    final hasDoc = (profile?.aadharDoc != null && profile!.aadharDoc!.isNotEmpty) ||
        (_profileAadhaarDocUrl != null && _profileAadhaarDocUrl!.isNotEmpty) ||
        _localProfileAadhaarPath != null;

    return Container(
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
                            isOrg
                                ? (isAadhaarVerified ? loc.contactPersonAadhaarVerified : loc.contactPersonAadhaarPending)
                                : (isAadhaarVerified ? loc.aadhaarVerified : loc.aadhaarPending),
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
                            isAadhaarVerified ? loc.verifiedUpper : loc.actionRequiredLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isAadhaarVerified ? const Color(0xFF15803D) : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOrg ? loc.authContactPersonIdentity : loc.nationalIdentityUidai,
                      style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Aadhaar Details Box
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
                  label: isOrg ? loc.contactPersonAadhaar : loc.aadhaarAuthenticationLabel,
                  subtitle: isAadhaarVerified
                      ? (displayAadhaarName.isNotEmpty
                          ? '${displayAadhaarNo.isNotEmpty ? displayAadhaarNo : 'N/A'}\n$displayAadhaarName'
                          : (displayAadhaarNo.isNotEmpty ? displayAadhaarNo : 'N/A'))
                      : null,
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
                  onPressed: !hasDoc
                      ? null
                      : () async {
                          final docUrl = _profileAadhaarDocUrl ?? profile?.aadharDoc;
                          if (docUrl != null && docUrl.isNotEmpty) {
                            final url = Uri.tryParse(docUrl);
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
                  child: Text(
                    loc.viewDocument,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: hasDoc ? AppColors.ink : Colors.grey,
                    ),
                  ),
                ),
              ),
              if (!isAadhaarVerified || !hasDoc) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                      backgroundColor: AppColors.primary700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _openKycModal(KycStep.upload),
                    child: Text(
                      isAadhaarVerified ? loc.uploadDocument : '${loc.verifyAadhaar} →',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPanCard({
    required bool isPanVerified,
    required String displayPanNo,
    required String displayPanName,
    required ConsumerProfileData? profile,
  }) {
    final loc = AppLocalizations.of(context)!;
    final hasDoc = (profile?.panDoc != null && profile!.panDoc!.isNotEmpty) ||
        (_profilePanDocUrl != null && _profilePanDocUrl!.isNotEmpty) ||
        _localProfilePanPath != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPanVerified ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPanVerified ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
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
                  color: isPanVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isPanVerified ? Icons.business : Icons.warning_amber_rounded,
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
                            isPanVerified ? loc.orgPanVerified : loc.orgPanPending,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isPanVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isPanVerified ? const Color(0xFF86EFAC) : const Color(0xFFFCD34D),
                            ),
                          ),
                          child: Text(
                            isPanVerified ? loc.verifiedUpper : loc.actionRequiredLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isPanVerified ? const Color(0xFF15803D) : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loc.incomeTaxDeptEntityPan,
                      style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // PAN Details Box
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
                  icon: Icons.badge_outlined,
                  label: loc.orgPan,
                  subtitle: isPanVerified
                      ? '${displayPanNo.isNotEmpty ? displayPanNo : 'N/A'}${displayPanName.isNotEmpty ? '\n$displayPanName' : ''}'
                      : null,
                  isVerified: isPanVerified,
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
                  onPressed: !hasDoc
                      ? null
                      : () async {
                          final docUrl = _profilePanDocUrl ?? profile?.panDoc;
                          if (docUrl != null && docUrl.isNotEmpty) {
                            final url = Uri.tryParse(docUrl);
                            if (url != null) {
                              try {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              } catch (_) {}
                            }
                          } else if (_localProfilePanPath != null) {
                            try {
                              await OpenFile.open(_localProfilePanPath!);
                            } catch (_) {}
                          }
                        },
                  child: Text(
                    loc.viewDocument,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: hasDoc ? AppColors.ink : Colors.grey,
                    ),
                  ),
                ),
              ),
              if (!isPanVerified || !hasDoc) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                      backgroundColor: AppColors.primary700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _openPanModal(KycStep.upload),
                    child: Text(
                      isPanVerified ? loc.uploadDocument : loc.verifyPanArrow,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistRow({
    required IconData icon,
    required String label,
    String? subtitle,
    required bool isVerified,
    String? verifiedText,
    String? pendingText,
  }) {
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
              isVerified ? (verifiedText ?? loc.aadhaarVerified) : (pendingText ?? loc.aadhaarPending),
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

