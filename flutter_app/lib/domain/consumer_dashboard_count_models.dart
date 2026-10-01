class ConsumerDashboardCountData {
  final int notReceivedCount;
  final int inTransitCount;
  final int deliveredCount;
  final int totalCount;

  ConsumerDashboardCountData({
    this.notReceivedCount = 0,
    this.inTransitCount = 0,
    this.deliveredCount = 0,
    this.totalCount = 0,
  });

  factory ConsumerDashboardCountData.fromJson(Map<String, dynamic> json) {
    return ConsumerDashboardCountData(
      notReceivedCount: (json['notReceivedCount'] as num?)?.toInt() ?? 0,
      inTransitCount: (json['inTransitCount'] as num?)?.toInt() ?? 0,
      deliveredCount: (json['deliveredCount'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notReceivedCount': notReceivedCount,
      'inTransitCount': inTransitCount,
      'deliveredCount': deliveredCount,
      'totalCount': totalCount,
    };
  }
}

class ConsumerDashboardCountApiResponse {
  final String statusCode;
  final String statusMessage;
  final ConsumerDashboardCountData? responseData;

  ConsumerDashboardCountApiResponse({
    required this.statusCode,
    required this.statusMessage,
    this.responseData,
  });

  bool get isSuccess => statusCode == '200';

  factory ConsumerDashboardCountApiResponse.fromJson(Map<String, dynamic> json) {
    return ConsumerDashboardCountApiResponse(
      statusCode: json['statusCode']?.toString() ?? '',
      statusMessage: json['statusMessage']?.toString() ?? '',
      responseData: json['responseData'] != null
          ? ConsumerDashboardCountData.fromJson(json['responseData'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'statusMessage': statusMessage,
      'responseData': responseData?.toJson(),
    };
  }
}
