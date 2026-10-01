import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
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

  ConsumerReportRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    )
  );

  @override
  Future<ConsumerPlotResponse> getConsumerPlots(int consumerId) async {
    final url = ApiEndpoints.getConsumerPlotsUrl(consumerId);
    final response = await _dio.get(url);
    return ConsumerPlotResponse.fromJson(response.data);
  }

  @override
  Future<ConsumerReportResponse> getConsumerInvoiceReport({
    required int consumerId,
    required String fromDate,
    required String toDate,
    required int materialId,
    required int plotId,
  }) async {
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
    return ConsumerReportResponse.fromJson(response.data);
  }
}
