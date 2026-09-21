import 'common.dart';

enum TemporaryExcavationStatus {
  draft('DRAFT'),
  submitted('SUBMITTED'),
  underReview('UNDER_REVIEW'),
  queryRaised('QUERY_RAISED'),
  demandNoteIssued('DEMAND_NOTE_ISSUED'),
  orderIssued('ORDER_ISSUED'),
  rejected('REJECTED');

  final String value;
  const TemporaryExcavationStatus(this.value);

  static TemporaryExcavationStatus fromString(String val) {
    return TemporaryExcavationStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => TemporaryExcavationStatus.underReview,
    );
  }
}

class ApplicantDetails {
  final String fullName;
  final String mobileNumber;
  final String? landlineNumber;
  final String? email;
  final String panNumber;
  final String? aadhaarNumber;
  final String? gstNumber;
  final Address registeredAddress;

  const ApplicantDetails({
    required this.fullName,
    required this.mobileNumber,
    this.landlineNumber,
    this.email,
    required this.panNumber,
    this.aadhaarNumber,
    this.gstNumber,
    required this.registeredAddress,
  });

  factory ApplicantDetails.fromJson(Map<String, dynamic> json) {
    return ApplicantDetails(
      fullName: json['fullName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      landlineNumber: json['landlineNumber'],
      email: json['email'],
      panNumber: json['panNumber'] ?? '',
      aadhaarNumber: json['aadhaarNumber'],
      gstNumber: json['gstNumber'],
      registeredAddress: Address.fromJson(json['registeredAddress'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'mobileNumber': mobileNumber,
    if (landlineNumber != null) 'landlineNumber': landlineNumber,
    if (email != null) 'email': email,
    'panNumber': panNumber,
    if (aadhaarNumber != null) 'aadhaarNumber': aadhaarNumber,
    if (gstNumber != null) 'gstNumber': gstNumber,
    'registeredAddress': registeredAddress.toJson(),
  };
}

class SurveyEntry {
  final String id;
  final String surveyNumber;
  final double areaInHectares;
  final bool sevenTwelveAttached;
  final bool ownerApprovalAttached;

  const SurveyEntry({
    required this.id,
    required this.surveyNumber,
    this.areaInHectares = 0.75,
    this.sevenTwelveAttached = true,
    this.ownerApprovalAttached = true,
  });

  factory SurveyEntry.fromJson(Map<String, dynamic> json) {
    return SurveyEntry(
      id: json['id'] ?? '',
      surveyNumber: json['surveyNumber'] ?? '',
      areaInHectares: (json['areaInHectares'] as num?)?.toDouble() ?? 0.75,
      sevenTwelveAttached: json['sevenTwelveAttached'] ?? true,
      ownerApprovalAttached: json['ownerApprovalAttached'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'surveyNumber': surveyNumber,
    'areaInHectares': areaInHectares,
    'sevenTwelveAttached': sevenTwelveAttached,
    'ownerApprovalAttached': ownerApprovalAttached,
  };
}

class ApplicationDocument {
  final String id;
  final String kind;
  final String fileName;
  final String documentType;
  final String? documentNumber;
  final String uploadedAt;

  const ApplicationDocument({
    required this.id,
    required this.kind,
    required this.fileName,
    required this.documentType,
    this.documentNumber,
    required this.uploadedAt,
  });

  factory ApplicationDocument.fromJson(Map<String, dynamic> json) {
    return ApplicationDocument(
      id: json['id'] ?? '',
      kind: json['kind'] ?? 'OTHER',
      fileName: json['fileName'] ?? '',
      documentType: json['documentType'] ?? '',
      documentNumber: json['documentNumber'],
      uploadedAt: json['uploadedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'fileName': fileName,
    'documentType': documentType,
    if (documentNumber != null) 'documentNumber': documentNumber,
    'uploadedAt': uploadedAt,
  };
}

class DemandNote {
  final String demandNoteNumber;
  final String issuedAt;
  final String dueDate;
  final Money totalAmount;

  const DemandNote({
    required this.demandNoteNumber,
    required this.issuedAt,
    required this.dueDate,
    required this.totalAmount,
  });

  factory DemandNote.fromJson(Map<String, dynamic> json) {
    return DemandNote(
      demandNoteNumber: json['demandNoteNumber'] ?? '',
      issuedAt: json['issuedAt'] ?? '',
      dueDate: json['dueDate'] ?? '',
      totalAmount: Money.fromJson(json['totalAmount'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'demandNoteNumber': demandNoteNumber,
    'issuedAt': issuedAt,
    'dueDate': dueDate,
    'totalAmount': totalAmount.toJson(),
  };
}

class ExcavationOrder {
  final String orderNumber;
  final String issuedAt;
  final String validFrom;
  final String validUntil;
  final Quantity permittedQuantity;

  const ExcavationOrder({
    required this.orderNumber,
    required this.issuedAt,
    required this.validFrom,
    required this.validUntil,
    required this.permittedQuantity,
  });

  factory ExcavationOrder.fromJson(Map<String, dynamic> json) {
    return ExcavationOrder(
      orderNumber: json['orderNumber'] ?? '',
      issuedAt: json['issuedAt'] ?? '',
      validFrom: json['validFrom'] ?? '',
      validUntil: json['validUntil'] ?? '',
      permittedQuantity: Quantity.fromJson(json['permittedQuantity'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'orderNumber': orderNumber,
    'issuedAt': issuedAt,
    'validFrom': validFrom,
    'validUntil': validUntil,
    'permittedQuantity': permittedQuantity.toJson(),
  };
}

class TemporaryExcavationApplication {
  final String id;
  final String applicationNumber;
  final String organizationId;
  final String? projectId;
  final String? packageId;
  final ApplicantDetails applicant;
  
  // Proposal & Excavation
  final String applicationType; // 'QUARRY_TEMPORARY_PLOT' | 'QUARRY_PROJECT_SELF_CONSUMPTION'
  final String leaseType; // 'TEMPORARY'
  final String proposalLevel; // 'DISTRICT_LEVEL' | 'SUB_DIVISIONAL_LEVEL' | 'STATE_LEVEL'
  final String mineralId;
  final String mineralName;
  final Quantity estimatedQuantity;
  final String excavationMethod; // 'MANUAL' | 'SEMI_MECHANISED' | 'MECHANISED'
  final int liftingPeriodDays;
  final String reasonForApplying;
  final String purpose;
  
  // Self-consumption specific
  final double? totalExcavationQuantityBrass;
  final String projectType; // 'GOVERNMENT' | 'PRIVATE'
  final String? departmentName;
  final String? officeName;
  final String? workOrderNumber;
  final String? workOrderDocumentName;
  final String? projectCode;
  final String? projectName;
  final String? projectAddress;
  final String? projectLatitude;
  final String? projectLongitude;
  final String zeroRoyaltyScheme; // 'NO' | 'YES'

  // Location Details
  final String category; // 'RURAL' | 'URBAN'
  final String plotLocationType; // 'INTERIOR' | 'RIVERBED' | 'PLAIN_AGRICULTURAL' | 'HILLY'
  final String districtCode;
  final String districtName;
  final String talukaCode;
  final String talukaName;
  final String villageCode;
  final String villageName;
  final Address siteAddress;
  final GeoPoint siteGeo;
  final String village;
  final String surveyNumber;
  final List<SurveyEntry> surveyEntries;
  final String? subDivisionNumber;
  final String landType; // 'PRIVATE' | 'GOVERNMENT' | 'GRAM_PANCHAYAT'
  final double totalPlotAreaHectare;
  final double areaInSqm;
  final double depthInMetres;
  final String demandNoteOffice;
  final String grasOfficeName;

  final String fromDate;
  final String toDate;
  final Money applicationFee;
  final bool declarationAccepted;
  final TemporaryExcavationStatus status;
  final String? submittedAt;
  final DemandNote? demandNote;
  final ExcavationOrder? excavationOrder;
  final String statusUpdatedAt;
  final String? statusRemarks;
  final int? lastStepIndex;
  final List<ApplicationDocument> documents;

  const TemporaryExcavationApplication({
    required this.id,
    required this.applicationNumber,
    required this.organizationId,
    this.projectId,
    this.packageId,
    required this.applicant,
    this.applicationType = 'QUARRY_TEMPORARY_PLOT',
    this.leaseType = 'TEMPORARY',
    this.proposalLevel = 'DISTRICT_LEVEL',
    required this.mineralId,
    this.mineralName = '',
    required this.estimatedQuantity,
    this.excavationMethod = 'SEMI_MECHANISED',
    this.liftingPeriodDays = 60,
    this.reasonForApplying = '',
    required this.purpose,
    this.totalExcavationQuantityBrass,
    this.projectType = 'GOVERNMENT',
    this.departmentName,
    this.officeName,
    this.workOrderNumber,
    this.workOrderDocumentName,
    this.projectCode,
    this.projectName,
    this.projectAddress,
    this.projectLatitude,
    this.projectLongitude,
    this.zeroRoyaltyScheme = 'NO',
    this.category = 'RURAL',
    this.plotLocationType = 'INTERIOR',
    this.districtCode = '',
    this.districtName = '',
    this.talukaCode = '',
    this.talukaName = '',
    this.villageCode = '',
    this.villageName = '',
    required this.siteAddress,
    required this.siteGeo,
    required this.village,
    required this.surveyNumber,
    this.surveyEntries = const [],
    this.subDivisionNumber,
    this.landType = 'PRIVATE',
    this.totalPlotAreaHectare = 0.75,
    this.areaInSqm = 7500.0,
    this.depthInMetres = 0.0,
    this.demandNoteOffice = 'DMO_PUNE',
    this.grasOfficeName = 'GRAS_PUNE',
    required this.fromDate,
    required this.toDate,
    required this.applicationFee,
    this.declarationAccepted = false,
    required this.status,
    this.submittedAt,
    this.demandNote,
    this.excavationOrder,
    required this.statusUpdatedAt,
    this.statusRemarks,
    this.lastStepIndex,
    this.documents = const [],
  });

  bool get isDraft => status == TemporaryExcavationStatus.draft;

  factory TemporaryExcavationApplication.fromJson(Map<String, dynamic> json) {
    return TemporaryExcavationApplication(
      id: json['id'] ?? '',
      applicationNumber: json['applicationNumber'] ?? '',
      organizationId: json['organizationId'] ?? '',
      projectId: json['projectId'],
      packageId: json['packageId'],
      applicant: ApplicantDetails.fromJson(json['applicant'] ?? {}),
      applicationType: json['applicationType'] ?? 'QUARRY_TEMPORARY_PLOT',
      leaseType: json['leaseType'] ?? 'TEMPORARY',
      proposalLevel: json['proposalLevel'] ?? 'DISTRICT_LEVEL',
      mineralId: json['mineralId'] ?? '',
      mineralName: json['mineralName'] ?? '',
      estimatedQuantity: Quantity.fromJson(json['estimatedQuantity'] ?? {}),
      excavationMethod: json['excavationMethod'] ?? 'SEMI_MECHANISED',
      liftingPeriodDays: json['liftingPeriodDays'] as int? ?? 60,
      reasonForApplying: json['reasonForApplying'] ?? '',
      purpose: json['purpose'] ?? '',
      totalExcavationQuantityBrass: (json['totalExcavationQuantityBrass'] as num?)?.toDouble(),
      projectType: json['projectType'] ?? 'GOVERNMENT',
      departmentName: json['departmentName'],
      officeName: json['officeName'],
      workOrderNumber: json['workOrderNumber'],
      workOrderDocumentName: json['workOrderDocumentName'],
      projectCode: json['projectCode'],
      projectName: json['projectName'],
      projectAddress: json['projectAddress'],
      projectLatitude: json['projectLatitude'],
      projectLongitude: json['projectLongitude'],
      zeroRoyaltyScheme: json['zeroRoyaltyScheme'] ?? 'NO',
      category: json['category'] ?? 'RURAL',
      plotLocationType: json['plotLocationType'] ?? 'INTERIOR',
      districtCode: json['districtCode'] ?? '',
      districtName: json['districtName'] ?? '',
      talukaCode: json['talukaCode'] ?? '',
      talukaName: json['talukaName'] ?? '',
      villageCode: json['villageCode'] ?? '',
      villageName: json['villageName'] ?? '',
      siteAddress: Address.fromJson(json['siteAddress'] ?? {}),
      siteGeo: GeoPoint.fromJson(json['siteGeo'] ?? {}),
      village: json['village'] ?? '',
      surveyNumber: json['surveyNumber'] ?? '',
      surveyEntries: (json['surveyEntries'] as List<dynamic>?)
              ?.map((s) => SurveyEntry.fromJson(s))
              .toList() ??
          [],
      subDivisionNumber: json['subDivisionNumber'],
      landType: json['landType'] ?? 'PRIVATE',
      totalPlotAreaHectare: (json['totalPlotAreaHectare'] as num?)?.toDouble() ?? 0.75,
      areaInSqm: (json['areaInSqm'] as num?)?.toDouble() ?? 7500.0,
      depthInMetres: (json['depthInMetres'] as num?)?.toDouble() ?? 0.0,
      demandNoteOffice: json['demandNoteOffice'] ?? 'DMO_PUNE',
      grasOfficeName: json['grasOfficeName'] ?? 'GRAS_PUNE',
      fromDate: json['fromDate'] ?? '',
      toDate: json['toDate'] ?? '',
      applicationFee: Money.fromJson(json['applicationFee'] ?? {}),
      declarationAccepted: json['declarationAccepted'] ?? false,
      status: TemporaryExcavationStatus.fromString(json['status'] ?? 'DRAFT'),
      submittedAt: json['submittedAt'],
      demandNote: json['demandNote'] != null ? DemandNote.fromJson(json['demandNote']) : null,
      excavationOrder: json['excavationOrder'] != null ? ExcavationOrder.fromJson(json['excavationOrder']) : null,
      statusUpdatedAt: json['statusUpdatedAt'] ?? '',
      statusRemarks: json['statusRemarks'],
      lastStepIndex: json['lastStepIndex'] as int?,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((d) => ApplicationDocument.fromJson(d))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'applicationNumber': applicationNumber,
    'organizationId': organizationId,
    if (projectId != null) 'projectId': projectId,
    if (packageId != null) 'packageId': packageId,
    'applicant': applicant.toJson(),
    'applicationType': applicationType,
    'leaseType': leaseType,
    'proposalLevel': proposalLevel,
    'mineralId': mineralId,
    'mineralName': mineralName,
    'estimatedQuantity': estimatedQuantity.toJson(),
    'excavationMethod': excavationMethod,
    'liftingPeriodDays': liftingPeriodDays,
    'reasonForApplying': reasonForApplying,
    'purpose': purpose,
    if (totalExcavationQuantityBrass != null) 'totalExcavationQuantityBrass': totalExcavationQuantityBrass,
    'projectType': projectType,
    if (departmentName != null) 'departmentName': departmentName,
    if (officeName != null) 'officeName': officeName,
    if (workOrderNumber != null) 'workOrderNumber': workOrderNumber,
    if (workOrderDocumentName != null) 'workOrderDocumentName': workOrderDocumentName,
    if (projectCode != null) 'projectCode': projectCode,
    if (projectName != null) 'projectName': projectName,
    if (projectAddress != null) 'projectAddress': projectAddress,
    if (projectLatitude != null) 'projectLatitude': projectLatitude,
    if (projectLongitude != null) 'projectLongitude': projectLongitude,
    'zeroRoyaltyScheme': zeroRoyaltyScheme,
    'category': category,
    'plotLocationType': plotLocationType,
    'districtCode': districtCode,
    'districtName': districtName,
    'talukaCode': talukaCode,
    'talukaName': talukaName,
    'villageCode': villageCode,
    'villageName': villageName,
    'siteAddress': siteAddress.toJson(),
    'siteGeo': siteGeo.toJson(),
    'village': village,
    'surveyNumber': surveyNumber,
    'surveyEntries': surveyEntries.map((s) => s.toJson()).toList(),
    if (subDivisionNumber != null) 'subDivisionNumber': subDivisionNumber,
    'landType': landType,
    'totalPlotAreaHectare': totalPlotAreaHectare,
    'areaInSqm': areaInSqm,
    'depthInMetres': depthInMetres,
    'demandNoteOffice': demandNoteOffice,
    'grasOfficeName': grasOfficeName,
    'fromDate': fromDate,
    'toDate': toDate,
    'applicationFee': applicationFee.toJson(),
    'declarationAccepted': declarationAccepted,
    'status': status.value,
    if (submittedAt != null) 'submittedAt': submittedAt,
    if (demandNote != null) 'demandNote': demandNote!.toJson(),
    if (excavationOrder != null) 'excavationOrder': excavationOrder!.toJson(),
    'statusUpdatedAt': statusUpdatedAt,
    if (statusRemarks != null) 'statusRemarks': statusRemarks,
    if (lastStepIndex != null) 'lastStepIndex': lastStepIndex,
    'documents': documents.map((d) => d.toJson()).toList(),
  };
}
