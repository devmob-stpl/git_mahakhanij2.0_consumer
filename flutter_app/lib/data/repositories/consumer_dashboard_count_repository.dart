import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_checker.dart';
import '../../core/network/release_json.dart';
import '../../core/utils/api_error_localizer.dart';
import '../../domain/consumer_dashboard_count_models.dart';

abstract class ConsumerDashboardCountRepository {
  Future<ConsumerDashboardCountApiResponse> getConsumerDashboardCount(int consumerId);
}

class ConsumerDashboardCountRepositoryImpl implements ConsumerDashboardCountRepository {
  final Dio _dio;

  ConsumerDashboardCountRepositoryImpl({Dio? dio})
      : _dio = dio ?? DioClient.createDio();

  @override
  Future<ConsumerDashboardCountApiResponse> getConsumerDashboardCount(int consumerId) async {
    // Pre-flight internet connectivity check
    if (!await NetworkChecker.checkOrNotify()) {
      return ConsumerDashboardCountApiResponse(
        statusCode: 'NoInternet',
        statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
      );
    }

    final url = ApiEndpoints.getConsumerDashboardCountUrl(consumerId);
    try {
      final response = await _dio.get(url);
      final json = asResponseMap(response.data);
      if (json == null) {
        return ConsumerDashboardCountApiResponse(
          statusCode: '500',
          statusMessage: ApiErrorLocalizer.currentLocalizations.invalidResponseFromServer,
        );
      }
      final parsed = ConsumerDashboardCountApiResponse.fromJson(json);
      return ConsumerDashboardCountApiResponse(
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
        return ConsumerDashboardCountApiResponse(
          statusCode: 'NoInternet',
          statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
        );
      }
      if (e.response?.data != null) {
        final errJson = asResponseMap(e.response!.data);
        if (errJson != null) {
          final parsed = ConsumerDashboardCountApiResponse.fromJson(errJson);
          return ConsumerDashboardCountApiResponse(
            statusCode: parsed.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(
              parsed.statusMessage,
              defaultMessage: parsed.statusMessage,
            ),
            responseData: parsed.responseData,
          );
        }
      }
      return ConsumerDashboardCountApiResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: ApiErrorLocalizer.currentLocalizations.failedToFetchDashboardCounts,
      );
    } catch (_) {
      return ConsumerDashboardCountApiResponse(
        statusCode: '500',
        statusMessage: ApiErrorLocalizer.currentLocalizations.failedToFetchDashboardCounts,
      );
    }
  }
}
