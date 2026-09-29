class DistrictModel {
  final int id;
  final String district;
  final String? mDistrict;
  final int? stateId;
  final int? distCode;

  const DistrictModel({
    required this.id,
    required this.district,
    this.mDistrict,
    this.stateId,
    this.distCode,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      district: json['district']?.toString() ?? '',
      mDistrict: json['m_District']?.toString(),
      stateId: json['stateId'] is int ? json['stateId'] as int : int.tryParse(json['stateId']?.toString() ?? ''),
      distCode: json['distCode'] is int ? json['distCode'] as int : int.tryParse(json['distCode']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'district': district,
    'm_District': mDistrict,
    'stateId': stateId,
    'distCode': distCode,
  };
}

class TalukaModel {
  final int id;
  final String taluka;
  final int districtId;
  final String? mTaluka;

  const TalukaModel({
    required this.id,
    required this.taluka,
    required this.districtId,
    this.mTaluka,
  });

  factory TalukaModel.fromJson(Map<String, dynamic> json) {
    return TalukaModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      taluka: json['taluka']?.toString() ?? '',
      districtId: json['districtID'] is int
          ? json['districtID'] as int
          : (json['districtId'] is int ? json['districtId'] as int : int.tryParse(json['districtID']?.toString() ?? json['districtId']?.toString() ?? '') ?? 0),
      mTaluka: json['m_Taluka']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'taluka': taluka,
    'districtID': districtId,
    'm_Taluka': mTaluka,
  };
}

class VillageCityModel {
  final int id;
  final String name;
  final int districtId;
  final int talukaId;
  final bool isTown;

  const VillageCityModel({
    required this.id,
    required this.name,
    required this.districtId,
    required this.talukaId,
    required this.isTown,
  });

  factory VillageCityModel.fromJson(Map<String, dynamic> json) {
    return VillageCityModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      districtId: json['districtId'] is int ? json['districtId'] as int : int.tryParse(json['districtId']?.toString() ?? '') ?? 0,
      talukaId: json['talukaId'] is int ? json['talukaId'] as int : int.tryParse(json['talukaId']?.toString() ?? '') ?? 0,
      isTown: json['isTown'] == true || json['isTown']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'districtId': districtId,
    'talukaId': talukaId,
    'isTown': isTown,
  };
}
