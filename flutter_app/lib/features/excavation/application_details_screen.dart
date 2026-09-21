import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/temporary_excavation.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_button.dart';
import '../../providers/excavation_provider.dart';

class ApplicationDetailsScreen extends ConsumerStatefulWidget {
  final String applicationId;

  const ApplicationDetailsScreen({super.key, required this.applicationId});

  @override
  ConsumerState<ApplicationDetailsScreen> createState() => _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends ConsumerState<ApplicationDetailsScreen> {
  // 0: Status & Progress, 1: Application Info, 2: Issued Document, 3: Upload Files
  int _tabIndex = 0;

  // Track dynamically uploaded custom documents
  final List<Map<String, String>> _uploadedFilesList = [];

  void _showDocumentPreviewModal(BuildContext context, String title, String filename) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.picture_as_pdf, color: Color(0xFF1D4ED8), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            filename,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_user, color: Color(0xFF16A34A), size: 44),
                    const SizedBox(height: 10),
                    const Text(
                      'Document Digitally Verified',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'File Hash: SHA256-88a4b2f1c...99e',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Downloading $filename...')),
                        );
                      },
                      icon: const Icon(Icons.download, size: 18, color: Color(0xFF1D4ED8)),
                      label: const Text('Download', style: TextStyle(color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF1D4ED8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Full Preview', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUploadModal(BuildContext context) {
    String selectedType = 'Other Attachment';
    final nameController = TextEditingController(text: 'additional-proof.pdf');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Upload Document',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Document Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Other Attachment', child: Text('Other Supporting Document')),
                      DropdownMenuItem(value: 'Site Boundary Photo', child: Text('Site Boundary Photo')),
                      DropdownMenuItem(value: 'NOC Document', child: Text('Environmental / Gram Panchayat NOC')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text('File Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        setState(() {
                          _uploadedFilesList.add({
                            'title': selectedType,
                            'filename': nameController.text.trim().isNotEmpty ? nameController.text.trim() : 'uploaded-doc.pdf',
                          });
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Document uploaded successfully!'),
                            backgroundColor: Color(0xFF16A34A),
                          ),
                        );
                      },
                      icon: const Icon(Icons.upload_file, size: 20),
                      label: const Text('Upload File', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showQueryResponseModal(BuildContext context, TemporaryExcavationApplication app) {
    final commentController = TextEditingController();
    String? uploadedDocName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Respond to Query',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DEPARTMENT QUERY:',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFFB45309)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          app.purpose.isNotEmpty
                              ? app.purpose
                              : 'Revised site plan required with clear demarcation of excavation boundary.',
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF92400E), height: 1.35),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Attach Requested Document', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      setModalState(() {
                        uploadedDocName = 'revised-site-plan-demarcation.pdf';
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            uploadedDocName != null ? Icons.check_circle : Icons.upload_file,
                            color: uploadedDocName != null ? const Color(0xFF16A34A) : const Color(0xFF1D4ED8),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            uploadedDocName ?? 'Click to Upload Revised Site Plan (PDF)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: uploadedDocName != null ? const Color(0xFF16A34A) : const Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Response Remarks / Justification', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Provide details regarding the submitted documents...',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      fillColor: const Color(0xFFF8FAFC),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Query response submitted successfully! Status updated to Under Review.'),
                            backgroundColor: Color(0xFF15803D),
                          ),
                        );
                      },
                      child: const Text('Submit Response', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final excavationState = ref.watch(excavationProvider);
    final app = excavationState.applications.firstWhere(
      (a) => a.id == widget.applicationId || a.applicationNumber == widget.applicationId,
      orElse: () => excavationState.applications.first,
    );

    String statusBadgeLabel;
    Color statusBadgeBg;
    Color statusBadgeFg;
    switch (app.status) {
      case TemporaryExcavationStatus.orderIssued:
        statusBadgeLabel = 'Permit Ready';
        statusBadgeBg = const Color(0xFFF0FDF4);
        statusBadgeFg = const Color(0xFF16A34A);
        break;
      case TemporaryExcavationStatus.demandNoteIssued:
        statusBadgeLabel = 'Payment Due';
        statusBadgeBg = const Color(0xFFFFFBEB);
        statusBadgeFg = const Color(0xFFD97706);
        break;
      case TemporaryExcavationStatus.rejected:
        statusBadgeLabel = 'Rejected';
        statusBadgeBg = const Color(0xFFFEF2F2);
        statusBadgeFg = const Color(0xFFDC2626);
        break;
      case TemporaryExcavationStatus.queryRaised:
        statusBadgeLabel = 'Query Raised';
        statusBadgeBg = const Color(0xFFFFFBEB);
        statusBadgeFg = const Color(0xFFD97706);
        break;
      case TemporaryExcavationStatus.underReview:
        statusBadgeLabel = 'Under Review';
        statusBadgeBg = const Color(0xFFEFF6FF);
        statusBadgeFg = const Color(0xFF1D4ED8);
        break;
      default:
        statusBadgeLabel = 'Submitted';
        statusBadgeBg = const Color(0xFFEFF6FF);
        statusBadgeFg = const Color(0xFF1D4ED8);
        break;
    }

    Widget? bottomAction;
    if (app.status == TemporaryExcavationStatus.queryRaised) {
      bottomAction = AppButton(
        label: 'Respond to Department Query',
        icon: const Icon(Icons.reply, size: 18),
        variant: AppButtonVariant.primary,
        onPressed: () => _showQueryResponseModal(context, app),
      );
    } else if (app.status == TemporaryExcavationStatus.demandNoteIssued && app.demandNote != null) {
      bottomAction = AppButton(
        label: 'Pay Royalty Demand Note (${app.demandNote!.totalAmount.formatted})',
        icon: const Icon(Icons.credit_card, size: 18),
        variant: AppButtonVariant.primary,
        onPressed: () => context.push('/excavation/pay', extra: {
          'title': 'Royalty Demand Note Payment',
          'amount': app.demandNote!.totalAmount.formatted,
          'applicationId': app.applicationNumber,
          'applicantName': app.applicant.fullName,
          'proposedQuantity': app.estimatedQuantity.formatted,
          'applicationFee': app.demandNote!.totalAmount.formatted,
          'stampDuty': '₹0',
        }),
      );
    } else if (app.status == TemporaryExcavationStatus.rejected) {
      bottomAction = AppButton(
        label: 'Edit & Re-submit Proposal →',
        icon: const Icon(Icons.edit, size: 18),
        variant: AppButtonVariant.danger,
        onPressed: () => context.push('/excavation/new', extra: app),
      );
    }

    return AppScaffold(
      title: 'Temporary excavation',
      subtitle: app.applicationNumber.isNotEmpty ? app.applicationNumber : 'TEA/2026/001411',
      showBackButton: true,
      bottomActionButton: bottomAction,
      bottomNavigationBar: _buildBottomNavBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Top Summary Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Status badge on left, App No on right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBadgeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            statusBadgeLabel,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: statusBadgeFg,
                            ),
                          ),
                        ),
                        Text(
                          app.applicationNumber.isNotEmpty ? app.applicationNumber : 'TEA/2026/001411',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row 2 & 3: Quantity + Mineral & Land Type label/value
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.estimatedQuantity.formatted.isNotEmpty
                                  ? app.estimatedQuantity.formatted
                                  : '100 Brass',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              app.mineralName.isNotEmpty ? app.mineralName : 'River Sand',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Land Type',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              app.landType.isNotEmpty ? app.landType : 'Private',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 10),
                    // Row 4: Location pin + Survey & Village
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                            children: [
                              const TextSpan(text: 'Survey No. '),
                              TextSpan(
                                text: app.surveyNumber.isNotEmpty ? app.surveyNumber : '142/1',
                                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                              ),
                              TextSpan(
                                text: ', ${app.village.isNotEmpty ? app.village : "Kharadi"}, ${app.siteAddress.taluka.isNotEmpty ? app.siteAddress.taluka : "Haveli"}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 2. Horizontally Scrollable Tab Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTabPill(0, Icons.bolt_outlined, 'Status & Progress'),
                  const SizedBox(width: 8),
                  _buildTabPill(1, Icons.info_outline_rounded, 'Application Info'),
                  const SizedBox(width: 8),
                  _buildTabPill(2, Icons.insert_drive_file_outlined, 'Issued Document'),
                  const SizedBox(width: 8),
                  _buildTabPill(3, Icons.folder_outlined, 'Upload Files'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Tab Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTabBody(app),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPill(int index, IconData icon, String label) {
    final isSelected = _tabIndex == index;
    return InkWell(
      onTap: () => setState(() => _tabIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1D4ED8) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF1D4ED8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody(TemporaryExcavationApplication app) {
    switch (_tabIndex) {
      case 0:
        return _buildStatusAndProgressTab(app);
      case 1:
        return _buildApplicationInfoTab(app);
      case 2:
        return _buildIssuedDocumentTab(app);
      case 3:
        return _buildUploadFilesTab(app);
      default:
        return _buildStatusAndProgressTab(app);
    }
  }

  // ---------------------------------------------------------------------------
  // TAB 1: STATUS & PROGRESS
  // ---------------------------------------------------------------------------
  Widget _buildStatusAndProgressTab(TemporaryExcavationApplication app) {
    int currentStep = 1;
    if (app.status == TemporaryExcavationStatus.underReview || app.status == TemporaryExcavationStatus.queryRaised) {
      currentStep = 2;
    } else if (app.status == TemporaryExcavationStatus.demandNoteIssued) {
      currentStep = 3;
    } else if (app.status == TemporaryExcavationStatus.orderIssued) {
      currentStep = 4;
    }

    String statusTitle = 'Application Submitted';
    String statusSubtitle = 'Application and GRAS fee verified successfully.';
    if (app.status == TemporaryExcavationStatus.queryRaised) {
      statusTitle = 'Department Query Raised';
      statusSubtitle = 'Action Required: Please upload the requested documents.';
    } else if (app.status == TemporaryExcavationStatus.demandNoteIssued) {
      statusTitle = 'Demand Note Issued';
      statusSubtitle = 'Royalty payment requested by Revenue Department.';
    } else if (app.status == TemporaryExcavationStatus.orderIssued) {
      statusTitle = 'Permit Order Issued';
      statusSubtitle = 'Excavation permit approved and generated.';
    } else if (app.status == TemporaryExcavationStatus.rejected) {
      statusTitle = 'Application Rejected';
      statusSubtitle = 'Proposal was rejected by Department.';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: APPLICATION STATUS + Step badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'APPLICATION STATUS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1D4ED8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Step $currentStep of 4',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            statusTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            statusSubtitle,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),

          // Stepper component
          _buildStepperRow(currentStep),
          const SizedBox(height: 20),

          // NEXT UPCOMING MILESTONE Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'NEXT UPCOMING MILESTONE',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      'Stage ${currentStep < 4 ? currentStep + 1 : 4}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  currentStep == 1
                      ? 'Revenue Officer Site Inspection & Boundary Verification'
                      : (currentStep == 2
                          ? 'Statutory Royalty Demand Note Generation'
                          : (currentStep == 3
                              ? 'Final Excavation Order Issuance'
                              : 'Permit Active & Excavation Operations')),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),

          // ACTIVITY LOG
          const Text(
            'ACTIVITY LOG',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),

          // Activity item 1: Application & GRAS Fee Submitted
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Flexible(
                          child: Text(
                            'Application & GRAS Fee Submitted',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LATEST',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Receipt No: MH091123313123 · ₹520',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '18 Sept 2026',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperRow(int currentStep) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepNode(1, 'Submitted', currentStep >= 1, currentStep == 1),
            _buildStepLine(currentStep > 1),
            _buildStepNode(2, 'Inspection', currentStep >= 2, currentStep == 2),
            _buildStepLine(currentStep > 2),
            _buildStepNode(3, 'Demand Note', currentStep >= 3, currentStep == 3),
            _buildStepLine(currentStep > 3),
            _buildStepNode(4, 'Permit', currentStep >= 4, currentStep == 4),
          ],
        );
      },
    );
  }

  Widget _buildStepNode(int stepNum, String label, bool isDone, bool isActive) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? const Color(0xFF1D4ED8) : Colors.white,
            border: Border.all(
              color: isDone ? const Color(0xFF1D4ED8) : const Color(0xFFCBD5E1),
              width: 1.5,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$stepNum',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isDone || isActive ? FontWeight.w700 : FontWeight.w500,
            color: isDone || isActive ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isDone) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 13, left: 4, right: 4),
        height: 2,
        color: isDone ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: APPLICATION INFO
  // ---------------------------------------------------------------------------
  Widget _buildApplicationInfoTab(TemporaryExcavationApplication app) {
    return Column(
      children: [
        // Card 1: LAND & SITE DETAILS
        _buildInfoCard(
          icon: Icons.location_on_outlined,
          title: 'LAND & SITE DETAILS',
          rows: [
            {'label': 'Village', 'value': app.village.isNotEmpty ? app.village : 'Kharadi'},
            {'label': 'Taluka', 'value': app.siteAddress.taluka.isNotEmpty ? app.siteAddress.taluka : 'Haveli'},
            {'label': 'District', 'value': app.siteAddress.district.isNotEmpty ? app.siteAddress.district : 'Pune'},
            {'label': 'Survey Number', 'value': app.surveyNumber.isNotEmpty ? app.surveyNumber : '142/1'},
            {'label': 'Land Classification', 'value': app.landType.isNotEmpty ? app.landType : 'Private'},
            {'label': 'Excavation Area', 'value': '${app.areaInSqm.toInt()} sq m'},
            {'label': 'Max Depth', 'value': '${app.depthInMetres > 0 ? app.depthInMetres.toInt() : 4} metres'},
            {'label': 'Excavation Method', 'value': app.excavationMethod.isNotEmpty ? app.excavationMethod : 'SEMI_MECHANISED'},
            {'label': 'Purpose', 'value': app.purpose.isNotEmpty ? app.purpose : 'Commercial plot excavation and infrastructure fill'},
          ],
        ),
        const SizedBox(height: 14),

        // Card 2: APPLICANT & ENTITY
        _buildInfoCard(
          icon: Icons.person_outline,
          title: 'APPLICANT & ENTITY',
          rows: [
            {'label': 'Authorized Person', 'value': app.applicant.fullName.isNotEmpty ? app.applicant.fullName : 'Rohit Sanghavi'},
            {'label': 'Mobile Number', 'value': app.applicant.mobileNumber.isNotEmpty ? app.applicant.mobileNumber : '9822014576'},
            {'label': 'ID Proof Type', 'value': 'PAN (${app.applicant.panNumber.isNotEmpty ? app.applicant.panNumber : "ANDPG4491M"})'},
            {'label': 'Entity Name', 'value': 'Maharashtra Infrastructure Corporation Ltd.'},
            {'label': 'Registered Address', 'value': '4th Floor, Sanghavi House, LBS Marg, Kurla, Mumbai Suburban'},
          ],
        ),
        const SizedBox(height: 14),

        // Card 3: TIMELINE & PROJECT LINKAGE
        _buildInfoCard(
          icon: Icons.access_time,
          title: 'TIMELINE & PROJECT LINKAGE',
          rows: [
            {'label': 'Excavation From', 'value': app.fromDate.isNotEmpty ? app.fromDate : '18 Sept 2026'},
            {'label': 'Excavation To', 'value': app.toDate.isNotEmpty ? app.toDate : '17 Nov 2026'},
            {'label': 'Submitted On', 'value': '18 Sept 2026'},
            {'label': 'Last Status Update', 'value': '18 Sept 2026'},
            {'label': 'Linked Project', 'value': 'Mumbai-Nashik Highway Widening'},
            {'label': 'Contract Package', 'value': 'Package A — Km 12 to Km 28'},
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Map<String, String>> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF1D4ED8)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(rows.length, (index) {
            final row = rows[index];
            final isLast = index == rows.length - 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row['label']!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          row['value']!,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: ISSUED DOCUMENT
  // ---------------------------------------------------------------------------
  Widget _buildIssuedDocumentTab(TemporaryExcavationApplication app) {
    return Column(
      children: [
        // Document Card 1: Application Fee Demand Note
        _buildDocumentCard(
          title: 'Application Fee Demand Note',
          subtitle: 'DM No. 244 · Akole Tahsil Office',
          icon: Icons.article_outlined,
          iconBg: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF1D4ED8),
          downloadBg: const Color(0xFFF1F5F9),
          downloadColor: const Color(0xFF475569),
          onDownload: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Downloading Application Fee Demand Note...')),
            );
          },
        ),
        const SizedBox(height: 12),

        // Document Card 2: Application Fee GRAS Receipt
        _buildDocumentCard(
          title: 'Application Fee GRAS Receipt',
          subtitle: 'Challan: MH091123313123 · ₹520 Paid',
          icon: Icons.assignment_turned_in_outlined,
          iconBg: const Color(0xFFDCFCE7),
          iconColor: const Color(0xFF16A34A),
          downloadBg: const Color(0xFFDCFCE7),
          downloadColor: const Color(0xFF16A34A),
          onDownload: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Downloading GRAS Fee Receipt...')),
            );
          },
        ),

        // Document Card 3 (If Royalty Demand Note Issued)
        if (app.demandNote != null) ...[
          const SizedBox(height: 12),
          _buildDocumentCard(
            title: 'Royalty & Statutory Demand Note',
            subtitle: 'DN No. ${app.demandNote!.demandNoteNumber} · ${app.demandNote!.totalAmount.formatted}',
            icon: Icons.file_present,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            downloadBg: const Color(0xFFFEF3C7),
            downloadColor: const Color(0xFFD97706),
            onDownload: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading Royalty Demand Note...')),
              );
            },
          ),
        ],

        // Document Card 4 (If Excavation Order Issued)
        if (app.excavationOrder != null) ...[
          const SizedBox(height: 12),
          _buildDocumentCard(
            title: 'Official Excavation Permit Order',
            subtitle: 'Order No. ${app.excavationOrder!.orderNumber}',
            icon: Icons.verified,
            iconBg: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF16A34A),
            downloadBg: const Color(0xFFDCFCE7),
            downloadColor: const Color(0xFF16A34A),
            onDownload: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading Official Excavation Permit Order...')),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color downloadBg,
    required Color downloadColor,
    required VoidCallback onDownload,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onDownload,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: downloadBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.download, color: downloadColor, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 4: UPLOAD FILES
  // ---------------------------------------------------------------------------
  Widget _buildUploadFilesTab(TemporaryExcavationApplication app) {
    return Column(
      children: [
        // Default Uploaded Documents matching prototype
        _buildUploadFileCard(
          title: 'PAN Card Document',
          filename: 'pan-card.pdf',
        ),
        const SizedBox(height: 12),
        _buildUploadFileCard(
          title: '7/12 Extract (Satbara)',
          filename: 'seven-twelve.pdf',
        ),
        const SizedBox(height: 12),
        _buildUploadFileCard(
          title: 'Owner Approval / Affidavit',
          filename: 'owner-approval.pdf',
        ),

        // Dynamically Uploaded Files
        ...List.generate(_uploadedFilesList.length, (idx) {
          final file = _uploadedFilesList[idx];
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildUploadFileCard(
              title: file['title']!,
              filename: file['filename']!,
            ),
          );
        }),

        const SizedBox(height: 16),
        // Dashed upload button card
        InkWell(
          onTap: () => _showUploadModal(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFCBD5E1),
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: Color(0xFF1D4ED8), size: 20),
                SizedBox(width: 8),
                Text(
                  'Upload Additional Document',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadFileCard({
    required String title,
    required String filename,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.article_outlined, color: Color(0xFF64748B), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  filename,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _showDocumentPreviewModal(context, title, filename),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.file_download_outlined, color: Color(0xFF334155), size: 16),
                  SizedBox(width: 4),
                  Text(
                    'View',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM NAVIGATION BAR
  // ---------------------------------------------------------------------------
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      padding: EdgeInsets.only(
        top: 6,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 8,
      ),
      child: Row(
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', false, () => context.go('/home')),
          _buildNavItem(Icons.layers_outlined, 'Projects', false, () => context.go('/organization/projects')),
          _buildNavItem(Icons.show_chart, 'Activity', true, () => context.go('/activity')),
          _buildNavItem(Icons.more_horiz, 'More', false, () => context.go('/more')),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 26,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFEEF4FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isActive ? const Color(0xFF1241A6) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 3),
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
