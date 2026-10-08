import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../providers/consumer_report_provider.dart';
import '../../providers/session_provider.dart';
import '../../l10n/app_localizations.dart';

class TimeTab {
  final String label;
  final DateTime fromDate;
  final DateTime toDate;
  TimeTab(this.label, this.fromDate, this.toDate);
}

class ConsumerReportsScreen extends ConsumerStatefulWidget {
  const ConsumerReportsScreen({super.key});

  @override
  ConsumerState<ConsumerReportsScreen> createState() => _ConsumerReportsScreenState();
}

class _ConsumerReportsScreenState extends ConsumerState<ConsumerReportsScreen> {
  String? _selectedTime;
  int _selectedPlotId = 0; // 0 means 'All Quarries'
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final now = DateTime.now();
    
    // Generate dynamic tabs
    final List<TimeTab> timeTabs = [
      TimeTab(loc.last30Days, now.subtract(const Duration(days: 30)), now),
      TimeTab(loc.quarterly, now.subtract(const Duration(days: 90)), now),
    ];
    
    // Add only current financial year dynamically
    int currentFyStartYear = now.month >= 4 ? now.year : now.year - 1;
    final yearRangeString = '${currentFyStartYear.toString().substring(2)}-${(currentFyStartYear + 1).toString().substring(2)}';
    final label = loc.fy2425.replaceAll('24-25', yearRangeString);
    timeTabs.add(TimeTab(
      label,
      DateTime(currentFyStartYear, 4, 1),
      DateTime(currentFyStartYear + 1, 3, 31, 23, 59, 59),
    ));

    _selectedTime ??= timeTabs.first.label;

    final consumerId = ref.watch(sessionProvider).currentUser?.consumerId ?? 0;
    
    final plotsAsync = ref.watch(consumerPlotsProvider);
    
    final reportParams = ConsumerReportParams(
      consumerId: consumerId,
      fromDate: _fromDate.toUtc().toIso8601String(),
      toDate: _toDate.toUtc().toIso8601String(),
      materialId: 0,
      plotId: _selectedPlotId,
    );
    final reportAsync = ref.watch(consumerReportProvider(reportParams));

    return AppScaffold(
      title: loc.reports,
      showBackButton: Navigator.canPop(context),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(consumerPlotsProvider);
          ref.invalidate(consumerReportProvider(reportParams));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Time Filters
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: timeTabs.map((tab) => _buildDynamicTimeTab(tab)).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quarry Filter
            Row(
              children: [
                Text(
                  loc.filterByQuarry,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: plotsAsync.when(
                    data: (plots) {
                      final dropdownItems = [
                        DropdownMenuItem<int>(
                          value: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(loc.allQuarries),
                          ),
                        ),
                        ...plots.map((p) => DropdownMenuItem<int>(
                              value: p.plotId,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Text(
                                  p.plotName,
                                  softWrap: true,
                                ),
                              ),
                            )),
                      ];
                      return DropdownButton<int>(
                        value: _selectedPlotId,
                        isExpanded: true,
                        itemHeight: null,
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary700),
                        elevation: 16,
                        style: const TextStyle(color: AppColors.neutral900, fontSize: 14, fontWeight: FontWeight.w600),
                        underline: Container(
                          height: 2,
                          color: AppColors.primary100,
                        ),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedPlotId = newValue;
                            });
                          }
                        },
                        items: dropdownItems,
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => Text(loc.errorLoadingPlots),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Report Data
            reportAsync.when(
              data: (reportData) {
                if (reportData == null) {
                  return Center(child: Text(loc.noDataAvailable));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Cards
                    Row(
                      children: [
                        Expanded(child: _buildTotalReceivedCard(
                          reportData.summary?.totalReceivedQuantity ?? 0.0,
                          reportData.materialWiseData.isNotEmpty ? reportData.materialWiseData.first.materialUnit ?? '':'',
                          loc,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDigiTPIssuedCard(reportData.summary?.totalDigiTPReceived ?? 0, loc)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Breakdown Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                loc.mineralProcurementBreakdown,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.neutral600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                loc.byVolume,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.neutral500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (reportData.materialWiseData.isEmpty)
                            Center(child: Text(loc.noMaterialsFound))
                          else
                            ...reportData.materialWiseData.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final totalVol = reportData.materialWiseData.fold<double>(0, (sum, m) => sum + m.receivedQuantity);
                              final pct = totalVol > 0 ? (item.receivedQuantity / totalVol * 100) : 0.0;
                              final color = _getColorForIndex(index);
                              
                              return _buildBreakdownItem(
                                item.materialName,
                                item.receivedQuantity.toInt(),
                                double.parse(pct.toStringAsFixed(1)),
                                color,
                                unit: item.materialUnit ?? '',
                                isLast: index == reportData.materialWiseData.length - 1,
                              );
                            }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('${loc.errorLoadingReport}$err')),
            ),
          ],
        ),
      ),
    ));
  }

  Color _getColorForIndex(int index) {
    const colors = [
      Color(0xFF1E3A8A), // Basalt
      Color(0xFF0284C7), // Murum
      Color(0xFFF59E0B), // Sand
      Color(0xFF8B5CF6), // Aggregate
      Color(0xFF10B981), // Green
      Color(0xFFEF4444), // Red
    ];
    return colors[index % colors.length];
  }

  Widget _buildDynamicTimeTab(TimeTab tab) {
    final isSelected = _selectedTime == tab.label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTime = tab.label;
            _fromDate = tab.fromDate;
            _toDate = tab.toDate;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          tab.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.neutral900 : AppColors.neutral500,
          ),
        ),
      ),
    )
    );
  }

  Widget _buildTotalReceivedCard(double quantity, String unit, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0F2FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.totalReceived, style: const TextStyle(color: Color(0xFF0369A1), fontSize: 13, fontWeight: FontWeight.w600)),
              const Icon(Icons.trending_up, color: Color(0xFF0369A1), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: '${NumberFormat('#,##0.##').format(quantity)} ', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 28, fontWeight: FontWeight.w800)),
                TextSpan(text: unit, style: const TextStyle(color: Color(0xFF0369A1), fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigiTPIssuedCard(int count, AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3E8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.digitpsReceived, style: const TextStyle(color: Color(0xFF7E22CE), fontSize: 13, fontWeight: FontWeight.w600)),
              const Icon(Icons.description_outlined, color: Color(0xFF7E22CE), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: '${NumberFormat('#,##0').format(count)} ', style: const TextStyle(color: Color(0xFF7E22CE), fontSize: 28, fontWeight: FontWeight.w800)),
                TextSpan(text: loc.passes, style: const TextStyle(color: Color(0xFF9333EA), fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, int amount, double percentage, Color color, {String unit = 'Units', bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neutral900)),
              Text('${NumberFormat('#,##0').format(amount)} $unit', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.neutral900)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
