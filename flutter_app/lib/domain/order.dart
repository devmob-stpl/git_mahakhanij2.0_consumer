import 'common.dart';

enum OrderStatus {
  placed('PLACED'),
  confirmed('CONFIRMED'),
  processing('PROCESSING'),
  partiallyDelivered('PARTIALLY_DELIVERED'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  final String value;
  const OrderStatus(this.value);

  static OrderStatus fromString(String val) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => OrderStatus.placed,
    );
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String? organizationId;
  final String? projectId;
  final String? packageId;
  final String? consumerUserId;
  final String mineralId;
  final String mineralName;
  final Quantity orderedQuantity;
  final Quantity deliveredQuantity;
  final Money totalAmount;
  final OrderStatus status;
  final String stockPointId;
  final String stockPointName;
  final String createdAt;
  final List<String> deliveryIds;

  const Order({
    required this.id,
    required this.orderNumber,
    this.organizationId,
    this.projectId,
    this.packageId,
    this.consumerUserId,
    required this.mineralId,
    required this.mineralName,
    required this.orderedQuantity,
    required this.deliveredQuantity,
    required this.totalAmount,
    required this.status,
    required this.stockPointId,
    required this.stockPointName,
    required this.createdAt,
    this.deliveryIds = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      organizationId: json['organizationId'],
      projectId: json['projectId'],
      packageId: json['packageId'],
      consumerUserId: json['consumerUserId'],
      mineralId: json['mineralId'] ?? '',
      mineralName: json['mineralName'] ?? '',
      orderedQuantity: Quantity.fromJson(json['orderedQuantity'] ?? {}),
      deliveredQuantity: Quantity.fromJson(json['deliveredQuantity'] ?? {}),
      totalAmount: Money.fromJson(json['totalAmount'] ?? {}),
      status: OrderStatus.fromString(json['status'] ?? 'PLACED'),
      stockPointId: json['stockPointId'] ?? '',
      stockPointName: json['stockPointName'] ?? '',
      createdAt: json['createdAt'] ?? '',
      deliveryIds: (json['deliveryIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderNumber': orderNumber,
    if (organizationId != null) 'organizationId': organizationId,
    if (projectId != null) 'projectId': projectId,
    if (packageId != null) 'packageId': packageId,
    if (consumerUserId != null) 'consumerUserId': consumerUserId,
    'mineralId': mineralId,
    'mineralName': mineralName,
    'orderedQuantity': orderedQuantity.toJson(),
    'deliveredQuantity': deliveredQuantity.toJson(),
    'totalAmount': totalAmount.toJson(),
    'status': status.value,
    'stockPointId': stockPointId,
    'stockPointName': stockPointName,
    'createdAt': createdAt,
    'deliveryIds': deliveryIds,
  };
}
