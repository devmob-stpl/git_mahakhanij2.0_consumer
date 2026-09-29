import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/vehicle_tracking_repository.dart';
import '../domain/vehicle_tracking_models.dart';

final vehicleTrackingRepositoryProvider = Provider<VehicleTrackingRepository>((ref) {
  return VehicleTrackingRepositoryImpl();
});

final vehicleTrackingProvider = FutureProvider.family<VehicleTrackingApiResponse, String>((ref, vehicleNo) async {
  final repository = ref.watch(vehicleTrackingRepositoryProvider);
  return repository.getVehicleLocationAndTrip(vehicleNo: vehicleNo);
});
