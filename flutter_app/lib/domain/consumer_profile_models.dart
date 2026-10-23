import '../core/constants/app_constants.dart';
export '../core/constants/app_constants.dart';

class ConsumerProfileData {
  final int id;
  final int consumerType;
  final String name;
  final String mobileNo;
  final String? emailId;
  final bool isTown;
  final int? stateId;
  final String? state;
  final int? districtId;
  final int? talukaId;
  final int? censusId;
  final String? districtName;
  final String? talukaName;
  final String? cityName;
  final String? villageName;
  final String? censusName;
  final String? address;
  final String? pinCode;
  final String? aadharCardNo;
  final String? aadharDoc;
  final bool isAadharVerified;
  final String? aadharVerifiedName;
  final String? aadharClientId;
  final String? contactPersonName;
  final String? panNo;
  final String? panDoc;
  final bool isPanVerified;
  final String? panClientName;
  final String? panClientId;
  final String? gstNo;
  final String? gstDoc;
  final bool? isGstVerified;
  final String? rationCardId;
  final String? rcDoc;
  final int? createdBy;
  final String? flag;
  final bool? isCompulsoryVerification;
  final bool? isKycRequired;
  final bool? isPanKycRequired;
  final bool? isAdharKycRequired;
  final bool? isGSTKycRequired;
  final bool? isKycCompleted;

  const ConsumerProfileData({
    required this.id,
    required this.consumerType,
    required this.name,
    required this.mobileNo,
    this.emailId,
    required this.isTown,
    this.stateId,
    this.state,
    this.districtId,
    this.talukaId,
    this.censusId,
    this.districtName,
    this.talukaName,
    this.cityName,
    this.villageName,
    this.censusName,
    this.address,
    this.pinCode,
    this.aadharCardNo,
    this.aadharDoc,
    this.isAadharVerified = false,
    this.aadharVerifiedName,
    this.aadharClientId,
    this.contactPersonName,
    this.panNo,
    this.panDoc,
    this.isPanVerified = false,
    this.panClientName,
    this.panClientId,
    this.gstNo,
    this.gstDoc,
    this.isGstVerified,
    this.rationCardId,
    this.rcDoc,
    this.createdBy,
    this.flag,
    this.isCompulsoryVerification,
    this.isKycRequired,
    this.isPanKycRequired,
    this.isAdharKycRequired,
    this.isGSTKycRequired,
    this.isKycCompleted,
  });

