import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_checker.dart';
import '../../core/network/release_json.dart';
import '../../core/utils/api_error_localizer.dart';
import '../../domain/report_models.dart';

abstract class ConsumerReportRepository {
  Future<ConsumerPlotResponse> getConsumerPlots(int consumerId);
  Future<ConsumerReportResponse> getConsumerInvoiceReport({
    required int consumerId,
    required String fromDate,
    required String toDate,
    required int materialId,
    required int plotId,
  });
}

class ConsumerReportRepositoryImpl implements ConsumerReportRepository {
  final Dio _dio;

  ConsumerReportRepositoryImpl({Dio? dio}) : _dio = dio ?? DioClient.createDio();

  @override
  Future<ConsumerPlotResponse> getConsumerPlots(int consumerId) async {
    // Pre-flight internet connectivity check
    if (!await NetworkChecker.checkOrNotify()) {
      return ConsumerPlotResponse(
        statusCode: 'NoInternet',
        statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
        responseData: [],
      );
    }

    try {
      final url = ApiEndpoints.getConsumerPlotsUrl(consumerId);
      final response = await _dio.get(url);
      final map = asResponseMap(response.data);
      if (map == null) {
        throw FormatException(ApiErrorLocalizer.currentLocalizations.invalidResponseFromServer);
      }
      final parsed = ConsumerPlotResponse.fromJson(map);
      return ConsumerPlotResponse(
        statusCode: parsed.statusCode,
        statusMessage: ApiErrorLocalizer.localizeCurrent(
          parsed.statusMessage,
          defaultMessage: parsed.statusMessage,
        ),
        responseData: parsed.responseData,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        NetworkChecker.showOfflineMessage();
        return ConsumerPlotResponse(
          statusCode: 'NoInternet',
          statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
          responseData: [],
        );
      }
      return ConsumerPlotResponse(
        statusCode: '500',
        statusMessage: ApiErrorLocalizer.currentLocalizations.somethingWentWrong,
        responseData: [],
      );
    } catch (_) {
      return ConsumerPlotResponse(
        statusCode: '500',
        statusMessage: ApiErrorLocalizer.currentLocalizations.somethingWentWrong,
        responseData: [],
      );
    }
  }

  @override
  Future<ConsumerReportResponse> getConsumerInvoiceReport({
    required int consumerId,
    required String fromDate,
    required String toDate,
    required int materialId,
    required int plotId,
  }) async {
    // Pre-flight internet connectivity check
    if (!await NetworkChecker.checkOrNotify()) {
      return ConsumerReportResponse(
        statusCode: 'NoInternet',
        statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
      );
    }

    try {
      final data = {
        "consumerId": consumerId,
        "fromDate": fromDate,
        "toDate": toDate,
        "materialId": materialId,
        "plotId": plotId,
      };
      
      final response = await _dio.post(
        ApiEndpoints.consumerInvoiceReport,
        data: data,
      );
      final map = asResponseMap(response.data);
      if (map == null) {
        throw FormatException(ApiErrorLocalizer.currentLocalizations.invalidResponseFromServer);
      }
      final parsed = ConsumerReportResponse.fromJson(map);
      return ConsumerReportResponse(
        statusCode: parsed.statusCode,
        statusMessage: ApiErrorLocalizer.localizeCurrent(
          parsed.statusMessage,
          defaultMessage: parsed.statusMessage,
        ),
        responseData: parsed.responseData,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        NetworkChecker.showOfflineMessage();
        return ConsumerReportResponse(
          statusCode: 'NoInternet',
          statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
        );
      }
      return ConsumerReportResponse(
        statusCode: '500',
        statusMessage: ApiErrorLocalizer.currentLocalizations.somethingWentWrong,
      );
    } catch (_) {
      return ConsumerReportResponse(
        statusCode: '500',
        statusMessage: ApiErrorLocalizer.currentLocalizations.somethingWentWrong,
      );
    }
  }
}
