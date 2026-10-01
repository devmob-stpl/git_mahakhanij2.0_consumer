import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/consumer_report_repository.dart';
import '../domain/report_models.dart';
import 'session_provider.dart';

final consumerReportRepositoryProvider = Provider<ConsumerReportRepository>((ref) {
  return ConsumerReportRepositoryImpl();
});

final consumerPlotsProvider = FutureProvider.autoDispose<List<ConsumerPlot>>((ref) async {
  final consumerId = ref.watch(sessionProvider).currentUser?.consumerId ?? 0;
  if (consumerId == 0) return [];

  final repo = ref.watch(consumerReportRepositoryProvider);
  final response = await repo.getConsumerPlots(consumerId);
  return response.responseData;
});

class ConsumerReportParams {
  final int consumerId;
  final String fromDate;
  final String toDate;
  final int materialId;
  final int plotId;

  ConsumerReportParams({
    required this.consumerId,
    required this.fromDate,
    required this.toDate,
    required this.materialId,
    required this.plotId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsumerReportParams &&
          other.consumerId == consumerId &&
          other.fromDate == fromDate &&
          other.toDate == toDate &&
          other.materialId == materialId &&
          other.plotId == plotId;

  @override
  int get hashCode =>
      consumerId.hashCode ^
      fromDate.hashCode ^
      toDate.hashCode ^
      materialId.hashCode ^
      plotId.hashCode;
}

final consumerReportProvider = FutureProvider.autoDispose.family<ConsumerReportData?, ConsumerReportParams>((ref, params) async {
  if (params.consumerId == 0) return null;
  
  final repo = ref.watch(consumerReportRepositoryProvider);
  final response = await repo.getConsumerInvoiceReport(
    consumerId: params.consumerId,
    fromDate: params.fromDate,
    toDate: params.toDate,
    materialId: params.materialId,
    plotId: params.plotId,
  );
  
  return response.responseData;
});
