import 'package:dio/dio.dart';
import '../../domain/consumer_profile_models.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_checker.dart';
import '../../core/network/release_json.dart';
import '../../core/utils/api_error_localizer.dart';

abstract class ConsumerProfileRepository {
  Future<ConsumerProfileApiResponse> getConsumerProfile(String mobileNo);
}

class ConsumerProfileRepositoryImpl implements ConsumerProfileRepository {
  final Dio _dio;

  ConsumerProfileRepositoryImpl({Dio? dio}) : _dio = dio ?? DioClient.createDio();

  @override
  Future<ConsumerProfileApiResponse> getConsumerProfile(String mobileNo) async {
    // Pre-flight internet connectivity check
    if (!await NetworkChecker.checkOrNotify()) {
      return ConsumerProfileApiResponse(
        statusCode: 'NoInternet',
        statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
      );
    }

    try {
      final url = ApiEndpoints.getConsumerProfileUrl(mobileNo);
      final response = await _dio.get(url);

      final data = asResponseMap(response.data);
      if (data != null) {
        final parsed = ConsumerProfileApiResponse.fromJson(data);
        return ConsumerProfileApiResponse(
          statusCode: parsed.statusCode,
          statusMessage: ApiErrorLocalizer.localizeCurrent(
            parsed.statusMessage,
            defaultMessage: parsed.statusMessage,
          ),
          responseData: parsed.responseData,
          responseData1: parsed.responseData1,
        );
      }

      return ConsumerProfileApiResponse(
        statusCode: '500',
        statusMessage: ApiErrorLocalizer.currentLocalizations.invalidResponseFromServer,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        NetworkChecker.showOfflineMessage();
        return ConsumerProfileApiResponse(
          statusCode: 'NoInternet',
          statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
        );
      }
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          final parsed = ConsumerProfileApiResponse.fromJson(errData);
          return ConsumerProfileApiResponse(
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
      return ConsumerProfileApiResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
      );
    } catch (_) {
      return ConsumerProfileApiResponse(
        statusCode: '500',
        statusMessage: ApiErrorLocalizer.currentLocalizations.somethingWentWrong,
      );
    }
  }
}
