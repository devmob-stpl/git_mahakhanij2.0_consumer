import 'common.dart';

class InventoryBalance {
  final String id;
  final String packageId;
  final String mineralId;
  final String mineralName;
  final Quantity receivedBalance;
  final Quantity consumedBalance;
  final Quantity currentAvailableBalance;
  final String lastUpdatedAt;

  const InventoryBalance({
    required this.id,
    required this.packageId,
    required this.mineralId,
    required this.mineralName,
    required this.receivedBalance,
    required this.consumedBalance,
    required this.currentAvailableBalance,
    required this.lastUpdatedAt,
  });

  factory InventoryBalance.fromJson(Map<String, dynamic> json) {
    return InventoryBalance(
      id: json['id'] ?? '',
      packageId: json['packageId'] ?? '',
      mineralId: json['mineralId'] ?? '',
      mineralName: json['mineralName'] ?? '',
      receivedBalance: Quantity.fromJson(json['receivedBalance'] ?? {}),
      consumedBalance: Quantity.fromJson(json['consumedBalance'] ?? {}),
      currentAvailableBalance: Quantity.fromJson(json['currentAvailableBalance'] ?? {}),
      lastUpdatedAt: json['lastUpdatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'packageId': packageId,
    'mineralId': mineralId,
    'mineralName': mineralName,
    'receivedBalance': receivedBalance.toJson(),
    'consumedBalance': consumedBalance.toJson(),
    'currentAvailableBalance': currentAvailableBalance.toJson(),
    'lastUpdatedAt': lastUpdatedAt,
  };
}

class ConsumptionEntry {
  final String id;
  final String inventoryBalanceId;
  final String packageId;
  final Quantity quantity;
  final String purpose;
  final String recordedByUserId;
  final String recordedByName;
  final String recordedAt;

  String get action => 'DRAWDOWN';
  String get mineralName => 'Basalt Stone';
  String get timestamp => recordedAt;
  String get remarks => purpose;

  const ConsumptionEntry({
    required this.id,
    required this.inventoryBalanceId,
    required this.packageId,
    required this.quantity,
    required this.purpose,
    required this.recordedByUserId,
    required this.recordedByName,
    required this.recordedAt,
  });

  factory ConsumptionEntry.fromJson(Map<String, dynamic> json) {
    return ConsumptionEntry(
      id: json['id'] ?? '',
      inventoryBalanceId: json['inventoryBalanceId'] ?? '',
      packageId: json['packageId'] ?? '',
      quantity: Quantity.fromJson(json['quantity'] ?? {}),
      purpose: json['purpose'] ?? '',
      recordedByUserId: json['recordedByUserId'] ?? '',
      recordedByName: json['recordedByName'] ?? '',
      recordedAt: json['recordedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'inventoryBalanceId': inventoryBalanceId,
    'packageId': packageId,
    'quantity': quantity.toJson(),
    'purpose': purpose,
    'recordedByUserId': recordedByUserId,
    'recordedByName': recordedByName,
    'recordedAt': recordedAt,
  };
}
