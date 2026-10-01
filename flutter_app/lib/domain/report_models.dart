class ConsumerPlot {
  final int plotId;
  final String plotName;

  ConsumerPlot({required this.plotId, required this.plotName});

  factory ConsumerPlot.fromJson(Map<String, dynamic> json) {
    return ConsumerPlot(
      plotId: json['plotId'] as int? ?? 0,
      plotName: json['plotName'] as String? ?? '',
    );
  }
}

class ConsumerPlotResponse {
  final String statusCode;
  final String statusMessage;
  final List<ConsumerPlot> responseData;

  ConsumerPlotResponse({
    required this.statusCode,
    required this.statusMessage,
    required this.responseData,
  });

  factory ConsumerPlotResponse.fromJson(Map<String, dynamic> json) {
    var data = json['responseData'] as List?;
    return ConsumerPlotResponse(
      statusCode: json['statusCode']?.toString() ?? '',
      statusMessage: json['statusMessage']?.toString() ?? '',
      responseData: data?.map((e) => ConsumerPlot.fromJson(e)).toList() ?? [],
    );
  }
}

class ConsumerReportSummary {
  final double totalReceivedQuantity;
  final int totalDigiTPReceived;

  ConsumerReportSummary({
    required this.totalReceivedQuantity,
    required this.totalDigiTPReceived,
  });

  factory ConsumerReportSummary.fromJson(Map<String, dynamic> json) {
    return ConsumerReportSummary(
      totalReceivedQuantity: (json['totalReceivedQuantity'] as num?)?.toDouble() ?? 0.0,
      totalDigiTPReceived: (json['totalDigiTPReceived'] as num?)?.toInt() ?? 0,
    );
  }
}

class ConsumerReportMaterial {
  final int materialId;
  final String materialName;
  final int materialCount;
  final double totalQuantity;
  final double receivedQuantity;
  final double transitQuantity;
  final String? materialUnit;

  ConsumerReportMaterial({
    required this.materialId,
    required this.materialName,
    required this.materialCount,
    required this.totalQuantity,
    required this.receivedQuantity,
    required this.transitQuantity,
    this.materialUnit,
  });

  factory ConsumerReportMaterial.fromJson(Map<String, dynamic> json) {
    return ConsumerReportMaterial(
      materialId: (json['materialId'] as num?)?.toInt() ?? 0,
      materialName: json['materialName'] as String? ?? '',
      materialCount: (json['materialCount'] as num?)?.toInt() ?? 0,
      totalQuantity: (json['totalQuantity'] as num?)?.toDouble() ?? 0.0,
      receivedQuantity: (json['receivedQuantity'] as num?)?.toDouble() ?? 0.0,
      transitQuantity: (json['transitQuantity'] as num?)?.toDouble() ?? 0.0,
      materialUnit: json['materialUnit'] as String?,
    );
  }
}

class ConsumerReportData {
  final ConsumerReportSummary? summary;
  final List<ConsumerReportMaterial> materialWiseData;

  ConsumerReportData({this.summary, required this.materialWiseData});

  factory ConsumerReportData.fromJson(Map<String, dynamic> json) {
    var materials = json['materialWiseData'] as List?;
    return ConsumerReportData(
      summary: json['summary'] != null ? ConsumerReportSummary.fromJson(json['summary']) : null,
      materialWiseData: materials?.map((e) => ConsumerReportMaterial.fromJson(e)).toList() ?? [],
    );
  }
}

class ConsumerReportResponse {
  final String statusCode;
  final String statusMessage;
  final ConsumerReportData? responseData;

  ConsumerReportResponse({
    required this.statusCode,
    required this.statusMessage,
    this.responseData,
  });

  factory ConsumerReportResponse.fromJson(Map<String, dynamic> json) {
    return ConsumerReportResponse(
      statusCode: json['statusCode']?.toString() ?? '',
      statusMessage: json['statusMessage']?.toString() ?? '',
      responseData: json['responseData'] != null ? ConsumerReportData.fromJson(json['responseData']) : null,
    );
  }
}
