import 'common.dart';

class Project {
  final String id;
  final String organizationId;
  final String name;
  final String code;
  final String? description;
  final String status; // 'PLANNING' | 'ACTIVE' | 'COMPLETED' | 'ON_HOLD'
  final String startDate;
  final String? expectedEndDate;
  final Address location;
  final String? department;
  final String? workOrderNumber;
  final String? officeName;
  final String? workOrderDate;
  final String? projectType;
  final String? category;
  final String? city;
  final String? village;
  final GeoPoint? geo;

  const Project({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.code,
    this.description,
    required this.status,
    required this.startDate,
    this.expectedEndDate,
    required this.location,
    this.department,
    this.workOrderNumber,
    this.officeName,
    this.workOrderDate,
    this.projectType,
    this.category,
    this.city,
    this.village,
    this.geo,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      organizationId: json['organizationId'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'ACTIVE',
      startDate: json['startDate'] ?? '',
      expectedEndDate: json['expectedEndDate'],
      location: Address.fromJson(json['location'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'organizationId': organizationId,
    'name': name,
    'code': code,
    if (description != null) 'description': description,
    'status': status,
    'startDate': startDate,
    if (expectedEndDate != null) 'expectedEndDate': expectedEndDate,
    'location': location.toJson(),
  };
}
