import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
import '../../domain/vehicle_tracking_models.dart';

abstract class VehicleTrackingRepository {
  Future<VehicleTrackingApiResponse> getVehicleLocationAndTrip({
    required String vehicleNo,
  });
}

class VehicleTrackingRepositoryImpl implements VehicleTrackingRepository {
  final Dio _dio;

  VehicleTrackingRepositoryImpl({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  @override
  Future<VehicleTrackingApiResponse> getVehicleLocationAndTrip({
    required String vehicleNo,
  }) async {
    final cleanedVehicleNo = vehicleNo.trim();
    if (cleanedVehicleNo.isEmpty) {
      return const VehicleTrackingApiResponse(
        statusCode: '400',
        statusMessage: 'Vehicle number cannot be empty.',
      );
    }

    try {
      final url = ApiEndpoints.getVehicleTrackingLocationAndTripUrl(cleanedVehicleNo);
      final response = await _dio.get(url);

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic>) {
        return VehicleTrackingApiResponse.fromJson(data);
      }

      return const VehicleTrackingApiResponse(
        statusCode: '500',
        statusMessage: 'Invalid response format received from tracking server.',
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return VehicleTrackingApiResponse(
          statusCode: '408',
          statusMessage: 'Connection timed out while reaching tracking server for vehicle $cleanedVehicleNo. Please check your network and try again.',
        );
      }

      if (e.response?.data != null) {
        dynamic errData = e.response!.data;
        if (errData is String) {
          try {
            errData = jsonDecode(errData);
          } catch (_) {}
        }
        if (errData is Map<String, dynamic>) {
          return VehicleTrackingApiResponse.fromJson(errData);
        }
      }

      return VehicleTrackingApiResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: 'Network error occurred while fetching tracking details: ${e.message ?? 'Server unreachable.'}',
      );
    } catch (e) {
      return VehicleTrackingApiResponse(
        statusCode: '500',
        statusMessage: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}
