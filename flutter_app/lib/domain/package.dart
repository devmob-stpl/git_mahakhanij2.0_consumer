import 'common.dart';

class SupervisorInfo {
  final String? id;
  final String name;
  final String mobileNumber;
  final String employeeCode;
  final String? assignedPackageId;
  final String? assignedPackageName;

  const SupervisorInfo({
    this.id,
    required this.name,
    required this.mobileNumber,
    required this.employeeCode,
    this.assignedPackageId,
    this.assignedPackageName,
  });

  factory SupervisorInfo.fromJson(Map<String, dynamic> json) {
    return SupervisorInfo(
      id: json['id'],
      name: json['name'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      employeeCode: json['employeeCode'] ?? '',
      assignedPackageId: json['assignedPackageId'],
      assignedPackageName: json['assignedPackageName'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'mobileNumber': mobileNumber,
    'employeeCode': employeeCode,
    if (assignedPackageId != null) 'assignedPackageId': assignedPackageId,
    if (assignedPackageName != null) 'assignedPackageName': assignedPackageName,
  };
}

class Package {
  final String id;
  final String projectId;
  final String organizationId;
  final String name;
  final String code;
  final Address siteAddress;
  final GeoPoint siteGeo;
  final String status;
  final String startDate;
  final String? expectedEndDate;
  final SupervisorInfo? supervisor;

  const Package({
    required this.id,
    required this.projectId,
    required this.organizationId,
    required this.name,
    required this.code,
    required this.siteAddress,
    required this.siteGeo,
    required this.status,
    required this.startDate,
    this.expectedEndDate,
    this.supervisor,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      organizationId: json['organizationId'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      siteAddress: Address.fromJson(json['siteAddress'] ?? {}),
      siteGeo: GeoPoint.fromJson(json['siteGeo'] ?? {}),
      status: json['status'] ?? 'ACTIVE',
      startDate: json['startDate'] ?? '',
      expectedEndDate: json['expectedEndDate'],
      supervisor: json['supervisor'] != null
          ? SupervisorInfo.fromJson(json['supervisor'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'organizationId': organizationId,
    'name': name,
    'code': code,
    'siteAddress': siteAddress.toJson(),
    'siteGeo': siteGeo.toJson(),
    'status': status,
    'startDate': startDate,
    if (expectedEndDate != null) 'expectedEndDate': expectedEndDate,
    if (supervisor != null) 'supervisor': supervisor!.toJson(),
  };
}
