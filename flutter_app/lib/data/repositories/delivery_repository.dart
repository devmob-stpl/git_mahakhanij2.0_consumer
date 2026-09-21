import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/delivery.dart';
import '../../domain/inventory.dart';
import '../../domain/common.dart';
import '../../core/config/app_config.dart';
import '../mock_db.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepositoryImpl();
});

abstract class DeliveryRepository {
  Future<List<Delivery>> listDeliveries({String? packageId, bool activeOnly = true});
  Future<Delivery?> getDeliveryById(String id);
  Future<Delivery?> getById(String id);
  Future<Delivery?> findByQrPayload(String qrPayload);
  Future<Delivery> recordReceipt({
    required String deliveryId,
    required double receivedQuantity,
    String? remarks,
    required String userId,
  });
}

class DeliveryRepositoryImpl implements DeliveryRepository {
  final MockDb _db = MockDb();

  @override
  Future<List<Delivery>> listDeliveries({String? packageId, bool activeOnly = true}) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    var list = _db.deliveries;
    if (packageId != null) {
      list = list.where((d) => d.packageId == packageId).toList();
    }
    if (activeOnly) {
      list = list.where((d) => d.status != DeliveryStatus.received).toList();
    }
    return list;
  }

  @override
  Future<Delivery?> getById(String id) => getDeliveryById(id);

  @override
  Future<Delivery?> getDeliveryById(String id) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    try {
      return _db.deliveries.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Delivery?> findByQrPayload(String qrPayload) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    try {
      return _db.deliveries.firstWhere(
        (d) => d.transportPermit.qrPayload.trim() == qrPayload.trim() ||
               d.transportPermit.etpNumber.trim().toLowerCase() == qrPayload.trim().toLowerCase(),
      );
    } catch (_) {
      return _db.deliveries.firstOrNull;
    }
  }

  @override
  Future<Delivery> recordReceipt({
    required String deliveryId,
    required double receivedQuantity,
    String? remarks,
    required String userId,
  }) async {
    await Future.delayed(Duration(milliseconds: AppConfig.mockLatencyMs));
    final index = _db.deliveries.indexWhere((d) => d.id == deliveryId);
    if (index == -1) throw Exception('Delivery not found');

    final current = _db.deliveries[index];
    final permitted = current.transportPermit.permittedQuantity.value;
    final hasDiscrepancy = (permitted - receivedQuantity).abs() > 0.05;

    final updated = Delivery(
      id: current.id,
      deliveryNumber: current.deliveryNumber,
      orderId: current.orderId,
      organizationId: current.organizationId,
      packageId: current.packageId,
      transportPermit: current.transportPermit,
      vehicle: current.vehicle,
      status: hasDiscrepancy ? DeliveryStatus.receivedWithDiscrepancy : DeliveryStatus.received,
      dispatchedAt: current.dispatchedAt,
      deliveredAt: DateTime.now().toIso8601String(),
      discrepancyReport: hasDiscrepancy
          ? DiscrepancyReport(
              manifestQuantity: current.transportPermit.permittedQuantity,
              actualReceivedQuantity: Quantity(value: receivedQuantity, unit: current.transportPermit.permittedQuantity.unit),
              remarks: remarks ?? 'Quantity shortage detected upon site inspection',
              reportedAt: DateTime.now().toIso8601String(),
              reportedByUserId: userId,
            )
          : null,
    );

    _db.deliveries[index] = updated;

    // Credit site inventory with actually received quantity
    final invIndex = _db.inventoryBalances.indexWhere(
      (b) => b.packageId == current.packageId && b.mineralId == current.transportPermit.mineralId,
    );
    final nowIso = DateTime.now().toIso8601String();
    final unit = current.transportPermit.permittedQuantity.unit;

    if (invIndex != -1) {
      final oldInv = _db.inventoryBalances[invIndex];
      final newRec = oldInv.receivedBalance.value + receivedQuantity;
      final newAvail = newRec - oldInv.consumedBalance.value;
      _db.inventoryBalances[invIndex] = InventoryBalance(
        id: oldInv.id,
        packageId: oldInv.packageId,
        mineralId: oldInv.mineralId,
        mineralName: oldInv.mineralName,
        receivedBalance: Quantity(value: newRec, unit: unit),
        consumedBalance: oldInv.consumedBalance,
        currentAvailableBalance: Quantity(value: newAvail > 0 ? newAvail : 0, unit: unit),
        lastUpdatedAt: nowIso,
      );
    } else {
      _db.inventoryBalances.add(
        InventoryBalance(
          id: 'inv-${_db.inventoryBalances.length + 1}',
          packageId: current.packageId,
          mineralId: current.transportPermit.mineralId,
          mineralName: 'Mineral Material',
          receivedBalance: Quantity(value: receivedQuantity, unit: unit),
          consumedBalance: Quantity(value: 0, unit: unit),
          currentAvailableBalance: Quantity(value: receivedQuantity, unit: unit),
          lastUpdatedAt: nowIso,
        ),
      );
    }

    return updated;
  }
}
