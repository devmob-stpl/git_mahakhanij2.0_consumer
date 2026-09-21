import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/user.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../providers/session_provider.dart';
import '../../providers/operating_context_provider.dart';

enum KycStep { view, upload, success }

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _designationController;
  late TextEditingController _orgNameController;
  late TextEditingController _line1Controller;
  late TextEditingController _talukaController;
  late TextEditingController _districtController;
  late TextEditingController _pincodeController;

  String _orgType = 'CONTRACTOR';
  bool _isKycVerified = true;
  bool _isSaving = false;
  bool _showSaveToast = false;

  // KYC Modal State
  KycStep _kycStep = KycStep.view;
  String _uploadedDocName = '';
  bool _isUploadingDoc = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(sessionProvider).currentUser;
    final org = ref.read(operatingContextProvider).organization;

    _nameController = TextEditingController(text: user?.fullName ?? 'Rohit Sanghavi');
    _emailController = TextEditingController(
      text: user?.email ?? (user?.userType == UserType.organization ? 'contact@sanghaviinfra.com' : 'aniket.deshmukh@gmail.com'),
    );
    _mobileController = TextEditingController(text: user?.mobileNumber ?? '9822014576');
    _designationController = TextEditingController(text: 'Project Director');
    _orgNameController = TextEditingController(text: org?.legalName ?? 'Sanghavi Infrastructure Pvt Ltd');
    _line1Controller = TextEditingController(
      text: org?.address.line1 ?? 'Plot 42, MIDC Industrial Area, Chakan',
    );
    _talukaController = TextEditingController(text: org?.address.taluka ?? 'Khed');
    _districtController = TextEditingController(text: org?.address.district ?? 'Pune');
    _pincodeController = TextEditingController(text: org?.address.pincode ?? '410501');
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
    _pincodeController.dispose();
    super.dispose();
  }

  void _handleSaveProfile() {
    setState(() => _isSaving = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _showSaveToast = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showSaveToast = false);
      });
    });
  }

  void _openKycModal(KycStep step) {
    setState(() {
      _kycStep = step;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_user, color: Color(0xFF1241A6), size: 22),
                            const SizedBox(width: 8),
                            Text(
                              _kycStep == KycStep.upload
                                  ? 'Submit KYC Documents'
                                  : (_kycStep == KycStep.success ? 'KYC Verification Done' : 'e-KYC Identity Verification'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20, color: AppColors.inkMuted),
                          onPressed: () => Navigator.pop(modalContext),
                        ),
                      ],
                    ),
                    const Divider(height: 1, color: AppColors.line),
                    const SizedBox(height: 14),

                    // Body according to step
                    if (_kycStep == KycStep.view) ...[
                      // Green Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFF047857), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'UIDAI & Government Portal Verified',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF065F46)),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'All minor mineral allocations, DigiTP passes, and temporary excavation orders generated by this profile are legally authorized.',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF047857)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Verification Details Table
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _buildKycDetailRow('Aadhaar Linked', 'XXXX-XXXX-8842'),
                            const Divider(height: 12, color: Color(0xFFE2E8F0)),
                            _buildKycDetailRow('PAN Number', 'ANDPG4491M'),
                            const Divider(height: 12, color: Color(0xFFE2E8F0)),
                            _buildKycDetailRow('GSTIN Reference', '27AADCL8842R1Z8'),
                            const Divider(height: 12, color: Color(0xFFE2E8F0)),
                            _buildKycDetailRow('Verification Date', '14-Jan-2024'),
                            const Divider(height: 12, color: Color(0xFFE2E8F0)),
                            _buildKycDetailRow('Digital Authority', 'MahaOnline / DigiLocker e-Sign'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 44),
                                side: const BorderSide(color: AppColors.line),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                setModalState(() {
                                  _kycStep = KycStep.upload;
                                });
                              },
                              child: const Text('Re-upload Documents', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppButton(
                              label: 'Close',
                              onPressed: () => Navigator.pop(modalContext),
                            ),
                          ),
                        ],
                      ),
                    ] else if (_kycStep == KycStep.upload) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Select and upload official identification or address proof for statutory verification:',
                          style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_isUploadingDoc)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: AppColors.primary700),
                              SizedBox(height: 12),
                              Text('Verifying with Government Portal...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                            ],
                          ),
                        )
                      else ...[
                        _buildUploadDocTile(
                          icon: Icons.badge_outlined,
                          title: 'Aadhaar Card (PDF / JPG)',
                          subtitle: 'UIDAI verified national identity card',
                          onTap: () => _simulateDocUpload(setModalState, 'Aadhaar_UIDAI_Verified.pdf'),
                        ),
                        const SizedBox(height: 10),
                        _buildUploadDocTile(
                          icon: Icons.credit_card_outlined,
                          title: 'PAN Card Document',
                          subtitle: 'Income tax department identity proof',
                          onTap: () => _simulateDocUpload(setModalState, 'PAN_Card_Verification.jpg'),
                        ),
                        const SizedBox(height: 10),
                        _buildUploadDocTile(
                          icon: Icons.business_outlined,
                          title: 'GST & Incorporation Certificate',
                          subtitle: 'Ministry of Corporate Affairs registration',
                          onTap: () => _simulateDocUpload(setModalState, 'GST_Incorporation_2024.pdf'),
                        ),
                      ],
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
                        'KYC Verification Completed!',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Document "$_uploadedDocName" has been verified against Government of Maharashtra databases.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'Done',
                        fullWidth: true,
                        onPressed: () {
                          setState(() => _isKycVerified = true);
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

  void _simulateDocUpload(StateSetter setModalState, String docName) {
    setModalState(() {
      _isUploadingDoc = true;
      _uploadedDocName = docName;
    });

    Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setModalState(() {
        _isUploadingDoc = false;
        _kycStep = KycStep.success;
      });
      setState(() => _isKycVerified = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider).currentUser;
    final isOrg = user?.userType == UserType.organization;

    return AppScaffold(
      title: 'Profile & KYC',
      showBackButton: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1) Top Navy Identity Hero Card (#102d5e)
                Container(
                  color: const Color(0xFF102D5E),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                        ),
                        child: Center(
                          child: Text(
                            user != null && user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'R',
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
                                    user?.fullName ?? 'Rohit Sanghavi',
                                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
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
                              '+91 ${user?.mobileNumber ?? "9822014576"}',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontFamily: 'monospace'),
                            ),
                            Text(
                              isOrg ? 'ID: MH/MK/ENT/2023/018842' : 'ID: CON-2024-10425',
                              style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11, fontFamily: 'monospace'),
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
                      // 2) KYC VERIFICATION STATUS CARD
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isKycVerified ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isKycVerified ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
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
                                    color: _isKycVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _isKycVerified ? Icons.verified_user : Icons.warning_amber_rounded,
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
                                          Text(
                                            _isKycVerified ? 'e-KYC Verified' : 'KYC Verification Pending',
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _isKycVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: _isKycVerified ? const Color(0xFF86EFAC) : const Color(0xFFFCD34D),
                                              ),
                                            ),
                                            child: Text(
                                              _isKycVerified ? 'Active & Approved' : 'Action Required',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: _isKycVerified ? const Color(0xFF15803D) : const Color(0xFFB45309),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _isKycVerified
                                            ? 'Your Aadhaar, PAN and registry identity credentials are authenticated with the Government of Maharashtra.'
                                            : 'Complete your pending KYC documents to unlock digital transit passes and permit applications.',
                                        style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary, height: 1.35),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // KYC Document Checklist Card
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
                                    label: isOrg ? 'Company GSTIN & Incorporation' : 'Aadhaar / UIDAI e-KYC',
                                    isVerified: _isKycVerified,
                                  ),
                                  const Divider(height: 16, color: Color(0xFFF1F5F9)),
                                  _buildChecklistRow(
                                    icon: Icons.description_outlined,
                                    label: isOrg ? 'Authorized Signatory PAN' : 'Permanent Account Number (PAN)',
                                    isVerified: true,
                                  ),
                                  const Divider(height: 16, color: Color(0xFFF1F5F9)),
                                  _buildChecklistRow(
                                    icon: Icons.location_on_outlined,
                                    label: isOrg ? 'Registered Office Address Proof' : 'Delivery Address Proof (7/12)',
                                    isVerified: _isKycVerified,
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
                                    child: const Text('View KYC Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
                                  ),
                                ),
                                if (!_isKycVerified) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(double.infinity, 40),
                                        backgroundColor: AppColors.primary700,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => _openKycModal(KycStep.upload),
                                      child: const Text('Complete KYC →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Prototype testing helper toggle
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() => _isKycVerified = !_isKycVerified);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(_isKycVerified ? 'Demo: KYC switched to Verified' : 'Demo: KYC switched to Pending Action'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.swap_horiz, size: 14, color: AppColors.inkMuted),
                                label: Text(
                                  _isKycVerified ? 'Test: Simulate Pending KYC' : 'Test: Simulate Verified KYC',
                                  style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 3) Personal & Account Details Form
                      const Text(
                        'Personal & Account Details',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
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
                              label: 'Full Name *',
                              controller: _nameController,
                              prefixIcon: const Icon(Icons.person_outline, size: 18),
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              label: 'Registered Mobile Number',
                              controller: _mobileController,
                              enabled: false,
                              prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                              helperText: 'Verified via Government OTP (Locked)',
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              label: 'Email Address *',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.mail_outline, size: 18),
                            ),
                            if (isOrg) ...[
                              const SizedBox(height: 12),
                              AppTextField(
                                label: 'Designation / Role in Company',
                                controller: _designationController,
                                hint: 'e.g. Project Director, Site Manager',
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 4) Organization & Business Details
                      if (isOrg) ...[
                        const Text(
                          'Organization & Business Details',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppTextField(
                                label: 'Company / Enterprise Name *',
                                controller: _orgNameController,
                                prefixIcon: const Icon(Icons.business_outlined, size: 18),
                              ),
                              const SizedBox(height: 12),
                              const Text('Entity Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _orgType,
                                decoration: const InputDecoration(),
                                items: const [
                                  DropdownMenuItem(value: 'CONTRACTOR', child: Text('Contractor / Infrastructure')),
                                  DropdownMenuItem(value: 'BUILDER', child: Text('Builder / Developer')),
                                  DropdownMenuItem(value: 'GOVERNMENT', child: Text('Government Agency / PSU')),
                                  DropdownMenuItem(value: 'OTHER', child: Text('Other Commercial Entity')),
                                ],
                                onChanged: (v) => setState(() => _orgType = v ?? 'CONTRACTOR'),
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                label: 'MahaKhanij Registration ID',
                                controller: TextEditingController(text: 'MH/MK/ENT/2023/018842'),
                                enabled: false,
                                helperText: 'Official State Mineral Concessionaire ID',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // 5) Address Details
                      Text(
                        isOrg ? 'Registered Office Address' : 'Default Delivery Destination',
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
                              label: 'Address Line 1 *',
                              controller: _line1Controller,
                              prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    label: 'Taluka *',
                                    controller: _talukaController,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppTextField(
                                    label: 'District *',
                                    controller: _districtController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              label: 'PIN Code *',
                              controller: _pincodeController,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Save Button
                      AppButton(
                        label: _isSaving ? 'Saving Changes...' : 'Save Profile Changes',
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
                    BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
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
      ),
    );
  }

  Widget _buildChecklistRow({required IconData icon, required String label, required bool isVerified}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: isVerified ? const Color(0xFF059669) : AppColors.inkMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.ink),
            ),
          ],
        ),
        Row(
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
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: AppColors.ink)),
      ],
    );
  }

  Widget _buildUploadDocTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF1241A6)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.inkSecondary)),
                ],
              ),
            ),
            const Text(
              'Upload',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1241A6)),
            ),
          ],
        ),
      ),
    );
  }
}