  ConsumerProfileData copyWith({
    String? name,
    bool? isAadharVerified,
    String? aadharCardNo,
    String? aadharDoc,
    String? aadharVerifiedName,
    String? aadharClientId,
    String? contactPersonName,
    String? panNo,
    String? panDoc,
    bool? isPanVerified,
    String? panClientName,
    String? panClientId,
    String? gstNo,
    String? gstDoc,
    bool? isGstVerified,
    int? stateId,
    String? state,
    int? districtId,
    int? talukaId,
    int? censusId,
    String? districtName,
    String? talukaName,
    String? cityName,
    String? villageName,
    String? censusName,
    String? address,
    String? pinCode,
    String? rationCardId,
    String? rcDoc,
    int? createdBy,
    String? flag,
    bool? isCompulsoryVerification,
    bool? isKycRequired,
    bool? isPanKycRequired,
    bool? isAdharKycRequired,
    bool? isGSTKycRequired,
    bool? isKycCompleted,
  }) {
    return ConsumerProfileData(
      id: id,
      consumerType: consumerType,
      name: name ?? this.name,
      mobileNo: mobileNo,
      emailId: emailId,
      isTown: isTown,
      stateId: stateId ?? this.stateId,
      state: state ?? this.state,
      districtId: districtId ?? this.districtId,
      talukaId: talukaId ?? this.talukaId,
      censusId: censusId ?? this.censusId,
      districtName: districtName ?? this.districtName,
      talukaName: talukaName ?? this.talukaName,
      cityName: cityName ?? this.cityName,
      villageName: villageName ?? this.villageName,
      censusName: censusName ?? this.censusName,
      address: address ?? this.address,
      pinCode: pinCode ?? this.pinCode,
      aadharCardNo: aadharCardNo ?? this.aadharCardNo,
      aadharDoc: aadharDoc ?? this.aadharDoc,
      isAadharVerified: isAadharVerified ?? this.isAadharVerified,
      aadharVerifiedName: aadharVerifiedName ?? this.aadharVerifiedName,
      aadharClientId: aadharClientId ?? this.aadharClientId,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      panNo: panNo ?? this.panNo,
      panDoc: panDoc ?? this.panDoc,
      isPanVerified: isPanVerified ?? this.isPanVerified,
      panClientName: panClientName ?? this.panClientName,
      panClientId: panClientId ?? this.panClientId,
      gstNo: gstNo ?? this.gstNo,
      gstDoc: gstDoc ?? this.gstDoc,
      isGstVerified: isGstVerified ?? this.isGstVerified,
      rationCardId: rationCardId ?? this.rationCardId,
      rcDoc: rcDoc ?? this.rcDoc,
      createdBy: createdBy ?? this.createdBy,
      flag: flag ?? this.flag,
      isCompulsoryVerification: isCompulsoryVerification ?? this.isCompulsoryVerification,
      isKycRequired: isKycRequired ?? this.isKycRequired,
      isPanKycRequired: isPanKycRequired ?? this.isPanKycRequired,
      isAdharKycRequired: isAdharKycRequired ?? this.isAdharKycRequired,
      isGSTKycRequired: isGSTKycRequired ?? this.isGSTKycRequired,
      isKycCompleted: isKycCompleted ?? this.isKycCompleted,
    );
  }

  bool get isOrganization => consumerType == CONSUMER_TYPE_ORGANISATION;
  bool get isIndividual => !isOrganization;

  String get verifiedAadhaarDisplayName {
    if (aadharVerifiedName != null && aadharVerifiedName!.trim().isNotEmpty) {
      return aadharVerifiedName!.trim();
    }
    if (isOrganization) {
      if (contactPersonName != null && contactPersonName!.trim().isNotEmpty) {
        return contactPersonName!.trim();
      }
      return '';
    }
    return name.trim();
  }

