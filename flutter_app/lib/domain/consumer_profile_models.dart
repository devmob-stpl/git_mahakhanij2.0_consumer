class ConsumerProfileData {
  final int id;
  final int consumerType;
  final String name;
  final String mobileNo;
  final String? emailId;
  final bool isTown;
  final int? districtId;
  final int? talukaId;
  final int? censusId;
  final String? districtName;
  final String? talukaName;
  final String? cityName;
  final String? villageName;
  final String? address;
  final String? pinCode;
  final String? aadharCardNo;
  final String? aadharDoc;
  final bool isAadharVerified;
  final String? panNo;
  final String? panDoc;
  final bool isPanVerified;
  final String? gstNo;
  final String? gstDoc;
  final bool? isGstVerified;

  const ConsumerProfileData({
    required this.id,
    required this.consumerType,
    required this.name,
    required this.mobileNo,
    this.emailId,
    required this.isTown,
    this.districtId,
    this.talukaId,
    this.censusId,
    this.districtName,
    this.talukaName,
    this.cityName,
    this.villageName,
    this.address,
    this.pinCode,
    this.aadharCardNo,
    this.aadharDoc,
    this.isAadharVerified = false,
    this.panNo,
    this.panDoc,
    this.isPanVerified = false,
    this.gstNo,
    this.gstDoc,
    this.isGstVerified,
  });

  ConsumerProfileData copyWith({
    String? name,
    bool? isAadharVerified,
    String? aadharCardNo,
    String? aadharDoc,
  }) {
    return ConsumerProfileData(
      id: id,
      consumerType: consumerType,
      name: name ?? this.name,
      mobileNo: mobileNo,
      emailId: emailId,
      isTown: isTown,
      districtId: districtId,
      talukaId: talukaId,
      censusId: censusId,
      districtName: districtName,
      talukaName: talukaName,
      cityName: cityName,
      villageName: villageName,
      address: address,
      pinCode: pinCode,
      aadharCardNo: aadharCardNo ?? this.aadharCardNo,
      aadharDoc: aadharDoc ?? this.aadharDoc,
      isAadharVerified: isAadharVerified ?? this.isAadharVerified,
      panNo: panNo,
      panDoc: panDoc,
      isPanVerified: isPanVerified,
      gstNo: gstNo,
      gstDoc: gstDoc,
      isGstVerified: isGstVerified,
    );
  }

  factory ConsumerProfileData.fromJson(Map<String, dynamic> json) {
    return ConsumerProfileData(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      consumerType: json['consumerType'] is int ? json['consumerType'] as int : int.tryParse(json['consumerType']?.toString() ?? '') ?? 1,
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? '',
      mobileNo: json['mobileNo']?.toString() ?? json['mobileNumber']?.toString() ?? '',
      emailId: json['emailId']?.toString() ?? json['email']?.toString(),
      isTown: json['isTown'] == true || json['isTown']?.toString().toLowerCase() == 'true',
      districtId: json['districtId'] is int
          ? json['districtId'] as int
          : (json['districtID'] is int ? json['districtID'] as int : int.tryParse(json['districtId']?.toString() ?? json['districtID']?.toString() ?? '')),
      talukaId: json['talukaId'] is int
          ? json['talukaId'] as int
          : (json['talukaID'] is int ? json['talukaID'] as int : int.tryParse(json['talukaId']?.toString() ?? json['talukaID']?.toString() ?? '')),
      censusId: json['censusId'] is int
          ? json['censusId'] as int
          : (json['censusID'] is int ? json['censusID'] as int : int.tryParse(json['censusId']?.toString() ?? json['censusID']?.toString() ?? '')),
      districtName: json['districtName']?.toString() ?? json['district']?.toString(),
      talukaName: json['talukaName']?.toString() ?? json['taluka']?.toString(),
      cityName: json['cityName']?.toString() ?? json['city']?.toString() ?? json['urbanLocation']?.toString(),
      villageName: json['villageName']?.toString() ?? json['village']?.toString() ?? json['ruralLocation']?.toString(),
      address: json['address']?.toString() ?? json['addressLine']?.toString(),
      pinCode: json['pinCode']?.toString() ?? json['pincode']?.toString(),
      aadharCardNo: json['aadharCardNo']?.toString() ?? json['aadharNo']?.toString(),
      aadharDoc: json['aadharDoc']?.toString(),
      isAadharVerified: json['isAadharVerified'] == true || json['isAadharVerified']?.toString().toLowerCase() == 'true',
      panNo: json['panNo']?.toString(),
      panDoc: json['panDoc']?.toString(),
      isPanVerified: json['isPanVerified'] == true || json['isPanVerified']?.toString().toLowerCase() == 'true',
      gstNo: json['gstNo']?.toString(),
      gstDoc: json['gstDoc']?.toString(),
      isGstVerified: json['isGSTVerified'] == true || json['isGSTVerified']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'consumerType': consumerType,
    'name': name,
    'mobileNo': mobileNo,
    'emailId': emailId,
    'isTown': isTown,
    'districtId': districtId,
    'talukaId': talukaId,
    'censusId': censusId,
    'districtName': districtName,
    'talukaName': talukaName,
    'cityName': cityName,
    'villageName': villageName,
    'address': address,
    'pinCode': pinCode,
    'aadharCardNo': aadharCardNo,
    'aadharDoc': aadharDoc,
    'isAadharVerified': isAadharVerified,
    'panNo': panNo,
    'panDoc': panDoc,
    'isPanVerified': isPanVerified,
    'gstNo': gstNo,
    'gstDoc': gstDoc,
    'isGSTVerified': isGstVerified,
  };
}

/// Release isolate JSON uses `Map<dynamic, dynamic>`. A strict
/// `is Map<String, dynamic>` check drops `responseData` and the profile
/// screen never receives the API payload.
Map<String, dynamic>? _asStringKeyMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return Map<String, dynamic>.from(
      value.map((key, item) => MapEntry(key.toString(), item)),
    );
  }
  return null;
}

class ConsumerProfileApiResponse {
  final String statusCode;
  final String statusMessage;
  final ConsumerProfileData? responseData;
  final dynamic responseData1;

  const ConsumerProfileApiResponse({
    required this.statusCode,
    required this.statusMessage,
    this.responseData,
    this.responseData1,
  });

  bool get isSuccess =>
      (statusCode == '200' || statusCode == '200.0') && responseData != null;

  factory ConsumerProfileApiResponse.fromJson(Map<String, dynamic> json) {
    ConsumerProfileData? dataObj;
    final raw = json['responseData'];
    if (raw != null) {
      final objectMap = _asStringKeyMap(raw);
      if (objectMap != null) {
        dataObj = ConsumerProfileData.fromJson(objectMap);
      } else if (raw is List && raw.isNotEmpty) {
        final firstMap = _asStringKeyMap(raw.first);
        if (firstMap != null) {
          dataObj = ConsumerProfileData.fromJson(firstMap);
        }
      }
    }

    return ConsumerProfileApiResponse(
      statusCode: json['statusCode']?.toString() ?? '500',
      statusMessage: json['statusMessage']?.toString() ?? 'Failed to fetch consumer profile.',
      responseData: dataObj,
      responseData1: json['responseData1'],
    );
  }
}
