class ConsumerDigiTpItem {
  final String invoiceNo;
  final dynamic plotId;
  final String? plotName;
  final int? ownerId;
  final String? ownerName;
  final String? ownerMobileNo;
  final int? vehicleId;
  final String? vehicleNo;
  final String? validityFrom;
  final String? validityUpto;
  final double? distance;
  final String? destination;
  final String? timeStamp;
  final int? userId;
  final double? quantity;
  final int? createdBy;
  final int? materialId;
  final String? materialType;
  final String? mineralUnit;
  final dynamic projectId;
  final String? projectName;
  final String? driverMobNo;
  final String? driverName;
  final int? consumerId;
  final int? invoiceStatusId;
  final String? invoiceStatus;
  final String? receiveApprovedDate;

  const ConsumerDigiTpItem({
    required this.invoiceNo,
    this.plotId,
    this.plotName,
    this.ownerId,
    this.ownerName,
    this.ownerMobileNo,
    this.vehicleId,
    this.vehicleNo,
    this.validityFrom,
    this.validityUpto,
    this.distance,
    this.destination,
    this.timeStamp,
    this.userId,
    this.quantity,
    this.createdBy,
    this.materialId,
    this.materialType,
    this.mineralUnit,
    this.projectId,
    this.projectName,
    this.driverMobNo,
    this.driverName,
    this.consumerId,
    this.invoiceStatusId,
    this.invoiceStatus,
    this.receiveApprovedDate,
  });

