import 'common.dart';

enum UserType {
  normalConsumer('NORMAL_CONSUMER'),
  organization('ORGANIZATION'),
  supervisor('SUPERVISOR');

  final String value;
  const UserType(this.value);

  static UserType fromString(String val) {
    switch (val) {
      case 'ORGANIZATION':
        return UserType.organization;
      case 'SUPERVISOR':
        return UserType.supervisor;
      case 'NORMAL_CONSUMER':
      default:
        return UserType.normalConsumer;
    }
  }
}

class User {
  final String id;
  final String fullName;
  final String mobileNumber;
  final String? email;
  final UserType userType;
  final String? organizationId;
  final String? designation;
  final String? assignedPackageId;
  final Address? deliveryAddress;
  final GeoPoint? deliveryGeo;
  final String createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.mobileNumber,
    this.email,
    required this.userType,
    this.organizationId,
    this.designation,
    this.assignedPackageId,
    this.deliveryAddress,
    this.deliveryGeo,
    required this.createdAt,
  });

  bool get isOrganization => userType == UserType.organization;
  bool get isConsumer => userType == UserType.normalConsumer;
  bool get isSupervisor => userType == UserType.supervisor;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      email: json['email'],
      userType: UserType.fromString(json['userType'] ?? 'NORMAL_CONSUMER'),
      organizationId: json['organizationId'],
      designation: json['designation'],
      assignedPackageId: json['assignedPackageId'],
      deliveryAddress: json['deliveryAddress'] != null
          ? Address.fromJson(json['deliveryAddress'])
          : null,
      deliveryGeo: json['deliveryGeo'] != null
          ? GeoPoint.fromJson(json['deliveryGeo'])
          : null,
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'mobileNumber': mobileNumber,
    if (email != null) 'email': email,
    'userType': userType.value,
    if (organizationId != null) 'organizationId': organizationId,
    if (designation != null) 'designation': designation,
    if (assignedPackageId != null) 'assignedPackageId': assignedPackageId,
    if (deliveryAddress != null) 'deliveryAddress': deliveryAddress!.toJson(),
    if (deliveryGeo != null) 'deliveryGeo': deliveryGeo!.toJson(),
    'createdAt': createdAt,
  };
}
