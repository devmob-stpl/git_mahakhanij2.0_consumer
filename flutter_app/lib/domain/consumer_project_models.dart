class ConsumerProjectDocument {
  final int id;
  final String entity;
  final int refId;
  final int docTypeId;
  final String docType;
  final String docNo;
  final String docPath;
  final String filename;
  final int createdBy;
  final String createdDate;
  final bool isDeleted;
  final int modifiedBy;
  final String modifiedDate;
  final String documentDate;
  final String remark;

  const ConsumerProjectDocument({
    required this.id,
    required this.entity,
    required this.refId,
    required this.docTypeId,
    required this.docType,
    required this.docNo,
    required this.docPath,
    required this.filename,
    required this.createdBy,
    required this.createdDate,
    required this.isDeleted,
    required this.modifiedBy,
    required this.modifiedDate,
    required this.documentDate,
    required this.remark,
  });

  factory ConsumerProjectDocument.fromJson(Map<String, dynamic> json) {
    return ConsumerProjectDocument(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      entity: json['entity']?.toString() ?? '',
      refId: json['refId'] is int ? json['refId'] as int : int.tryParse(json['refId']?.toString() ?? '') ?? 0,
      docTypeId: json['docTypeId'] is int ? json['docTypeId'] as int : int.tryParse(json['docTypeId']?.toString() ?? '') ?? 0,
      docType: json['docType']?.toString() ?? '',
      docNo: json['docNo']?.toString() ?? '',
      docPath: json['docPath']?.toString() ?? '',
      filename: json['filename']?.toString() ?? '',
      createdBy: json['createdBy'] is int ? json['createdBy'] as int : int.tryParse(json['createdBy']?.toString() ?? '') ?? 0,
      createdDate: json['createdDate']?.toString() ?? '',
      isDeleted: json['isDeleted'] == true || json['isDeleted']?.toString().toLowerCase() == 'true',
      modifiedBy: json['modifiedBy'] is int ? json['modifiedBy'] as int : int.tryParse(json['modifiedBy']?.toString() ?? '') ?? 0,
      modifiedDate: json['modifiedDate']?.toString() ?? '',
      documentDate: json['documentDate']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
    );
  }
}

class ConsumerProjectItem {
  final int rowNumber;
  final int id;
  final int departmentId;
  final String? departmentName;
  final int organizationId;
  final String? organizationName;
  final String projectCode;
  final String name;
  final String projectAddress;
  final String contractorName;
  final String contractorMobileNo;
  final double latitude;
  final double longitude;
  final String projectLocation;
  final double estimatedQuantityInTon;
  final int projectTypeId;
  final String? projectType;
  final bool isDepartmentProject;
  final String? departmentProject;
  final int stateId;
  final String? state;
  final int divisionId;
  final String? division;
  final int districtId;
  final String? district;
  final int talukaId;
  final String? taluka;
  final int censusId;
  final String? village;
  final int officeId;
  final String? officeName;
  final int categoryId;
  final String? projectCategory;
  final int consumerId;
  final String? consumerName;
  final String aadharCardNo;
  final int isEditable;
  final String? gutNo;
  final int isCompleted;
  final int status;
  final String? remark;
  final double approvedQuantity;
  final List<ConsumerProjectDocument> getDocument;

  const ConsumerProjectItem({
    required this.rowNumber,
    required this.id,
    required this.departmentId,
    this.departmentName,
    required this.organizationId,
    this.organizationName,
    required this.projectCode,
    required this.name,
    required this.projectAddress,
    required this.contractorName,
    required this.contractorMobileNo,
    required this.latitude,
    required this.longitude,
    required this.projectLocation,
    required this.estimatedQuantityInTon,
    required this.projectTypeId,
    this.projectType,
    required this.isDepartmentProject,
    this.departmentProject,
    required this.stateId,
    this.state,
    required this.divisionId,
    this.division,
    required this.districtId,
    this.district,
    required this.talukaId,
    this.taluka,
    required this.censusId,
    this.village,
    required this.officeId,
    this.officeName,
    required this.categoryId,
    this.projectCategory,
    required this.consumerId,
    this.consumerName,
    required this.aadharCardNo,
    required this.isEditable,
    this.gutNo,
    required this.isCompleted,
    required this.status,
    this.remark,
    required this.approvedQuantity,
    required this.getDocument,
  });

