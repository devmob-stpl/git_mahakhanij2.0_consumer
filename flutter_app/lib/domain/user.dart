import 'common.dart';
import '../core/constants/app_constants.dart';
export '../core/constants/app_constants.dart';

enum UserType {
  normalConsumer('NORMAL_CONSUMER'),
  organization('ORGANIZATION'),
  supervisor('SUPERVISOR');

  final String value;
  const UserType(this.value);

  int get consumerType => this == UserType.organization
      ? CONSUMER_TYPE_ORGANISATION
      : CONSUMER_TYPE_INDIVIDUAL;

  static UserType fromConsumerType(int? type) {
    if (type == CONSUMER_TYPE_ORGANISATION) {
      return UserType.organization;
    }
    return UserType.normalConsumer;
  }

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
  final int? consumerId;
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
  final int? appId;

  const User({
    required this.id,
    this.consumerId,
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
    this.appId,
  });

  bool get isOrganization => userType == UserType.organization;
  bool get isConsumer => userType == UserType.normalConsumer;
  bool get isSupervisor => userType == UserType.supervisor;
  int get consumerType => userType.consumerType;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      consumerId: json['consumerId'] is int
          ? json['consumerId'] as int
          : int.tryParse(json['consumerId']?.toString() ?? ''),
      fullName: json['fullName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      email: json['email'],
      userType: json['consumerType'] != null
          ? UserType.fromConsumerType(json['consumerType'] is int
              ? json['consumerType'] as int
              : int.tryParse(json['consumerType']?.toString() ?? ''))
          : UserType.fromString(json['userType'] ?? 'NORMAL_CONSUMER'),
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
      appId: json['appId'] is int ? json['appId'] as int : int.tryParse(json['appId']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (consumerId != null) 'consumerId': consumerId,
    'fullName': fullName,
    'mobileNumber': mobileNumber,
    if (email != null) 'email': email,
    'userType': userType.value,
    'consumerType': consumerType,
    if (organizationId != null) 'organizationId': organizationId,
    if (designation != null) 'designation': designation,
    if (assignedPackageId != null) 'assignedPackageId': assignedPackageId,
    if (deliveryAddress != null) 'deliveryAddress': deliveryAddress!.toJson(),
    if (deliveryGeo != null) 'deliveryGeo': deliveryGeo!.toJson(),
    'createdAt': createdAt,
    if (appId != null) 'appId': appId,
  };
}