  factory ConsumerProfileData.fromJson(Map<String, dynamic> json) {
    return ConsumerProfileData(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      consumerType: json['consumerType'] is int ? json['consumerType'] as int : int.tryParse(json['consumerType']?.toString() ?? '') ?? CONSUMER_TYPE_INDIVIDUAL,
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? '',
      mobileNo: json['mobileNo']?.toString() ?? json['mobileNumber']?.toString() ?? '',
      emailId: json['emailId']?.toString() ?? json['email']?.toString(),
      isTown: json['isTown'] == true || json['isTown']?.toString().toLowerCase() == 'true',
      stateId: json['stateId'] is int
          ? json['stateId'] as int
          : int.tryParse(json['stateId']?.toString() ?? ''),
      state: json['state']?.toString(),
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
      censusName: json['censusName']?.toString(),
      address: json['address']?.toString() ?? json['addressLine']?.toString(),
      pinCode: json['pinCode']?.toString() ?? json['pincode']?.toString(),
      aadharCardNo: json['aadharCardNo']?.toString() ?? json['aadharNo']?.toString() ?? json['aadharNumber']?.toString(),
      aadharDoc: json['aadharDoc']?.toString() ?? json['aadharDocument']?.toString(),
      isAadharVerified: json['isAadharVerified'] == true ||
          json['isAadharVerified']?.toString().toLowerCase() == 'true' ||
          json['isAadhaarVerified'] == true ||
          json['isAadhaarVerified']?.toString().toLowerCase() == 'true',
      aadharVerifiedName: json['aadharVerifiedName']?.toString() ??
          json['aadhaarVerifiedName']?.toString() ??
          json['verifiedName']?.toString() ??
          json['verifiedAadharName']?.toString() ??
          json['verifiedAadhaarName']?.toString() ??
          json['aadharName']?.toString() ??
          json['aadhaarName']?.toString() ??
          json['aadhar_verified_name']?.toString() ??
          json['aadhaar_verified_name']?.toString(),
      aadharClientId: json['aadharClientId']?.toString(),
      contactPersonName: json['contactPersonName']?.toString() ??
          json['contactPerson']?.toString() ??
          json['contact_person_name']?.toString() ??
          json['contactPersonFullName']?.toString(),
      panNo: json['panNo']?.toString() ?? json['panNumber']?.toString() ?? json['panCardNo']?.toString(),
      panDoc: json['panDoc']?.toString() ?? json['panDocument']?.toString(),
      isPanVerified: json['isPanVerified'] == true ||
          json['isPanVerified']?.toString().toLowerCase() == 'true' ||
          json['isPANVerified'] == true ||
          json['isPANVerified']?.toString().toLowerCase() == 'true',
      panClientName: json['panClientName']?.toString() ??
          json['panName']?.toString() ??
          json['clientName']?.toString() ??
          json['pan_client_name']?.toString(),
      panClientId: json['panClientId']?.toString(),
      gstNo: json['gstNo']?.toString(),
      gstDoc: json['gstDoc']?.toString(),
      isGstVerified: json['isGSTVerified'] == true || json['isGSTVerified']?.toString().toLowerCase() == 'true',
      rationCardId: json['rationCardId']?.toString(),
      rcDoc: json['rcDoc']?.toString(),
      createdBy: json['createdBy'] is int ? json['createdBy'] as int : int.tryParse(json['createdBy']?.toString() ?? ''),
      flag: json['flag']?.toString(),
      isCompulsoryVerification: json['isCompulsoryVerification'] == true || json['isCompulsoryVerification']?.toString().toLowerCase() == 'true',
      isKycRequired: json['isKycRequired'] == true || json['isKycRequired']?.toString().toLowerCase() == 'true',
      isPanKycRequired: json['isPanKycRequired'] == true || json['isPanKycRequired']?.toString().toLowerCase() == 'true',
      isAdharKycRequired: json['isAdharKycRequired'] == true || json['isAdharKycRequired']?.toString().toLowerCase() == 'true',
      isGSTKycRequired: json['isGSTKycRequired'] == true || json['isGSTKycRequired']?.toString().toLowerCase() == 'true',
      isKycCompleted: json['isKycCompleted'] == true || json['isKycCompleted']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'consumerType': consumerType,
    'name': name,
    'mobileNo': mobileNo,
    'emailId': emailId,
    'isTown': isTown,
    'stateId': stateId,
    'state': state,
    'districtId': districtId,
    'talukaId': talukaId,
    'censusId': censusId,
    'districtName': districtName,
    'talukaName': talukaName,
    'cityName': cityName,
    'villageName': villageName,
    'censusName': censusName,
    'address': address,
    'pinCode': pinCode,
    'aadharCardNo': aadharCardNo,
    'aadharDoc': aadharDoc,
    'isAadharVerified': isAadharVerified,
    'aadharVerifiedName': aadharVerifiedName,
    'aadharClientId': aadharClientId,
    'contactPersonName': contactPersonName,
    'panNo': panNo,
    'panDoc': panDoc,
    'isPanVerified': isPanVerified,
    'panClientName': panClientName,
    'panClientId': panClientId,
    'gstNo': gstNo,
    'gstDoc': gstDoc,
    'isGSTVerified': isGstVerified,
    'rationCardId': rationCardId,
    'rcDoc': rcDoc,
    'createdBy': createdBy,
    'flag': flag,
    'isCompulsoryVerification': isCompulsoryVerification,
    'isKycRequired': isKycRequired,
    'isPanKycRequired': isPanKycRequired,
    'isAdharKycRequired': isAdharKycRequired,
    'isGSTKycRequired': isGSTKycRequired,
    'isKycCompleted': isKycCompleted,
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
