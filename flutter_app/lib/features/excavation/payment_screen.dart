import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

class PaymentScreen extends StatefulWidget {
  final String title;
  final String amount;
  final String applicationId;
  final String applicantName;
  final String proposedQuantity;
  final String applicationFee;
  final String stampDuty;

  const PaymentScreen({
    super.key,
    this.title = 'Application Fee Payment',
    this.amount = '₹520',
    this.applicationId = 'TEA/2026/DRAFT-001410',
    this.applicantName = 'Rohit Sanghavi',
    this.proposedQuantity = '22 Brass',
    this.applicationFee = '₹500',
    this.stampDuty = '₹20',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedTab = 0; // 0: Online (NetBanking/UPI), 1: Offline GRAS Challan
  bool _isProcessing = false;
  bool _isSettled = false;

  // Offline Challan Form Controllers
  late final TextEditingController _grnController;
  late final TextEditingController _cinController;
  late final TextEditingController _challanDateController;
  late final TextEditingController _bankBranchController;
  String? _uploadedFileName;

  @override
  void initState() {
    super.initState();
    _grnController = TextEditingController();
    _cinController = TextEditingController();
    _challanDateController = TextEditingController(text: '18/09/2026');
    _bankBranchController = TextEditingController(text: 'State Bank of India (Cyber Treasury)');
  }

  @override
  void dispose() {
    _grnController.dispose();
    _cinController.dispose();
    _challanDateController.dispose();
    _bankBranchController.dispose();
    super.dispose();
  }

  void _handlePay() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isSettled = true;
      });
    }
  }

  void _handleSubmitOfflineChallan() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isSettled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appIdText = widget.applicationId.isNotEmpty ? widget.applicationId : 'TEA/2026/DRAFT-001410';

    if (_isSettled) {
      return _buildSettledView(context, appIdText);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP HEADER BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.ink),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Application Fee Payment',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appIdText,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. SCROLLABLE BODY CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PAYMENT METHOD TAB SWITCHER
                    Container(
                      height: 48,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 0),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: _selectedTab == 0
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.06),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  '🌐 Online (NetBanking/UPI)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w600,
                                    color: _selectedTab == 0 ? const Color(0xFF1D4ED8) : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedTab = 1),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: _selectedTab == 1
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.06),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  '🏛️ Offline GRAS Challan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w600,
                                    color: _selectedTab == 1 ? const Color(0xFF1D4ED8) : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CARD 1: APPLICATION FEE ASSESSMENT
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'APPLICATION FEE ASSESSMENT',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                '₹',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Pay the application fee to submit your excavation proposal. The proposal is forwarded to the Revenue Officer as soon as payment succeeds.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Inner Summary Box
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              children: [
                                _buildSummaryRow('Application No:', appIdText, isValueBold: true),
                                const SizedBox(height: 8),
                                _buildSummaryRow('Applicant / Lessee:', widget.applicantName),
                                const SizedBox(height: 8),
                                _buildSummaryRow('Proposed Quantity:', widget.proposedQuantity),
                                const SizedBox(height: 8),
                                _buildSummaryRow('Application Fee:', widget.applicationFee),
                                const SizedBox(height: 8),
                                _buildSummaryRow('Stamp Duty:', widget.stampDuty),
                                const Divider(color: Color(0xFFE2E8F0), height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Payable:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    Text(
                                      widget.amount,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CARD 2: ENTER BANK / TREASURY CHALLAN DETAILS (OFFLINE TAB)
                    if (_selectedTab == 1) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF94A3B8), width: 1.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.credit_card_outlined,
                                    size: 18,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Enter Bank / Treasury Challan Details',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Field 1: GRN Reference
                            _buildFieldLabel('GRAS Challan GRN / Reference No. *'),
                            const SizedBox(height: 6),
                            _buildInputBox(
                              controller: _grnController,
                              hint: 'E.G. MH000242672202627E',
                              isMonospace: true,
                            ),
                            const SizedBox(height: 14),

                            // Row of 2 Fields: CIN & Challan Date
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildFieldLabel('CIN (Challan ID)'),
                                      const SizedBox(height: 6),
                                      _buildInputBox(
                                        controller: _cinController,
                                        hint: 'e.g. 0200394202609038',
                                        isMonospace: true,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildFieldLabel('Challan Date *'),
                                      const SizedBox(height: 6),
                                      InkWell(
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2025),
                                            lastDate: DateTime(2030),
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              _challanDateController.text =
                                                  '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                                            });
                                          }
                                        },
                                        child: Container(
                                          height: 44,
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: const Color(0xFFCBD5E1)),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _challanDateController.text.isNotEmpty
                                                    ? _challanDateController.text
                                                    : 'DD/MM/YYYY',
                                                style: const TextStyle(fontSize: 13, color: AppColors.ink),
                                              ),
                                              const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.inkMuted),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Field 3: Bank Branch
                            _buildFieldLabel('Bank / Cyber Treasury Branch'),
                            const SizedBox(height: 6),
                            _buildInputBox(
                              controller: _bankBranchController,
                              hint: 'State Bank of India (Cyber Treasury)',
                            ),
                            const SizedBox(height: 14),

                            // Field 4: File Upload
                            _buildFieldLabel('Upload Bank Stamped Challan Receipt (PDF / Image)'),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _uploadedFileName = 'bank_stamped_receipt_MH2026.pdf';
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Attached bank_stamped_receipt_MH2026.pdf')),
                                );
                              },
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.upload_outlined, size: 18, color: Color(0xFF64748B)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _uploadedFileName ?? 'Click to select challan receipt',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: _uploadedFileName != null ? AppColors.ink : const Color(0xFF64748B),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Text(
                                      'Browse',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1D4ED8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // 3. FIXED BOTTOM ACTION BUTTON
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedTab == 0 ? const Color(0xFF15803D) : const Color(0xFFCBD5E1),
                    foregroundColor: _selectedTab == 0 ? Colors.white : const Color(0xFF334155),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _isProcessing
                      ? null
                      : (_selectedTab == 0 ? _handlePay : _handleSubmitOfflineChallan),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_selectedTab == 0) ...[
                              const Text('₹', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                              const SizedBox(width: 8),
                              Text(
                                'Pay Online via GRAS · ${widget.amount}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                            ] else ...[
                              const Icon(Icons.description_outlined, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Verify & Submit Offline Challan (${widget.amount})',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ),

            // 4. BOTTOM NAVIGATION BAR
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFDDE3EE), width: 1)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  _buildBottomNavItem(Icons.home_outlined, 'Home', false, () => context.go('/home')),
                  _buildBottomNavItem(Icons.layers_outlined, 'Projects', false, () => context.go('/organization/projects')),
                  _buildBottomNavItem(Icons.show_chart, 'Activity', false, () => context.go('/activity')),
                  _buildBottomNavItem(Icons.more_horiz, 'More', false, () => context.go('/more')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettledView(BuildContext context, String appIdText) {
    final formattedAppId = appIdText.contains('DRAFT')
        ? appIdText.replaceAll('DRAFT-', '')
        : (appIdText.isNotEmpty ? appIdText : 'TEA/2026/001411');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP HEADER BAR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
              ),
              child: const Text(
                'Payment Verified & Settled',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),

            // 2. SCROLLABLE BODY CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    // Green Checkmark Badge
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6F4EA),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC8E6C9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF15803D),
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Title
                    const Text(
                      'Application Fee Verified & Submitted!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Amount
                    Text(
                      widget.amount,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle
                    const Text(
                      'Application Fee Settled via GRAS Cyber Treasury',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // CARD 1: APPLICATION SUMMARY BOX
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Application Number',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                formattedAppId,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Color(0xFFF1F5F9), height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFF334155), width: 1.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.check, size: 14, color: Color(0xFF0F172A)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Submitted (Under Review)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CARD 2: OFFICIAL GOVERNMENT RECEIPTS & PASSES
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.description_outlined, size: 18, color: Color(0xFF1D4ED8)),
                              SizedBox(width: 8),
                              Text(
                                'OFFICIAL GOVERNMENT RECEIPTS & PASSES',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Downloaded GRAS e-Challan (GRN & CIN) PDF')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.credit_card_outlined, size: 18, color: Color(0xFF1D4ED8)),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Download GRAS e-Challan (GRN & CIN)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1D4ED8),
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.download_outlined, size: 18, color: Color(0xFF1D4ED8)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // PRIMARY BUTTON: Return to Application Overview ->
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1D4ED8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          context.pop(true);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Return to Application Overview',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. BOTTOM NAVIGATION BAR
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFDDE3EE), width: 1)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  _buildBottomNavItem(Icons.home_outlined, 'Home', false, () => context.go('/home')),
                  _buildBottomNavItem(Icons.layers_outlined, 'Projects', false, () => context.go('/organization/projects')),
                  _buildBottomNavItem(Icons.show_chart, 'Activity', false, () => context.go('/activity')),
                  _buildBottomNavItem(Icons.more_horiz, 'More', false, () => context.go('/more')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isValueBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.inkSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isValueBold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      ),
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required String hint,
    bool isMonospace = false,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 13,
        fontFamily: isMonospace ? 'monospace' : null,
        color: AppColors.ink,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13,
          fontFamily: isMonospace ? 'monospace' : null,
          color: const Color(0xFF94A3B8),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary700, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFEEF4FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isActive ? const Color(0xFF1241A6) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? const Color(0xFF1241A6) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

