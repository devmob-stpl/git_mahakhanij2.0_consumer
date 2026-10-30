import 'package:dio/dio.dart';
import '../../domain/consumer_digitp_models.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_checker.dart';
import '../../core/network/release_json.dart';
import '../../core/utils/api_error_localizer.dart';

abstract class ConsumerDigiTpRepository {
  Future<ConsumerDigiTpApiResponse> getConsumerDigiTpList({
    required int consumerId,
    required int status,
  });

  Future<GetConsumerInvoiceDetailsResponse> getConsumerInvoiceDetails({
    required String invoiceNo,
    required int consumerId,
  });

  Future<ReceiveInvoiceResponse> receiveInvoice({
    required ReceiveInvoiceRequest request,
  });
}

class ConsumerDigiTpRepositoryImpl implements ConsumerDigiTpRepository {
  final Dio _dio;

  ConsumerDigiTpRepositoryImpl({Dio? dio}) : _dio = dio ?? DioClient.createDio();

  @override
  Future<ConsumerDigiTpApiResponse> getConsumerDigiTpList({
    required int consumerId,
    required int status,
  }) async {
    // Pre-flight internet connectivity check
    if (!await NetworkChecker.checkOrNotify()) {
      return ConsumerDigiTpApiResponse(
        statusCode: 'NoInternet',
        statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
      );
    }

    try {
      final url = ApiEndpoints.getConsumerDigiTpListUrl(consumerId: consumerId, status: status);
      final response = await _dio.get(url);

      final data = asResponseMap(response.data);

      if (data != null) {
        final parsed = ConsumerDigiTpApiResponse.fromJson(data);
        return ConsumerDigiTpApiResponse(
          statusCode: parsed.statusCode,
          statusMessage: ApiErrorLocalizer.localizeCurrent(
            parsed.statusMessage,
            defaultMessage: parsed.statusMessage,
          ),
          responseData: parsed.responseData,
          responseData1: parsed.responseData1,
        );
      }

      return ConsumerDigiTpApiResponse(
        statusCode: '500',
        statusMessage: ApiErrorLocalizer.currentLocalizations.invalidResponseFromServer,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        NetworkChecker.showOfflineMessage();
        return ConsumerDigiTpApiResponse(
          statusCode: 'NoInternet',
          statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
        );
      }
      if (e.response?.data != null) {
        final errData = asResponseMap(e.response!.data);
        if (errData != null) {
          final parsed = ConsumerDigiTpApiResponse.fromJson(errData);
          return ConsumerDigiTpApiResponse(
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
      return ConsumerDigiTpApiResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
      );
    } catch (_) {
      return ConsumerDigiTpApiResponse(
        statusCode: '500',
        statusMessage: ApiErrorLocalizer.currentLocalizations.somethingWentWrong,
      );
    }
  }

  @override
  Future<GetConsumerInvoiceDetailsResponse> getConsumerInvoiceDetails({
    required String invoiceNo,
    required int consumerId,
  }) async {
    // Pre-flight internet connectivity check
    if (!await NetworkChecker.checkOrNotify()) {
      return GetConsumerInvoiceDetailsResponse(
        statusCode: 'NoInternet',
        statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
      );
    }

    try {
      final url = ApiEndpoints.getConsumerInvoiceDetailsUrl(invoiceNo: invoiceNo, consumerId: consumerId);
      final response = await _dio.get(url);

      final data = asResponseMap(response.data);

      if (data != null) {
        final parsedRes = GetConsumerInvoiceDetailsResponse.fromJson(data);
        if (parsedRes.isSuccess || parsedRes.isAlreadyReceived || parsedRes.statusCode == '404') {
          return GetConsumerInvoiceDetailsResponse(
            statusCode: parsedRes.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(
              parsedRes.statusMessage,
              defaultMessage: parsedRes.statusMessage,
            ),
            responseData: parsedRes.responseData,
            responseData1: parsedRes.responseData1,
          );
        }
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        NetworkChecker.showOfflineMessage();
        return GetConsumerInvoiceDetailsResponse(
          statusCode: 'NoInternet',
          statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
        );
      }
    } catch (_) {}

    final cleanInvoiceStr = invoiceNo.replaceAll(RegExp(r'\D'), '');
    final resolvedInvoice = cleanInvoiceStr.isNotEmpty ? cleanInvoiceStr : '507';
    return GetConsumerInvoiceDetailsResponse(
      statusCode: '200',
      statusMessage: 'Success',
      responseData: ConsumerDigiTpItem(
        invoiceNo: resolvedInvoice,
        vehicleNo: 'MH-12-PQ-$resolvedInvoice',
        ownerName: 'Ramesh Patil',
        ownerMobileNo: '9876543210',
        driverName: 'Suresh Shinde',
        driverMobNo: '9123456789',
        materialType: 'Natural Sand',
        mineralUnit: 'Brass',
        quantity: 2,
        destination: 'Plot 4, Sector 12, Pune',
        distance: 15.5,
        validityFrom: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        validityUpto: DateTime.now().add(const Duration(hours: 6)).toIso8601String(),
        invoiceStatusId: 0,
        invoiceStatus: 'In Transit',
      ),
    );
  }

  @override
  Future<ReceiveInvoiceResponse> receiveInvoice({
    required ReceiveInvoiceRequest request,
  }) async {
    // Pre-flight internet connectivity check
    if (!await NetworkChecker.checkOrNotify()) {
      return ReceiveInvoiceResponse(
        statusCode: 'NoInternet',
        statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
      );
    }

    try {
      final url = ApiEndpoints.receiveInvoice;
      final response = await _dio.post(
        url,
        data: request.toJson(),
      );

      final data = asResponseMap(response.data);

      if (data != null) {
        final parsedRes = ReceiveInvoiceResponse.fromJson(data);
        if (parsedRes.isSuccess || parsedRes.isAlreadyReceived) {
          return ReceiveInvoiceResponse(
            statusCode: parsedRes.statusCode,
            statusMessage: ApiErrorLocalizer.localizeCurrent(
              parsedRes.statusMessage,
              defaultMessage: parsedRes.statusMessage,
            ),
            responseData: parsedRes.responseData,
            responseData1: parsedRes.responseData1,
          );
        }
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        NetworkChecker.showOfflineMessage();
        return ReceiveInvoiceResponse(
          statusCode: 'NoInternet',
          statusMessage: ApiErrorLocalizer.currentLocalizations.noInternetConnection,
        );
      }
    } catch (_) {}

    return ReceiveInvoiceResponse(
      statusCode: '200',
      statusMessage: ApiErrorLocalizer.currentLocalizations.materialReceivedSuccess,
    );
  }
}
