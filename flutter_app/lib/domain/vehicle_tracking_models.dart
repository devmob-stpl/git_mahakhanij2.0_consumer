class VehicleLocationData {
  final String? vehicleNo;
  final String? vehicleId;
  final String? vehicleStatus;
  final String? gpsStatus;
  final String? latitude;
  final String? longitude;
  final num? speed;
  final num? direction;
  final String? locationName;
  final String? deviceDatetime;
  final String? driverName;
  final String? driverMobileNo;
  final String? vehTypeName;
  final String? capacity;
  final String? gpsFixed;
  final num? ignition;
  final num? odometer;
  final num? gsmStrength;
  final num? altitude;
  final String? deviceId;
  final String? colorCode;
  final String? vehicleTypeImage;
  final String? vehicleOwner;
  final String? powerCut;
  final num? powercut;
  final double? dateDiff;
  final String? date;
  final String? createdDate;
  final int? deviceCompanyId;
  final int? vehicleStatusId;
  final String? tenantId;
  final String? invoiceNo;

  const VehicleLocationData({
    this.vehicleNo,
    this.vehicleId,
    this.vehicleStatus,
    this.gpsStatus,
    this.latitude,
    this.longitude,
    this.speed,
    this.direction,
    this.locationName,
    this.deviceDatetime,
    this.driverName,
    this.driverMobileNo,
    this.vehTypeName,
    this.capacity,
    this.gpsFixed,
    this.ignition,
    this.odometer,
    this.gsmStrength,
    this.altitude,
    this.deviceId,
    this.colorCode,
    this.vehicleTypeImage,
    this.vehicleOwner,
    this.powerCut,
    this.powercut,
    this.dateDiff,
    this.date,
    this.createdDate,
    this.deviceCompanyId,
    this.vehicleStatusId,
    this.tenantId,
    this.invoiceNo,
  });

  factory VehicleLocationData.fromJson(Map<String, dynamic> json) {
    return VehicleLocationData(
      vehicleNo: json['vehicleNo']?.toString() ?? json['vehicle']?.toString(),
      vehicleId: json['vehicleId']?.toString(),
      vehicleStatus: json['vehicleStatus']?.toString(),
      gpsStatus: json['gpsStatus']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      speed: json['speed'] is num
          ? (json['speed'] as num)
          : num.tryParse(json['speed']?.toString() ?? ''),
      direction: json['direction'] is num
          ? (json['direction'] as num)
          : (json['courseDeg'] is num
              ? (json['courseDeg'] as num)
              : num.tryParse(json['direction']?.toString() ?? json['courseDeg']?.toString() ?? '')),
      locationName: json['locationName']?.toString(),
      deviceDatetime: json['deviceDatetime']?.toString() ?? json['deviceDateTime']?.toString() ?? json['deviceDate']?.toString(),
      driverName: json['driverName']?.toString(),
      driverMobileNo: json['driverMobileNo']?.toString(),
      vehTypeName: json['vehTypeName']?.toString() ?? json['vehicleTypeName']?.toString() ?? json['vehicleType']?.toString(),
      capacity: json['capacity']?.toString(),
      gpsFixed: json['gpsFixed']?.toString(),
      ignition: json['ignition'] is num
          ? (json['ignition'] as num)
          : num.tryParse(json['ignition']?.toString() ?? ''),
      odometer: json['odometer'] is num
          ? (json['odometer'] as num)
          : num.tryParse(json['odometer']?.toString() ?? ''),
      gsmStrength: json['gsmStrength'] is num
          ? (json['gsmStrength'] as num)
          : num.tryParse(json['gsmStrength']?.toString() ?? ''),
      altitude: json['altitude'] is num
          ? (json['altitude'] as num)
          : num.tryParse(json['altitude']?.toString() ?? ''),
      deviceId: json['deviceId']?.toString(),
      colorCode: json['colorCode']?.toString(),
      vehicleTypeImage: json['vehicleTypeImage']?.toString(),
      vehicleOwner: json['vehicleOwner']?.toString(),
      powerCut: json['powerCut']?.toString(),
      powercut: json['powercut'] is num
          ? (json['powercut'] as num)
          : num.tryParse(json['powercut']?.toString() ?? ''),
      dateDiff: (json['dateDiff'] is num)
          ? (json['dateDiff'] as num).toDouble()
          : double.tryParse(json['dateDiff']?.toString() ?? ''),
      date: json['date']?.toString(),
      createdDate: json['createdDate']?.toString(),
      deviceCompanyId: json['deviceCompanyId'] is int
          ? (json['deviceCompanyId'] as int)
          : int.tryParse(json['deviceCompanyId']?.toString() ?? ''),
      vehicleStatusId: json['vehicleStatusId'] is int
          ? (json['vehicleStatusId'] as int)
          : int.tryParse(json['vehicleStatusId']?.toString() ?? ''),
      tenantId: json['tenantId']?.toString(),
      invoiceNo: json['invoiceNo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'vehicleNo': vehicleNo,
        'vehicleId': vehicleId,
        'vehicleStatus': vehicleStatus,
        'gpsStatus': gpsStatus,
        'latitude': latitude,
        'longitude': longitude,
        'speed': speed,
        'direction': direction,
        'locationName': locationName,
        'deviceDatetime': deviceDatetime,
        'driverName': driverName,
        'driverMobileNo': driverMobileNo,
        'vehTypeName': vehTypeName,
        'capacity': capacity,
        'gpsFixed': gpsFixed,
        'ignition': ignition,
        'odometer': odometer,
        'gsmStrength': gsmStrength,
        'altitude': altitude,
        'deviceId': deviceId,
        'colorCode': colorCode,
        'vehicleTypeImage': vehicleTypeImage,
        'vehicleOwner': vehicleOwner,
        'powerCut': powerCut,
        'powercut': powercut,
        'dateDiff': dateDiff,
        'date': date,
        'createdDate': createdDate,
        'deviceCompanyId': deviceCompanyId,
        'vehicleStatusId': vehicleStatusId,
        'tenantId': tenantId,
        'invoiceNo': invoiceNo,
      };

  double? get parsedLatitude => double.tryParse(latitude ?? '');
  double? get parsedLongitude => double.tryParse(longitude ?? '');
  bool get isIgnitionOn => ignition == 1;
}

class VehicleTripData {
  final String? tripID;
  final String? driverName;
  final String? driverMobNo;
  final String? validityFrom;
  final String? validityUpto;
  final String? capacity;
  final String? division;
  final String? district;
  final String? taluka;
  final String? destination;
  final String? materialType;
  final String? mineralUnit;
  final String? quantity;
  final num? distance;
  final String? plotName;
  final String? sourceLatLong;
  final String? destinationLatLong;

  const VehicleTripData({
    this.tripID,
    this.driverName,
    this.driverMobNo,
    this.validityFrom,
    this.validityUpto,
    this.capacity,
    this.division,
    this.district,
    this.taluka,
    this.destination,
    this.materialType,
    this.mineralUnit,
    this.quantity,
    this.distance,
    this.plotName,
    this.sourceLatLong,
    this.destinationLatLong,
  });

  factory VehicleTripData.fromJson(Map<String, dynamic> json) {
    return VehicleTripData(
      tripID: json['tripID']?.toString() ?? json['tripId']?.toString() ?? json['invoiceNo']?.toString(),
      driverName: json['driverName']?.toString(),
      driverMobNo: json['driverMobNo']?.toString() ?? json['driverMobileNo']?.toString(),
      validityFrom: json['validityFrom']?.toString(),
      validityUpto: json['validityUpto']?.toString(),
      capacity: json['capacity']?.toString() ?? json['quantity']?.toString(),
      division: json['division']?.toString(),
      district: json['district']?.toString(),
      taluka: json['taluka']?.toString(),
      destination: json['destination']?.toString(),
      materialType: json['materialType']?.toString(),
      mineralUnit: json['mineralUnit']?.toString(),
      quantity: json['quantity']?.toString(),
      distance: json['distance'] is num
          ? (json['distance'] as num)
          : num.tryParse(json['distance']?.toString() ?? ''),
      plotName: json['plotName']?.toString(),
      sourceLatLong: json['sourceLatLong']?.toString(),
      destinationLatLong: json['destinationLatLong']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'tripID': tripID,
        'driverName': driverName,
        'driverMobNo': driverMobNo,
        'validityFrom': validityFrom,
        'validityUpto': validityUpto,
        'capacity': capacity,
        'division': division,
        'district': district,
        'taluka': taluka,
        'destination': destination,
        'materialType': materialType,
        'mineralUnit': mineralUnit,
        'quantity': quantity,
        'distance': distance,
        'plotName': plotName,
        'sourceLatLong': sourceLatLong,
        'destinationLatLong': destinationLatLong,
      };
}

class VehicleTrackingApiResponse {
  final String statusCode;
  final String statusMessage;
  final List<VehicleLocationData>? responseData;
  final List<VehicleTripData>? responseData1;

  const VehicleTrackingApiResponse({
    required this.statusCode,
    required this.statusMessage,
    this.responseData,
    this.responseData1,
  });

  bool get isSuccess => statusCode == '200' || statusCode == '200.0';
  bool get hasLocation => responseData != null && responseData!.isNotEmpty;
  bool get hasTrip => responseData1 != null && responseData1!.isNotEmpty;

  VehicleLocationData? get location => hasLocation ? responseData!.first : null;
  VehicleTripData? get trip => hasTrip ? responseData1!.first : null;

  factory VehicleTrackingApiResponse.fromJson(Map<String, dynamic> json) {
    List<VehicleLocationData>? locationList;
    if (json['responseData'] != null && json['responseData'] is List) {
      locationList = (json['responseData'] as List)
          .map((e) => VehicleLocationData.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<VehicleTripData>? tripList;
    if (json['responseData1'] != null && json['responseData1'] is List) {
      tripList = (json['responseData1'] as List)
          .map((e) => VehicleTripData.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return VehicleTrackingApiResponse(
      statusCode: json['statusCode']?.toString() ?? '500',
      statusMessage: json['statusMessage']?.toString() ?? 'Vehicle tracking details fetched successfully.',
      responseData: locationList,
      responseData1: tripList,
    );
  }
}