  factory ConsumerProjectItem.fromJson(Map<String, dynamic> json) {
    List<ConsumerProjectDocument> docs = [];
    if (json['getDocument'] != null && json['getDocument'] is List) {
      docs = (json['getDocument'] as List)
          .map((d) => ConsumerProjectDocument.fromJson(d as Map<String, dynamic>))
          .toList();
    }

    return ConsumerProjectItem(
      rowNumber: json['rowNumber'] is int ? json['rowNumber'] as int : int.tryParse(json['rowNumber']?.toString() ?? '') ?? 0,
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      departmentId: json['departmentId'] is int ? json['departmentId'] as int : int.tryParse(json['departmentId']?.toString() ?? '') ?? 0,
      departmentName: json['departmentName']?.toString(),
      organizationId: json['organizationId'] is int ? json['organizationId'] as int : int.tryParse(json['organizationId']?.toString() ?? '') ?? 0,
      organizationName: json['organizationName']?.toString(),
      projectCode: json['projectCode']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      projectAddress: json['projectAddress']?.toString() ?? '',
      contractorName: json['contractorName']?.toString() ?? '',
      contractorMobileNo: json['contractorMobileNo']?.toString() ?? '',
      latitude: json['latitude'] is num ? (json['latitude'] as num).toDouble() : double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0,
      longitude: json['longitude'] is num ? (json['longitude'] as num).toDouble() : double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0,
      projectLocation: json['projectLocation']?.toString() ?? '',
      estimatedQuantityInTon: json['estimatedQuantityInTon'] is num ? (json['estimatedQuantityInTon'] as num).toDouble() : double.tryParse(json['estimatedQuantityInTon']?.toString() ?? '') ?? 0.0,
      projectTypeId: json['projectTypeId'] is int ? json['projectTypeId'] as int : int.tryParse(json['projectTypeId']?.toString() ?? '') ?? 0,
      projectType: json['projectType']?.toString(),
      isDepartmentProject: json['isDepartmentProject'] == true || json['isDepartmentProject']?.toString().toLowerCase() == 'true',
      departmentProject: json['departmentProject']?.toString(),
      stateId: json['stateId'] is int ? json['stateId'] as int : int.tryParse(json['stateId']?.toString() ?? '') ?? 0,
      state: json['state']?.toString(),
      divisionId: json['divisionId'] is int ? json['divisionId'] as int : int.tryParse(json['divisionId']?.toString() ?? '') ?? 0,
      division: json['division']?.toString(),
      districtId: json['districtId'] is int ? json['districtId'] as int : int.tryParse(json['districtId']?.toString() ?? '') ?? 0,
      district: json['district']?.toString(),
      talukaId: json['talukaId'] is int ? json['talukaId'] as int : int.tryParse(json['talukaId']?.toString() ?? '') ?? 0,
      taluka: json['taluka']?.toString(),
      censusId: json['censusId'] is int ? json['censusId'] as int : int.tryParse(json['censusId']?.toString() ?? '') ?? 0,
      village: json['village']?.toString(),
      officeId: json['officeId'] is int ? json['officeId'] as int : int.tryParse(json['officeId']?.toString() ?? '') ?? 0,
      officeName: json['officeName']?.toString(),
      categoryId: json['categoryId'] is int ? json['categoryId'] as int : int.tryParse(json['categoryId']?.toString() ?? '') ?? 0,
      projectCategory: json['projectCategory']?.toString(),
      consumerId: json['consumerId'] is int ? json['consumerId'] as int : int.tryParse(json['consumerId']?.toString() ?? '') ?? 0,
      consumerName: json['consumerName']?.toString(),
      aadharCardNo: json['aadharCardNo']?.toString() ?? '',
      isEditable: json['isEditable'] is int ? json['isEditable'] as int : int.tryParse(json['isEditable']?.toString() ?? '') ?? 0,
      gutNo: json['gutNo']?.toString(),
      isCompleted: json['isCompleted'] is int ? json['isCompleted'] as int : int.tryParse(json['isCompleted']?.toString() ?? '') ?? 0,
      status: json['status'] is int ? json['status'] as int : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      remark: json['remark']?.toString(),
      approvedQuantity: json['approvedQuantity'] is num ? (json['approvedQuantity'] as num).toDouble() : double.tryParse(json['approvedQuantity']?.toString() ?? '') ?? 0.0,
      getDocument: docs,
    );
  }
}

class ConsumerProjectApiResponse {
  final String statusCode;
  final String statusMessage;
  final List<ConsumerProjectItem> projects;
  final int pageNo;
  final int pageCount;
  final String totalCount;

  const ConsumerProjectApiResponse({
    required this.statusCode,
    required this.statusMessage,
    required this.projects,
    required this.pageNo,
    required this.pageCount,
    required this.totalCount,
  });

  bool get isSuccess => statusCode == '200' || statusCode == '200.0';

  factory ConsumerProjectApiResponse.fromJson(Map<String, dynamic> json) {
    List<ConsumerProjectItem> list = [];
    int pNo = 1;
    int pCount = 1;
    String totCount = '0';

    if (json['responseData'] != null && json['responseData'] is Map) {
      final respData = json['responseData'] as Map<String, dynamic>;
      if (respData['data'] != null && respData['data'] is List) {
        list = (respData['data'] as List)
            .map((item) => ConsumerProjectItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      pNo = respData['pageno'] is int ? respData['pageno'] as int : int.tryParse(respData['pageno']?.toString() ?? '') ?? 1;
      pCount = respData['pageCount'] is int ? respData['pageCount'] as int : int.tryParse(respData['pageCount']?.toString() ?? '') ?? 1;
      totCount = respData['totalCount']?.toString() ?? list.length.toString();
    }

    return ConsumerProjectApiResponse(
      statusCode: json['statusCode']?.toString() ?? '500',
      statusMessage: json['statusMessage']?.toString() ?? 'Failed to fetch project details',
      projects: list,
      pageNo: pNo,
      pageCount: pCount,
      totalCount: totCount,
    );
  }
}
