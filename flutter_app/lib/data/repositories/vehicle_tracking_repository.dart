import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
import '../../domain/vehicle_tracking_models.dart';

abstract class VehicleTrackingRepository {
  Future<VehicleTrackingApiResponse> getVehicleLocationAndTrip({
    required String vehicleNo,
    String? deliveryId,
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
    String? deliveryId,
  }) async {
    final cleanedVehicleNo = vehicleNo.trim();
    if (cleanedVehicleNo.isEmpty) {
      return const VehicleTrackingApiResponse(
        statusCode: '400',
        statusMessage: 'Vehicle number cannot be empty.',
      );
    }

    try {
      final locUrl = ApiEndpoints.getVehicleTrackingLocationUrl(cleanedVehicleNo);
      final locResponse = await _dio.get(locUrl);

      dynamic locData = locResponse.data;
      if (locData is String) {
        locData = jsonDecode(locData);
      }

      List<VehicleLocationData>? locationList;
      if (locData != null && locData['responseData'] != null) {
        // The new API returns a single object in responseData, not a list
        if (locData['responseData'] is Map<String, dynamic>) {
          locationList = [VehicleLocationData.fromJson(locData['responseData'] as Map<String, dynamic>)];
        }
      }

      List<VehicleTripData>? tripList;
      if (deliveryId != null && deliveryId.isNotEmpty) {
        try {
          final tripUrl = ApiEndpoints.getConsumerInvoiceDetailsUrl(deliveryId);
          final tripResponse = await _dio.get(tripUrl);
          
          dynamic tripData = tripResponse.data;
          if (tripData is String) {
            tripData = jsonDecode(tripData);
          }
          
          if (tripData != null && tripData['responseData'] != null) {
            if (tripData['responseData'] is Map<String, dynamic>) {
              tripList = [VehicleTripData.fromJson(tripData['responseData'] as Map<String, dynamic>)];
            }
          }
        } catch (_) {
          // If trip fails, we can still return location data
        }
      }

      return VehicleTrackingApiResponse(
        statusCode: locData?['statusCode']?.toString() ?? '200',
        statusMessage: locData?['statusMessage']?.toString() ?? 'Success',
        responseData: locationList,
        responseData1: tripList,
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
