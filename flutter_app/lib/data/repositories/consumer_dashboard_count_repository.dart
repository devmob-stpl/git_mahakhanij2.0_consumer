import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/network/api_endpoints.dart';
import '../../domain/consumer_dashboard_count_models.dart';

abstract class ConsumerDashboardCountRepository {
  Future<ConsumerDashboardCountApiResponse> getConsumerDashboardCount(int consumerId);
}

class ConsumerDashboardCountRepositoryImpl implements ConsumerDashboardCountRepository {
  final http.Client _client;

  ConsumerDashboardCountRepositoryImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<ConsumerDashboardCountApiResponse> getConsumerDashboardCount(int consumerId) async {
    final url = ApiEndpoints.getConsumerDashboardCountUrl(consumerId);
    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return ConsumerDashboardCountApiResponse.fromJson(json);
      } else {
        return ConsumerDashboardCountApiResponse(
          statusCode: response.statusCode.toString(),
          statusMessage: 'Failed to fetch dashboard counts (HTTP ${response.statusCode})',
        );
      }
    } catch (e) {
      return ConsumerDashboardCountApiResponse(
        statusCode: '500',
        statusMessage: 'Error fetching consumer dashboard count: $e',
      );
    }
  }
}
