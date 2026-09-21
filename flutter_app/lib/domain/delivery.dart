import 'common.dart';

enum DeliveryStatus {
  scheduled('SCHEDULED'),
  dispatched('DISPATCHED'),
  inTransit('IN_TRANSIT'),
  arrivedAtDestination('ARRIVED_AT_DESTINATION'),
  received('RECEIVED'),
  receivedWithDiscrepancy('RECEIVED_WITH_DISCREPANCY');

  final String value;
  const DeliveryStatus(this.value);

  static DeliveryStatus fromString(String val) {
    return DeliveryStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => DeliveryStatus.inTransit,
    );
  }
}

class TransportPermit {
  final String etpNumber;
  final String qrPayload;
  final String issuedAt;
  final String validUntil;
  final String sourceQuarryName;
  final String sourceStockPointId;
  final String destinationLabel;
  final GeoPoint destinationGeo;
  final String mineralId;
  final Quantity permittedQuantity;
  final String vehicleNumber;

  const TransportPermit({
    required this.etpNumber,
    required this.qrPayload,
    required this.issuedAt,
    required this.validUntil,
    required this.sourceQuarryName,
    required this.sourceStockPointId,
    required this.destinationLabel,
    required this.destinationGeo,
    required this.mineralId,
    required this.permittedQuantity,
    required this.vehicleNumber,
  });

  factory TransportPermit.fromJson(Map<String, dynamic> json) {
    return TransportPermit(
      etpNumber: json['etpNumber'] ?? '',
      qrPayload: json['qrPayload'] ?? '',
      issuedAt: json['issuedAt'] ?? '',
      validUntil: json['validUntil'] ?? '',
      sourceQuarryName: json['sourceQuarryName'] ?? '',
      sourceStockPointId: json['sourceStockPointId'] ?? '',
      destinationLabel: json['destinationLabel'] ?? '',
      destinationGeo: GeoPoint.fromJson(json['destinationGeo'] ?? {}),
      mineralId: json['mineralId'] ?? '',
      permittedQuantity: Quantity.fromJson(json['permittedQuantity'] ?? {}),
      vehicleNumber: json['vehicleNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'etpNumber': etpNumber,
    'qrPayload': qrPayload,
    'issuedAt': issuedAt,
    'validUntil': validUntil,
    'sourceQuarryName': sourceQuarryName,
    'sourceStockPointId': sourceStockPointId,
    'destinationLabel': destinationLabel,
    'destinationGeo': destinationGeo.toJson(),
    'mineralId': mineralId,
    'permittedQuantity': permittedQuantity.toJson(),
    'vehicleNumber': vehicleNumber,
  };
}

class Vehicle {
  final String registrationNumber;
  final String transporterName;
  final String driverName;
  final String driverMobileNumber;

  const Vehicle({
    required this.registrationNumber,
    required this.transporterName,
    required this.driverName,
    required this.driverMobileNumber,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      registrationNumber: json['registrationNumber'] ?? '',
      transporterName: json['transporterName'] ?? '',
      driverName: json['driverName'] ?? '',
      driverMobileNumber: json['driverMobileNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'registrationNumber': registrationNumber,
    'transporterName': transporterName,
    'driverName': driverName,
    'driverMobileNumber': driverMobileNumber,
  };
}

class DiscrepancyReport {
  final Quantity manifestQuantity;
  final Quantity actualReceivedQuantity;
  final String remarks;
  final String reportedAt;
  final String reportedByUserId;

  const DiscrepancyReport({
    required this.manifestQuantity,
    required this.actualReceivedQuantity,
    required this.remarks,
    required this.reportedAt,
    required this.reportedByUserId,
  });

  factory DiscrepancyReport.fromJson(Map<String, dynamic> json) {
    return DiscrepancyReport(
      manifestQuantity: Quantity.fromJson(json['manifestQuantity'] ?? {}),
      actualReceivedQuantity: Quantity.fromJson(json['actualReceivedQuantity'] ?? {}),
      remarks: json['remarks'] ?? '',
      reportedAt: json['reportedAt'] ?? '',
      reportedByUserId: json['reportedByUserId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'manifestQuantity': manifestQuantity.toJson(),
    'actualReceivedQuantity': actualReceivedQuantity.toJson(),
    'remarks': remarks,
    'reportedAt': reportedAt,
    'reportedByUserId': reportedByUserId,
  };
}

class Delivery {
  final String id;
  final String deliveryNumber;
  final String orderId;
  final String organizationId;
  final String packageId;
  final TransportPermit transportPermit;
  final Vehicle vehicle;
  final DeliveryStatus status;
  final String dispatchedAt;
  final String? deliveredAt;
  final DiscrepancyReport? discrepancyReport;

  const Delivery({
    required this.id,
    required this.deliveryNumber,
    required this.orderId,
    required this.organizationId,
    required this.packageId,
    required this.transportPermit,
    required this.vehicle,
    required this.status,
    required this.dispatchedAt,
    this.deliveredAt,
    this.discrepancyReport,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] ?? '',
      deliveryNumber: json['deliveryNumber'] ?? '',
      orderId: json['orderId'] ?? '',
      organizationId: json['organizationId'] ?? '',
      packageId: json['packageId'] ?? '',
      transportPermit: TransportPermit.fromJson(json['transportPermit'] ?? {}),
      vehicle: Vehicle.fromJson(json['vehicle'] ?? {}),
      status: DeliveryStatus.fromString(json['status'] ?? 'IN_TRANSIT'),
      dispatchedAt: json['dispatchedAt'] ?? '',
      deliveredAt: json['deliveredAt'],
      discrepancyReport: json['discrepancyReport'] != null
          ? DiscrepancyReport.fromJson(json['discrepancyReport'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'deliveryNumber': deliveryNumber,
    'orderId': orderId,
    'organizationId': organizationId,
    'packageId': packageId,
    'transportPermit': transportPermit.toJson(),
    'vehicle': vehicle.toJson(),
    'status': status.value,
    'dispatchedAt': dispatchedAt,
    if (deliveredAt != null) 'deliveredAt': deliveredAt,
    if (discrepancyReport != null) 'discrepancyReport': discrepancyReport!.toJson(),
  };
}
