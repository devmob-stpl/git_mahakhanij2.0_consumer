import 'common.dart';
export 'project.dart';
export 'package.dart';

class Organization {
  final String id;
  final String legalName;
  final String registrationNumber;
  final String panNumber;
  final String? gstNumber;
  final Address registeredAddress;
  Address get address => registeredAddress;
  final String createdAt;

  const Organization({
    required this.id,
    required this.legalName,
    required this.registrationNumber,
    required this.panNumber,
    this.gstNumber,
    required this.registeredAddress,
    required this.createdAt,
  });

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'] ?? '',
      legalName: json['legalName'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      panNumber: json['panNumber'] ?? '',
      gstNumber: json['gstNumber'],
      registeredAddress: Address.fromJson(json['registeredAddress'] ?? {}),
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'legalName': legalName,
    'registrationNumber': registrationNumber,
    'panNumber': panNumber,
    if (gstNumber != null) 'gstNumber': gstNumber,
    'registeredAddress': registeredAddress.toJson(),
    'createdAt': createdAt,
  };
}
