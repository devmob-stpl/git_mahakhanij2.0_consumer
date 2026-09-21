import 'common.dart';

class Mineral {
  final String id;
  final String name;
  final String code;
  final String category; // 'SAND' | 'AGGREGATE' | 'MURRUM' | 'STONE' | 'EARTH'
  final String description;
  final String standardUnit;
  final double defaultRatePerUnit;
  final bool isRegulated;

  const Mineral({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.description,
    required this.standardUnit,
    required this.defaultRatePerUnit,
    this.isRegulated = true,
  });

  factory Mineral.fromJson(Map<String, dynamic> json) {
    return Mineral(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      category: json['category'] ?? 'SAND',
      description: json['description'] ?? '',
      standardUnit: json['standardUnit'] ?? 'BRASS',
      defaultRatePerUnit: (json['defaultRatePerUnit'] as num?)?.toDouble() ?? 0.0,
      isRegulated: json['isRegulated'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'category': category,
    'description': description,
    'standardUnit': standardUnit,
    'defaultRatePerUnit': defaultRatePerUnit,
    'isRegulated': isRegulated,
  };
}

class StockPoint {
  final String id;
  final String name;
  final String code;
  final String operatorName;
  final String contactPhone;
  String get contact => contactPhone;
  String get operatingHours => '08:00 AM - 06:00 PM';
  final Address address;
  final GeoPoint geo;
  final List<String> availableMineralIds;
  List<String> get minerals => availableMineralIds;
  final double distanceKm;
  final bool isGovernmentApproved;

  const StockPoint({
    required this.id,
    required this.name,
    required this.code,
    required this.operatorName,
    required this.contactPhone,
    required this.address,
    required this.geo,
    required this.availableMineralIds,
    this.distanceKm = 0.0,
    this.isGovernmentApproved = true,
  });

  factory StockPoint.fromJson(Map<String, dynamic> json) {
    return StockPoint(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      operatorName: json['operatorName'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      address: Address.fromJson(json['address'] ?? {}),
      geo: GeoPoint.fromJson(json['geo'] ?? {}),
      availableMineralIds: (json['availableMineralIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      isGovernmentApproved: json['isGovernmentApproved'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'operatorName': operatorName,
    'contactPhone': contactPhone,
    'address': address.toJson(),
    'geo': geo.toJson(),
    'availableMineralIds': availableMineralIds,
    'distanceKm': distanceKm,
    'isGovernmentApproved': isGovernmentApproved,
  };
}