  factory ConsumerDigiTpItem.fromJson(Map<String, dynamic> json) {
    return ConsumerDigiTpItem(
      invoiceNo: json['invoiceNo']?.toString() ?? '',
      plotId: json['plotId'],
      plotName: json['plotName']?.toString(),
      ownerId: json['ownerId'] is int ? json['ownerId'] as int : int.tryParse(json['ownerId']?.toString() ?? ''),
      ownerName: json['ownerName']?.toString(),
      ownerMobileNo: json['ownerMobileNo']?.toString(),
      vehicleId: json['vechileId'] is int
          ? json['vechileId'] as int
          : (json['vehicleId'] is int ? json['vehicleId'] as int : int.tryParse(json['vechileId']?.toString() ?? json['vehicleId']?.toString() ?? '')),
      vehicleNo: json['vehicleNo']?.toString() ?? json['vechileNo']?.toString(),
      validityFrom: json['validityFrom']?.toString(),
      validityUpto: json['validityUpto']?.toString(),
      distance: (json['distance'] is num) ? (json['distance'] as num).toDouble() : double.tryParse(json['distance']?.toString() ?? ''),
      destination: json['destination']?.toString(),
      timeStamp: json['timeStamp']?.toString(),
      userId: json['userId'] is int ? json['userId'] as int : int.tryParse(json['userId']?.toString() ?? ''),
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toDouble() : double.tryParse(json['quantity']?.toString() ?? ''),
      createdBy: json['createdBy'] is int ? json['createdBy'] as int : int.tryParse(json['createdBy']?.toString() ?? ''),
      materialId: json['materialId'] is int ? json['materialId'] as int : int.tryParse(json['materialId']?.toString() ?? ''),
      materialType: json['materialType']?.toString(),
      mineralUnit: json['mineralUnit']?.toString(),
      projectId: json['projectId'],
      projectName: json['projectName']?.toString(),
      driverMobNo: json['driverMobNo']?.toString(),
      driverName: json['driverName']?.toString(),
      consumerId: json['consumerId'] is int ? json['consumerId'] as int : int.tryParse(json['consumerId']?.toString() ?? ''),
      invoiceStatusId: json['invoiceStatusId'] is int ? json['invoiceStatusId'] as int : int.tryParse(json['invoiceStatusId']?.toString() ?? ''),
      invoiceStatus: json['invoiceStatus']?.toString(),
      receiveApprovedDate: json['receiveApprovedDate']?.toString() ?? json['receive_Approved_Date']?.toString() ?? json['receiveDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'invoiceNo': invoiceNo,
    'plotId': plotId,
    'plotName': plotName,
    'ownerId': ownerId,
    'ownerName': ownerName,
    'ownerMobileNo': ownerMobileNo,
    'vechileId': vehicleId,
    'vehicleNo': vehicleNo,
    'validityFrom': validityFrom,
    'validityUpto': validityUpto,
    'distance': distance,
    'destination': destination,
    'timeStamp': timeStamp,
    'userId': userId,
    'quantity': quantity,
    'createdBy': createdBy,
    'materialId': materialId,
    'materialType': materialType,
    'mineralUnit': mineralUnit,
    'projectId': projectId,
    'projectName': projectName,
    'driverMobNo': driverMobNo,
    'driverName': driverName,
    'consumerId': consumerId,
    'invoiceStatusId': invoiceStatusId,
    'invoiceStatus': invoiceStatus,
    'receiveApprovedDate': receiveApprovedDate,
  };
}

class ConsumerDigiTpCount {
  final int totalCount;
  final int inTransitCount;
  final int deliveredCount;
  final int status;
  final int statusCount;

  const ConsumerDigiTpCount({
    this.totalCount = 0,
    this.inTransitCount = 0,
    this.deliveredCount = 0,
    this.status = 0,
    this.statusCount = 0,
  });

  factory ConsumerDigiTpCount.fromJson(Map<String, dynamic> json) {
    return ConsumerDigiTpCount(
      totalCount: json['totalCount'] is int
          ? json['totalCount'] as int
          : (int.tryParse(json['totalCount']?.toString() ?? '') ?? 0),
      inTransitCount: json['inTransitCount'] is int
          ? json['inTransitCount'] as int
          : (int.tryParse(json['inTransitCount']?.toString() ?? '') ?? 0),
      deliveredCount: json['deliveredCount'] is int
          ? json['deliveredCount'] as int
          : (int.tryParse(json['deliveredCount']?.toString() ?? '') ?? 0),
      status: json['status'] is int ? json['status'] as int : (int.tryParse(json['status']?.toString() ?? '') ?? 0),
      statusCount: json['statusCount'] is int ? json['statusCount'] as int : (int.tryParse(json['statusCount']?.toString() ?? '') ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalCount': totalCount,
    'inTransitCount': inTransitCount,
    'deliveredCount': deliveredCount,
    'status': status,
    'statusCount': statusCount,
  };
}

class ConsumerDigiTpData {
  final List<ConsumerDigiTpItem> data;
  final ConsumerDigiTpCount? count;

  const ConsumerDigiTpData({
    required this.data,
    this.count,
  });

  factory ConsumerDigiTpData.fromJson(Map<String, dynamic> json) {
    List<ConsumerDigiTpItem> list = [];
    if (json['data'] != null && json['data'] is List) {
      list = (json['data'] as List)
          .map((item) => ConsumerDigiTpItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    ConsumerDigiTpCount? cnt;
    if (json['count'] != null && json['count'] is Map<String, dynamic>) {
      cnt = ConsumerDigiTpCount.fromJson(json['count'] as Map<String, dynamic>);
    }
    return ConsumerDigiTpData(data: list, count: cnt);
  }

  Map<String, dynamic> toJson() => {
    'data': data.map((x) => x.toJson()).toList(),
    'count': count?.toJson(),
  };
}

class ConsumerDigiTpApiResponse {
  final String statusCode;
  final String statusMessage;
  final ConsumerDigiTpData? responseData;
  final dynamic responseData1;

  const ConsumerDigiTpApiResponse({
    required this.statusCode,
    required this.statusMessage,
    this.responseData,
    this.responseData1,
  });

  bool get isSuccess => statusCode == '200' && responseData != null;

  List<ConsumerDigiTpItem> get items => responseData?.data ?? [];

  factory ConsumerDigiTpApiResponse.fromJson(Map<String, dynamic> json) {
    ConsumerDigiTpData? dataObj;
    if (json['responseData'] != null && json['responseData'] is Map<String, dynamic>) {
      dataObj = ConsumerDigiTpData.fromJson(json['responseData'] as Map<String, dynamic>);
    }

    return ConsumerDigiTpApiResponse(
      statusCode: json['statusCode']?.toString() ?? '500',
      statusMessage: json['statusMessage']?.toString() ?? 'Failed to fetch Consumer DigiTP list.',
      responseData: dataObj,
      responseData1: json['responseData1'],
    );
  }
}

class GetConsumerInvoiceDetailsResponse {
  final String statusCode;
  final String statusMessage;
  final ConsumerDigiTpItem? responseData;
  final dynamic responseData1;

  const GetConsumerInvoiceDetailsResponse({
    required this.statusCode,
    required this.statusMessage,
    this.responseData,
    this.responseData1,
  });

  bool get isSuccess => statusCode == '200' && responseData != null;
  bool get isAlreadyReceived => statusCode == '409';

  factory GetConsumerInvoiceDetailsResponse.fromJson(Map<String, dynamic> json) {
    ConsumerDigiTpItem? item;
    if (json['responseData'] != null && json['responseData'] is Map<String, dynamic>) {
      item = ConsumerDigiTpItem.fromJson(json['responseData'] as Map<String, dynamic>);
    }

    return GetConsumerInvoiceDetailsResponse(
      statusCode: json['statusCode']?.toString() ?? '500',
      statusMessage: json['statusMessage']?.toString() ?? 'Failed to fetch invoice details.',
      responseData: item,
      responseData1: json['responseData1'],
    );
  }
}

class ReceiveInvoiceRequest {
  final dynamic invoiceNo;
  final double rVehicleLat;
  final double rVehicleLong;
  final dynamic consumerId;

  const ReceiveInvoiceRequest({
    required this.invoiceNo,
    required this.consumerId,
    this.rVehicleLat = 0.0,
    this.rVehicleLong = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'invoiceNo': int.tryParse(invoiceNo.toString()) ?? invoiceNo,
    'r_Vehicle_Lat': rVehicleLat,
    'r_Vehicle_Long': rVehicleLong,
    'consumerId': consumerId,
  };
}

class ReceiveInvoiceResponse {
  final String statusCode;
  final String statusMessage;
  final dynamic responseData;
  final dynamic responseData1;

  const ReceiveInvoiceResponse({
    required this.statusCode,
    required this.statusMessage,
    this.responseData,
    this.responseData1,
  });

  bool get isSuccess => statusCode == '200';
  bool get isAlreadyReceived => statusCode == '409';

  factory ReceiveInvoiceResponse.fromJson(Map<String, dynamic> json) {
    return ReceiveInvoiceResponse(
      statusCode: json['statusCode']?.toString() ?? '500',
      statusMessage: json['statusMessage']?.toString() ?? 'Failed to receive invoice.',
      responseData: json['responseData'],
      responseData1: json['responseData1'],
    );
  }
}
