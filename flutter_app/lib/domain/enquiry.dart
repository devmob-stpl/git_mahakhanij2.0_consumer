import 'common.dart';

enum EnquiryStatus {
  submitted('SUBMITTED'),
  acknowledged('ACKNOWLEDGED'),
  responded('RESPONDED'),
  actionRequired('ACTION_REQUIRED'),
  digitpGenerated('DIGITP_GENERATED'),
  convertedToOrder('CONVERTED_TO_ORDER'),
  closed('CLOSED');

  final String value;
  const EnquiryStatus(this.value);

  static EnquiryStatus fromString(String val) {
    return EnquiryStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => EnquiryStatus.submitted,
    );
  }
}

class Enquiry {
  final String id;
  final String enquiryNumber;
  final String raisedByUserId;
  final String? organizationId;
  final String? projectId;
  final String? projectName;
  final String? packageId;
  final String? packageName;
  final String stockPointId;
  final String stockPointName;
  final String mineralId;
  final String mineralName;
  final Quantity requiredQuantity;
  final String requiredByDate;
  final String contactName;
  final String contactMobileNumber;
  final String? remarks;
  final EnquiryStatus status;
  final String statusLabel;
  final String createdAt;
  final String updatedAt;

  const Enquiry({
    required this.id,
    required this.enquiryNumber,
    required this.raisedByUserId,
    this.organizationId,
    this.projectId,
    this.projectName = 'Mumbai–Nashik Highway Widening',
    this.packageId,
    this.packageName = 'Package B — Km 28 to Km 41',
    required this.stockPointId,
    required this.stockPointName,
    required this.mineralId,
    required this.mineralName,
    required this.requiredQuantity,
    required this.requiredByDate,
    required this.contactName,
    required this.contactMobileNumber,
    this.remarks,
    required this.status,
    this.statusLabel = 'Enquiry Sent',
    required this.createdAt,
    this.updatedAt = '16 Sept 2026',
  });

  factory Enquiry.fromJson(Map<String, dynamic> json) {
    return Enquiry(
      id: json['id'] ?? '',
      enquiryNumber: json['enquiryNumber'] ?? '',
      raisedByUserId: json['raisedByUserId'] ?? '',
      organizationId: json['organizationId'],
      projectId: json['projectId'],
      projectName: json['projectName'] ?? 'Mumbai–Nashik Highway Widening',
      packageId: json['packageId'],
      packageName: json['packageName'] ?? 'Package B — Km 28 to Km 41',
      stockPointId: json['stockPointId'] ?? '',
      stockPointName: json['stockPointName'] ?? '',
      mineralId: json['mineralId'] ?? '',
      mineralName: json['mineralName'] ?? '',
      requiredQuantity: Quantity.fromJson(json['requiredQuantity'] ?? {}),
      requiredByDate: json['requiredByDate'] ?? '',
      contactName: json['contactName'] ?? '',
      contactMobileNumber: json['contactMobileNumber'] ?? '',
      remarks: json['remarks'],
      status: EnquiryStatus.fromString(json['status'] ?? 'SUBMITTED'),
      statusLabel: json['statusLabel'] ?? 'Enquiry Sent',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '16 Sept 2026',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'enquiryNumber': enquiryNumber,
    'raisedByUserId': raisedByUserId,
    if (organizationId != null) 'organizationId': organizationId,
    if (projectId != null) 'projectId': projectId,
    if (projectName != null) 'projectName': projectName,
    if (packageId != null) 'packageId': packageId,
    if (packageName != null) 'packageName': packageName,
    'stockPointId': stockPointId,
    'stockPointName': stockPointName,
    'mineralId': mineralId,
    'mineralName': mineralName,
    'requiredQuantity': requiredQuantity.toJson(),
    'requiredByDate': requiredByDate,
    'contactName': contactName,
    'contactMobileNumber': contactMobileNumber,
    if (remarks != null) 'remarks': remarks,
    'status': status.value,
    'statusLabel': statusLabel,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
