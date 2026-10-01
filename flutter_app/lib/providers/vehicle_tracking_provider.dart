import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/vehicle_tracking_repository.dart';
import '../domain/vehicle_tracking_models.dart';

class VehicleTrackingParams {
  final String vehicleNo;
  final String? deliveryId;
  final int consumerId;

  VehicleTrackingParams({required this.vehicleNo, this.deliveryId, this.consumerId = 0});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleTrackingParams &&
          other.vehicleNo == vehicleNo &&
          other.deliveryId == deliveryId &&
          other.consumerId == consumerId;

  @override
  int get hashCode => vehicleNo.hashCode ^ deliveryId.hashCode ^ consumerId.hashCode;
}

final vehicleTrackingRepositoryProvider = Provider<VehicleTrackingRepository>((ref) {
  return VehicleTrackingRepositoryImpl();
});

final vehicleTrackingProvider = StreamProvider.family<VehicleTrackingApiResponse, VehicleTrackingParams>((ref, params) async* {
  final repository = ref.watch(vehicleTrackingRepositoryProvider);
  
  while (true) {
    yield await repository.getVehicleLocationAndTrip(
      vehicleNo: params.vehicleNo,
      deliveryId: params.deliveryId,
      consumerId: params.consumerId,
    );
    await Future.delayed(const Duration(seconds: 10)); // Poll every 10 seconds
  }
});
