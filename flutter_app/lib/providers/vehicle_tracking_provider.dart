import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/vehicle_tracking_repository.dart';
import '../domain/vehicle_tracking_models.dart';

class VehicleTrackingParams {
  final String vehicleNo;
  final String? deliveryId;

  VehicleTrackingParams({required this.vehicleNo, this.deliveryId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleTrackingParams &&
          other.vehicleNo == vehicleNo &&
          other.deliveryId == deliveryId;

  @override
  int get hashCode => vehicleNo.hashCode ^ deliveryId.hashCode;
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
    );
    await Future.delayed(const Duration(seconds: 10)); // Poll every 10 seconds
  }
});
