import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/consumer_profile_models.dart';
import '../../core/network/api_endpoints.dart';

abstract class ConsumerProfileRepository {
  Future<ConsumerProfileApiResponse> getConsumerProfile(String mobileNo);
}

class ConsumerProfileRepositoryImpl implements ConsumerProfileRepository {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  @override
  Future<ConsumerProfileApiResponse> getConsumerProfile(String mobileNo) async {
    try {
      final url = ApiEndpoints.getConsumerProfileUrl(mobileNo);
      final response = await _dio.get(url);

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic>) {
        return ConsumerProfileApiResponse.fromJson(data);
      }

      return const ConsumerProfileApiResponse(
        statusCode: '500',
        statusMessage: 'Invalid profile response format from server.',
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        dynamic errData = e.response!.data;
        if (errData is String) {
          try {
            errData = jsonDecode(errData);
          } catch (_) {}
        }
        if (errData is Map<String, dynamic>) {
          return ConsumerProfileApiResponse.fromJson(errData);
        }
      }
      return ConsumerProfileApiResponse(
        statusCode: e.response?.statusCode?.toString() ?? '500',
        statusMessage: 'Unable to connect to Profile server. ${e.message ?? ''}',
      );
    } catch (e) {
      return ConsumerProfileApiResponse(
        statusCode: '500',
        statusMessage: 'Error fetching profile: ${e.toString()}',
      );
    }
  }
}
