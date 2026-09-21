import '../../domain/inventory.dart';
import '../../domain/common.dart';
import '../../core/config/app_config.dart';
import '../mock_db.dart';

abstract class InventoryRepository {
  Future<List<InventoryBalance>> listBalances(String packageId);
  Future<List<ConsumptionEntry>> listConsumptionHistory(String packageId);
  Future<ConsumptionEntry> recordConsumption({
    required String balanceId,
    required String packageId,
    required double quantityValue,
    required String purpose,
    required String userId,
    required String userName,
  });
}

class InventoryRepositoryImpl implements InventoryRepository {
  final MockDb _db = MockDb();

  @override
  Future<List<InventoryBalance>> listBalances(String packageId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    return _db.inventoryBalances.where((b) => b.packageId == packageId).toList();
  }

  @override
  Future<List<ConsumptionEntry>> listConsumptionHistory(String packageId) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    return _db.consumptionEntries.where((c) => c.packageId == packageId).toList();
  }

  @override
  Future<ConsumptionEntry> recordConsumption({
    required String balanceId,
    required String packageId,
    required double quantityValue,
    required String purpose,
    required String userId,
    required String userName,
  }) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    final balanceIndex = _db.inventoryBalances.indexWhere((b) => b.id == balanceId);
    if (balanceIndex == -1) throw Exception('Inventory balance not found');

    final balance = _db.inventoryBalances[balanceIndex];
    final updatedAvailable = balance.currentAvailableBalance.value - quantityValue;
    final updatedConsumed = balance.consumedBalance.value + quantityValue;

    _db.inventoryBalances[balanceIndex] = InventoryBalance(
      id: balance.id,
      packageId: balance.packageId,
      mineralId: balance.mineralId,
      mineralName: balance.mineralName,
      receivedBalance: balance.receivedBalance,
      consumedBalance: Quantity(value: updatedConsumed, unit: balance.consumedBalance.unit),
      currentAvailableBalance: Quantity(value: updatedAvailable, unit: balance.currentAvailableBalance.unit),
      lastUpdatedAt: DateTime.now().toIso8601String(),
    );

    final newEntry = ConsumptionEntry(
      id: 'con-${DateTime.now().millisecondsSinceEpoch}',
      inventoryBalanceId: balanceId,
      packageId: packageId,
      quantity: Quantity(value: quantityValue, unit: balance.receivedBalance.unit),
      purpose: purpose,
      recordedByUserId: userId,
      recordedByName: userName,
      recordedAt: DateTime.now().toIso8601String(),
    );

    _db.consumptionEntries.insert(0, newEntry);
    return newEntry;
  }
}
