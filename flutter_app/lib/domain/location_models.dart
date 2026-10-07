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
      id: (json['id'] ?? json['Id']) is int ? (json['id'] ?? json['Id']) as int : int.tryParse((json['id'] ?? json['Id'])?.toString() ?? '') ?? 0,
      name: (json['name'] ?? json['Name'])?.toString() ?? '',
      districtId: (json['districtId'] ?? json['DistrictId']) is int ? (json['districtId'] ?? json['DistrictId']) as int : int.tryParse((json['districtId'] ?? json['DistrictId'])?.toString() ?? '') ?? 0,
      talukaId: (json['talukaId'] ?? json['TalukaId']) is int ? (json['talukaId'] ?? json['TalukaId']) as int : int.tryParse((json['talukaId'] ?? json['TalukaId'])?.toString() ?? '') ?? 0,
      isTown: (json['isTown'] ?? json['IsTown']) == true || (json['isTown'] ?? json['IsTown'])?.toString().toLowerCase() == 'true' || (json['isTown'] ?? json['IsTown']) == 1,
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

class StateModel {
  final int id;
  final String state;
  final int stateCode;

  const StateModel({
    required this.id,
    required this.state,
    required this.stateCode,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      state: json['state']?.toString() ?? '',
      stateCode: json['stateCode'] is int ? json['stateCode'] as int : int.tryParse(json['stateCode']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'state': state,
    'stateCode': stateCode,
  };
}
