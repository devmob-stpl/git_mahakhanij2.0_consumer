import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_checker.dart';
import '../../core/network/release_json.dart';
import '../../core/utils/api_error_localizer.dart';
import '../../domain/vehicle_tracking_models.dart';

abstract class VehicleTrackingRepository {
  Future<VehicleTrackingApiResponse> getVehicleLocationAndTrip({
    required String vehicleNo,
    String? deliveryId,
    int consumerId = 0,
  });
}

class VehicleTrackingRepositoryImpl implements VehicleTrackingRepository {
  final Dio _dio;

  VehicleTrackingRepositoryImpl({Dio? dio})
      : _dio = dio ??
            DioClient.createDio(
              options: BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  @override
  Future<VehicleTrackingApiResponse> getVehicleLocationAndTrip({
    required String vehicleNo,
    String? deliveryId,
    int consumerId = 0,
  }) async {
    final cleanedVehicleNo = vehicleNo.trim();
    if (cleanedVehicleNo.isEmpty) {
      return VehicleTrackingApiResponse(
        statusCode: '400',
        statusMessage: ApiErrorLocalizer.currentLocalizations.errVehicleNoRequired,
      );
    }

    if (!await NetworkChecker.checkOrNotify()) {
      return VehicleTrackingApiResponse(
        statusCode: 'NoInternet',
        statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
      );
    }

    try {
      final locUrl = ApiEndpoints.getVehicleTrackingLocationUrl(cleanedVehicleNo);
      final locResponse = await _dio.get(locUrl);

      final locData = asResponseMap(locResponse.data);

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
          final tripUrl = ApiEndpoints.getConsumerInvoiceDetailsUrl(invoiceNo: deliveryId, consumerId: consumerId);
          final tripResponse = await _dio.get(tripUrl);
          
          final tripData = asResponseMap(tripResponse.data);
          
          if (tripData != null && tripData['responseData'] != null) {
            if (tripData['responseData'] is Map<String, dynamic>) {
              tripList = [VehicleTripData.fromJson(tripData['responseData'] as Map<String, dynamic>)];
            }
          }
        } catch (_) {
          // If trip fails, we can still return location data
        }
      }

      final rawStatusMsg = locData?['statusMessage']?.toString() ?? 'Success';
      return VehicleTrackingApiResponse(
        statusCode: locData?['statusCode']?.toString() ?? '200',
        statusMessage: ApiErrorLocalizer.localizeCurrent(
          rawStatusMsg,
          defaultMessage: rawStatusMsg,
        ),
        responseData: locationList,
        responseData1: tripList,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return VehicleTrackingApiResponse(
          statusCode: '408',
          statusMessage: ApiErrorLocalizer.currentLocalizations.connectionTimeout,
        );
      }

      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          final parsed = VehicleTrackingApiResponse.fromJson(errData);
          return VehicleTrackingApiResponse(
            statusCode: parsed.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(
              parsed.statusMessage,
              defaultMessage: parsed.statusMessage,
            ),
            responseData: parsed.responseData,
            responseData1: parsed.responseData1,
          );
        }
      }

      return VehicleTrackingApiResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
      );
    } catch (_) {
      return VehicleTrackingApiResponse(
        statusCode: '500',
        statusMessage: ApiErrorLocalizer.currentLocalizations.somethingWentWrong,
      );
    }
  }
}
