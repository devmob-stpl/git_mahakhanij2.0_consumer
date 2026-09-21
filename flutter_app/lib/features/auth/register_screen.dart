import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/user.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/prototype_bar.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // Step 0: Choose Account Type (0), Step 1: Basic & Address details (1), Step 2: KYC Verification (2)
  int _step = 0;
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
  String _district = 'Pune';
  String _taluka = 'Haveli';
  final _cityController = TextEditingController(text: 'Pune City (PMC)');
  final _villageController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Step 2: KYC Details
  final _aadhaarController = TextEditingController();
  final _panController = TextEditingController();
  String? _kycFileName;
  String? _panFileName;
  String? _aadhaarFileName;

  // Form Errors
  Map<String, String> _errors = {};

  final List<String> _districts = const [
    'Pune',
    'Mumbai City',
    'Mumbai Suburban',
    'Thane',
    'Nagpur',
    'Nashik',
    'Chhatrapati Sambhajinagar',
    'Ahilyanagar',
    'Raigad',
    'Solapur',
    'Satara',
    'Kolhapur',
  ];

  final Map<String, List<String>> _talukasByDistrict = const {
    'Pune': ['Haveli', 'Maval', 'Mulshi', 'Shirur', 'Khed', 'Baramati', 'Daund', 'Purandar'],
    'Mumbai City': ['Mumbai City'],
    'Mumbai Suburban': ['Andheri', 'Borivali', 'Kurla'],
    'Thane': ['Thane', 'Kalyan', 'Bhiwandi', 'Ulhasnagar', 'Ambernath'],
    'Nagpur': ['Nagpur Urban', 'Nagpur Rural', 'Kamptee', 'Hingna', 'Katol'],
    'Nashik': ['Nashik', 'Sinnar', 'Niphad', 'Dindori', 'Malegaon'],
    'Chhatrapati Sambhajinagar': ['Chhatrapati Sambhajinagar', 'Paithan', 'Gangapur', 'Vaijapur'],
    'Ahilyanagar': ['Nagar', 'Rahata', 'Sangamner', 'Kopargaon', 'Shrirampur'],
  };

  @override
  void dispose() {
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
    _panController.dispose();
    super.dispose();
  }

  void _handleQuickFill() {
    setState(() {
      _errors.clear();
      if (_step == 0) {
        _step = 1;
      }
      if (_userType == UserType.organization) {
        _fullNameController.text = 'Rajesh Patil';
        _mobileController.text = '9822014576';
        _orgNameController.text = 'Shree Infra & Constructions Pvt Ltd';
        _orgType = 'CONTRACTOR';
        _gstController.text = '27ABCDE1234F1Z5';
        _regNumberController.text = 'MH-2024-ORG-9988';
        _gstStatus = 'verified';
        _noGst = false;
        _areaClassification = 'URBAN';
        _district = 'Pune';
        _taluka = 'Haveli';
        _cityController.text = 'Pune City (PMC)';
        _addressController.text = 'Survey No. 42/1, Wagholi-Kesnand Road';
        _pincodeController.text = '412207';
        _panController.text = 'ABCDE1234F';
        _aadhaarController.text = '4532 1098 4532';
        _panFileName = 'Company_PAN_ABCDE1234F.pdf';
        _aadhaarFileName = 'Signatory_Aadhaar.pdf';
      } else {
        _fullNameController.text = 'Amit Deshmukh';
        _mobileController.text = '9730845120';
        _areaClassification = 'URBAN';
        _district = 'Pune';
        _taluka = 'Haveli';
        _cityController.text = 'Pune City (PMC)';
        _villageController.text = '';
        _addressController.text = 'Flat 402, Shivajinagar Heights';
        _pincodeController.text = '411005';
        _aadhaarController.text = '9876 5432 1098';
        _kycFileName = 'Aadhaar_Card_Amit_Deshmukh.pdf';
      }
    });
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
      if (_step == 0) {
        context.pop();
      } else {
        _step--;
      }
    });
  }

  void _next() {
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

    // Step 2 complete -> proceed to OTP verification
    final mobile = _mobileController.text.trim();
    context.push('/otp', extra: mobile);
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
      if (_userType == UserType.normalConsumer) {
        final aadh = _aadhaarController.text.replaceAll(' ', '').trim();
        if (aadh.length != 12 || !RegExp(r'^\d{12}$').hasMatch(aadh)) {
          found['aadhaar'] = 'Enter a valid 12-digit Aadhaar number.';
        }
        if (_kycFileName == null) {
          found['kycFile'] = 'Please upload the required KYC document to continue.';
        }
      } else {
        final pan = _panController.text.trim().toUpperCase();
        if (pan.length != 10 || !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(pan)) {
          found['pan'] = 'Enter a valid 10-character PAN (e.g. ABCDE1234F).';
        }
        if (_panFileName == null) {
          found['panFile'] = 'Please upload the required KYC document to continue.';
        }
        final aadh = _aadhaarController.text.replaceAll(' ', '').trim();
        if (aadh.length != 12 || !RegExp(r'^\d{12}$').hasMatch(aadh)) {
          found['aadhaar'] = 'Enter a valid 12-digit Aadhaar number.';
        }
        if (_aadhaarFileName == null) {
          found['aadhaarFile'] = 'Please upload the required KYC document to continue.';
        }
      }
    }

    return found;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        children: [
          const PrototypeBar(),
          // Top Auth Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.ink),
                  onPressed: _back,
                ),
                TextButton.icon(
                  onPressed: _handleQuickFill,
                  icon: const Icon(Icons.bolt, size: 16, color: Color(0xFFB45309)),
                  label: const Text(
                    'Quick Fill',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF3C7),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                ),
              ],
            ),
          ),

          // Step Progress Bar (Step 1 and 2)
          if (_step > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary700,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: _step == 2 ? AppColors.primary700 : AppColors.line,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: AppButton(
              label: _step == 0
                  ? 'Continue'
                  : _step == 1
                      ? 'Continue to KYC Verification'
                      : 'Verify & Send OTP',
              fullWidth: true,
              size: AppButtonSize.large,
              onPressed: _next,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 0: Choose Account Type
  // -------------------------------------------------------------
  Widget _buildStep0ChooseType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Account Type',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        const Text(
          'How will you use Mahakhanij?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
        ),
        const SizedBox(height: 4),
        const Text(
          'This decides what the app shows you. It cannot be changed later.',
          style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Individual',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'For an individual buying mineral for personal use.',
                        style: TextStyle(fontSize: 13, color: AppColors.inkSecondary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Organization',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'For a builder, contractor, government body or any other organization working across projects and packages.',
                        style: TextStyle(fontSize: 13, color: AppColors.inkSecondary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),
        Row(
          children: [
            const Text('Already have an account? ', style: TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
            GestureDetector(
              onTap: () => context.push('/login'),
              child: const Text(
                'Sign in',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary700, decoration: TextDecoration.underline),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOrg ? 'Organization details' : 'Your details',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          isOrg
              ? 'Enter authorized representative, entity and registered office details.'
              : 'Enter your personal contact and delivery destination details.',
          style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
        ),
        const SizedBox(height: 20),

        // Full Name / Rep Name
        _buildFieldLabel(isOrg ? 'Authorized person full name' : 'Full name'),
        const SizedBox(height: 6),
        _buildTextField(_fullNameController, hint: isOrg ? 'Rajesh Patil' : 'Amit Deshmukh', error: _errors['fullName']),
        const SizedBox(height: 16),

        // Mobile Number with +91 Prefix
        _buildFieldLabel('Mobile number'),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
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
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                  decoration: const InputDecoration(
                    hintText: '10-digit number',
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_errors.containsKey('mobile')) ...[
          const SizedBox(height: 4),
          Text(_errors['mobile']!, style: const TextStyle(fontSize: 12, color: AppColors.danger700)),
        ],
        const SizedBox(height: 16),

        // Organization Specific Fields
        if (isOrg) ...[
          _buildFieldLabel('Organization name'),
          const SizedBox(height: 6),
          _buildTextField(_orgNameController, hint: 'Shree Infra & Constructions Pvt Ltd', error: _errors['orgName']),
          const SizedBox(height: 16),

          _buildFieldLabel('Organization type'),
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

          // GSTIN Section with Verify button
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
          const SizedBox(height: 24),
        ],

        // Address Section
        const Divider(height: 32),
        const Text(
          'Where should mineral be delivered?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
        const SizedBox(height: 4),
        const Text(
          'Used to find nearby mineral places and to verify deliveries on arrival.',
          style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
        ),
        const SizedBox(height: 16),

        // Urban / Rural Toggle Pills
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _areaClassification = 'URBAN'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _areaClassification == 'URBAN' ? AppColors.primary700 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _areaClassification == 'URBAN' ? AppColors.primary700 : AppColors.line),
                  ),
                  child: Center(
                    child: Text(
                      'Urban',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _areaClassification == 'URBAN' ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _areaClassification = 'RURAL'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _areaClassification == 'RURAL' ? AppColors.primary700 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _areaClassification == 'RURAL' ? AppColors.primary700 : AppColors.line),
                  ),
                  child: Center(
                    child: Text(
                      'Rural',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _areaClassification == 'RURAL' ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // District Dropdown
        _buildFieldLabel('District'),
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
              value: _district,
              isExpanded: true,
              items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _district = val;
                    final talukas = _talukasByDistrict[val] ?? ['Central'];
                    _taluka = talukas.first;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Taluka Dropdown
        _buildFieldLabel('Taluka'),
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
              value: (_talukasByDistrict[_district]?.contains(_taluka) ?? false) ? _taluka : _talukasByDistrict[_district]?.first,
              isExpanded: true,
              items: (_talukasByDistrict[_district] ?? ['Central']).map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _taluka = val);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),

        if (_areaClassification == 'URBAN') ...[
          _buildFieldLabel('City / Municipal Area'),
          const SizedBox(height: 6),
          _buildTextField(_cityController, hint: 'e.g. Pune City (PMC)'),
          const SizedBox(height: 14),
        ] else ...[
          _buildFieldLabel('Village'),
          const SizedBox(height: 6),
          _buildTextField(_villageController, hint: 'e.g. Wagholi'),
          const SizedBox(height: 14),
        ],

        // Street Address
        _buildFieldLabel(isOrg ? 'Registered office / site address' : 'Address (House / Flat / Street / Area)'),
        const SizedBox(height: 6),
        _buildTextField(_addressController, hint: 'e.g. Survey No. 42/1, Wagholi Road', error: _errors['address']),
        const SizedBox(height: 14),

        // PIN code
        _buildFieldLabel('PIN code'),
        const SizedBox(height: 6),
        _buildTextField(_pincodeController, hint: '6-digit PIN code', error: _errors['pincode']),
        const SizedBox(height: 24),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 2: KYC Verification
  // -------------------------------------------------------------
  Widget _buildStep2Kyc() {
    final isOrg = _userType == UserType.organization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOrg ? 'Organization KYC Verification' : 'Individual KYC Verification',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Text(
          isOrg
              ? 'Verify entity via PAN. An OTP will be sent to your PAN-registered mobile number.'
              : 'Verify identity via Aadhaar. An OTP will be sent to your Aadhaar-linked mobile number.',
          style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
        ),
        const SizedBox(height: 20),

        if (!isOrg) ...[
          // Individual: Aadhaar Card Input
          _buildFieldLabel('Aadhaar card number'),
          const SizedBox(height: 6),
          _buildTextField(_aadhaarController, hint: '12-digit Aadhaar number', error: _errors['aadhaar']),
          const SizedBox(height: 16),

          // Upload Aadhaar Card
          _buildUploadCard(
            title: 'Upload Aadhaar Card',
            hint: 'Front or combined copy of Aadhaar card',
            fileName: _kycFileName,
            error: _errors['kycFile'],
            onPick: () => setState(() => _kycFileName = 'Aadhaar_Card_Amit_Deshmukh.pdf'),
          ),
          const SizedBox(height: 20),

          // UIDAI Notice Box
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
                    'A secure 6-digit OTP will be dispatched to your Aadhaar-linked mobile number for UIDAI verification.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF166534), height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Organization: PAN Card Input
          _buildFieldLabel('Organization PAN number'),
          const SizedBox(height: 6),
          _buildTextField(_panController, hint: '10-character PAN (e.g. ABCDE1234F)', error: _errors['pan'], uppercase: true),
          const SizedBox(height: 16),

          // Upload PAN Card
          _buildUploadCard(
            title: 'Upload Organization PAN Card',
            hint: 'Clear copy of entity PAN card',
            fileName: _panFileName,
            error: _errors['panFile'],
            onPick: () => setState(() => _panFileName = 'Company_PAN_ABCDE1234F.pdf'),
          ),
          const SizedBox(height: 20),

          // Signatory Aadhaar Number
          _buildFieldLabel('Signatory Aadhaar Card Number'),
          const SizedBox(height: 6),
          _buildTextField(_aadhaarController, hint: '12-digit Aadhaar number', error: _errors['aadhaar']),
          const SizedBox(height: 16),

          // Upload Signatory Aadhaar Card
          _buildUploadCard(
            title: 'Upload Signatory Aadhaar Card',
            hint: 'Clear copy of authorized signatory Aadhaar',
            fileName: _aadhaarFileName,
            error: _errors['aadhaarFile'],
            onPick: () => setState(() => _aadhaarFileName = 'Signatory_Aadhaar.pdf'),
          ),
          const SizedBox(height: 20),

          // Organization Signatory Notice Box
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
                    'A secure 6-digit OTP will be dispatched to the authorized mobile number registered with this Aadhaar.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF166534), height: 1.3),
                  ),
                ),
              ],
            ),
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
            textCapitalization: uppercase ? TextCapitalization.characters : TextCapitalization.none,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted, fontWeight: FontWeight.normal),
              border: InputBorder.none,
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
    String? error,
    required VoidCallback onPick,
  }) {
    final hasFile = fileName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onPick,
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
                    color: hasFile ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
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
                        hasFile ? fileName : title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: hasFile ? const Color(0xFF15803D) : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasFile ? 'File attached (240 KB)' : hint,
                        style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  hasFile ? 'Replace' : 'Upload',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary700),
                ),
              ],
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
}
